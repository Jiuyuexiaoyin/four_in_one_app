# P11 Get Ready logo geometry correction report

> **已被轮廓锁定阶段取代。** 本报告记录的是随后被视觉审查拒绝的“仅比例校正”批次；其中对称圆弧、共享水平中心与 `192 × 64 / D128` 坐标不再代表当前生产资产。当前几何、证据与验证结果以 `reports/p11_get_ready_logo_silhouette_correction_report.md` 为准。

日期：2026-07-16

## 1. 范围与结论

本批次只校正 Get Ready 标志中绿色状态条与就绪圆点的几何比例。开放圆弧的路径、`110°` 右侧开口、描边宽度、黑/白用色和 Brand green `#16A34A` 均保持不变；没有修改应用功能、导航、Stores、持久化 schema、Android 权限、package ID 或版本。

校正后的生产几何满足批准范围，并已重新生成全部衍生品牌资产。Flutter analyze、完整测试与 debug APK 构建均通过；APK 内的 launcher、adaptive、themed、splash、notification 和 Flutter Settings/About 资源已逐项验包。资产尚未 commit 或 push，等待 contact sheet 的人工视觉批准。

## 2. 批准参考来源

- 本地参考板：`.ai_reference/branding/get_ready_2_6_brand_board.png`
- 尺寸：`1448 × 1086`
- SHA-256：`3A3FC9F7E1CBF7CB03B5AF7913337D36E5ED7714B10D6D7A424BFC8EB021EC47`
- 边界：参考板保持 Git 忽略，只作为几何比较输入；生产资产没有从参考板裁切、采样或嵌入。

参考板实测：

| 样本 | 状态条 | 圆点 | `W/D` | `H/D` | `gap/D` |
| --- | ---: | ---: | ---: | ---: | ---: |
| 主标志 | `65 × 22 px` | `≈44 px` | `≈1.477` | `≈0.500` | `≈0.318` |
| 构造图 | `71 × 25 px` | `48 px` | `≈1.479` | `≈0.521` | `≈0.271` |
| 深色 App 图标 | `30 × 11 px` | `20 px` | `1.500` | `0.550` | `0.300` |

生成器在制作对比 proof 前验证参考板 SHA-256 与尺寸，并以完整 `4:3` 画面等比缩放展示，不裁切。

## 3. 几何校正

1000-unit 生产母稿：

| 项目 | 校正前 | 校正后 |
| --- | ---: | ---: |
| 状态条 | `x=575, y=405, 230 × 80, r=40` | `x=594, y=413, 192 × 64, r=32` |
| 圆点 | `cx=640, cy=610, D=88` | `cx=690, cy=581, D=128` |
| 状态条宽 / 圆点直径 | `2.614` | `1.500` |
| 状态条高 / 圆点直径 | `0.909` | `0.500` |
| 边缘垂直间距 / 圆点直径 | `0.920` | `0.3125` |
| 水平中心 | 相差 `50` units | 同为 `x=690` |

最终值落在要求的 `W/D=1.45–1.60`、`H/D=0.48–0.55`、`gap/D=0.25–0.35` 内。状态条现在是紧凑状态信号，不再像长减号；圆点具有明确视觉重量，不再像微小标点。

Android notification optical master 采用 `24 × 24` viewport：状态条 `6 × 2`、圆点直径 `4`、共享中心 `x=17`、边缘间距 `1.2`，即 `W/D=1.500`、`H/D=0.500`、`gap/D=0.300`。背景透明，几何为纯白 alpha mask，没有方形底、绿色、渐变或阴影。

## 4. 更新的矢量与 Android 源资源

已更新全部受控矢量母稿：

- `assets/branding/get_ready_mark.svg`
- `assets/branding/get_ready_mark_dark.svg`
- `assets/branding/get_ready_mark_light.svg`
- `assets/branding/get_ready_mark_monochrome.svg`
- `assets/branding/get_ready_wordmark_horizontal.svg`
- `assets/branding/get_ready_logo_vertical.svg`
- `assets/branding/get_ready_splash_logo.svg`
- `assets/branding/get_ready_notification_mark.svg`

已同步更新：

- Android adaptive foreground
- Android themed/monochrome icon
- Android 12 splash vector
- Android notification vector
- 五个 density 的标准与 round launcher PNG
- legacy Android splash PNG
- Settings/About 使用的 `get_ready_mark_64.png`
- horizontal wordmark、dark/light splash 与全部 mark PNG
- README 稳定品牌图

仓库不存在 `web/` 平台目录或 Web favicon，因此没有创建孤立 favicon，也没有为本次几何校正生成整个平台目标。

## 5. 生成器与输出

`tools/branding/GenerateGetreadyAssets.java` 现在会在写出资产前数值校验每个 SVG 组合中的状态条/圆点尺寸、胶囊半径、共享水平中心和归一化间距；越界会立即失败。生成命令：

```powershell
.\tools\branding\generate_getready_assets.ps1
```

结果：`34` 张经过重新解码验证的 sRGB PNG，4× supersampling，透明像素 RGB 清零；manifest 记录 8 个矢量 source 与 34 个 output。

新增或专门更新的视觉复核文件：

| 文件 | 尺寸 | SHA-256 |
| --- | ---: | --- |
| `reports/p11_get_ready_brand_assets/get_ready_geometry_before_after.png` | `3200 × 1800` | `011BF633C2209B0DDF6F10952D5E89BE57B191A6AA902F09892BD27F42FF0221` |
| `reports/p11_get_ready_brand_assets/get_ready_corrected_small_size_preview.png` | `2304 × 1900` | `90F2D26430D3E13CE997506CDDC8069868505718813E5801A2DBF2A2EB6906A0` |
| `reports/p11_get_ready_brand_assets/get_ready_corrected_contact_sheet.png` | `2400 × 1600` | `F9D81D170CA05AF522C2593D3382C99CDA4F21710C7478A210E8C63DCE360FB2` |
| `docs/screenshots/get_ready_branding.png` | `2400 × 1600` | `F9D81D170CA05AF522C2593D3382C99CDA4F21710C7478A210E8C63DCE360FB2` |
| `assets/branding/generated/get_ready_mark_16.png` | `16 × 16` | `7D09BF778CD9BF929A1B18C5FC08C62FBF7470D95E3E7AB17FBDC25F8B469DFC` |

小尺寸 proof 同时覆盖 `16、24、32、64、128、256、512、1024 px`，其中 `16、24、32 px` 另有 nearest-neighbor 像素诊断。通知 proof 同时展示原生 `24 × 24` 状态栏比例、通知卡片模拟和 14× alpha 网格诊断。

生产 SVG 与 Android 源资源的精确旧坐标扫描没有发现 `230 × 80 / D88` 长条版本；旧几何只保留在明确标注为 “Before” 的校正证明绘制逻辑中，不被应用或平台资源引用。

## 6. Flutter 验证

| 检查 | 命令 | 结果 |
| --- | --- | --- |
| Analyze | `D:\ai\flutter\bin\flutter.bat analyze` | 通过，`No issues found!` |
| 完整测试 | `D:\ai\flutter\bin\flutter.bat test` | `251/251` 通过 |
| Debug APK | `D:\ai\flutter\bin\flutter.bat build apk --debug` | 通过 |

测试已覆盖校正坐标与比例、Android vector path、16 px PNG、11 张 P11 proof、README 品牌图一致性、版本和 Android 权限契约。构建仅报告 Flutter/Kotlin Gradle Plugin 的未来迁移提示；它不影响本次构建，也不是品牌几何阻塞项。

## 7. Debug APK 与验包

- 路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 大小：`154,633,684` 字节（`147.47 MiB`）
- SHA-256：`5BCB97F6FE44DADB91B1E259AC7E0A3F9739EF1591B4FEAAD68932F382C5F122`
- package：`com.example.four_in_one_app`
- versionName / versionCode：`2.6.0 / 18`
- min / target / compile SDK：`24 / 36 / 36`
- application label：`Get Ready`
- debug 签名：Android Debug；APK Signature Scheme v2 验证通过
- 16 KB 对齐：`zipalign -c -P 16 4` 通过

APK ZIP 与 compiled XML 检查确认：

- 5 个 density 的标准 launcher 和 5 个 round launcher PNG 均存在，且逐字节 SHA-256 与仓库 source PNG 一致；
- v26 adaptive icon 引用独立背景和 corrected foreground；
- v33 adaptive icon另引用 corrected monochrome layer；
- foreground、monochrome 与 Android 12 splash 的编译 pathData 包含校正后的 `192 × 64 / D128` 等比坐标；
- notification 编译 pathData 包含 `6 × 2 / D4` 校正坐标；
- legacy splash PNG 与 Flutter `get_ready_mark_64.png` 已打包并与 source 一致；
- APK 资源色值仍为 `#111111`、`#16A34A` 与 `#F6F7F8`。

## 8. 身份与权限保持

`pubspec.yaml`、Android Gradle identity 与 Android manifests 在本批次没有差异。最终仍为：

- 产品名：`Get Ready`
- Flutter 版本：`2.6.0+18`
- package ID：`com.example.four_in_one_app`

APK 权限集合保持 P9 已接受状态：

- `android.permission.INTERNET`（debug/profile tooling）
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.VIBRATE`
- `com.example.four_in_one_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

没有新增 camera、microphone、location、storage、exact alarm 或 foreground-service 权限。

## 9. Git 与设备边界

- 当前分支：`p7-ui-foundation`
- 基线提交：`e2f89b5 release: prepare Get Ready 2.6.0`
- staged 文件：无
- 本几何校正：未 commit、未 push
- 未创建 tag、GitHub Release 或 PR；未 merge main；未 force-push
- 原始参考板与 debug APK 保持 Git 忽略

本批次没有 Android 物理设备验证。仍需在真实设备/OEM launcher 上人工复核标准/round/adaptive mask、Android 13 themed icon、Android 12 splash、Settings/About 标志以及通知 shade/status-bar 小图标。GitHub description 与 topics 未在本批次修改。

## 10. 视觉批准门

请以 `get_ready_corrected_contact_sheet.png` 为主要批准图，并结合 `get_ready_geometry_before_after.png` 与 `get_ready_corrected_small_size_preview.png` 检查。只有在人工批准后才应暂存、提交或推送本批次校正。

状态：ready for visual review；尚未发布本次几何校正。
