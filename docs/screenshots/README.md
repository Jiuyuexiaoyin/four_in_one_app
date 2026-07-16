# Get Ready 截图清单

本目录保存 README 和长期仓库文档使用的稳定截图副本。它不保存 Playwright 临时输出、浏览器 profile、原始参考板或 APK 解包产物。

## 使用边界

- 应用界面截图来自经过交互检查的 Flutter browser QA 构建。
- 这些图片用于说明页面结构和已实现功能，不代表 Android 物理设备最终渲染。
- 不得据此声称 Launcher、Adaptive Icon、Android 12 Splash、themed icon、通知阴影或厂商调度已经通过实机验证。
- 截图包含 QA 用本地示例状态；不包含真实用户账户或云端数据。
- 浏览器控制工具的临时输出、诊断图和临时端口产物不得链接进 README。
- `.ai_reference/` 中的批准品牌板不得复制到本目录或提交。

## 当前稳定截图

| 文件 | 内容 | 尺寸 | 原始 QA 证据 |
| --- | --- | ---: | --- |
| `today.png` | Today 主页面与跨功能汇总 | 1280 × 900 | `reports/p8_system_qa_screenshots/01_today.png` |
| `habits.png` | Habits 主页面、当前节奏与打卡入口 | 1280 × 900 | `reports/p8_system_qa_screenshots/02_habits.png` |
| `plan.png` | Plan 简化布局与常驻搜索/筛选 | 390 × 844 | `reports/p8_targeted_component_polish/after/plan_search_filter_after.png` |
| `focus.png` | Focus 时长选择、动作与周概览 | 390 × 844 | `reports/p8_targeted_component_polish/after/focus_duration_after.png` |
| `review.png` | Review 的真实 Store 数据指标 | 1280 × 900 | `reports/p8_system_qa_screenshots/05_review.png` |
| `settings.png` | Settings Theme Studio 与常用色卡 | 390 × 844 | `reports/p8_targeted_component_polish/after/settings_color_palette_after.png` |
| `create_habit.png` | 新建习惯对话框 | 1280 × 900 | `reports/p8_system_qa_screenshots/07_create_habit_dialog.png` |
| `get_ready_branding.png` | P11 Get Ready 轮廓锁定品牌证明 | 2400 × 1600 | `reports/p11_get_ready_brand_assets/get_ready_silhouette_corrected_contact_sheet.png` |

## 证据说明

`today.png`、`habits.png`、`review.png` 和 `create_habit.png` 来自 2026-07-12 的 P8 system QA：

- viewport：1280 × 900 CSS pixels；
- source：最终 post-fix Flutter Web build；
- 浏览器检查覆盖主 Tab、Review/Settings 返回、新建习惯取消、Focus/Plan 交互；
- 最终 pass 没有 console error 或 Flutter overflow；
- 存在一个不阻塞的 Noto fallback-font warning。

`plan.png`、`focus.png` 和 `settings.png` 来自 2026-07-13 的 P8 targeted component QA：

- viewport：390 × 844 CSS pixels；
- 覆盖 Settings 色板、Plan 搜索/筛选和 Focus 时长组件；
- 最终检查为 0 console error、0 console warning、0 overflow；
- 它们是手机尺寸 browser viewport，不是 Android screenshot。

对应报告：

- `reports/p8_app_system_qa_completion_report.md`
- `reports/p8_system_qa_screenshots/README.md`
- `reports/p8_targeted_component_verification_report.md`

## 品牌证明图

README 引用 `get_ready_branding.png`。品牌生成器会把轮廓锁定 contact sheet 同步写入这个稳定路径；不得手工从参考板裁切或用不同几何替换。

禁止把 P10 三阶标志、旧 Wordmark、旧 Splash proof 或旧 Launcher proof 重命名后放入该位置。

## 更新流程

更新应用截图时：

1. 使用干净、可复现的本地测试数据。
2. 通过正常用户交互进入目标页面。
3. 记录平台、viewport、日期和对应 QA 报告。
4. 检查 console、Flutter error、overflow、遮挡和隐私信息。
5. 只把选定图片复制为上述稳定文件名。
6. 更新本文件的来源和尺寸。
7. 不直接链接临时浏览器目录。

物理 Android 设备截图可在完成设备 QA 后替换或补充，但必须保留设备型号、Android API 和验证边界。
