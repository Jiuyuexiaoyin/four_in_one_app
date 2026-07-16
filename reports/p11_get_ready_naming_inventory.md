# P11 Get Ready 命名清单

日期：2026-07-16
最终用户可见品牌名：`Get Ready`

## 强制规则

- 所有当前用户可见产品名称统一为 `Get Ready`。
- 必须保留大写 `G`、大写 `R` 和中间一个可见空格。
- 禁止在当前应用界面、系统标签、当前文档标题、proof labels 中使用 `getready`、`GetReady`、`get ready` 或 `GET READY`。
- 技术标识可保持稳定：Dart package、Android package/application ID、Kotlin package、资源名、文件名、类名、key、通知渠道 ID、路由 key。
- 历史 P8/P9/P10 报告中的旧名称是审计证据，不代表当前品牌，不做伪造式历史重写。

## 发现的旧可见名称与替换

| 表面 | P11 前值 | P11 目标 | 实施位置 |
| --- | --- | --- | --- |
| Android launcher / 系统应用标签 | `getready` | `Get Ready` | `android/app/src/main/res/values/strings.xml` |
| Flutter window/application title | `getready` | `Get Ready` | `lib/app/app.dart` |
| Settings/About 字标 | `getready` | `Get Ready` | `lib/features/settings/presentation/pages/settings_page.dart` |
| Settings/About 图片语义 | `getready 标志` | `Get Ready 标志` | 同上 |
| Settings/About 组合语义 | `getready` | `Get Ready` | 同上 |
| Settings/About 标语 | `一步一个脚印，持续前进` | `随时准备，迎接每一次机会。` | 同上 |
| Settings/About 版本 | `版本 1.1.5+17` | `版本 2.6.0` | 同上 |
| iOS Display Name | `Four In One App` | `Get Ready` | `ios/Runner/Info.plist` |
| README 标题 | `four_in_one_app` | `Get Ready` | `README.md` |
| README 产品描述 | `Four-in-one productivity growth app.` | Get Ready 本地优先生产力产品描述 | `README.md` |
| pubspec 描述 | `Four-in-one productivity growth app.` | Get Ready 本地优先生产力产品描述 | `pubspec.yaml` |
| 生产 SVG title/desc | `getready` / 三步描述 | `Get Ready` / 开口圆弧、状态条、圆点描述 | `assets/branding/*.svg` |
| 生产横向/竖向字标 | 连续小写 `getready` | 分词且首字母大写 `Get Ready` | 品牌 SVG 与生成 PNG |
| legacy splash 字标 | 连续小写 `getready` | `Get Ready` | `drawable-nodpi` 生成图 |
| P11 proof sheet 标题 | P10 小写 `getready ...` | `Get Ready ...` | `reports/p11_get_ready_brand_assets/` |
| 生成器控制台/当前说明标题 | 小写产品称呼 | `Get Ready` | `tools/branding/`；技术文件名可保留或迁移 |
| 当前品牌/架构/通知文档标题 | 不存在或旧仓库技术称呼 | `Get Ready` | `docs/BRAND.md`、`docs/ARCHITECTURE.md`、`docs/ANDROID_NOTIFICATIONS.md` |

## 通知命名决策

- 通知归属应用名随 Android `app_name` 变为 `Get Ready`。
- 渠道显示名 `习惯提醒`、`专注完成` 已准确描述功能，无旧产品名，不改。
- 渠道 ID `habit_reminders_v1`、`focus_completion_v1` 是稳定技术标识，保持不变。
- 小图标资源名 `ic_stat_getready` 可作为兼容技术名保留，但其视觉内容必须换为新 mark。

## 平台适用性

- Android：适用，必须更新。
- Flutter 应用层：适用，必须更新。
- iOS：存在可见 Display Name，安全更新；bundle identifier/name 不变。
- Web：仓库无 `web/` 目录，当前无 title、manifest 或 favicon 可更新；不为命名目的生成整个平台。
- Windows：仓库无 `windows/` 目录，当前无 runner metadata 可更新；不阻塞 Android 发布。

## 允许保留的内部名称

- `four_in_one_app` Dart package、repository 名称和 import 路径。
- `com.example.four_in_one_app` Android namespace/application ID。
- `_GetreadyAboutSection`、`getready-about-row` 等内部类名或 widget key（如不改名更安全）。
- `ic_stat_getready`、`ic_splash_getready` 等 Android resource identifiers。
- P10 历史报告路径及其对旧 `getready` / 三步品牌的事实描述。
- 依赖版本 `image_picker_android: ^0.8.13+17` 中的 `+17`；它不是应用 build number。

命名清单结论：`GET_READY_NAMING_RULES_ESTABLISHED`
