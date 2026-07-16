# Get Ready 2.6 品牌几何规范

日期：2026-07-16

批准参考板：`.ai_reference\branding\get_ready_2_6_brand_board.png`（仅作方向参考，不作为生产位图来源）

生产资产全部以 SVG 几何重新绘制。不得裁切参考板，不得嵌入参考板背景、光晕、纹理或其他栅格内容。

## 1. 主标志画布

- Master viewBox：`0 0 1000 1000`
- 圆弧中心：`(430, 500)`
- 圆弧中心线半径：`220`
- 圆弧粗细：`80`
- 端点：圆头，光学半径 `40`
- 右侧开口角：`110°`
- 实际绘制角：`250°`，从屏幕坐标系 `55°` 端点经左侧绘制到 `305°` 端点
- 中心线起点：`(556.187, 680.213)`
- 中心线终点：`(556.187, 319.787)`
- 圆弧外接范围（含线宽和圆头，取整）：`x=170…596`、`y=240…760`

中心线以四段等角度 `62.5°` 的三次贝塞尔曲线表达；该分段仅用于确定性 SVG/Java2D 渲染，不改变上述圆弧设计半径和开口角。

## 2. 状态条与就绪圆点

状态条：

- 位置：`x=575, y=405`
- 尺寸：`230 × 80`
- 圆角：`40`，即完整胶囊端点
- 填充：Brand green `#16A34A`

就绪圆点：

- 圆心：`(640, 610)`
- 直径：`88`
- 半径：`44`
- 填充：Brand green `#16A34A`

状态条与圆点互不相连。它们共同位于圆弧右侧开口内，保持“状态 / 就绪”的清晰层级，不得合并成阶梯或感叹号。

## 3. 组合边界与安全区

- 完整标志视觉边界：`x=170…805`、`y=240…760`
- 左安全区：`170`（17%）
- 右安全区：`195`（19.5%）
- 上下安全区：各 `240`（24%）
- 视觉边界中心：约 `(487.5, 500)`；相对画布几何中心向左 `12.5`，用于平衡右侧状态条
- Launcher 前景继续使用同一 1000-unit 构图；adaptive foreground 不包含任何圆角方块背景

Logo 周围最小留白以圆点直径 `x=88` 为基准：常规排版四周至少 `1x`；紧凑 UI 不得低于 `0.5x`。

## 4. Launcher 规则

`get_ready_mark.svg` 是主 launcher 组合：

- 方形画布 `1000 × 1000`
- Ink black 背景 `#111111`
- 背景圆角半径 `220` 仅供 legacy/文档 launcher tile 使用
- 圆弧使用 Background gray/off-white `#F6F7F8`
- 状态条和圆点使用 Brand green `#16A34A`

Android adaptive icon 必须把 `#111111` 作为独立 background layer；foreground 与 monochrome layer 只包含标志，不得烘焙 tile 或平台 mask。

## 5. 亮色、暗色与单色规则

| 场景 | 圆弧 | 状态条 | 圆点 | 背景 |
|---|---|---|---|---|
| 亮色表面 | `#111111` | `#16A34A` | `#16A34A` | 透明或 `#F6F7F8` |
| 暗色表面 | `#F6F7F8` | `#16A34A` | `#16A34A` | 透明或 `#111111` |
| 黑色单色 | `#111111` | `#111111` | `#111111` | 透明 |
| 白色单色 | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` | 透明 |

批准色板：

- Ink black：`#111111`
- Brand green：`#16A34A`
- Deep gray：`#6B7280`
- Light gray：`#E5E7EB`
- Background gray：`#F6F7F8`

不得继续使用 P10 品牌色 `#0D1117`、`#1A1F28`、`#22C55E` 或 `#F1F3F5` 作为 Get Ready 生产品牌色。

## 6. Wordmark 与标语

- 唯一可见产品名：`Get Ready`
- `G` 与 `R` 必须大写，两个单词之间必须保留可见空格
- `Get`：亮色表面 `#111111`，暗色表面 `#F6F7F8`
- `Ready`：`#16A34A`
- 字体：优先系统 `Segoe UI`，开放/系统 sans-serif 回退；不复制或嵌入商业字体
- Horizontal wordmark viewBox：`1600 × 400`
- Horizontal mark 缩放：主几何的 `0.34` 倍，并平移 `(20, 30)`
- Horizontal `Get` 起点：`x=370`
- Horizontal `Ready` 起点：`x=735`；显式间距不得压缩为 `GetReady`
- Vertical logo viewBox：`1000 × 1250`；标志在上，wordmark 自 `y=800` 开始
- 批准标语：`随时准备，迎接每一次机会。`

## 7. Splash 规则

- Splash master viewBox：`1440 × 2560`
- 默认深色背景：`#111111`
- 亮色 proof 背景：`#F6F7F8`
- 完整构图包含标志、`Get Ready` 和批准标语
- Legacy Android 使用透明 vertical lockup 置于 `#111111` native background
- Android 12+ native splash 只使用 mark，不放 wordmark 或标语
- 不加入进度条、人为延时、渐变、阴影或光晕

## 8. Android 通知光学校正

通知图标使用独立 `24 × 24` optical master，以适应系统状态栏，不直接机械缩小 launcher tile：

- 圆弧中心：`(9.5, 12)`
- 圆弧半径：`6.5`
- 圆弧粗细：`2.4`
- 开口角：`110°`
- 状态条：`x=14, y=9.2, 6.4 × 2.6, r=1.3`
- 圆点：圆心 `(16.2, 15.7)`，直径 `3.4`
- 颜色：单一纯白 `#FFFFFF`，由 Android 作为 alpha mask 着色
- 背景：透明；无 tile、绿色、渐变、描边或阴影

## 9. 最小尺寸

- 数字 mark：`16 px` 可识别下限，`24 px` 常规最小尺寸
- Android notification：原生 `24 × 24` viewport
- Horizontal wordmark：建议最小宽度 `180 px`
- Vertical logo：建议最小宽度 `104 px`
- Launcher：始终从 SVG master 生成，不得放大小尺寸 PNG

16–24 px 下必须仍可辨认一个开口圆弧、一个状态条和一个独立圆点；不得用三步阶梯替代。

## 10. 禁止变形

不得：

- 闭合、镜像、旋转、倾斜、拉伸或压扁圆弧；
- 改变右侧开口方向；
- 把状态条或圆点挪成三步阶梯；
- 合并状态条与圆点；
- 改变 `Get Ready` 的大小写、空格或词序；
- 在 launcher 或通知图标中加入 wordmark；
- 在 adaptive foreground 中烘焙圆角方块；
- 使用 P10 三步 mark、旧标语或小写 `getready` 作为生产可见品牌；
- 使用裁切参考板、滤镜、渐变、模糊、纹理、光晕、阴影或外部位图。
