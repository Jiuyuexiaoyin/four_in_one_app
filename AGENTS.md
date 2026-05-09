# AGENTS.md

> 新账号 Codex 接手 `four_in_one_app` 时必须先读的规则文档。  
> 项目根目录：`D:\AI\Projects\four_in_one_app`  
> 交接文档：`D:\AI\Projects\four_in_one_app\CODEx_账号切换交接文档.md`  
> 当前版本：`1.0.1+11`  
> 最新 phone-test debug APK：`D:\AI\Projects\four_in_one_app\build\alpha_apks\four_in_one_app_v1.0.1+11_debug.apk`

这不是一个从零开始的 Flutter MVP。项目已经经历多轮真实设备反馈、Benchmark Gate Review、Plan/Habits/Focus/Review 深度修补和 P0 UX 修复。新账号接手后，第一任务不是继续狂加功能，而是保护已有语义、继续真实设备反馈驱动的修补。

---

## 1. 新账号第一句话应该先读取哪些文件

接手后的第一句工作更新建议是：

```text
我先读取 AGENTS.md、CODEx_账号切换交接文档.md、versioning、产品方向文档和当前高风险页面代码，确认当前约束后再动手。
```

必须先按顺序读取：

1. `D:\AI\Projects\four_in_one_app\AGENTS.md`
2. `D:\AI\Projects\four_in_one_app\CODEx_账号切换交接文档.md`
3. `D:\AI\Projects\four_in_one_app\docs\versioning.md`
4. `D:\AI\Projects\four_in_one_app\docs\product_vision.md`
5. `D:\AI\Projects\four_in_one_app\docs\ui_direction.md`
6. `D:\AI\Projects\four_in_one_app\docs\source_ui_reference.md`
7. `D:\AI\Projects\four_in_one_app\docs\visual_gap_audit_v1.md`
8. `D:\AI\Projects\four_in_one_app\docs\ui_reference_components.md`
9. `D:\AI\Projects\four_in_one_app\docs\benchmark_parity_gate_v1.md`
10. `D:\AI\Projects\four_in_one_app\docs\benchmark_parity_roadmap.md`
11. `D:\AI\Projects\four_in_one_app\docs\feature_completion_checklist.md`
12. `D:\AI\Projects\four_in_one_app\docs\references\app_report_v2.txt`
13. `D:\AI\Projects\four_in_one_app\docs\references\app_content\HabitDone`
14. `D:\AI\Projects\four_in_one_app\docs\references\app_content\daymark`
15. `D:\AI\Projects\four_in_one_app\docs\references\app_content\OffScreen`
16. `D:\AI\Projects\four_in_one_app\docs\references\app_content\番茄ToDo`

当前最容易出问题的代码也要优先读：

1. `lib/features/today/presentation/pages/today_page.dart`
2. `lib/features/goals/presentation/pages/goals_page.dart`
3. `lib/shared/widgets/product/plan_goal_card.dart`
4. `lib/shared/widgets/product/plan_tree_row.dart`
5. `lib/features/habits/presentation/pages/habits_page.dart`
6. `lib/shared/widgets/product/habit_identity_card.dart`

核心语义代码要在改 Habits / Plan 前读：

1. `lib/features/habits/domain/models/habit_item.dart`
2. `lib/features/habits/domain/models/habit_record.dart`
3. `lib/features/habits/domain/models/habit_record_attachment.dart`
4. `lib/features/habits/domain/models/habit_statistics_summary.dart`
5. `lib/features/habits/application/habits_store.dart`
6. `lib/features/habits/data/habits_local_storage.dart`
7. `lib/features/habits/data/habit_reminder_notification_service.dart`
8. `lib/features/habits/data/habit_record_attachment_storage.dart`
9. `lib/features/goals/domain/models/goal_item.dart`
10. `lib/features/goals/application/goals_store.dart`
11. `lib/features/goals/data/goals_local_storage.dart`
12. `lib/features/goals/data/plan_record_attachment_storage.dart`

---

## 2. 项目目标

这是一个“四合一”个人效率成长应用，目标不是做单点工具，而是把四类能力统一在一个轻量、有质感、真实可用的移动端产品里：

- `今日`：每日 command center，汇总习惯、计划、专注、复盘的真实状态。
- `计划`：DayMark 风格的长期目标 / 项目 / 分组 / 行动对象系统。
- `习惯`：HabitDone 风格的成熟轻量 habit tracker。
- `专注`：番茄ToDo 风格的清晰专注计时执行页。
- `复盘`：OffScreen 风格的冷静数据回看页。
- `我的/设置`：主题、强调色、权限和设置入口。

Benchmark 方向：

- `HabitDone`：习惯身份、每日打卡、多次打卡、备注、跳过、补打卡、图片证明、热力图、统计、提醒、自定义颜色、生命周期。
- `daymark`：计划层级、项目记录、数值/备注记录、项目统计、日期历史、可编辑项目身份。
- `番茄ToDo`：大视觉计时器、开始/暂停/重置清晰、任务/行动绑定、完成通知、历史记录。
- `OffScreen`：冷静、克制、高级感的数据表达，不做假数据，不做吵闹 dashboard。

不能复制 benchmark app 的品牌、精确布局或视觉资产。目标是吸收产品特质，让本 app 统一但不平庸。

---

## 3. 用户长期要求

这些是用户反复强调的硬约束，必须默认遵守：

- 只有准备新的 phone-test APK 时才更新版本号。
- 普通开发、UI 修补、逻辑修补不更新版本号。
- 未经明确批准，不准备 phone-test APK。
- 不随意新增依赖。
- 不随意修改 routing。
- 不改 bottom navigation。
- 不破坏现有 `今日 / 计划 / 专注 / 复盘 / 我的` 五 tab IA。
- 不引入假数据、假趋势、假 analytics。
- 不为了“看起来更强”伪造完成率、趋势、streak、数字健康数据。
- 不自动完成 Plan task，除非用户未来明确设计这种语义。
- 不让 Plan records 影响 task progress。
- 不让 Habit proof / note / skip 影响 completion count。
- 不让 proof image 影响 Today count、Review metrics、heatmap、streak。
- 不让 Focus binding mutate Plan task completion。
- 不混合不同 unit 的 numeric totals。
- 不把图片 bytes/base64 存进 SharedPreferences/JSON。
- 不把普通一键打卡变重。
- 不做 noisy dashboard。
- 不复制 benchmark app 的 branding 或精确布局。
- 不在 Windows 上承诺已经能产出 iOS IPA。

版本规则：

- 当前版本：`1.0.1+11`。
- 当前 APK：`build\alpha_apks\four_in_one_app_v1.0.1+11_debug.apk`。
- 下一次 phone-test 若需要 bump，建议从 `1.1.0+12` 开始。
- 版本记录必须同步更新 `pubspec.yaml` 和 `docs/versioning.md`。

Phone-test APK 必须流程：

1. 更新 `pubspec.yaml`。
2. 更新 `docs/versioning.md`。
3. 不改业务/UI/store/routing/dependency/native config，除非任务明确要求。
4. 运行 `flutter analyze --no-pub`。
5. 运行 `flutter test --no-pub`。
6. 运行 `flutter build apk --debug --no-pub`。
7. 用 `aapt dump badging` 确认 `versionName` / `versionCode`。
8. 复制 APK 到 `build\alpha_apks\...debug.apk`。

---

## 4. 当前项目状态

当前项目阶段：

- 已进入真实 `1.0` 测试阶段。
- 当前版本为 `1.0.1+11`。
- `1.0.1+11` 是 P0 UX repair phone-test build，不是新功能大版本。
- 最新 APK 位于 `D:\AI\Projects\four_in_one_app\build\alpha_apks\four_in_one_app_v1.0.1+11_debug.apk`。

当前关键依赖：

```yaml
flutter_local_notifications: ^21.0.0
image_picker: ^1.2.1
path_provider: ^2.1.5
shared_preferences: ^2.5.5
```

已确认：

- `image_picker` resolved to `1.2.1`。
- `path_provider` resolved to `2.1.5`。
- 这两个依赖是 Plan/Habit 图片证明功能批准加入的，不要重复添加相邻图片依赖。

Native config 语义：

- iOS 已有 photo library usage description。
- iOS 已有 camera usage description，用于 Habit proof camera capture。
- 不需要 `NSMicrophoneUsageDescription`，因为没有 video capture。
- 不需要 `NSPhotoLibraryAddUsageDescription`，因为当前只选择/拍摄图片并复制到 app-managed storage。
- Android 不要随便改 `AndroidManifest.xml`。
- Android 不要随便加 storage/camera permission，除非有直接、可复现 blocker 并先报告。

---

## 5. 当前项目目录结构

根目录：

```text
D:\AI\Projects\four_in_one_app
├─ .dart_tool/
├─ .idea/
├─ android/
├─ build/
│  └─ alpha_apks/
│     ├─ four_in_one_app_v0.2.0+2_debug.apk
│     ├─ four_in_one_app_v0.3.0+3_debug.apk
│     ├─ four_in_one_app_v0.4.0+4_debug.apk
│     ├─ four_in_one_app_v0.5.0+5_debug.apk
│     ├─ four_in_one_app_v0.6.0+6_debug.apk
│     ├─ four_in_one_app_v0.7.0+7_debug.apk
│     ├─ four_in_one_app_v0.8.0+8_debug.apk
│     ├─ four_in_one_app_v0.9.0+9_debug.apk
│     ├─ four_in_one_app_v1.0.0+10_debug.apk
│     └─ four_in_one_app_v1.0.1+11_debug.apk
├─ docs/
│  ├─ benchmark_parity_gate_v1.md
│  ├─ benchmark_parity_roadmap.md
│  ├─ feature_completion_checklist.md
│  ├─ product_vision.md
│  ├─ roadmap.md
│  ├─ source_ui_reference.md
│  ├─ ui_direction.md
│  ├─ ui_reference_components.md
│  ├─ versioning.md
│  ├─ visual_gap_audit_v1.md
│  └─ references/
│     ├─ app_report_v2.txt
│     └─ app_content/
│        ├─ HabitDone/
│        ├─ daymark/
│        ├─ OffScreen/
│        └─ 番茄ToDo/
├─ integration_test/
├─ ios/
├─ lib/
│  ├─ main.dart
│  ├─ app/
│  │  ├─ app.dart
│  │  ├─ router/
│  │  ├─ settings/
│  │  └─ theme/
│  ├─ features/
│  │  ├─ focus/
│  │  ├─ goals/
│  │  ├─ habits/
│  │  ├─ review/
│  │  ├─ settings/
│  │  └─ today/
│  └─ shared/
│     └─ widgets/
│        ├─ app_shell.dart
│        └─ product/
├─ test/
├─ AGENTS.md
├─ CODEx_账号切换交接文档.md
├─ analysis_options.yaml
├─ pubspec.yaml
├─ pubspec.lock
└─ README.md
```

共享产品组件：

```text
lib/shared/widgets/product/activity_strip.dart
lib/shared/widgets/product/focus_timer_hero.dart
lib/shared/widgets/product/habit_identity_card.dart
lib/shared/widgets/product/metric_strip.dart
lib/shared/widgets/product/metric_tile.dart
lib/shared/widgets/product/mini_heatmap_cell.dart
lib/shared/widgets/product/my_settings_section.dart
lib/shared/widgets/product/plan_goal_card.dart
lib/shared/widgets/product/plan_tree_row.dart
lib/shared/widgets/product/product_page_header.dart
lib/shared/widgets/product/progress_rail.dart
lib/shared/widgets/product/soft_surface.dart
```

主要测试：

```text
test/app_settings_store_test.dart
test/app_smoke_test.dart
test/focus_flow_test.dart
test/focus_persistence_test.dart
test/focus_store_test.dart
test/goals_attachment_widget_test.dart
test/goals_flow_test.dart
test/goals_persistence_test.dart
test/habits_flow_test.dart
test/habits_persistence_test.dart
test/habits_reminder_notifications_test.dart
test/habit_plan_linking_test.dart
test/habit_record_attachment_storage_test.dart
test/habit_statistics_test.dart
test/plan_record_attachment_storage_test.dart
test/review_overview_test.dart
test/settings_theme_test.dart
test/today_overview_test.dart
```

---

## 6. 重要文件说明

App shell / theme：

- `lib/app/app.dart`：App composition、store injection、Habit → Plan writer/coordinator wiring。
- `lib/app/router/app_router.dart`：路由定义，不要随意改。
- `lib/shared/widgets/app_shell.dart`：bottom navigation，当前五 tab 不要改。
- `lib/app/theme/app_theme.dart`、`lib/app/theme/app_theme_tokens.dart`：全局主题和 token。Habit per-color 不等于 global accent。

Today：

- `lib/features/today/presentation/pages/today_page.dart`：今日 command center，只读，汇总 Habits/Plan/Focus。
- `test/today_overview_test.dart`：包含 360/393/412dp + text scale 1.15 responsive coverage。

Plan / Goals：

- `lib/features/goals/domain/models/goal_item.dart`：GoalItem、ProjectItem、SubprojectItem、GoalTaskItem、PlanRecord、PlanRecordAttachment、PlanRecord source metadata。
- `lib/features/goals/application/goals_store.dart`：Plan hierarchy、Project stats、habit-linked generated PlanRecords、sourceKey duplicate prevention。
- `lib/features/goals/data/goals_local_storage.dart`：Goals local JSON storage。
- `lib/features/goals/data/plan_record_attachment_storage.dart`：Plan image copy/storage abstraction。
- `lib/features/goals/presentation/pages/goals_page.dart`：Goal edit、Project edit、Project stats、focused goal tree。
- `lib/shared/widgets/product/plan_goal_card.dart`：Goal card visual，P0 后 `编辑目标` 必须明显。
- `lib/shared/widgets/product/plan_tree_row.dart`：Project/Subproject/Task row，P0 后 `编辑项目` / `编辑分组` / `编辑行动` 必须是 visible text action。

Habits：

- `lib/features/habits/domain/models/habit_item.dart`：HabitItem、HabitLifecycleStatus、HabitPauseInterval、HabitReminderRule、HabitPlanLink、habitColorValue。
- `lib/features/habits/domain/models/habit_record.dart`：HabitRecord，type 为 checkIn / skip / makeup，包含 note/localDate/createdAt semantics。
- `lib/features/habits/domain/models/habit_record_attachment.dart`：HabitRecordAttachment，多图证明 metadata。
- `lib/features/habits/domain/models/habit_statistics_summary.dart`：per-habit stats、streak、pause-aware streak protection、proof/skip/makeup counting rules。
- `lib/features/habits/application/habits_store.dart`：check-in、detailed record、skip、makeup、lifecycle、reminder rules、attachments、Habit → Plan trigger。
- `lib/features/habits/data/habits_local_storage.dart`：Habit snapshot storage/migration。
- `lib/features/habits/data/habit_record_attachment_storage.dart`：Habit proof image storage，gallery/camera source abstraction，missing file safe state。
- `lib/features/habits/data/habit_reminder_notification_service.dart`：Habit local notification scheduling/cancel，绝对不要触碰 Focus notification IDs。
- `lib/features/habits/presentation/pages/habits_page.dart`：Habits UI、record sheets、proof grid/preview、stats sheet、lifecycle actions、reminder rules sheet、Habit-plan link picker。
- `lib/shared/widgets/product/habit_identity_card.dart`：Habit card visual、per-habit color、reminder summary、lifecycle chips。

Focus：

- `lib/features/focus/application/focus_store.dart`：timer state、persistence、binding snapshots。
- `lib/features/focus/presentation/pages/focus_page.dart`：Focus UI。
- `lib/shared/widgets/product/focus_timer_hero.dart`：Timer hero component。

Review：

- `lib/features/review/presentation/pages/review_page.dart`：OffScreen-style calm data panels。不要过早膨胀 Review。

Settings：

- `lib/features/settings/presentation/pages/settings_page.dart`：My/settings page。
- `lib/app/settings/...`：App settings store/storage。
- `test/app_settings_store_test.dart`、`test/settings_theme_test.dart`：theme persistence 相关。

---

## 7. 已完成工作

Plan / DayMark：

- Plan Records + Project Statistics V3A。
- Plan Identity Editing V3B。
- Plan Photo Attachment Foundation V3C。
- Plan Photo Attachment Test Hardening。
- Plan Statistics Detail / Heatmap V3D。
- P0 Plan edit discoverability repair。
- 当前支持 Goal / Project / Subproject / Task hierarchy、identity edit、records、numeric logs、date history、image proof、project stats、current-month activity、habit-linked generated PlanRecords。

Habits / HabitDone：

- Habits Notes / Skip / Makeup V3A。
- Habit Proof Attachments V3B。
- Habit Statistics V3C。
- Habit Customization V3D。
- Habits Record Semantics Repair V4A。
- Habits Visual Analytics V4B。
- Habits Annual Heatmap + Streak Foundation V4C。
- Habits Lifecycle V4D。
- Habits Pause-aware Streak Protection V4E。
- Habits Advanced Reminder Rules V4F。
- Habits Multi-image Proof + Camera Capture V4G。
- Habit-Goal Linking V4H。
- 当前支持 quick check-in、detailed record draft/save、notes、skip、makeup、max 3 proof images、camera/gallery、annual heatmap、pause-aware streak、lifecycle、advanced reminders、per-habit color、Habit → Plan link。

Focus / 番茄ToDo：

- Large visual timer center。
- Custom duration。
- Restore after app kill。
- Completed focus history。
- Completion notification path。
- Task/action binding。
- Target snapshot in history。
- No task auto-completion。

Review / OffScreen：

- Real metrics。
- Calm data panels。
- Habit activity summary。
- Plan progress summary。
- Focus completion summary。
- Honest zero states。
- No fake digital wellbeing data。

Unified UI：

- 已建立 `SoftSurface`、`MetricTile`、`MetricStrip`、`MiniHeatmapCell`、`ActivityStrip`、`ProgressRail`、`PlanGoalCard`、`PlanTreeRow`、`HabitIdentityCard`、`FocusTimerHero`、`ProductPageHeader`、`MySettingsSection`。

P0 UX Critical Repair Pack：

- Goal card 显示 `编辑目标`。
- Focused goal tree 显示 `编辑目标`。
- Project row 显示 `编辑项目`。
- Subproject row 显示 `编辑分组`。
- Task/action row 显示 `编辑行动`。
- Today 改成更像 daily command center。
- Today/Plan/major sheets 增加 360/393/412dp 和 text scale 1.15 相关测试。

---

## 8. 禁止重复做的事情

不要重复做：

- 不要重新添加 `image_picker` / `path_provider`。
- 不要再做 Plan one-image attachment foundation。
- 不要再做 Habit one-image proof foundation，已升级到 max 3 + camera。
- 不要重新设计 Habit skip/makeup semantics。
- 不要重新添加 annual heatmap/streak foundation。
- 不要重新添加 lifecycle/pause/archive/delete。
- 不要重新添加 pause-aware streak intervals。
- 不要重新添加 advanced reminder rules。
- 不要重新添加 Habit → Plan link foundation。
- 不要新增 Review global analytics，用户多次要求 Review 不要过早膨胀。
- 不要改变 Focus logic，除非新反馈明确要求。
- 不要改变 bottom nav/routing。
- 不要让 ordinary habit check-in 变重。
- 不要把 Plan tree 做成桌面式复杂树，必须 phone-readable。
- 不要把 Today 做成假 dashboard。
- 不要在非 phone-test 包时 bump version。
- 不要在 Windows 上承诺 iOS IPA。

不要误改语义：

- Plan task progress = task completion only。
- Plan records = evidence/history，不是 progress。
- Habit proof/note/skip 不计 completion。
- Habit makeup 使用 selected localDate。
- Habit skip 不增加 heatmap intensity。
- Habit pause days 不增加 streak，只 neutral。
- Focus binding 不完成 Plan task。
- Generated habit-linked PlanRecord 不完成 Plan task。
- Numeric totals 按 unit 分组，不混合。
- 图片只存 app-managed path + metadata，不存 bytes/base64。

---

## 9. 已踩坑记录

Dependency access：

- 早期 `flutter pub get` 因访问 `pub.dev` socket error 失败，曾阻塞 Plan photo attachment V3C。
- 后来通过 Flutter China mirror 恢复。
- 如果 pub get 失败，报告 exact error，不改代码，不换包，停下来等批准。

Flutter SDK sandbox：

- 直接运行 Flutter 可能出现 `CreateFile failed 5` 或 analysis server snapshot 拒绝访问。
- 这是 SDK/cache 权限问题，不一定是代码问题。
- 需要时使用 escalated shell command。

Android build：

```powershell
$env:JAVA_HOME='D:\AI\Tools\AndroidStudio\android-studio\jbr'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
flutter build apk --debug --no-pub
```

APK badging stale：

- `flutter build apk --debug --no-pub` 曾构建成功但仍输出旧 badging。
- 解决：

```powershell
flutter build apk --debug --no-pub --build-name=1.0.1 --build-number=11
```

- 以后 version bump 后必须跑：

```powershell
& 'D:\AI\SDKs\Android\build-tools\36.0.0\aapt.exe' dump badging 'D:\AI\Projects\four_in_one_app\build\app\outputs\flutter-apk\app-debug.apk'
```

Git 状态：

- 当前项目根目录看起来没有 `.git`。
- 不要依赖 `git diff/status` 作为唯一变更追踪。

中文编码：

- PowerShell 默认读部分中文文件可能 mojibake。
- 读取中文文档建议：

```powershell
[Console]::OutputEncoding=[System.Text.Encoding]::UTF8
Get-Content -Encoding UTF8 <path>
```

Today layout：

- Today 顶部 metrics 曾在窄宽度/默认 test height 下把 `today-habits-view-all` 推到底部导航遮挡区。
- 窄屏下要使用 compact chips，避免固定大卡片堆叠。

Plan edit discoverability：

- 之前功能存在但用户感知不到。
- 后续 edit 入口不要只放 icon、long press 或隐藏菜单。

Habit record semantics：

- `详细打卡` 必须先开 detail sheet，保存后才创建。
- `补打卡` 必须指向过去 selected localDate，不能默认今天。
- `跳过` 对已有 checkIn/makeup 的日期必须禁用或提示。
- Month view 必须能选过去日期。

Streak protection：

- Paused days neutral。
- Completed days 仍只来自 real checkIn + makeup。
- Skip outside pause breaks streak。
- 不要把 skip 直接当 streak protection token。

Habit → Plan：

- Habit 达标可以生成 PlanRecord evidence/history。
- 不能自动完成 linked task。
- 不能改变 task progress。
- 不能重复生成。
- 清 link 不删除历史 generated records。

---

## 10. 后续下一步建议

当前最自然下一步：

1. 把 `1.0.1+11` APK 给用户做真实手机测试。
2. 收集真实设备反馈。
3. 重点观察 Plan edit 是否终于明显、Today 是否像 daily command center、小屏是否不再溢出、Habit bottom sheets 是否可用、Habit → Plan generated records 是否容易理解。

如果用户继续要求 iPhone 安装包：

- 当前 Windows 环境不能直接产出 iOS IPA。
- 需要 macOS、Xcode、Apple Developer 账号、Bundle ID、signing、provisioning profile。
- 可走 `flutter build ipa`、Xcode archive、TestFlight 或 Ad Hoc。
- 不要承诺像 APK 一样直接发文件安装。

如果继续 P0/P1 修补：

1. 优先修真实设备布局反馈。
2. 继续 Plan/Habits 高频路径 discoverability polish。
3. Today 做更精细但仍真实的数据分层。
4. 检查 iOS-ready 配置。
5. 再考虑新功能。

如果继续功能路线：

- 可以考虑 Cross-feature Review analytics，但必须避免 fake。
- 可以考虑 Plan archive/lifecycle。
- 可以考虑 Plan record advanced filters。
- 可以考虑 iOS/TestFlight packaging。
- 可以考虑 Export/backup/data management。
- 可以考虑 soft-deleted habits 的 hard delete strategy，但必须先有安全确认和备份思路。

---

## 11. 必须运行的验证命令

常规验证：

```powershell
flutter analyze --no-pub
flutter test --no-pub
```

重点单测：

```powershell
flutter test --no-pub test\today_overview_test.dart
flutter test --no-pub test\goals_flow_test.dart
flutter test --no-pub test\habits_flow_test.dart
flutter test --no-pub test\habit_plan_linking_test.dart
flutter test --no-pub test\habits_reminder_notifications_test.dart
flutter test --no-pub test\habit_statistics_test.dart
```

构建验证：

```powershell
$env:JAVA_HOME='D:\AI\Tools\AndroidStudio\android-studio\jbr'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
flutter build apk --debug --no-pub
```

版本 badging 检查：

```powershell
& 'D:\AI\SDKs\Android\build-tools\36.0.0\aapt.exe' dump badging 'D:\AI\Projects\four_in_one_app\build\app\outputs\flutter-apk\app-debug.apk'
```

如果刚 bump version 且 badging 仍旧：

```powershell
flutter build apk --debug --no-pub --build-name=<versionName> --build-number=<versionCode>
```

---

## 12. 当前最后一次已知验证状态

`1.0.1+11` packaging 前最后验证：

```text
flutter analyze --no-pub
=> No issues found.

flutter test --no-pub
=> All tests passed, 158 tests.

flutter build apk --debug --no-pub --build-name=1.0.1 --build-number=11
=> Built build\app\outputs\flutter-apk\app-debug.apk

aapt dump badging
=> versionName='1.0.1'
=> versionCode='11'
```

最终 APK：

```text
D:\AI\Projects\four_in_one_app\build\alpha_apks\four_in_one_app_v1.0.1+11_debug.apk
```

---

## 13. 接手提醒

你不是从 0 开始。这个项目已经不是“搭壳 MVP”，而是经过大量 benchmark parity 修补的 1.0 测试应用。

继续工作时最重要的是：

- 保护已有语义。
- 保护用户信任。
- 做真实设备反馈驱动的修补。
- 不要一上来继续狂加功能。
- 不要因为 build passed 就认为 UX passed。
- 不要因为功能存在就认为用户能发现。
- 不要让 benchmark 方向变成 noisy imitation。

项目关键气质：

```text
HabitDone 的成熟 habit tracking
+ DayMark 的长期计划对象系统
+ 番茄ToDo 的执行清晰度
+ OffScreen 的克制数据表达
= 一个统一但不平庸的四合一效率成长 App
```
