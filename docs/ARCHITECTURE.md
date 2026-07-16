# Get Ready 架构说明

Get Ready 是一款 local-first Flutter 应用。当前架构以 feature-first 目录组织功能，用轻量 Presentation / Application / Domain / Data 分层保持业务语义、持久化和平台能力之间的边界。

本文档描述 2.6.0 的现有结构，不代表未来必须引入更重的框架。

## 架构目标

- 让 Today、Habits、Plan、Focus 和 Review 读取同一份实时应用状态。
- 让领域模型与页面布局解耦，避免 UI 直接修改持久化数据。
- 保持本地数据 schema 和既有 P8/P9 交互语义稳定。
- 把通知、权限、媒体选择等平台能力放在可替换、可测试的边界后。
- 在没有账号、后端或网络服务的情况下提供完整本地工作流。
- 通过 unit/widget/contract tests 验证状态、持久化、路由与 Android 配置。

## 顶层目录

```text
lib/
├─ main.dart
├─ app/
│  ├─ app.dart
│  ├─ router/
│  ├─ settings/
│  │  ├─ application/
│  │  ├─ data/
│  │  └─ presentation/
│  └─ theme/
├─ core/
│  ├─ media/
│  ├─ notifications/
│  └─ permissions/
├─ features/
│  ├─ today/
│  ├─ habits/
│  │  ├─ application/
│  │  ├─ data/
│  │  ├─ domain/
│  │  └─ presentation/
│  ├─ goals/                 Plan 的内部稳定技术目录名
│  │  ├─ application/
│  │  ├─ data/
│  │  ├─ domain/
│  │  └─ presentation/
│  ├─ focus/
│  │  ├─ application/
│  │  ├─ data/
│  │  ├─ domain/
│  │  └─ presentation/
│  ├─ review/
│  └─ settings/
└─ shared/
   ├─ theme/
   └─ widgets/
```

内部 `goals` 目录、Dart package 名与 Android package ID 是稳定技术标识；用户界面使用“计划”和 Get Ready。

## 应用组合

`lib/main.dart` 是入口，负责启动 Flutter 应用以及初始化需要的本地/平台基础设施。`lib/app/app.dart` 是组合根，连接主题、应用 Store、通知运行时与路由。

应用没有依赖第三方状态管理框架。核心 Store 基于 Flutter `ChangeNotifier`，通过明确的 scope/inherited notifier 或构造参数向页面提供状态。

主要状态对象：

| Store | 责任 |
| --- | --- |
| `HabitsStore` | 习惯、记录、提醒规则、生命周期、统计与 Habit→Plan 写入 |
| `GoalsStore` | 目标/项目/子项目/行动、PlanRecord、进度与筛选统计 |
| `FocusStore` | 倒计时状态、目标快照、会话恢复、历史与通知效果 |
| `AppSettingsStore` | 主题模式、强调色、背景色和卡片色 |

Store 是可变应用状态的主要来源；页面不维护另一套独立业务真相。

## 分层职责

### Presentation

位置：各 feature 的 `presentation/` 目录和 `lib/shared/widgets/`。

职责：

- 渲染 Store 派生的数据。
- 收集用户输入并调用明确的 Store/application 操作。
- 展示对话框、Bottom Sheet、表单、空状态和错误/权限说明。
- 保持 Today、Habits、Plan、Focus 主导航和 Review、Settings 次级导航规则一致。
- 不直接解析原生权限、写 Android 通知渠道或操作任意文件路径。

### Application / Stores

位置：feature 的 `application/` 和 `app/settings/application/`。

职责：

- 编排创建、编辑、打卡、完成、开始/暂停/恢复等用例。
- 校验输入并维护操作顺序。
- 计算 UI 需要的完成度、统计、周活动和目标选项。
- 调用持久化、通知和跨 feature writer 接口。
- 在状态变化后通知当前页面和其他消费者。

Store 提供内存实现/可替换接口以支持测试，生产环境使用本地持久化实现。

### Domain models

位置：各 feature 的 `domain/models/`。

主要模型：

- Habits：`HabitItem`、`HabitRecord`、提醒规则、暂停区间、附件和统计摘要。
- Plan：`GoalItem`、`ProjectItem`、`SubprojectItem`、`GoalTaskItem`、`PlanRecord` 和附件。
- Focus：活动会话、历史会话和目标快照。

领域规则包括：

- 行动是 Plan 中唯一可直接完成的单元。
- 父级进度由子行动派生。
- 跳过记录不计为习惯完成；补打按所选本地日期计算。
- Habit 关联写入 Plan 来源记录，但不改变行动完成状态。
- 运行中的 Focus 目标保持快照，即使对应 Plan 行动随后发生变化。

### Data / local persistence

结构化状态使用 `shared_preferences` 支持的本地存储实现：

- `HabitsLocalStorage`
- `GoalsLocalStorage`
- `FocusLocalStorage`
- `AppSettingsLocalStorage`

持久化实现负责：

- JSON/基础值序列化与读取。
- 旧数据兼容和畸形数据安全回退。
- schema 内缺失字段的默认值。
- Store 加载与写入所需的 snapshot。

图片附件通过 `path_provider` 定位应用文档目录，并复制到应用管理的子目录。结构化记录保存附件元数据，而不是把图片内容写入 `shared_preferences`。

当前没有 SQLite、远程数据库、云同步或后台服务器。

## 核心数据流

### 习惯打卡

```text
Habits UI
  -> HabitsStore 写入 HabitRecord
  -> HabitsLocalStorage 持久化
  -> （达到目标且已关联时）HabitPlanRecordWriter 写入来源明确的 PlanRecord
  -> notifyListeners
  -> Habits / Today / Review 读取新的派生状态
```

同一天可以有多个打卡记录。补打归属于所选本地日期；跳过保留为真实记录但不计入完成。

### Plan 行动完成

```text
Plan UI
  -> GoalsStore 更新 GoalTaskItem 完成状态
  -> GoalsLocalStorage 持久化
  -> 父项目/目标进度重新派生
  -> FocusStore 对空闲目标选项做协调
  -> Plan / Today / Review / Focus 读取一致状态
```

完成行动不会伪造 PlanRecord；记录和完成状态保持不同语义。

### Focus 会话

```text
Focus UI
  -> FocusStore 选择时长与可选 Plan 目标
  -> 保存活动会话和结束时间
  -> FocusNotificationService 安排普通完成提醒
  -> tick/恢复逻辑从时间戳计算剩余时间
  -> 完成时只写入一条 FocusSessionItem
  -> Today / Focus / Review 更新派生指标
```

暂停、重置、延迟通知回调和重启恢复都通过 Store 中的序列化效果与状态检查防止重复记录或过期调度覆盖新状态。

### 主题变更

```text
Settings UI
  -> AppSettingsStore
  -> AppSettingsLocalStorage
  -> MaterialApp / AppShell / 可见页面响应通知
```

主题变更不要求重启应用，也不改变 Habit/Plan/Focus 数据。

## 路由

`lib/app/router/app_router.dart` 集中维护现有命名路由：

| Route | 页面 |
| --- | --- |
| `/`、`/today` | 今天 |
| `/habits` | 习惯 |
| `/goals` | 计划（内部稳定 route key） |
| `/focus` | 专注 |
| `/review` | 复盘 |
| `/settings` | 设置/我的 |

主页面使用替换式导航，避免底部主 Tab 堆叠无意义历史。Review 与 Settings 提供显式返回行为；从根路由打开时有 Today 回退。

通知不接受任意 URI。通知 payload 经过严格 schema 校验，只能解析到允许的现有路由和动作。

## 通知基础设施

`lib/core/notifications/` 提供统一平台边界：

- `AppLocalNotificationService`：初始化、渠道、调度、取消、测试通知和健康信息。
- `LocalNotificationsGateway`：对 `flutter_local_notifications` 的可替换封装。
- `NotificationRuntimeController`：应用生命周期内的初始化、响应缓冲和一次性消费。
- notification payload/routing：严格 JSON schema、实体 ID 和目标路由验证。
- timezone provider：从 Android 获取设备时区并构造本地日历时间。

Habit 与 Focus 各自的 notification service 负责把领域状态转换为统一通知请求。Plan 当前没有提醒功能，因此没有 Plan channel 或 scheduler。

## 权限基础设施

`lib/core/permissions/` 将原生 Android 状态映射为跨 UI 的结构化模型：

- `granted`
- `denied`
- `settingsRequired`
- `restricted`
- `unavailable`
- `notApplicable`

Android 原生桥只负责读取系统状态、触发公开权限 API 和打开对应设置页面。解释文案、何时请求及拒绝后的产品行为由 Flutter 层控制。

非 Android 平台和 Web 安全返回 not-applicable，不调用 Android MethodChannel。拒绝通知权限不会回滚用户保存的 Habit 提醒或正在进行的 Focus 状态。

## 媒体边界

- Gallery 选择优先使用 Android Photo Picker 或用户范围的系统选择器。
- Camera 通过外部系统相机意图；应用没有直接相机预览。
- 选中的文件复制到应用管理目录。
- 应用不声明 `CAMERA`、`READ_MEDIA_IMAGES` 或广域存储权限。
- picker 取消、相机不可用、丢失返回数据和本地文件缺失都有安全回退。

## 测试策略

`test/` 按职责覆盖：

- Store 与派生逻辑。
- `shared_preferences` snapshot、迁移和畸形数据回退。
- Habit、Plan、Focus 页面真实交互。
- Today/Review 的真实 Store 指标。
- 跨页同步与导航。
- 通知调度、取消、时区、竞态和冷启动。
- 权限状态、Settings 权限中心和 Web 安全。
- Android manifest、receiver、permission 和资源契约。
- 品牌 SVG/PNG、Launcher、Adaptive Icon、notification icon 与 Splash 契约。

测试使用 fake storage、fake gateway、可注入时钟和平台抽象，避免 unit/widget tests 依赖真实通知、相机或 Android 设备。

## 隐私与安全边界

- 不读取账号、联系人、位置、电话、短信或麦克风数据。
- 不包含登录、云端 API、分析、广告或后台上传。
- 不申请精确闹钟、忽略电池优化或前台服务权限。
- 通知动作只打开已有 UI，不在后台 isolate 中静默修改 Store 数据。
- 通知 payload 拒绝畸形、未知、过大或不安全标识。
- Android receivers 尽可能为 `exported="false"`；依赖 receiver 使用系统/签名权限保护。

## 稳定性约束

Get Ready 2.6.0 品牌发布不得改变：

- Stores 的业务职责。
- 领域模型和持久化 schema。
- PlanRecord、进度和行动完成语义。
- Habit→Plan 同步语义。
- Focus 会话恢复与一次性历史写入。
- 现有路由层级。
- P9 接受的权限、渠道、receiver、调度和深链行为。

品牌、版本、文档和平台可见元数据可以更新，但不应借此引入新业务功能。

## 当前边界与后续方向

- 当前仅支持单设备本地状态，没有云同步或冲突合并。
- 大型数据集仍使用轻量本地序列化；若未来引入数据库，需要独立迁移设计和回归验证。
- 导出/备份尚未实现。
- 正式发布前仍需 package ID、release signing、AAB 和真实设备兼容性工作。
- Android 厂商电池策略、启动器遮罩和通知视觉必须通过物理设备验证。
