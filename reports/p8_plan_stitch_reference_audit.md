# P8 Plan Stitch Reference Audit

## Files Read

- `.ai_reference/stitch/export_20260708/项目简介.txt` (present, empty)
- `.ai_reference/stitch/export_20260708/程式码.txt`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/discipline_dashboard/code.html`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/discipline_dashboard/screen.png`
- `.ai_reference/stitch/export_20260708/stitch_app.zip` was not extracted again because the extracted `stitch_app` folder is present and readable.

## Exact Plan Screen

- Folder: `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/discipline_dashboard/`
- HTML title: `Discipline Dashboard - Plan`
- Screenshot size: `285 x 1600`
- Main visual theme: black technical grid, high-density roadmap/dashboard, cyan active Plan tab.

## Visible Text

- Header: `STRATEGIC COMMAND`
- Core section label: `核心意图 // CORE INTENT`
- Hero headline: `Discipline is the Bridge to Goals.`
- Hero body: `Focus on maintaining high-density execution across all operational pillars. Mental clarity is maintained through rigorous adherence to the established protocols. Deviations are logged, analyzed, and corrected.`
- Hero chips: `INTENSITY: HIGH`, `FOCUS: 94%`
- Pillar label: `战略支柱 // STRATEGIC PILLARS`
- Pillar cards:
  - `P1. 职业 // CAREER`, `Q3 Objectives`, `68%`, `LAUNCH`, `REVIEW`
  - `P2. 身体 // PHYSICAL`, `Readiness`, `80/100`, `RECOVERY`, `OPTIMAL`, `STRAIN`, `14.2`
  - `P3. 财富 // WEALTH`, `Asset Allocation`, `LIQUID`, `42%`, `FIXED`, `38%`, `RISK`, `20%`
  - `P4. 心智 // MIND`, `Cognitive Load`, `L-7D AVG`, `PEAK DETECTED`
- Milestone section: `里程碑日志 // MILESTONE LOG`, `VIEW ALL_`
- Milestone rows:
  - `2023.10.24`, `Deploy Core Algorithm Update`, `Completed`
  - `2023.10.28`, `Endurance Assessment Phase 2`, `Pending`
  - `2023.11.02`, `Quarterly Asset Rebalancing`, `Scheduled`
- Bottom nav: `今天`, `习惯`, `计划`, `专注`; Plan is active.

## Layout Structure

- Body background is `#000000` with a 24px grid using 1px white lines at about 2% opacity.
- Mobile header is a 48px top bar with `STRATEGIC COMMAND` at left and a settings icon at right.
- Main content starts below the header with about 20px horizontal padding and 80px top offset in the HTML.
- Core intent is a label, large two-line headline, then a dark surface card with body text and two mono metric chips.
- Strategic pillars is a section header plus a single-column mobile grid of four cards.
- Each card is `#121212`, low-opacity white border, 4-8px radius, 24px padding, no Material elevation.
- Milestone log uses transparent/list rows, left date column, title column, small status chip, arrow icon.
- Bottom nav is fixed, dark translucent, cyan active Plan state.

## Colors And Typography

- Background: `#000000` grid canvas.
- Surfaces: `#121212`, `#131313`, `#1c1b1b`, `#2a2a2a`, `#353534`.
- Primary cyan: `#00e5ff` / `#00daf3`.
- Green: `#bcff90`, `#6cec00`.
- Purple: `#dcb8ff`.
- Text: `#e5e2e1`, secondary `#bac9cc`, outline `#849396`, outline-variant `#3b494c`.
- Fonts in export: Hanken Grotesk for large headings and data, JetBrains Mono for labels/data, Inter for body.
- Flutter implementation should keep weight, all-caps/mono label feel, tabular numbers, and tight headline spacing.

## Current Flutter Plan Issues

- Current `GoalsPage` has useful real functionality but the top Plan surface is a generic StitchExact dashboard, not the exported black grid composition.
- The page starts directly with a command-header component instead of the exported mobile `STRATEGIC COMMAND` top bar.
- The core-intent headline is inside a generic command header and panel, not a large editorial hero followed by a technical card.
- Pillars render as generic timeline rows rather than four distinctive export cards: linear progress, circular readiness, allocation rows, and bar matrix.
- The milestone log is inside a generic panel rather than the transparent row table with date/status/arrow rhythm.
- The page backdrop is not strongly Plan-specific black grid.

## Preservation Requirements

- Keep real `GoalsStore` data. Do not hardcode the screenshot percentages, dates, or milestone titles.
- Keep create goal/project/subproject/task, edit goal/project/task, task completion, and plan record functionality.
- Only `lib/features/goals/presentation/pages/goals_page.dart` should be modified for the UI fix.
