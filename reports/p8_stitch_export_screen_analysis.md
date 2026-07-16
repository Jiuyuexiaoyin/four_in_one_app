# P8 Stitch Export Screen Analysis

Date: 2026-07-08
Source: `.ai_reference\stitch\export_20260708\`

## Export Verification

Found:

- `.ai_reference\stitch\export_20260708\项目简介.txt`
- `.ai_reference\stitch\export_20260708\程式码.txt`
- `.ai_reference\stitch\export_20260708\stitch_app.zip`
- `.ai_reference\stitch\export_20260708\stitch_app\`

The extracted folder contains a nested export root:

- `.ai_reference\stitch\export_20260708\stitch_app\stitch_app\`

The ZIP contains the same five screen folders plus `premium_performance\DESIGN.md`, so no extra extraction was required.

## Design System

The export is titled `Premium Performance`, not the older generic Stitch/MCP reference. It defines an `OPTIMIZE Premium Performance OS` with four primary centers and a Theme Studio personalization screen.

Core style:

- Technical editorial / premium performance dashboard.
- True dark carbon background: `#000000`, `#0e0e0e`, `#131313`.
- Layered dark surfaces: `#1c1b1b`, `#201f1f`, `#2a2a2a`, `#353534`.
- Primary accent: electric cyan `#00e5ff` / `#00daf3`.
- Supporting accents: acid green `#80ff2c`, purple `#dcb8ff`, critical red `#ffb4ab`.
- Typography intent: Hanken Grotesk for large data/headlines, JetBrains Mono for caps/data labels, Inter for body.
- Geometry: 4-12px card radii, pill action buttons, thin chart lines, compact high-density data cards.
- Navigation: four-key floating/docked bottom bar for Today / Habits / Plan / Focus. Theme Studio is separate from the four primary centers.

## Exact Screens Found

| Export folder | Screen | File pair | PNG size |
|---|---|---|---|
| `final_synthesis_2` | Today / Premium Productivity | `code.html`, `screen.png` | `339 x 1600` |
| `scale_proportion_refinement` | Strive / Habits | `code.html`, `screen.png` | `411 x 1600` |
| `discipline_dashboard` | Discipline Dashboard / Plan | `code.html`, `screen.png` | `285 x 1600` |
| `final_synthesis_1` | Focus Dashboard | `code.html`, `screen.png` | `486 x 1600` |
| `performance_hub` | Mine / Personal Hub / Theme Studio | `code.html`, `screen.png` | `381 x 1600` |

## Today: `final_synthesis_2`

Visible structure:

- Mobile header with back chevron, centered `今日 / TODAY`, profile/avatar button.
- Large `Focus Score` block: lightning icon, huge score `88%`, date.
- Thin green-edged `Peak Rhythm` cue card.
- `Momentum Metrics`: three compact circular ring metrics for completion, velocity, and streak.
- `Priority Execute` card with time, main action title, duration pill, cyan initiate CTA.
- `Focus Flux` line chart with grid and `Optimum Range`.
- `Action Plan`: time-based vertical rows, task title, body text, small indicator bars, small icon action.
- Bottom dock with four tabs: 今天 / 习惯 / 计划 / 专注.

Implementation mapping:

- Use real habit completion for completion ring.
- Use real goals/task progress for velocity or plan advancement.
- Use real habit streak/focus continuity where available, otherwise show empty/zero state.
- Priority Execute should use the next real incomplete task/habit/focus target, not fake text.

## Habits: `scale_proportion_refinement`

Visible structure:

- `STRIVE` header with cyan bolt and profile/settings icon.
- Large `系统完整性 (SYSTEM INTEGRITY)` card with `每日准备就绪` headline and large readiness percentage.
- Cognitive load rail labeled `最佳`.
- Three black metric cards: recovery, pressure, sleep.
- `当前节奏 (CURRENT CADENCE)` card with active habit title, description, target, elapsed/completed count, full-width cyan `完成 (COMPLETE)` button, and progress rail.
- `每日节奏 (DAILY RHYTHM)` card with large percentage and sparse weekly chart.
- `活跃协议 (ACTIVE PROTOCOLS)` cards: icon tile, habit title/subtitle, streak count, and seven LED-style weekday dots.
- Four-key bottom dock with Habits active.

Implementation mapping:

- Readiness maps to real `HabitsStore` completion ratio.
- Current cadence maps to first active pending habit or first active habit.
- Complete button triggers the real check-in flow.
- Protocol cards keep real edit/check-in/record/stat/statistics actions.

## Plan: `discipline_dashboard`

Visible structure:

- Compact top header: `STRATEGIC COMMAND`, settings icon.
- Dark grid background.
- `核心意图 // CORE INTENT` hero with oversized editorial sentence `Discipline is the Bridge to Goals.` and cyan-highlighted word.
- Description panel with status chips `INTENSITY: HIGH` and `FOCUS: 94%`.
- `战略支柱 // STRATEGIC PILLARS`: four stacked strategic cards:
  - P1 Career / Q3 Objectives with progress rail.
  - P2 Physical / Readiness with ring gauge and recovery/strain rows.
  - P3 Wealth / Asset Allocation with split bars.
  - P4 Mind / Cognitive Load with bar chart.
- `里程碑日志 // MILESTONE LOG`: dated rows with status chips and arrow affordances.
- Four-key bottom dock with Plan active.

Implementation mapping:

- Strategic cards should be generated from real goals/projects/tasks where possible.
- The fixed export pillar labels become visual shells; their values must be real local counts/progress.
- Milestone log maps to real recent project/task records or upcoming/incomplete tasks.

## Focus: `final_synthesis_1`

Visible structure:

- Top app bar: terminal icon, centered `OPTIMIZE`, profile button.
- Large cockpit card: `实时心流状态 / FLOW STATUS`, huge timer, horizontal progress rail, percent, current peak metric, cyan pause/start button.
- `FOCUS SCORE` card with green score and progress rail.
- `周专注分布 / WEEKLY DIST` bar chart.
- `专注热力图 / HEATMAP` 3-row intensity matrix.
- Four-key bottom dock with Focus active.

Implementation mapping:

- Timer block binds to real `FocusStore.remainingSeconds`, status, selected duration, and start/pause/reset actions.
- Focus score maps to weekly real minutes/session count.
- Weekly distribution and heatmap map to real session history.
- Target selection and duration selector remain accessible below/inside the cockpit flow.

## My / Settings: `performance_hub`

Visible structure:

- Sticky header with small avatar tile, centered `STRATEGIC COMMAND`, settings icon.
- Large image-like `主题工作室 / Theme Studio` hero with line-wave background, edition dot, title/subtitle.
- `COLOR LAB` and `ACTIVE PALETTE CONFIGURATION` labels.
- `SAT / BRI MATRIX` square with cyan gradient and selector dot.
- `GLOBAL CONTROLS` card with hue rainbow slider, luminance slider, HEX and RGB tiles.
- Utility rows: reminders, privacy/security, local storage.
- Four-key bottom dock remains visible; Theme Studio is a separate screen, not one of the four primary centers.

Implementation mapping:

- Color matrix, hue slider, luminance slider, HEX/RGB tiles bind to `AppSettingsStore`.
- Utility rows expose real settings/theme controls and local data summary.
- Review must remain reachable from this page if Review exists.

## Bottom Navigation

Export primary navigation is four-key:

1. Today
2. Habits
3. Plan
4. Focus

Settings/Theme Studio is a fifth routed screen opened from profile/settings affordances rather than a bottom-nav tab.

## Reusable Components Needed

- Export-style page background with subtle grid/radial atmosphere.
- Four-tab glass bottom dock with active cyan glow.
- Technical caps label.
- Export card/panel with 1px low-opacity border.
- Large metric text.
- Ring metric.
- Horizontal progress rail.
- Mini line chart.
- Weekly bar chart.
- LED sequence dots.
- Heatmap matrix.
- Utility row with icon tile and trailing value/chevron.

## Critical Data Rules

- Do not use export hardcoded values (`88`, `78%`, `42:15`, `124 BPM`) as static values.
- Map all metrics to real `HabitsStore`, `GoalsStore`, `FocusStore`, or `AppSettingsStore`.
- If real data is missing, show zero/empty states using the exported visual structure.
