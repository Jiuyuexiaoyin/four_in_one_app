# P11 Get Ready 2.6.0 预变更审计

审计日期：2026-07-16（Asia/Shanghai）
仓库：`D:\ai\projects\four_in_one_app`
阶段：`P11-GET-READY-2.6.0-REBRAND-REPOSITORY`

本报告记录任何 P11 源码、资源或文档变更之前的仓库事实。工作区已经包含尚未提交但有 P8、P9、P10 报告和测试证据支撑的应用改动；P11 不回退、不覆盖这些用户已有工作，而是在安全审查后将属于发布范围的内容纳入 release consolidation commit。

## 1. 当前版本与构建号

- `pubspec.yaml`：`version: 1.1.5+17`。
- 当前用户可见版本名：`1.1.5`。
- 当前 Android 构建号：`17`。
- `android/app/build.gradle.kts` 通过 `flutter.versionName` 和 `flutter.versionCode` 解析版本，没有额外手工版本常量。
- `android/local.properties` 与 iOS 生成配置中的 `1.1.5/17` 属本地生成缓存，不应手工修改或提交。
- 因当前构建号确为 17，P11 目标按要求为 `2.6.0+18`，无需启用“当前已为 18 或更高时再加一”的例外规则。

## 2. 当前用户可见名称

| 表面 | P11 前值 | 来源 |
| --- | --- | --- |
| Android 应用标签 | `getready` | `android/app/src/main/res/values/strings.xml` |
| Flutter `MaterialApp.title` | `getready` | `lib/app/app.dart` |
| Settings/About 品牌名与语义标签 | `getready` | `lib/features/settings/presentation/pages/settings_page.dart` |
| Settings/About 版本 | `1.1.5+17` | 同上，当前为硬编码显示值 |
| Settings/About 标语 | `一步一个脚印，持续前进` | 同上 |
| iOS Display Name | `Four In One App` | `ios/Runner/Info.plist` |
| README 标题 | `four_in_one_app` | `README.md` |
| pubspec 描述 | `Four-in-one productivity growth app.` | `pubspec.yaml` |

仓库不存在 `web/` 和 `windows/` 平台目录，因此当前没有可更新的 Web title/manifest/favicon 或 Windows runner 可见标题。内部技术标识 `four_in_one_app`、Kotlin/Dart 标识和资源文件名不等同于用户可见品牌。

## 3. 当前包身份

- Android namespace：`com.example.four_in_one_app`。
- Android application ID：`com.example.four_in_one_app`。
- 两者均定义于 `android/app/build.gradle.kts`，必须保持不变。
- 当前 Kotlin 包路径与该身份一致。

## 4. 当前旧品牌与三步标记引用

P10 当前生产品牌是“三条等宽圆角台阶 + 小写 getready”，与本次批准的开口圆弧/状态条/圆点身份冲突。主要引用如下：

- `assets/branding/getready_mark*.svg`：三步主标记及明暗/单色变体。
- `assets/branding/getready_wordmark_horizontal.svg`、`getready_logo_vertical.svg`、`getready_splash_logo.svg`：小写连续 `getready` 组合。
- `assets/branding/generated/getready_*.png`：P10 三步标记、字标和启动图栅格。
- `android/app/src/main/res/drawable/ic_launcher_foreground.xml`：三步自适应前景。
- `android/app/src/main/res/drawable/ic_launcher_monochrome.xml`：三步 themed icon。
- `android/app/src/main/res/drawable/ic_splash_getready.xml` 与 `drawable-nodpi/getready_splash_brand.png`：三步启动图。
- `android/app/src/main/res/drawable/ic_stat_getready.xml`：三步通知状态图标，当前被运行时代码和 `raw/keep.xml` 引用。
- 五组 `mipmap-*/ic_launcher*.png`：三步 launcher/round launcher。
- `lib/features/settings/presentation/pages/settings_page.dart`：三步 64 px 图片、小写字标、旧标语和旧版本。
- `pubspec.yaml`：声明 P10 64 px 品牌资源。
- `tools/branding/GenerateGetreadyAssets.java` 与 PowerShell 入口：生成 P10 三步生产资源和 P10 proof sheets。
- `test/getready_brand_assets_test.dart`：当前明确断言三步几何、小写品牌和 `1.1.5+17`。

P10 历史报告和 proof sheets 会作为“旧品牌事实”保留；它们不是 P11 生产资源。P11 必须确保应用实际引用、当前文档标题和新 proof labels 使用 `Get Ready`。

## 5. 当前 launcher / adaptive / themed icon

- 标准 launcher：mdpi 48 px、hdpi 72 px、xhdpi 96 px、xxhdpi 144 px、xxxhdpi 192 px；视觉内容为 P10 三步标记。
- Round launcher：同五密度资源已存在且为 P10 三步标记。
- Adaptive icon：`mipmap-anydpi-v26/ic_launcher.xml` 与 `ic_launcher_round.xml`，背景色资源 + 独立前景矢量。
- Android 13+ themed icon：`mipmap-anydpi-v33/` 两个资源包含 `<monochrome>`，当前单色内容仍为三步标记。
- Manifest 继续使用稳定资源名 `@mipmap/ic_launcher` 和 `@mipmap/ic_launcher_round`；P11 可保留资源名而替换视觉内容。

## 6. 当前通知图标与通知身份

- 当前运行时小图标技术名：`ic_stat_getready`。
- `ic_stat_getready.xml` 是透明背景上的纯白三步标记，`raw/keep.xml` 保留它。
- `ic_stat_checkin.xml` 是 P9 圆环/勾选图标，目前仅作为历史兼容资源保留，不是新调度的默认图标。
- 稳定渠道 ID 为 `habit_reminders_v1` 与 `focus_completion_v1`，可见名称分别为 `习惯提醒` 与 `专注完成`；P11 不改渠道 ID。
- 通知系统归属名称来自 Android `app_name`，当前显示小写 `getready`。
- P9 已接受的主 Manifest 权限声明为 `POST_NOTIFICATIONS` 与 `RECEIVE_BOOT_COMPLETED`；依赖合并增加 `VIBRATE`，debug 变体增加 `INTERNET`。

## 7. 当前 splash 资产

- Android 11 及以下：base/v21 `launch_background.xml` 使用深色背景和 `drawable-nodpi/getready_splash_brand.png`，图片内容为三步标记 + 小写字标。
- Android 12+：`values-v31` 与 `values-night-v31` 使用 `ic_splash_getready.xml`，内容为三步 mark-only。
- 当前没有额外 Flutter 首帧延迟或加载流程；P11 必须继续避免人工延迟与白闪。

## 8. 当前 README 与支持文档质量

- `README.md` 仅 59 字节，只有仓库技术名标题和一行英文描述，不足以承担产品、架构、权限、运行、测试、隐私和质量说明。
- 根目录不存在 `CHANGELOG.md`。
- 不存在 `docs/BRAND.md`、`docs/ARCHITECTURE.md`、`docs/ANDROID_NOTIFICATIONS.md` 或 `docs/screenshots/README.md`。
- P8 系统 QA、P9 权限通知、P10 品牌报告提供可复用事实；P8 有 Today/Habits/Plan/Focus/Review/Settings 截图，P10 有旧品牌 proof sheets。
- 最近证据：P8 全量 183 tests；P9 全量 239 tests；P10 全量 247 tests。P11 必须以本阶段重新运行的实际结果为最终测试数，不能直接沿用历史数字。

## 9. 当前修改和未跟踪文件

### 已跟踪且已修改（49 个）

- Android：`AndroidManifest.xml`、`MainActivity.kt`、两份 legacy splash XML、五份标准 launcher PNG、`android/gradle.properties`。
- Flutter 应用：`lib/app/` 下 app/router/settings/theme 文件；Focus、Goals、Habits、Review、Settings、Today 的现有实现；`lib/main.dart`；AppShell 与 product widgets。
- 清单：`pubspec.yaml`、`pubspec.lock`。
- 测试：现有 smoke、Focus、Goals、Habits、Review、Settings、Today 测试文件。

完整文件名已由审计时的 `git diff --name-only` 记录；这些差异主要对应尚未提交的 P8/P9/P10 应用工作。

### 未跟踪项目内容（按目录/职责归组）

- P9/P10 Android 资源：`drawable-nodpi/`、launcher foreground/monochrome/splash/notification vectors、adaptive/themed icon XML、round launcher PNG、`raw/keep.xml`、颜色/字符串/v31 styles。
- P9 应用实现：`lib/core/`、Settings 通知权限 widget。
- P8 UI 组件：`lib/shared/widgets/stitch_exact/`、`lib/shared/widgets/visual_dna/`。
- P8/P9/P10 自动化测试：Android manifest、权限、通知、系统同步、品牌等新增测试。
- 品牌与生成工具：`assets/`、`tools/`。
- 设计/QA/权限/品牌证据：`reports/`。
- 本地浏览器诊断数据：`.playwright-mcp/`（不得提交）。

`.ai_reference/` 当前通过 `.git/info/exclude` 排除；`build/` 与 `.dart_tool/` 已由 `.gitignore` 排除。P11 仍需把 `.ai_reference/` 和本地浏览器数据写入仓库级 `.gitignore`，使安全边界可复现。

## 10. 可安全纳入本次 consolidation commit 的文件

在完成 P11 修改、验证和 staged review 后，下列类别属于用户明确要求的发布范围：

- P8 已接受的 UI、交互、同步实现与测试；
- P9 Android 权限、通知实现、资源、测试和报告；
- P10 历史品牌实现/报告中仍作为迁移证据或被 P11 安全覆盖的文件；
- P11 Flutter/iOS 可见命名、版本、Android 新品牌资源、矢量主文件、可复现生成工具；
- P11 更新后的品牌测试与其他未削弱的测试；
- README、CHANGELOG、docs、稳定截图、P11 报告与 proof assets；
- `.gitignore` 的安全排除规则。

任何既有改动只有在 staged diff 与发布目标一致、没有秘密或意外大文件时才会提交。

## 11. 必须保持排除的文件

- `.ai_reference/` 及批准参考板原图；
- `.playwright-mcp/`、浏览器 profile、临时网页和诊断状态；
- `build/`、`.dart_tool/`、Pub/Gradle/Flutter/Android SDK 缓存；
- `android/local.properties`、生成的 iOS/Flutter 本地配置；
- `app-debug.apk` 和任何 release APK/AAB；
- `.env`、认证文件、token、密钥、签名材料和本地 Codex 配置；
- Android SDK、Flutter SDK、Gradle cache 或任何仓库外运行时文件。

## 12. 分支、远端与差异状态

- 当前分支：`p7-ui-foundation`。
- 上游：`origin/p7-ui-foundation`。
- 当前 HEAD：`394b5eb`（`Bump version to 1.1.5+17`），审计时本地分支与已配置上游无 ahead/behind 标记。
- 远端：`origin https://github.com/Jiuyuexiaoyin/four_in_one_app.git`（fetch/push）。
- `git diff --check`：exit 0；仅报告现有 LF→CRLF 转换提示，没有 whitespace error。
- `git diff --stat`：49 个已跟踪文件，7031 insertions、5189 deletions；二进制 launcher 资源另计。
- 最近 10 条提交已审阅；本阶段不改历史提交、不合并 main、不 rebase、不 force-push。

## 13. 最窄安全实施路径

1. 建立 `Get Ready` 命名清单和新开口圆弧/状态条/圆点几何规范。
2. 就地替换稳定技术资源名的视觉内容，保持包 ID、渠道 ID、权限、Stores、模型、持久化、路由和功能行为不变。
3. 只更新必要 Dart 品牌呈现和对应契约测试，不进行无关重构。
4. 生成并人工检查生产 PNG、Android 资源和 P11 proof sheets。
5. 重写 README/支持文档，复制稳定截图而非引用临时 Playwright 路径。
6. 按用户指定命令验证；只格式化 P11 修改的 Dart 文件。
7. 显式暂存发布范围，审查 secrets/大文件/缓存，再由主代理提交和非强制推送当前分支。

预变更审计结论：`P11_PRECHANGE_AUDIT_COMPLETE`
