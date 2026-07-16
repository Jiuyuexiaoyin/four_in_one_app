# Get Ready Android 通知与权限

本文档说明 Get Ready 2.6.0 的 Android 权限边界、通知渠道、调度、深链、系统设置入口和设备验证要求。实现目标是：在不申请广域或高风险权限的前提下，为 Habit 与 Focus 提供可信、可解释、可恢复的普通提醒。

## 原则

- 不在首次启动时请求通知权限。
- 只在用户启用真实提醒、开始需要结束提醒的专注或主动触发权限操作时请求。
- 拒绝或关闭权限不会破坏本地数据，也不会回滚用户刚保存的 Habit/Focus 状态。
- 使用普通非精确提醒，不承诺精确到分钟。
- 不使用前台服务、全屏通知、免打扰绕过或电池优化豁免。
- 通知动作打开已有 UI，不在后台静默完成习惯或修改计划。
- 通知 payload 只允许进入受控的现有路由。

## 最终权限面

### Main / release

| 权限 | 来源 | 用途 |
| --- | --- | --- |
| `android.permission.POST_NOTIFICATIONS` | 应用显式声明及插件合并 | Android 13+ 显示 Habit、Focus 与用户主动测试通知 |
| `android.permission.RECEIVE_BOOT_COMPLETED` | 应用显式声明 | 重启或应用更新后恢复真实已调度提醒 |
| `android.permission.VIBRATE` | `flutter_local_notifications` 合并 | 普通通知渠道的标准震动提示 |
| `<package>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX 生成 | 用签名级包内权限保护非导出动态 receiver |

AndroidX 的包级权限不是危险/runtime 权限，不允许其他应用读取 Get Ready 数据。

### Debug / profile

Flutter 调试 manifest 额外声明：

- `android.permission.INTERNET`：仅用于 Flutter 工具通信，不应出现在 release 合并 manifest 中。

### 明确不申请

当前产品不需要，因此不声明：

- `CAMERA`、`RECORD_AUDIO`
- `READ_EXTERNAL_STORAGE`、`WRITE_EXTERNAL_STORAGE`、`MANAGE_EXTERNAL_STORAGE`
- `READ_MEDIA_IMAGES`、`READ_MEDIA_VIDEO`
- `SCHEDULE_EXACT_ALARM`、`USE_EXACT_ALARM`
- `FOREGROUND_SERVICE` 及其类型权限
- 位置、联系人、电话、短信、附近设备或蓝牙权限
- `QUERY_ALL_PACKAGES`、`REQUEST_INSTALL_PACKAGES`
- `SYSTEM_ALERT_WINDOW`、`USE_FULL_SCREEN_INTENT`、`ACCESS_NOTIFICATION_POLICY`
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`

## 通知权限流程

### 不触发请求的情况

以下操作只检查或协调状态，不弹出 Android 权限对话框：

- 应用首次启动。
- Store 加载和本地数据恢复。
- 通知插件初始化。
- 已保存提醒的启动协调。
- 打开 Settings/通知与权限区域。
- 仅查看通知健康信息。

### 上下文请求

可能触发 Android 13+ 通知权限请求的操作：

1. 用户保存一个刚启用的 Habit 提醒。
2. 用户开始需要安排完成提醒的 Focus 会话。
3. 用户主动点击 Settings 中的通知权限操作。
4. 用户主动发送测试通知，而权限尚不可用。

请求前先显示简短中文解释，再调用系统对话框。

### 结构化状态

Flutter 层把平台结果映射为：

| 状态 | 产品行为 |
| --- | --- |
| `granted` | 可以继续安排/发送通知 |
| `denied` | 保留本地配置，说明通知可能无法显示 |
| `settingsRequired` | 不重复弹窗，引导打开系统通知设置 |
| `restricted` | 说明系统限制并保留数据 |
| `unavailable` | 安全失败，不破坏 Habit/Focus 流程 |
| `notApplicable` | Web、非 Android 或无需该权限的系统版本 |

拒绝、关闭或系统限制不会撤销用户保存的 Habit 提醒规则，也不会停止本地 Focus 倒计时。

## 通知渠道

| Channel ID | 可见名称 | 说明 | Importance |
| --- | --- | --- | --- |
| `habit_reminders_v1` | 习惯提醒 | 按用户设置的日期和时间发送习惯打卡提醒 | default |
| `focus_completion_v1` | 专注完成 | 一轮专注结束时提醒用户查看记录 | default |

渠道 ID 是稳定技术标识，不因 Get Ready 品牌更新而重命名。Android 渠道行为创建后不可变；升级设备可能继续显示历史渠道记录，但新调度只使用上述版本化 ID。

当前没有 Plan reminder 功能，因此没有 Plan channel 或 scheduler。

## 调度模型

### Habit

- 每个习惯最多支持三条提醒规则。
- 规则包含时间、星期集合和启用状态。
- 调度使用普通 `inexactAllowWhileIdle` 模式。
- reminder ID 可重复计算并避开 Focus ID 范围。
- 编辑时替换对应未来调度；关闭或删除规则时取消。
- 暂停、归档或软删除习惯时取消所属提醒。
- 启动协调读取真实 pending list，清理应用拥有的孤儿请求并重新建立有效提醒。

### Focus

- 开始新一轮专注时按目标结束时间安排一条完成提醒。
- 暂停、重置或完成会取消/协调不再有效的请求。
- 活动会话保存结束时间；应用恢复后按真实时钟重算剩余时间。
- 调度/取消效果按顺序处理，防止延迟的旧操作覆盖更新状态。
- 会话完成历史只写入一次；通知不是完成记录的唯一触发源。

### 普通提醒精度

Get Ready 不申请 exact alarm special access。Doze、系统负载和厂商电池策略可能推迟通知，这是预期平台边界。Settings 必须使用“普通提醒”等真实文案，不承诺精确到分钟。

## 重启与应用更新恢复

Main manifest 注册插件所需 receiver，并保持应用拥有的通知 receiver 为非导出状态：

- `ScheduledNotificationReceiver`
- `ScheduledNotificationBootReceiver`
- `ActionBroadcastReceiver`

Boot receiver 处理：

- `BOOT_COMPLETED`
- `MY_PACKAGE_REPLACED`
- 支持的 Android/厂商 quick boot action

插件先恢复已保存调度；Habit Store 的启动协调随后以当前本地状态为权威，清理孤儿并确定性替换。Focus 通过保存的结束时间恢复活动会话。即使厂商抑制开机广播，用户重新打开应用仍有修复路径。

## 通知视觉身份

- 应用可见名称：**Get Ready**。
- 通知 status icon 使用开放圆弧/状态/圆点标志的单色版本。
- icon 背景透明，不包含方形容器、Wordmark、绿色、渐变或阴影。
- Android 在状态栏和通知卡片中负责着色。
- 资源通过 keep rule 保留，避免 release resource shrinking 删除字符串引用资源。
- 通知正文保持简短；需要时使用 BigText，不显示持续倒计时噪声或全屏 UI。

真实图标边缘、浅/深状态栏对比和厂商缩放必须在物理设备上验证。

## Payload 与路由

通知 payload 使用受控 JSON schema，包含版本、通知类型、安全实体 ID、已存在的 route 和可选 action。解析器拒绝：

- 畸形或非 JSON 数据。
- 未知版本、类型、route 或 action。
- 缺失字段、类型不匹配或过大字段。
- 不安全的实体 ID。
- route 与通知类型不匹配。

允许的行为：

| 通知 | 正文点击 | 可见动作 |
| --- | --- | --- |
| Habit reminder | 打开现有 Habits 页面，并传递安全实体 ID | `去打卡`：打开 Habits，不自动完成 |
| Focus completion | 打开现有 Focus 页面 | `查看记录`：打开 Review |
| Test notification | 打开 Settings | 无后台数据动作 |

冷启动响应在导航准备完成后消费一次；短时间内重复的 launch/live callback 会被抑制。

没有后台 action isolate，因为当前没有可信且必要的非 UI 动作。未实现“稍后提醒”或会误导用户的“再来一轮”。

## Settings 通知与权限中心

Settings 中的紧凑区域提供：

- 当前通知权限状态及对应请求/系统设置动作。
- 普通提醒精度说明。
- Photo Picker 和外部系统相机说明。
- 一次性、明确标注的测试通知动作。
- Android 应用通知设置入口。
- Habit 与 Focus 独立渠道设置入口。
- 权限、渠道可用性、pending 数量和最近调度状态的折叠健康信息。
- Android 7 或非 Android 环境下真实的禁用/not-applicable 状态。

如果 Habit channel 被系统关闭，测试动作不得声称发送成功；UI 应显示真实结果并提供对应系统设置入口。

## 图片选择与相机

### Photo Picker

- Android 使用系统 Photo Picker，必要时回退到用户范围的系统选择器。
- 应用只能访问用户明确选择的媒体。
- 选中的文件复制到应用管理目录。
- 不申请 `READ_MEDIA_IMAGES` 或广域存储权限。

### Camera

- 应用没有直接 Camera preview。
- 拍摄证明图片委托给外部系统相机意图。
- 该模式不要求应用声明 `CAMERA`。
- 取消或无可用相机时安全返回；Gallery 仍可使用。

### Microphone

当前没有录音、语音输入、转写或音频功能，因此不申请 `RECORD_AUDIO`，Settings 也不显示虚假开关。

## 自动化覆盖

相关测试包括：

- Android manifest 的允许/禁止权限契约。
- receiver exported 状态、notification icon 和 keep rule。
- 通知权限状态、Android 7 和 Web 安全行为。
- Habit/Focus 上下文请求与拒绝后状态保留。
- 渠道禁用、测试通知和 Settings 系统入口。
- 普通调度、取消、孤儿清理、时区与 DST。
- Focus 延迟调度竞态和旧操作抑制。
- payload 校验、正文/动作路由、冷启动一次性消费和重复抑制。

自动化覆盖不能替代 Android 系统 UI 和厂商行为验证。

## 物理设备检查清单

至少在 API 33+ 真实设备上完成：

1. 干净安装后首次启动不弹通知权限。
2. 在 Habit 提醒上下文中分别检查关闭、拒绝、再次请求/设置引导和授予。
3. 在 Focus 开始上下文中确认拒绝不影响倒计时。
4. 发送测试通知，检查前台、后台和 terminated 状态。
5. 检查 Habit 正文与 `去打卡`；确保没有静默完成。
6. 检查 Focus 正文与 `查看记录`。
7. 在浅色/深色状态栏检查单色小图标，无方形底或彩色填充。
8. 分别关闭 Habit/Focus channel，确认 UI 不误报发送成功。
9. 检查应用通知设置和两个渠道设置入口。
10. 检查重启、应用覆盖更新和时区变化后的提醒。
11. 确认系统没有 exact alarm special access 请求。
12. 检查 Photo Picker、外部相机取消和不可用回退。
13. 记录设备型号、Android API、厂商系统和电池策略。

建议补充 API 24–25 legacy icon、API 26–32 adaptive/渠道行为以及 API 33+ themed icon/通知权限的代表设备。

## 已知厂商限制

- Doze 或激进电池策略可能延迟普通提醒。
- 部分厂商抑制 boot/autostart broadcast；重新打开应用是协调修复路径。
- 用户或厂商可以关闭或修改不可变渠道；应用尊重系统选择。
- Photo Picker backport 可用性不同；系统选择器回退仍保持用户范围。
- 外部相机可用性由设备决定。
- 升级设备可能继续显示 Android 保存的旧渠道历史。

Get Ready 不通过请求电池优化豁免、精确闹钟、全屏通知或前台服务来绕过这些限制。
