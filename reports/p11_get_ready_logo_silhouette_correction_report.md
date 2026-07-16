# P11 Get Ready logo silhouette correction report

日期：2026-07-16

状态：等待人工视觉批准；本阶段未提交、未推送。

## 1. 为什么仅修正绿色比例仍然失败

上一轮把绿色状态条/圆点调整到 `W/D=1.500`、`H/D=0.500`、`gap/D=0.3125`，但仍保留了近似对称 C 圆弧和高位、外悬的绿色组。比例校正版的下端点归一化约 `(0.907, 0.847)`，而批准参考约为 `(0.520, 0.934)`；状态条中心约 `(1.221, 0.394)`，参考约 `(0.957, 0.644)`；圆点中心约 `(1.221, 0.656)`，参考约 `(1.003, 0.914)`。因此三个内部比例正确并不能锁定完整轮廓。

此前的比较图还混用了不同尺度、背景和颜色，并把完整品牌板缩进侧栏，不能提供有效的像素级视觉判断。本阶段改用 mark-only、同一 `1000 × 1000` 坐标框和相同白底/黑绿配色，并额外提供 50% magenta/cyan 透明叠加。

## 2. 参考裁图

批准源：`.ai_reference\branding\get_ready_2_6_brand_board.png`，`1448 × 1086`，SHA-256 `3A3FC9F7E1CBF7CB03B5AF7913337D36E5ED7714B10D6D7A424BFC8EB021EC47`。

| 裁图 | 输出尺寸 | SHA-256 |
|---|---:|---|
| `reports/p11_get_ready_brand_assets/reference_crops/reference_primary_mark.png` | `840 × 856` | `7BA357434118D69D9772E5AEDD085B2DCED9E6F87648CFB0B92957440A0641ED` |
| `reports/p11_get_ready_brand_assets/reference_crops/reference_construction_mark.png` | `988 × 1008` | `1FEE0417BFA2B4D38B9388F47FC0FBF39DE3618E96CAAD31C8C69FF3A5870DE0` |
| `reports/p11_get_ready_brand_assets/reference_crops/reference_launcher_mark.png` | `608 × 600` | `22997D6B17BC3CD76518DBED054372A4862E7F55B1E3820DF1E5C09604431482` |

裁图只用于审计和比较。生产 SVG、Android vector 与 PNG 没有从参考板裁切或嵌入。

## 3. 圆弧端点：旧值与新值

| 项目 | 被拒绝的比例校正版 | 新重建矢量 | 批准参考 |
|---|---:|---:|---:|
| 上端中心线 | `(0.907, 0.153)` | `(0.924, 0.190)` | `(0.924, 0.181)` |
| 下端中心线 | `(0.907, 0.847)` | `(0.514, 0.934)` | `(0.520, 0.934)` |

新主路径为：

`M675 300 C660 240 552 218 472 226 C326 236 230 351 230 497 C230 637 330 744 460 750`

它使用三个连续三次 Bézier 段、`80` 描边和 round 端点。下端点已收向底部中心，且不与上端点镜像；生产资产不再使用完整圆、字体 glyph 或对称 C 构造。

## 4. 绿色组：旧值与新值

| 项目 | 被拒绝的比例校正版 | 新重建矢量 | 批准参考 |
|---|---:|---:|---:|
| 状态条中心 | `(1.221, 0.394)` | `(0.963, 0.646)` | `(0.957, 0.644)` |
| 圆点中心 | `(1.221, 0.656)` | `(1.008, 0.909)` | `(1.003, 0.914)` |
| 状态条 geometry | `x=594, y=413, 192 × 64, r=32` | `x=583, y=538, 225 × 75, r=37.5` | 光学目标 |
| 圆点 geometry | `cx=690, cy=581, D=128` | `cx=719, cy=735, D=150` | 光学目标 |

新内部比例为 `W/D=1.500`、`H/D=0.500`、`gap/D=47/150≈0.313`。圆点中心相对状态条中心向右 `23.5` units，与参考的轻微光学错位一致。状态条左缘 `583` 与圆点左缘 `644` 均进入圆弧右边界 `715` 内，整个绿色组已下移并嵌入开口。

## 5. 圆弧宽高比与描边比

| 指标 | 比例校正版 | 新重建矢量 | 批准参考 | 新值偏差 |
|---|---:|---:|---:|---:|
| 圆弧宽/高 | `0.820` | `525/605=0.868` | `≈0.868` | `<0.001` |
| 描边/圆弧宽 | `0.188` | `80/525=0.152` | `≈0.145` | `≈0.007` |
| 下端点 | `(0.907,0.847)` | `(0.514,0.934)` | `(0.520,0.934)` | `(0.006,0.000)` |
| 状态条中心 | `(1.221,0.394)` | `(0.963,0.646)` | `(0.957,0.644)` | `(0.006,0.002)` |
| 圆点中心 | `(1.221,0.656)` | `(1.008,0.909)` | `(1.003,0.914)` | `(0.005,0.005)` |

端点、绿色位置与宽高比均在 `0.03` 接受范围内；描边比例偏差在 `0.02` 范围内。

## 6. 更新的矢量与几何源码

SVG master：

- `assets/branding/get_ready_mark.svg`
- `assets/branding/get_ready_mark_dark.svg`
- `assets/branding/get_ready_mark_light.svg`
- `assets/branding/get_ready_mark_monochrome.svg`
- `assets/branding/get_ready_wordmark_horizontal.svg`
- `assets/branding/get_ready_logo_vertical.svg`
- `assets/branding/get_ready_splash_logo.svg`
- `assets/branding/get_ready_notification_mark.svg`

受控生成/Android 几何：

- `tools/branding/GenerateGetreadyAssets.java`
- `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
- `android/app/src/main/res/drawable/ic_launcher_monochrome.xml`
- `android/app/src/main/res/drawable/ic_splash_getready.xml`
- `android/app/src/main/res/drawable/ic_stat_getready.xml`

生成器在写出前验证精确 Bézier path、stroke、归一化端点、绿色尺寸/间距/光学水平错位和接受阈值；检测到旧对称路径或越界坐标会失败。

## 7. 衍生资产再生成

运行 `tools\branding\generate_getready_assets.ps1` 成功，生成并重新解码验证 `42` 张 PNG：

- 8 个 mark 尺寸：`16、24、32、64、128、256、512、1024 px`
- horizontal wordmark 与 dark/light splash
- 5 个 Android density 的标准 launcher 与 round launcher（共 10 张）
- legacy Android splash lockup
- Settings/About 使用并随 APK 打包的 `get_ready_mark_64.png`
- 16 张 P11 proof、3 张 reference crop 与 README 稳定品牌图

Manifest：`assets/branding/generated/get_ready_asset_manifest.json`，SHA-256 `F757D88530CE63C46B5F7B08D907CF4BB2C6692A8CC826C89957BC78418F15CC`。

仓库没有 `web/` 或 `windows/` 平台目录，因此没有创建孤立 favicon 或 Windows 平台资产；这两个平台不被当前仓库声明为发布目标。

## 8. 有效视觉比较证据

| 证据 | 尺寸 | SHA-256 |
|---|---:|---|
| 同尺度并排 `reports/p11_get_ready_brand_assets/get_ready_same_scale_comparison.png` | `2240 × 1240` | `00C59E36DE90DE8D7C0593B8F8F4C6299757DAA274F1FC9B0B3895E80F60D9A7` |
| 50% overlay `reports/p11_get_ready_brand_assets/get_ready_reference_vector_overlay.png` | `1200 × 1280` | `0C0A229FF867B7771CD8FD1EA2BC4180B63E0F1DEB8F43A1BCC422D49E0B372D` |
| Landmark `reports/p11_get_ready_brand_assets/get_ready_landmark_comparison.png` | `2200 × 1360` | `B64412BB01D1AABB7912555A2B18821C78FE5E196D0FD74BF5CDDE96ED79AEE6` |
| Contact sheet `reports/p11_get_ready_brand_assets/get_ready_silhouette_corrected_contact_sheet.png` | `2400 × 1600` | `892191B48031139C424C18C0E6ECC11165B3BC3A139A3BDD97629EA8157F50BD` |
| 小尺寸 `reports/p11_get_ready_brand_assets/get_ready_silhouette_small_size_preview.png` | `2304 × 1900` | `A62730050741841E059D5F14EFD783161F9E71B50DC851DABB6D31F088A8F759` |

人工检查确认：重建轮廓不再呈视觉对称 C；下端点在底部中心附近结束；绿色组没有浮在标志之外；16/24/32 px 下仍能区分圆弧、状态条与圆点。通知 proof 为透明背景、单一 monochrome alpha 轮廓，24 px 和放大像素网格均可读。

## 9. Flutter 验证

| 检查 | 命令 | 结果 |
|---|---|---|
| 定向格式化 | `D:\ai\flutter\bin\dart.bat format test\getready_brand_assets_test.dart` | 仅格式化 1 个已改 Dart 测试文件 |
| Analyze | `D:\ai\flutter\bin\flutter.bat analyze` | 通过，`No issues found!` |
| 完整测试 | `D:\ai\flutter\bin\flutter.bat test` | `251/251` 通过 |
| Debug APK | `D:\ai\flutter\bin\flutter.bat build apk --debug` | 通过；未构建 release APK/AAB |
| Diff whitespace | `git diff --check` | 通过；无 whitespace error |

构建只报告 Flutter/Kotlin Gradle Plugin 的未来迁移 warning；它不影响当前 debug 构建，也不是本次品牌阻塞项。

## 10. Debug APK 与打包资源

- 路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 大小：`154,634,625` 字节（约 `147.47 MiB`）
- SHA-256：`BF2F87146F34FBC084C6FD4375418207A19F94A29D3A86849E6FFEE434824C8D`
- `zipalign -c -P 16 -v 4`：通过
- `apksigner verify --verbose --print-certs`：通过；Android Debug，v2 签名

APK 内逐项确认：

- 5 个 density 的标准/round launcher PNG 全部存在，且与再生成源码逐字节 SHA-256 相等；
- adaptive foreground 编译 pathData 为新不对称圆弧与 `225 × 75 / D150` 等比坐标；
- Android 13+ monochrome/themed 资源存在并包含同一不对称轮廓；
- Android 12+ splash `ic_splash_getready` 包含同一新 path，`LaunchTheme` 编译资源引用该 drawable；
- legacy splash PNG 存在并与源文件 SHA-256 相等；
- notification `ic_stat_getready` 使用 `M16.693…` 不对称圆弧、`6 × 2` 状态条和 `D4` 圆点，透明背景、纯白 alpha geometry；
- Flutter Settings/About 的 `assets/flutter_assets/assets/branding/generated/get_ready_mark_64.png` 存在并与源文件 SHA-256 相等。

## 11. 名称、版本、package 与权限证明

`aapt dump badging/permissions` 确认：

- application label：`Get Ready`
- package：`com.example.four_in_one_app`
- versionName：`2.6.0`
- versionCode：`18`
- min SDK：`24`
- target/compile SDK：`36 / 36`

Debug APK 权限集合保持 P9 已接受值：

- `android.permission.INTERNET`（debug/profile Flutter tooling）
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.VIBRATE`
- `com.example.four_in_one_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

没有新增 camera、microphone、location、contacts、SMS、phone、broad storage、exact alarm 或 foreground service 权限。版本、package ID、Stores、schema、导航、交互和功能均未修改。

## 12. Git 与设备边界

- 本阶段没有 stage、commit、push、tag、release、PR、merge、rebase、stash、reset、restore 或 Git metadata 修改。
- 当前分支仍为 `p7-ui-foundation`，HEAD 为阶段开始即存在的 `e2f89b5fc395bbeceeb32264d8db25936797327c`；cached diff 为空，`.git/index.lock` 不存在。
- 本阶段没有运行 Stitch，也没有重做品牌方向。
- `adb devices -l` 没有列出 Android 设备；launcher mask、themed icon、Android 12 splash、状态栏通知图标和 OEM 行为仍需物理 Android 设备复核。
- 在用户视觉批准 `get_ready_silhouette_corrected_contact_sheet.png` 前，不应提交或推送本阶段修改。

## 13. 视觉批准入口

主批准图：`reports/p11_get_ready_brand_assets/get_ready_silhouette_corrected_contact_sheet.png`

建议同时查看：

1. `get_ready_same_scale_comparison.png`
2. `get_ready_reference_vector_overlay.png`
3. `get_ready_landmark_comparison.png`
4. `get_ready_silhouette_small_size_preview.png`
5. `get_ready_notification_preview.png`

最终状态：ready for visual review；尚未发布。
