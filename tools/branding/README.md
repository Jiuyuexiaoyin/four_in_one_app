# Get Ready 品牌资产生成器

本目录包含 Get Ready 2.6 的项目内、无第三方依赖生产渲染器。它从 `assets/branding/get_ready_*.svg` 的受控矢量几何生成 PNG、Android launcher 栅格和 P11 proof；不会裁切或采样 `.ai_reference` 中的品牌板。

## 前置条件

- `PATH` 中可用的 OpenJDK 21 或更高版本
- 系统已安装 SVG 所引用的 `Segoe UI` 与中文 sans-serif 字体

不需要 npm、Python、ImageMagick、Inkscape、浏览器或专有设计软件。

## Windows PowerShell 命令

从仓库根目录运行：

```powershell
.\tools\branding\generate_getready_assets.ps1
```

PowerShell wrapper 以 Java source-file mode 运行 `GenerateGetreadyAssets.java`。渲染器只使用 JDK 自带的 JAXP、Java2D 与 ImageIO。

## 安全与可复现性

- 仅接受 `svg`、`g`、`rect`、`circle`、受控 `path`、`text`、`title` 和 `desc`。
- `path` 仅接受显式绝对 `M`、`L`、`C`、`Z` 命令；品牌圆弧使用三次贝塞尔与圆头 stroke。
- 拒绝 image、filter、gradient、pattern、mask、外部引用、transform、CSS style 与任意脚本。
- 颜色必须是显式 `#RRGGBB`；stroke 必须有正数宽度。
- 文本使用已安装的系统字体，不复制或嵌入字体文件。
- 所有生产 SVG 以 4× supersampling 渲染，再用 bicubic 缩小。
- PNG 写入显式 sRGB chunk；完全透明像素的 RGB 会清零。
- 每张 PNG 写入后重新解码并核对尺寸、alpha、透明边缘与关键品牌色。
- 写入使用同目录临时文件与原子替换。
- JSON manifest 记录 source/output SHA-256、尺寸和实际字体，不包含时间戳；在相同 JDK/字体栈上同输入可重复生成相同字节。

## 输出范围

生成器只允许写入：

- `assets/branding/generated/get_ready_*`
- `reports/p11_get_ready_brand_assets/`
- Android 五个 `mipmap-*` density 中的 `ic_launcher.png` 与 `ic_launcher_round.png`
- `android/app/src/main/res/drawable-nodpi/getready_splash_brand.png`

Android adaptive/themed/splash/notification vector XML 保留稳定 resource ID，由仓库源码维护；生成器负责与其共用的精确几何和 raster 输出。

## 生产输出

- `get_ready_mark_{1024,512,256,128,64,32,24}.png`
- `get_ready_wordmark_horizontal.png`
- `get_ready_splash_dark.png`
- `get_ready_splash_light.png`
- 五个 legacy launcher 和五个 round launcher density PNG
- legacy Android splash lockup
- 八张 P11 proof，包括历史 P10 与新品牌的对比图
- `get_ready_asset_manifest.json`
