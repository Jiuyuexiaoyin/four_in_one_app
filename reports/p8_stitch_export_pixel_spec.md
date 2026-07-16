# P8 Stitch Export Pixel Spec

## Source Files

- `.ai_reference/stitch/export_20260708/程式码.txt`
- `.ai_reference/stitch/export_20260708/项目简介.txt` (empty)
- `.ai_reference/stitch/export_20260708/stitch_app.zip`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/premium_performance/DESIGN.md`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/*/code.html`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/*/screen.png`

The extracted folder matches the zip contents, so no additional extraction was required.

## Global Design Rules

- Visual system name: `Premium Performance`.
- App concept: `OPTIMIZE Premium Performance OS`.
- Primary navigation: four-key navigation, not five tabs.
- Core tabs: Today / Habits / Plan / Focus.
- Settings / Theme Studio is a personal hub opened from the profile/settings affordance; the export still renders the same four-key dock at the bottom.
- Background: `#131313` for most screens, `#000000` grid base on Plan.
- Surface colors: `#0e0e0e`, `#121212`, `#1c1b1b`, `#201f1f`, `#2a2a2a`, `#353534`.
- Text: `#e5e2e1`, secondary `#bac9cc`, outline `#849396`, outline-variant `#3b494c`.
- Accents: cyan core `#00e5ff`, cyan fixed dim `#00daf3`, acid green `#6cec00` / `#80ff2c`, purple `#dcb8ff`, red `#ffb4ab`.
- Borders: 1px white at 5-10% opacity.
- Cards: mostly radius 8-12px, surface `#121212` or `#201f1f`, no generic Material card elevation.
- Buttons: cyan filled pill, black/dark text, strong action contrast.
- Fonts in export: Hanken Grotesk for headings/data, Inter for body, JetBrains Mono for labels/data. Flutter should approximate with current fonts but keep sizing, weights, caps, and tabular numeric feel.
- Mobile padding: 20px side padding. Major stack gap around 24px, section gap around 48px.
- Bottom dock: fixed bottom, translucent black/dim surface, blur/glow, four items, 9-10px mono/caps labels, 20-24px icons.
- Do not hardcode export metrics. Bind every metric to real store data, using zero/empty states where data is absent.

## Screen 1: Today

- Export folder: `final_synthesis_2`.
- PNG size: `339 x 1600`.
- HTML title: `Today - Premium Productivity`.
- Mobile header: fixed top, height about 48-56px, left chevron, centered `今日 / TODAY`, right circular profile image at 32px.
- Main container: top margin 80px, side padding 20px, max width 3xl.
- First block:
  - Label row: cyan bolt icon 20px, mono caps `Focus Score`.
  - Huge score: `88` at about 80px, percent as headline beside baseline.
  - Date line in mono 14px.
  - Peak Rhythm card: `#1c1b1b`, radius 8px, padding 16px, 1px border, 2px green left border, green dot 6px, label `Peak Rhythm`.
- Momentum Metrics:
  - Mono caps section label.
  - Three equal columns, ring gauges about 56-64px diameter, labels `COMPLETION`, `VELOCITY`, `STREAK`, small secondary subtitles.
- Priority Execute:
  - High surface card `#2a2a2a`, radius 12px, padding 24px.
  - Header label cyan, time on right.
  - Large task title, body text, timer chip, cyan filled pill action.
- Focus Flux:
  - Section title left, purple `Optimum Range` right.
  - Chart card height 192px, grid overlay 20% x 25%, cyan line, glowing peak marker, small x-axis labels.
- Action Plan:
  - Vertical timeline rows. Time column width ~64px.
  - Row content title 18px, body 16px, small tags 10px, right 32px circular icon.
- Bottom nav:
  - Floating pill width 90%, bottom 8px, rounded top/full, four tabs.
  - Active Today: cyan text, high surface pill, 24px calendar icon, 10px label `今天`.

## Screen 2: Habits

- Export folder: `scale_proportion_refinement`.
- PNG size: `411 x 1600`.
- HTML title: `Strive - Habits`.
- Header: 20px side padding, top 48px, cyan bolt at left, huge `STRIVE`, right 32px rounded square avatar.
- Main stack: 20px side padding, 24px vertical gap.
- System Integrity card:
  - Surface `#201f1f`, border 1px white/5, radius 12px, padding 28px.
  - Label `系统完整性 (SYSTEM INTEGRITY)`, title `每日准备就绪`, score at right in cyan 48px.
  - Thin 2px progress bar, then 3 metric tiles in a 3-column grid, tile height 80px, black/surface lowest.
- Current Cadence:
  - Similar panel, padding 28px.
  - Cyan LED dot, `当前节奏 (CURRENT CADENCE)`, right psychology icon.
  - Large current habit/task title, body copy, two-column goal/elapsed metrics, full-width cyan pill button, 2px progress bar.
- Daily Rhythm:
  - Panel with label and score, chart height around 112px, seven bars and weekday labels.
- Active Protocols:
  - Section label `活跃协议 (ACTIVE PROTOCOLS)`.
  - Repeating protocol cards: surface `#201f1f`, radius 12px, padding 20px.
  - Left 40px icon box, title, cyan subtitle, right streak/count, seven 20px dot timeline indicators.
- Bottom nav:
  - Full-width bottom, rounded top 24px, height 72px, four tabs.
  - Active Habits icon is `rebase_edit`, cyan glow.

## Screen 3: Plan

- Export folder: `discipline_dashboard`.
- PNG size: `285 x 1600`.
- HTML title: `Discipline Dashboard - Plan`.
- Background: true black with 24px grid lines at 2% white opacity.
- Header: 16px vertical, 20px side padding, `STRATEGIC COMMAND`, gear/settings icon.
- Main: top 80px, bottom 100px, side padding 20px.
- Core Intent:
  - Small label `核心意图 // CORE INTENT`.
  - Massive heading `Discipline is the Bridge to Goals.`, with `Bridge` cyan.
  - Intent card: background `#131313`, radius 8px, padding 24px, border 1px white/5, body text and two inline chips `INTENSITY: HIGH`, `FOCUS: 94%`.
- Strategic Pillars:
  - Section label with grid icon.
  - Four cards, each radius 8px, `#121212`, padding 24px, border white/5.
  - Pillar cards use progress rail, ring gauge, allocation rows, or mini bars depending on data.
- Milestone Log:
  - Header row with `VIEW ALL_`.
  - Rows have date column about 96px, title, status chip, arrow.
- Bottom nav:
  - Full width bottom, rounded top 12px, black dim, four tabs.
  - Active Plan: scale 110%, cyan glow.

## Screen 4: Focus

- Export folder: `final_synthesis_1`.
- PNG size: `486 x 1600`.
- HTML title: `Focus Dashboard`.
- Header: fixed 64px, terminal icon left, centered `OPTIMIZE`, right 32px avatar button.
- Main: top 88px, side padding 20px, max 3xl, section gap 48px.
- Flow Status card:
  - Surface `#131313`, radius 12px, border white/5, padding 24px.
  - Label: `实时心流状态 / FLOW STATUS`, cyan right icon.
  - Timer centered, 42:15 with fractional `.89`, huge display styling.
  - Progress row max 240px, cyan rail, percent right.
  - Divider, bottom row: `CURRENT PEAK`, large cyan number, BPM label, cyan `PAUSE` pill.
  - Subtle cyan radial/gradient glow.
- Focus Score card:
  - Surface card, label `FOCUS SCORE`, green score, 1px/4px progress rail, body summary.
- Weekly Dist:
  - Surface card, label `周专注分布 / WEEKLY DIST`, 32px high chart with three horizontal grid lines, seven bars, highlighted active day.
- Heatmap:
  - Surface card, label `专注热力图 / HEATMAP`, 12-column grid of square cells, 4px gap, cyan opacity levels.
- Bottom nav:
  - Full-width rounded top/full, height 80px, black dim, active Focus has cyan top glow bar and filled timer icon.

## Screen 5: My / Settings

- Export folder: `performance_hub`.
- PNG size: `381 x 1600`.
- HTML title: `Mine / Personal Hub`.
- Header: sticky top, 20px padding, left 40px rounded avatar, centered `STRATEGIC COMMAND`, right 40px settings icon.
- Main: side padding 20px, top 32px, gap 48px.
- Hero:
  - Aspect 4:5, radius 16px, surface high, border white/5, padding 24px, dark wave/gradient background.
  - Labels: cyan dot, `Edition 01`, title `主题工作室`, subtitle `Theme Studio`, body copy.
- Color Lab:
  - Label `Color Lab`, secondary `Active Palette Configuration`.
  - Sat/Bri Matrix card: radius 12px, padding 16px, inner 48px high gradient matrix with selection marker.
  - Global Controls card: radius 12px, padding 24px.
  - Hue slider gradient, luminance slider, Hex/RGB two-column value tiles.
- Utility rows:
  - Three 64-78px rows: Reminders, Privacy, Local Storage.
  - 40px icon box, title 18px, mono caps subtitle, right chevron/value chip.
- Bottom nav:
  - Same four-tab dock, active highlight is fourth `专注` in the export even on this content screen.

## Implementation Implications

- The old broad `VisualDna*` surface style is too generic and should not be used by active routes.
- New Flutter components should encode exact constants: 20px horizontal padding, 24px panel padding, 8-12px radii, 1px low-opacity borders, four-item dock, mono caps labels, and dense data rows.
- Screens should use `SingleChildScrollView`/`ListView` with content-width constraints and fixed bottom padding around 100px to clear the dock.
- Empty states should use the same card language and real zero values rather than fake screenshot metrics.
