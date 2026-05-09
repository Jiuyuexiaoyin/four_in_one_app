# Codex 账号切换交接文档

> 项目根目录：`D:\AI\Projects\four_in_one_app`  
> 当前日期上下文：2026-05-07，时区 `Asia/Shanghai`  
> 当前 Flutter 版本号：`1.0.1+11`  
> 当前最新 phone-test debug APK：`D:\AI\Projects\four_in_one_app\build\alpha_apks\four_in_one_app_v1.0.1+11_debug.apk`

这份文档用于新账号 Codex 接手当前项目。请先读完，尤其是“不要重复做的事情”和“已经踩过的坑”。这个项目已经过多轮真实手机测试反馈与 benchmark 对齐修补，很多约束是用户反复强调过的，不能当成普通 Flutter MVP 继续粗暴加功能。

---

## 1. 项目目标

### 1.1 产品定位

这是一个“四合一”个人效率成长应用，目标不是做单点工具，而是把以下四类能力统一在一个轻量但有质感的移动端产品里：

- `今日`：每日 command center，汇总习惯、计划、专注、复盘的真实状态。
- `计划`：DayMark 风格的长期目标 / 项目 / 分组 / 行动系统。
- `习惯`：HabitDone 风格的成熟轻量 habit tracker。
- `专注`：番茄ToDo 风格的清晰专注计时执行页。
- `复盘`：OffScreen 风格的冷静数据回看页。
- `我的/设置`：主题、强调色、权限/设置入口。

### 1.2 Benchmark 方向

用户明确要求以四个 benchmark app 为方向，但不能复制品牌或照搬界面：

- `HabitDone`：习惯身份、每日打卡、多次打卡、备注、跳过、补打卡、图片证明、热力图、统计、提醒、自定义颜色、生命周期。
- `daymark`：计划层级、项目记录、数值/备注记录、项目统计、日期历史、可编辑项目身份。
- `番茄ToDo`：大视觉计时器、开始/暂停/重置清晰、任务/行动绑定、完成通知、历史记录。
- `OffScreen`：冷静、克制、高级感的数据表达，不做假数据、不做吵闹 dashboard。

### 1.3 当前阶段

项目已经进入真实 `1.0` 测试阶段，并已准备 `1.0.1+11` P0 UX repair phone-test debug APK。

`1.0.1+11` 是修复包，不是新功能大版本，包含：

- Plan edit discoverability 修复。
- Today daily center refinement。
- multi-device responsive layout repair。

---

## 2. 用户给过的所有关键要求

### 2.1 全局硬约束

这些约束在多轮任务中反复出现，新账号必须继续遵守：

- 只有准备新的 phone-test APK 时才更新版本号。
- 普通开发、UI 修补、逻辑修补不更新版本号。
- 未经明确批准，不准备 phone-test APK。
- 不随意新增依赖。
- 不随意改 routing。
- 不改 bottom navigation。
- 不破坏现有 `今日 / 计划 / 专注 / 复盘 / 我的` 五 tab IA。
- 不引入假数据、假趋势、假 analytics。
- 不为了“看起来更强”伪造完成率、趋势、streak、数字健康数据。
- 不自动完成 Plan task，除非用户未来明确设计这种语义。
- 不让 Plan records 影响 task progress。
- 不让 Habit proof / note / skip 影响 completion count。
- 不让 proof image 影响 heatmap/streak/Today count。
- 不让 Focus binding mutate Plan task completion。
- 不混合不同 unit 的 numeric totals。
- 不把图片 bytes/base64 存进 SharedPreferences/JSON。
- 不把普通一键打卡变重。
- 不做 noisy dashboard。
- 不复制 benchmark app 的 branding 或精确布局。

### 2.2 版本规则

版本文件：`pubspec.yaml` 和 `docs/versioning.md`。

规则：

- 只有准备 phone-test APK 才 bump version。
- 当前版本：`1.0.1+11`。
- 已准备 APK：`build\alpha_apks\four_in_one_app_v1.0.1+11_debug.apk`。
- 后续 phone-test 版本应继续为：
  - `1.1.0+12`
  - `1.2.0+13`
  - 以此类推

历史 phone-test 版本记录：

- `0.1.0+1`: first phone test build.
- `0.2.0+2`: second phone test build.
- `0.3.0+3`: Focus notification countdown + custom duration phone test build.
- `0.4.0+4`: Theme customization + Focus notification copy fix phone test build.
- `0.5.0+5`: Settings accent selector fix + HabitDone Habits V1 + DayMark Goals V1 phone test build.
- `0.6.0+6`: Five-tab IA + UI Product Feel V2A + Today/Plan source UI alignment phone test build.
- `0.7.0+7`: Habits/Today/Plan/Focus/Review source UI alignment phone test build.
- `0.8.0+8`: Benchmark Repair + Unified UI Component System prepared state.
- `0.9.0+9`: Deep Plan/Habits benchmark feature parity phone test build.
- `1.0.0+10`: Deep HabitDone + DayMark + Habit→Plan loop phone test build.
- `1.0.1+11`: P0 UX repair phone-test build.

### 2.3 Phone-test APK 规则

准备 APK 时必须：

1. 更新 `pubspec.yaml`。
2. 更新 `docs/versioning.md`。
3. 不改业务/UI/store/routing/dependency/native config，除非任务明确要求。
4. 运行：
   - `flutter analyze --no-pub`
   - `flutter test --no-pub`
   - `flutter build apk --debug --no-pub`
5. 确认 APK badging。
6. 复制 APK 到 `build\alpha_apks\...debug.apk`。

重要坑：`flutter build apk --debug --no-pub` 有时会复用旧 badging。见“踩过的坑”。

### 2.4 iPhone / 苹果安装包要求

用户之前说过：

- “给我一份苹果的安装包”
- “我的设备是苹果手机，苹果11~苹果17”

当前项目运行环境是 Windows / PowerShell，不能直接产出可安装 iOS IPA。后续如果要给 iPhone 安装包，需要：

- macOS 机器。
- Xcode。
- Apple Developer 账号。
- 正确 Bundle ID / signing / provisioning profile。
- 可能通过 TestFlight 或 Ad Hoc 分发。
- 使用 `flutter build ipa` 或 Xcode archive。
- 检查 iOS permissions：
  - `NSPhotoLibraryUsageDescription`
  - `NSCameraUsageDescription`
  - 不需要 microphone，因为项目不做 video capture。

不要在 Windows 上假装已经能产出 iOS 安装包。

---

## 3. 已完成的文件、命令、配置、修改

### 3.1 当前依赖

`pubspec.yaml` 当前关键依赖：

```yaml
version: 1.0.1+11

dependencies:
  flutter_local_notifications: ^21.0.0
  image_picker: ^1.2.1
  path_provider: ^2.1.5
  shared_preferences: ^2.5.5
```

历史确认：

- `image_picker` resolved to `1.2.1`。
- `path_provider` resolved to `2.1.5`。
- 这两个依赖是 Plan/Habit 图片证明功能批准加入的。
- 不要再添加相邻图片依赖，除非用户明确批准。

### 3.2 Native config 当前语义

iOS：

- 已加入 photo library usage description。
- Habit multi-image + camera V4G 后，已加入 camera usage description。
- 不应加入 microphone usage description，因为不支持视频。
- 不应加入 photo library add usage，当前只选择图片/拍照并复制到 app-managed storage。

Android：

- 历史要求是 gallery only 时不加 Android camera/storage permission。
- V4G camera capture 计划要求：只有直接、可复现 blocker 才改 AndroidManifest。
- 当前交接建议：不要随便改 AndroidManifest；先读现有文件确认。

### 3.3 已完成的大功能包

#### Plan / DayMark 方向

已完成：

- Plan Records + Project Statistics V3A。
- Plan Identity Editing V3B。
- Plan Photo Attachment Foundation V3C。
- Plan Photo Attachment Test Hardening。
- Plan Statistics Detail / Heatmap V3D。
- P0 Plan edit discoverability repair。

当前 Plan 支持：

- Goal / Project / Subproject / Task hierarchy。
- Goal title/icon/color/description editing。
- Project title/icon/color/description editing。
- Subproject title editing。
- Task/action title editing。
- Focused goal tree view。
- Task-derived progress rollup。
- Project/action records。
- Note records。
- Numeric records。
- Date-based history。
- Image proof。
- Project statistics bottom sheet。
- Current-month activity/heatmap。
- Habit-linked generated PlanRecords。
- Source chip/copy like `来自习惯`。

关键语义：

- Plan records 不影响 task progress。
- Habit-generated PlanRecord 不自动完成 task。
- Numeric totals 按 unit 分组，不能混合。
- Attachment 只存 metadata + relativePath，不存 base64/bytes。

#### Habits / HabitDone 方向

已完成：

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

当前 Habits 支持：

- HabitItem identity：emoji/custom emoji/name/description/target count/reminder/color。
- Multiple daily check-ins。
- Detailed check-in draft/save semantics。
- Note。
- Skip/no-check。
- Makeup for selected past localDate。
- Multi-image proof，max 3 images per HabitRecord。
- Gallery selection。
- Camera capture。
- Thumbnail grid / preview / remove / replace。
- 7-day activity。
- Current-month heatmap。
- Recent 3-month activity。
- Annual heatmap。
- Current streak / longest streak。
- Pause-aware streak protection。
- Lifecycle：active / paused / archived / deleted。
- Advanced reminder rules：multiple times, weekday rules, enabled switch。
- Habit ↔ Plan link。

核心计数语义：

- Effective check-ins = `checkIn + makeup`。
- Skip 不计 completion。
- Note 不计 completion。
- Proof 不计 completion。
- Proof 不影响 Today count。
- Proof 不影响 heatmap。
- Proof 不影响 streak。
- Makeup 使用 selected localDate，不使用 createdAt。
- Skip outside pause breaks streak。
- Paused days are neutral in pause-aware streak。
- Pause/archive/delete do not delete records/proof images。

#### Habit → Plan loop

已完成：

- HabitPlanLink model。
- Habit can link to Project。
- Habit can link to Task/Action。
- Habit reaching daily target creates one generated PlanRecord.
- Makeup reaching target creates one generated PlanRecord for selected localDate。
- Duplicate prevention via source metadata/sourceKey。
- Skip does not create PlanRecord。
- Note/proof-only changes do not create PlanRecord。
- Linked task is not auto-completed。
- Clearing link does not delete historical generated PlanRecords。
- Changing link does not move old generated PlanRecords。

PlanRecord source metadata：

- `sourceType`
- `sourceId`
- `sourceLocalDate`
- `sourceKey`

#### Focus / 番茄ToDo 方向

已完成：

- Large visual timer center。
- Custom duration。
- Restore after app kill。
- Completed focus history。
- Completion notification path。
- Task/action binding。
- Target snapshot in history。
- No task auto-complete。
- Start/pause/reset clarity。

硬约束：

- 不要碰 Focus logic，除非用户明确要求。
- Habit/Plan linking 不能影响 Focus binding。
- Focus notification IDs 不要被 Habit reminder touched。

#### Review / OffScreen 方向

已完成：

- Real metrics。
- Calm data panels。
- Habit activity summary。
- Plan progress summary。
- Focus completion summary。
- Honest zero states。
- No fake digital wellbeing data。
- Review 在近期 deep packages 中多次要求保持 mostly unchanged，不要过早扩展。

#### Unified UI Components

已完成并持续使用：

- `SoftSurface`
- `MetricTile`
- `MetricStrip`
- `MiniHeatmapCell`
- `ActivityStrip`
- `ProgressRail`
- `PlanGoalCard`
- `PlanTreeRow`
- `HabitIdentityCard`
- `FocusTimerHero`
- `ProductPageHeader`
- `MySettingsSection`

### 3.4 P0 UX Critical Repair Pack 已完成内容

真实设备反馈后完成的 P0 修复：

#### Plan edit discoverability

改过文件：

- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/shared/widgets/product/plan_goal_card.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- `test/goals_flow_test.dart`

修复点：

- Goal card identity 区直接显示 `编辑目标`。
- Goal card helper copy：`标题、图标、颜色和描述都可调整`。
- Focused goal tree sheet 也显示 `编辑目标`。
- Project row 改为更明显的 `编辑项目` tonal action。
- Subproject edit 改为 `编辑分组`。
- Task/action row 从 icon-only 改为 `编辑行动` 文本按钮。
- Plan title/description/metadata 添加 wrap/ellipsis，防止小屏飘字。
- Project stats bottom sheet 增加 360dp responsive test。
- Focused goal tree 增加 360dp responsive test。

#### Today daily center refinement

改过文件：

- `lib/features/today/presentation/pages/today_page.dart`
- `test/today_overview_test.dart`

修复点：

- Today 顶部从固定三列 MVP 卡片，改为真实 daily center：
  - 今日达标。
  - 连续天。
  - 今日记录。
  - 计划推进。
- 窄屏下 hero metrics 改成 compact chips，避免把后续按钮压进 bottom nav。
- Habit summary 加入：
  - 连续天。
  - 今日提醒数量。
  - 近 7 天活动次数。
  - 今日 note/image lightweight signal。
- Plan summary 加入：
  - 今日计划记录。
  - 来自习惯记录。
- Focus summary 加入执行导向 copy/chips，不改 Focus 逻辑。
- Module header 在窄宽度下 stack，避免 `查看全部` 漂移/遮挡。
- Preview row 长中文 text 加 maxLines/ellipsis。

#### Multi-device responsive layout repair

新增/强化测试：

- Today renders at `360dp`, `393dp`, `412dp` with text scale `1.15`。
- Plan edit affordances render at `360dp`, `393dp`, `412dp` with text scale `1.15`。
- Project statistics bottom sheet at `360dp`。
- Focused goal tree bottom sheet at `360dp`。
- Habit statistics sheet already has 360dp coverage。

### 3.5 1.0.1+11 phone-test APK 已完成

改过文件：

- `pubspec.yaml`
- `docs/versioning.md`

运行过命令：

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
flutter build apk --debug --no-pub --build-name=1.0.1 --build-number=11
& 'D:\AI\SDKs\Android\build-tools\36.0.0\aapt.exe' dump badging 'D:\AI\Projects\four_in_one_app\build\app\outputs\flutter-apk\app-debug.apk'
Copy-Item -LiteralPath 'D:\AI\Projects\four_in_one_app\build\app\outputs\flutter-apk\app-debug.apk' -Destination 'D:\AI\Projects\four_in_one_app\build\alpha_apks\four_in_one_app_v1.0.1+11_debug.apk' -Force
```

验证结果：

- `flutter analyze --no-pub`: passed。
- `flutter test --no-pub`: passed，`158` tests。
- `flutter build apk --debug --no-pub`: passed。
- Final badging：
  - `versionName='1.0.1'`
  - `versionCode='11'`

最终 APK：

```text
D:\AI\Projects\four_in_one_app\build\alpha_apks\four_in_one_app_v1.0.1+11_debug.apk
```

---

## 4. 当前项目目录结构

当前根目录：

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
├─ analysis_options.yaml
├─ pubspec.yaml
├─ pubspec.lock
└─ README.md
```

`lib/shared/widgets/product/` 当前文件：

```text
activity_strip.dart
focus_timer_hero.dart
habit_identity_card.dart
metric_strip.dart
metric_tile.dart
mini_heatmap_cell.dart
my_settings_section.dart
plan_goal_card.dart
plan_tree_row.dart
product_page_header.dart
progress_rail.dart
soft_surface.dart
```

`test/` 当前主要测试：

```text
app_settings_store_test.dart
app_smoke_test.dart
focus_flow_test.dart
focus_persistence_test.dart
focus_store_test.dart
goals_attachment_widget_test.dart
goals_flow_test.dart
goals_persistence_test.dart
habits_flow_test.dart
habits_persistence_test.dart
habits_reminder_notifications_test.dart
habit_plan_linking_test.dart
habit_record_attachment_storage_test.dart
habit_statistics_test.dart
plan_record_attachment_storage_test.dart
review_overview_test.dart
settings_theme_test.dart
today_overview_test.dart
```

---

## 5. 重要文件说明

### 5.1 必读项目文档

新账号打开项目后先读：

1. `AGENTS.md`
2. `docs/product_vision.md`
3. `docs/ui_direction.md`
4. `docs/source_ui_reference.md`
5. `docs/visual_gap_audit_v1.md`
6. `docs/ui_reference_components.md`
7. `docs/benchmark_parity_gate_v1.md`
8. `docs/benchmark_parity_roadmap.md`
9. `docs/feature_completion_checklist.md`
10. `docs/versioning.md`
11. `docs/references/app_report_v2.txt`
12. `docs/references/app_content/HabitDone`
13. `docs/references/app_content/daymark`
14. `docs/references/app_content/OffScreen`
15. `docs/references/app_content/番茄ToDo`

### 5.2 App shell / router / theme

- `lib/app/app.dart`
  - App composition。
  - Store injection。
  - Habit ↔ Plan writer/coordinator wiring 可能在这里或相邻 composition 中。
- `lib/app/router/app_router.dart`
  - 路由定义。
  - 不要随意改 routing。
- `lib/shared/widgets/app_shell.dart`
  - Bottom navigation。
  - 当前 tabs：`今日 / 计划 / 专注 / 复盘 / 我的`。
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_theme_tokens.dart`
  - 全局主题、tokens。
  - Habit per-color 不等于 global accent。

### 5.3 Today

- `lib/features/today/presentation/pages/today_page.dart`
  - 今日 command center。
  - 只读。
  - 汇总 Habits/Plan/Focus。
  - P0 修复后已加入真实 summary signal 和 responsive repair。
- `test/today_overview_test.dart`
  - Today overview tests。
  - 含 360/393/412dp + text scale 1.15 responsive coverage。

### 5.4 Plan / Goals

- `lib/features/goals/domain/models/goal_item.dart`
  - GoalItem / ProjectItem / SubprojectItem / GoalTaskItem / PlanRecord / PlanRecordAttachment。
  - PlanRecord source metadata 在这里。
- `lib/features/goals/application/goals_store.dart`
  - Plan hierarchy logic。
  - Project stats。
  - Generated habit-linked PlanRecords。
  - Duplicate prevention sourceKey。
- `lib/features/goals/data/goals_local_storage.dart`
  - Goals local JSON storage。
  - schemaVersion 当前应支持 records/attachments/source metadata。
- `lib/features/goals/data/plan_record_attachment_storage.dart`
  - Plan image copy/storage abstraction。
- `lib/features/goals/presentation/pages/goals_page.dart`
  - Plan UI。
  - Goal edit / Project edit / Project stats / Focused goal tree。
- `lib/shared/widgets/product/plan_goal_card.dart`
  - Goal card visual。
  - P0 后 `编辑目标` 变明显。
- `lib/shared/widgets/product/plan_tree_row.dart`
  - Project/Subproject/Task row。
  - P0 后 `编辑项目` / `编辑分组` / `编辑行动` 都是 visible text action。
- `test/goals_flow_test.dart`
  - Plan end-to-end flow。
  - 包含 edit visibility、project stats、focused goal tree small-width tests。
- `test/goals_persistence_test.dart`
  - Plan storage/migration。
- `test/goals_attachment_widget_test.dart`
  - Plan attachment widget fake tests。
- `test/plan_record_attachment_storage_test.dart`
  - Plan attachment storage fake tests。

### 5.5 Habits

- `lib/features/habits/domain/models/habit_item.dart`
  - HabitItem。
  - HabitLifecycleStatus。
  - HabitPauseInterval。
  - HabitReminderRule。
  - HabitPlanLink。
  - habitColorValue。
- `lib/features/habits/domain/models/habit_record.dart`
  - HabitRecord。
  - Types：checkIn / skip / makeup。
  - Note/localDate/createdAt semantics。
- `lib/features/habits/domain/models/habit_record_attachment.dart`
  - HabitRecordAttachment。
  - Multi-image proof metadata。
- `lib/features/habits/domain/models/habit_statistics_summary.dart`
  - Per-habit stats。
  - Streak。
  - Pause-aware streak protection。
  - Proof/skip/makeup counting rules。
- `lib/features/habits/application/habits_store.dart`
  - Habit business logic。
  - Check-in / detailed record / skip / makeup。
  - Lifecycle。
  - Reminder rules。
  - Attachment metadata。
  - Habit → Plan trigger。
- `lib/features/habits/data/habits_local_storage.dart`
  - Habit snapshot storage/migration。
- `lib/features/habits/data/habit_record_attachment_storage.dart`
  - Habit image proof storage。
  - Gallery/camera source abstraction。
  - Missing file safe state。
- `lib/features/habits/data/habit_reminder_notification_service.dart`
  - Habit local notification scheduling/cancel。
  - Must not touch Focus notification IDs。
- `lib/features/habits/presentation/pages/habits_page.dart`
  - Main Habits UI。
  - Detail record sheets。
  - Proof grid/preview。
  - Statistics sheet。
  - Lifecycle action sheet。
  - Reminder rules sheet。
  - Habit-plan link picker。
- `lib/shared/widgets/product/habit_identity_card.dart`
  - Habit card visual。
  - Per-habit color。
  - Reminder summary。
  - Lifecycle chips。
- Tests：
  - `test/habits_flow_test.dart`
  - `test/habits_persistence_test.dart`
  - `test/habits_reminder_notifications_test.dart`
  - `test/habit_record_attachment_storage_test.dart`
  - `test/habit_statistics_test.dart`
  - `test/habit_plan_linking_test.dart`

### 5.6 Focus

- `lib/features/focus/application/focus_store.dart`
  - Timer state。
  - Persistence。
  - Binding snapshots。
- `lib/features/focus/data/...`
  - Focus persistence/notifications。
- `lib/features/focus/domain/...`
  - Focus history/models。
- `lib/features/focus/presentation/pages/focus_page.dart`
  - Focus UI。
- `lib/shared/widgets/product/focus_timer_hero.dart`
  - Timer hero component。
- Tests：
  - `test/focus_flow_test.dart`
  - `test/focus_persistence_test.dart`
  - `test/focus_store_test.dart`

### 5.7 Review

- `lib/features/review/presentation/pages/review_page.dart`
  - OffScreen-style calm data panels。
  - Historically user要求 Review 不要在多个 feature package 中膨胀。
- `test/review_overview_test.dart`
  - Review summary validation。

### 5.8 Settings / My

- `lib/app/settings/...`
  - App settings store/storage。
- `lib/features/settings/presentation/pages/settings_page.dart`
  - My/settings page。
- `lib/shared/widgets/product/my_settings_section.dart`
- Tests：
  - `test/app_settings_store_test.dart`
  - `test/settings_theme_test.dart`

---

## 6. 已经踩过的坑

### 6.1 Dependency access / pub get

早期 `flutter pub get` 曾经因为访问 `pub.dev` socket error 失败，阻塞 Plan photo attachment V3C。

后来用 Flutter China mirror 恢复：

- `flutter pub get` passed。
- `image_picker` resolved to `1.2.1`。
- `path_provider` resolved to `2.1.5`。

不要因为网络失败就乱换包或改方案。用户明确要求过：

- 如果 pub get 失败，报告 exact error。
- 不改代码。
- 不尝试 alternative packages。
- 停下来等批准。

### 6.2 Flutter SDK sandbox 权限

在当前 Codex desktop sandbox 中，直接运行 Flutter 可能遇到：

```text
CreateFile failed 5 (拒绝访问。)
Flutter failed to run ... analysis_server.dart.snapshot
```

解决：

- 使用 escalated shell command 运行 Flutter analyzer/test/build。
- 这不是代码问题，是 SDK/cache 权限问题。

### 6.3 Android build 需要指定 JAVA_HOME

构建 APK 时使用：

```powershell
$env:JAVA_HOME='D:\AI\Tools\AndroidStudio\android-studio\jbr'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
flutter build apk --debug --no-pub
```

### 6.4 APK badging stale

在 `1.0.1+11` 打包时踩过：

普通命令：

```powershell
flutter build apk --debug --no-pub
```

构建成功，但 `aapt dump badging` 显示旧版本：

```text
versionName='1.0.0'
versionCode='10'
```

解决方式：

```powershell
flutter build apk --debug --no-pub --build-name=1.0.1 --build-number=11
```

然后 badging 正确：

```text
versionName='1.0.1'
versionCode='11'
```

以后 version bump 后要确认 badging，不要只相信 `pubspec.yaml`。

### 6.5 当前目录没有 `.git`

`D:\AI\Projects\four_in_one_app` 当前看起来不是 git repository：

```text
fatal: not a git repository (or any of the parent directories): .git
```

不要依赖 `git diff/status` 作为唯一变更追踪。

如果需要对比文件：

- 用 `Get-Content`。
- 用 `Select-String`。
- 或者确认是否有外部 repo/root。

### 6.6 中文文件要用 UTF-8 读

PowerShell 默认读部分中文文件可能 mojibake。

建议：

```powershell
Get-Content -Encoding UTF8 <path>
```

### 6.7 Today hero 曾经把按钮压进 bottom nav

P0 修复中，Today 顶部 metrics 增强后，窄宽度/默认 test height 下曾把 `today-habits-view-all` 推到底部导航遮挡区，导致 Habits tests 不能 tap。

解决：

- 窄宽度下 hero metrics 使用 compact chips。
- 宽布局才使用 MetricTile row。

不要再把 Today 顶部做成固定大卡片堆叠，容易重现这个问题。

### 6.8 Plan edit 原本“功能有，但用户感知不到”

Goal/Project 编辑功能之前其实存在，但：

- Goal edit 在卡片底部 action row。
- Focused goal tree 没有 Goal edit。
- Task edit 是 icon-only。
- Project edit 跟记录/统计/层级操作混在一起，不够像“身份可编辑”。

用户真实设备反馈仍觉得“名字和图标不能改”，说明可见性失败。

后续做 edit 入口时，不要只放 icon/long press/隐藏菜单。

### 6.9 Habit detailed check-in 语义修过一次

真实设备反馈指出：

- `详细打卡` 不能点了就立即创建 record。
- `补打卡` 不能默认今天。
- `跳过` 不能对已经打卡的日期随便创建。
- Month view 必须能选过去日期。

已修成：

- Detailed check-in draft/save based。
- Makeup targets selected past localDate。
- Future date disabled。
- Skip blocked if effective check-in exists。

不要回退成 instant same-day buttons。

### 6.10 Streak protection 不能 fake

已选择 pause-aware streak with pause intervals：

- Paused days neutral。
- Completed days still only real checkIn + makeup。
- Skip outside pause breaks streak。
- Skip inside pause interval neutral because date is paused。
- No tokens/rewards/badges yet。

不要把 skip 直接当 streak protection token。

### 6.11 Habit proof 不能影响 completion

多轮任务都强调：

- 图片证明是 metadata/evidence。
- 不影响 count。
- 不影响 Today。
- 不影响 Review check-in metrics。
- 不影响 heatmap。
- 不影响 streak。

### 6.12 Habit → Plan 不能 fake task completion

Habit 达标可以生成 PlanRecord 作为 evidence/history。

但不能：

- 自动完成 linked task。
- 改 task progress。
- 生成重复记录。
- 清 link 时删除历史 generated records。

---

## 7. 不要重复做的事情

### 7.1 不要重复做的产品/技术动作

- 不要重新添加 `image_picker` / `path_provider`，已经有。
- 不要再做 Plan one-image attachment foundation，已经做过并测试过。
- 不要再做 Habit one-image proof foundation，已经升级到 max 3 + camera。
- 不要重新设计 Habit skip/makeup semantics，已由 V4A 修过。
- 不要重新添加 annual heatmap/streak foundation，已完成。
- 不要重新添加 lifecycle/pause/archive/delete，已完成。
- 不要重新添加 pause-aware streak intervals，已完成。
- 不要重新添加 advanced reminder rules，已完成。
- 不要重新添加 Habit → Plan link foundation，已完成。
- 不要新增 Review global analytics，用户多次要求 Review 不要过早膨胀。
- 不要改变 Focus logic，除非新反馈明确要求。
- 不要改变 bottom nav/routing。
- 不要让 ordinary habit check-in 变重。
- 不要把 Plan tree 做成桌面式复杂树；必须 phone-readable。
- 不要把 Today 做成假 dashboard。

### 7.2 不要重复踩的发布坑

- 不要只改 `pubspec.yaml` 就认为 APK version 已更新。
- 不要跳过 `aapt dump badging`。
- 不要忘记复制 APK 到 `build\alpha_apks`。
- 不要在非 phone-test 包时 bump version。
- 不要在 Windows 上承诺 iOS IPA。

### 7.3 不要误改的语义

- Plan task progress = task completion only。
- Plan records = evidence/history，不是 progress。
- Habit proof/note/skip 不计 completion。
- Habit makeup 使用 selected localDate。
- Habit skip 不增加 heatmap intensity。
- Habit pause days 不增加 streak，只 neutral。
- Focus binding 不完成 Plan task。
- Generated habit-linked PlanRecord 不完成 Plan task。

---

## 8. 下一步应该怎么做

### 8.1 立刻下一步

当前最自然的下一步不是继续加功能，而是：

1. 把 `1.0.1+11` APK 发给用户做真实手机测试。
2. 收集真实设备反馈。
3. 特别观察：
   - Plan edit 是否终于明显。
   - Today 是否像 daily command center。
   - 360/393/412dp 宽度是否不再飘字/溢出。
   - Habit stats/proof/reminder sheets 是否小屏可用。
   - Habit → Plan generated records 是否被用户理解。
   - 是否仍觉得不如 benchmark app。

### 8.2 如果用户继续要求 iPhone 安装包

不要在 Windows 当前环境里硬做。

建议回复路线：

1. 说明当前环境只能产 Android APK。
2. iPhone 安装包需要 Mac + Xcode + Apple signing。
3. 如果用户有 Mac/Apple Developer：
   - 检查 iOS bundle id。
   - 检查 `ios/Runner/Info.plist` permissions。
   - 运行 `flutter build ipa`。
   - 用 TestFlight 或 Ad Hoc 安装。
4. 如果没有 Apple Developer：
   - 只能走本机开发者调试或 TestFlight 邀请，不能像 APK 一样直接发文件安装。

### 8.3 如果继续 P0/P1 修补

优先级建议：

1. 继续真实设备布局反馈修复。
2. 继续 Plan/Habits high-frequency paths 的 discoverability polish。
3. Today 做更精细但仍真实的数据分层。
4. 检查 iOS-ready 配置。
5. 再考虑下一个 feature。

### 8.4 如果继续功能路线

之前 HabitDone deep roadmap 中，V4H 已完成。可能未来方向：

- Cross-feature Review analytics，但要小心不要 fake。
- Plan archive/lifecycle。
- Plan record advanced filters。
- iOS/TestFlight packaging。
- Export/backup/data management。
- Hard delete strategy for soft-deleted habits，必须先有安全确认/备份思路。

不要直接上 heavy dashboard。

---

## 9. 新账号重新打开项目后，应该先读取哪些文件

请按顺序读：

### 9.1 第一组：工作规则

1. `D:\AI\Projects\four_in_one_app\AGENTS.md`
2. `D:\AI\Projects\four_in_one_app\CODEx_账号切换交接文档.md`
3. `D:\AI\Projects\four_in_one_app\docs\versioning.md`

### 9.2 第二组：产品方向

1. `docs/product_vision.md`
2. `docs/ui_direction.md`
3. `docs/source_ui_reference.md`
4. `docs/visual_gap_audit_v1.md`
5. `docs/ui_reference_components.md`
6. `docs/benchmark_parity_gate_v1.md`
7. `docs/benchmark_parity_roadmap.md`
8. `docs/feature_completion_checklist.md`
9. `docs/references/app_report_v2.txt`

### 9.3 第三组：benchmark reference

1. `docs/references/app_content/HabitDone`
2. `docs/references/app_content/daymark`
3. `docs/references/app_content/OffScreen`
4. `docs/references/app_content/番茄ToDo`

### 9.4 第四组：当前最容易出问题的代码

1. `lib/features/today/presentation/pages/today_page.dart`
2. `lib/features/goals/presentation/pages/goals_page.dart`
3. `lib/shared/widgets/product/plan_goal_card.dart`
4. `lib/shared/widgets/product/plan_tree_row.dart`
5. `lib/features/habits/presentation/pages/habits_page.dart`
6. `lib/shared/widgets/product/habit_identity_card.dart`

### 9.5 第五组：核心语义代码

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

### 9.6 第六组：必须跑的测试

优先：

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

## 10. 当前最后一次已知验证状态

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

## 11. 给新账号 Codex 的接手提醒

你不是从 0 开始。这个项目已经不是“搭壳 MVP”，而是经过大量 benchmark parity 修补的 1.0 测试应用。

接下来最重要的是：

- 保护已有语义。
- 保护用户信任。
- 做真实设备反馈驱动的修补。
- 不要一上来继续狂加功能。
- 不要因为 build passed 就认为 UX passed。
- 不要因为功能存在就认为用户能发现。
- 不要让 benchmark 方向变成 noisy imitation。

这个项目的关键气质是：

```text
HabitDone 的成熟 habit tracking
+ DayMark 的长期计划对象系统
+ 番茄ToDo 的执行清晰度
+ OffScreen 的克制数据表达
= 一个统一但不平庸的四合一效率成长 App
```

继续做的时候，保持这个方向。

