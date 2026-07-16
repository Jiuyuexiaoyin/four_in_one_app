# P11 旧品牌清理记录

日期：2026-07-16

范围：P10 三步标记、小写 `getready` 生产资产、Android 品牌资源及其引用。P10 报告和 proof 作为历史证据保留。

## 1. 被取代的旧生产资产

以下 P10 SVG production masters 已删除：

- `assets/branding/getready_mark.svg`
- `assets/branding/getready_mark_dark.svg`
- `assets/branding/getready_mark_light.svg`
- `assets/branding/getready_mark_monochrome.svg`
- `assets/branding/getready_wordmark_horizontal.svg`
- `assets/branding/getready_logo_vertical.svg`
- `assets/branding/getready_splash_logo.svg`
- `assets/branding/getready_notification_mark.svg`

以下 P10 generated production files 已删除：

- `assets/branding/generated/getready_mark_1024.png`
- `assets/branding/generated/getready_mark_512.png`
- `assets/branding/generated/getready_mark_256.png`
- `assets/branding/generated/getready_mark_128.png`
- `assets/branding/generated/getready_mark_64.png`
- `assets/branding/generated/getready_wordmark_horizontal.png`
- `assets/branding/generated/getready_splash_dark.png`
- `assets/branding/generated/getready_splash_light.png`
- `assets/branding/generated/getready_asset_manifest.json`

这些文件均已由严格 `get_ready_*` 路径的新 open-arc/status/dot production assets 取代。当前 `assets/branding/` 与 `assets/branding/generated/` 不再保留旧三步生产文件。

## 2. 新生产资产

新 SVG masters：

- `get_ready_mark.svg`
- `get_ready_mark_dark.svg`
- `get_ready_mark_light.svg`
- `get_ready_mark_monochrome.svg`
- `get_ready_wordmark_horizontal.svg`
- `get_ready_logo_vertical.svg`
- `get_ready_splash_logo.svg`
- `get_ready_notification_mark.svg`

新 raster 采用 `get_ready_*` 命名，包含 1024、512、256、128、64、32、24 px mark、horizontal wordmark、dark/light splash 和新的 manifest。

## 3. Android 更新引用

以下稳定 Android resource ID 被保留，但视觉内容已替换为 open arc + status bar + readiness dot：

- `@mipmap/ic_launcher`
- `@mipmap/ic_launcher_round`
- `@drawable/ic_launcher_foreground`
- `@drawable/ic_launcher_monochrome`
- `@drawable/ic_splash_getready`
- `@drawable/getready_splash_brand`
- `@drawable/ic_stat_getready`

稳定内部 resource 名中的小写 `getready` 属于 Android 技术标识，不是用户可见品牌名。保留这些名称避免不必要的资源迁移风险。

Android 可见应用名已改为 `Get Ready`。Android 颜色资源已替换为：

- `#111111`
- `#16A34A`
- `#6B7280`
- `#E5E7EB`
- `#F6F7F8`

Adaptive foreground 不包含圆角 tile；`#111111` 由独立 background layer 提供。Android 13 monochrome layer 仅含单色新标志。Android 12+ splash 仅含 mark；legacy splash 使用新 vertical lockup。

## 4. 通知兼容资源

`android/app/src/main/res/drawable/ic_stat_checkin.xml` 被保留。它是 P9 的圆环/打勾状态图标，不是 P10 三步标记；保留它可兼容升级前已序列化的旧通知请求。

`raw/keep.xml` 现在同时保护：

- `@drawable/ic_stat_getready`：当前新品牌通知图标
- `@drawable/ic_stat_checkin`：P9 兼容 fallback

通知渠道 ID、调度、权限、receiver 和 deep-link 行为未由本品牌资源批次修改。

## 5. 保留的历史证据

以下内容有意保留，不是生产应用品牌资产：

- `reports/p10_getready_brand_audit.md`
- `reports/p10_getready_geometry_spec.md`
- `reports/p10_getready_brand_integration_report.md`
- `reports/p10_getready_brand_assets/`

P11 的 `reports/p11_get_ready_brand_assets/old_vs_new_brand_comparison.png` 是唯一新生成、明确展示旧三步标记与小写 `getready` 的 proof。旧图仅用于对比，绝不作为 launcher、Splash、通知、About 或 README hero 的生产来源。

## 6. 生成工具处理

保留并升级了项目内工具：

- `tools/branding/generate_getready_assets.ps1`
- `tools/branding/GenerateGetreadyAssets.java`
- `tools/branding/README.md`

工具文件名是稳定技术标识。Java renderer 已切换到新的 `get_ready_*` masters、P11 输出目录和批准颜色，并增加受控 `path`/`circle` 支持。旧三步仅由 `createOldVsNewComparison` 的 proof-only 绘制函数产生；所有 production 输出均来自新 SVG masters。

## 7. 引用和扫描证据

清理后对 `assets/branding/` 与 `android/app/src/main/res/` 执行精确文本扫描，未发现：

- `step-top`、`step-middle`、`step-bottom`
- P10 三步坐标 `(500,275)`、`(350,445)`、`(200,615)`
- P10 色值 `#0D1117`、`#1A1F28`、`#22C55E`、`#F1F3F5`

对 Flutter/Android 可见字符串执行扫描，未发现：

- `title: 'getready'`
- `semanticsLabel: 'getready'`
- `<string name="app_name">getready</string>`
- 旧标语 `一步一个脚印，持续前进`
- 旧 About 版本 `1.1.5+17`

历史报告和 `old_vs_new_brand_comparison.png` 中的旧名称/图形属于有意保留的审计证据，不计入用户可见应用品牌。

## 8. 结论

当前 production branding 已由 P10 三步 mark 完整切换为 Get Ready 2.6 的右向开放圆弧、绿色状态条和绿色就绪圆点。没有用户可见应用资源继续使用旧三步视觉。
