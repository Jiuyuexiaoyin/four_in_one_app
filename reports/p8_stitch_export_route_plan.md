# P8 Stitch Export Route Replacement Plan

Date: 2026-07-08
Primary UI source: `.ai_reference\stitch\export_20260708\stitch_app\stitch_app\`

## Global Decisions

- Use the local export screenshots and HTML as the source of truth.
- Do not use prior Stitch MCP reports as visual target.
- Preserve all real stores and actions.
- Convert the app shell to the export's four primary bottom-nav centers: Today / Habits / Plan / Focus.
- Keep Settings/Theme Studio as a routed fifth screen opened from header/profile/settings actions.
- Keep Review routed and reachable from Today and Settings.

## Shared Layer

Modify or add under:

- `lib/shared/widgets/visual_dna/`
- `lib/app/theme/`

Needed components:

- Export page scaffold/background with carbon grid atmosphere.
- Export glass bottom dock.
- Export panel/card.
- Export caps label.
- Export metric ring.
- Export progress rail.
- Export mini line chart.
- Export bar chart.
- Export heatmap grid.
- Export LED sequence dots.
- Export action/utility rows.

## AppShell

File: `lib/shared/widgets/app_shell.dart`

Use export reference:

- Four-key dock from all exported primary screens.
- Dark translucent dock, cyan active icon/label, grey inactive icons.

Changes:

- Remove `My` from bottom navigation.
- Use Today/Habits/Plan/Focus as primary destinations.
- Add support for no active bottom tab on Settings/Review if needed.
- Keep route navigation to Settings through page header/profile controls.

Must not fake:

- Navigation routes or Review reachability.

## Today -> TodayPage

Export files:

- `final_synthesis_2\screen.png`
- `final_synthesis_2\code.html`

Flutter file:

- `lib/features/today/presentation/pages/today_page.dart`

Remove:

- Rejected generic Stitch command blocks and extra dashboard sections that do not exist in the export.

Implement:

- Header: back/icon area, `今日 / TODAY`, settings/profile action.
- Large Focus Score from real combined store progress.
- Peak Rhythm cue using real status summary.
- Three ring metrics:
  - habit completion ratio
  - plan/task progress or action velocity
  - real streak/session continuity where available
- Priority Execute card from next real task/habit/focus target.
- Focus Flux chart from real focus/session/habit data.
- Action Plan rows from real goals/tasks/habits.
- Review access as a small action from Today.

Real stores:

- `HabitsStore.totalCount`, `completedCount`, `remainingCount`, real active habits/check-ins.
- `GoalsStore.tasks`, progress, due/overdue tasks/records.
- `FocusStore` current/today/weekly session data.

Actions preserved:

- Habit check-in.
- Goal/task navigation summaries.
- Focus target/timer summary.
- Settings and Review access.

## Habits -> HabitsPage

Export files:

- `scale_proportion_refinement\screen.png`
- `scale_proportion_refinement\code.html`

Flutter file:

- `lib/features/habits/presentation/pages/habits_page.dart`

Remove:

- Old list-first visual hierarchy.
- Generic large sections before the export readiness/cadence/protocol sequence.

Implement:

- `STRIVE` header.
- System Integrity card with real readiness ratio.
- Three compact metric tiles from real habit data.
- Current Cadence card bound to pending/active habit.
- Complete button uses real check-in action/sheet.
- Daily Rhythm chart from real recent completion counts.
- Active Protocol cards with real habit data, streaks, LED weekday dots, and action entry points.
- Paused/archived sections remain reachable but visually secondary.

Real stores:

- `HabitsStore.habits`, active/paused/archived filters, completion counts, records, reminders, statistics.

Actions preserved:

- Create habit.
- Edit habit.
- Check-in.
- Reminder setting.
- Pause/archive/restore.
- Record/statistics/attachment flows.

## Plan -> GoalsPage

Export files:

- `discipline_dashboard\screen.png`
- `discipline_dashboard\code.html`

Flutter file:

- `lib/features/goals/presentation/pages/goals_page.dart`

Remove:

- Tree-first visual hierarchy at top.
- Generic search/overview surfaces before the export hero.

Implement:

- `STRATEGIC COMMAND` header.
- Core Intent hero with highlighted word.
- Description/status panel with real progress chips.
- Four strategic pillar cards mapped to real goal/task/project data.
- Milestone log from real project records/tasks.
- Keep full goal/project/subproject/task tree and edit/create actions below the export dashboard.

Real stores:

- `GoalsStore.goals`, projects, subprojects, tasks, task completion, records, due/overdue calculations.

Actions preserved:

- Create/edit goal.
- Create/edit project/subproject/task.
- Toggle task.
- Project/task records and attachments.

## Focus -> FocusPage

Export files:

- `final_synthesis_1\screen.png`
- `final_synthesis_1\code.html`

Flutter file:

- `lib/features/focus/presentation/pages/focus_page.dart`

Remove:

- Rejected ring-first focus hero.

Implement:

- `OPTIMIZE` top bar.
- Flow Status cockpit card with huge timer text and horizontal progress.
- Current peak/real session status.
- Start/pause/reset controls as export-style cyan pill/action icons.
- Focus Score card from real weekly focus data.
- Weekly distribution bars from real sessions.
- Heatmap from real focus history.
- Target selection and duration controls remain accessible.

Real stores:

- `FocusStore.status`, duration, remaining seconds, current target, completed sessions, weekly/today minutes.

Actions preserved:

- Start.
- Pause.
- Reset.
- Select target.
- Select duration/custom duration.

## My / Settings -> SettingsPage

Export files:

- `performance_hub\screen.png`
- `performance_hub\code.html`

Flutter file:

- `lib/features/settings/presentation/pages/settings_page.dart`

Remove:

- Settings-first generic card order.

Implement:

- Strategic command header.
- Theme Studio hero with dark line-wave/card background.
- Color Lab labels.
- Saturation/brightness matrix bound to selected color.
- Hue/luminance controls bound to `AppSettingsStore`.
- HEX/RGB readouts and existing advanced color inputs.
- Utility rows for reminders, privacy/security, local data.
- Review access.

Real stores:

- `AppSettingsStore.themeMode`, accent/background/surface colors.
- `HabitsStore`, `GoalsStore`, `FocusStore` for local data summary where available.

Actions preserved:

- Theme mode selection.
- Accent/background/surface color presets.
- HEX/RGB/ARGB inputs.
- Reset all colors.
- Review navigation.

## Review -> ReviewPage

Export files:

- No direct export screen.
- Visual language borrowed from `Premium Performance` export.

Flutter file:

- `lib/features/review/presentation/pages/review_page.dart`

Implement:

- Keep Review outside four-key bottom nav.
- Restyle with export panels, caps labels, real metrics, and compact charts.
- Expose from Today and Settings.

Real stores:

- Existing Review data from `HabitsStore`, `GoalsStore`, and `FocusStore`.

Actions preserved:

- Review route and all existing real summary calculations.

## Verification Plan

Run after implementation:

- `D:\ai\flutter\bin\dart.bat format -o none .` because project AGENTS.md forbids broad mutating `dart format .`.
- `D:\ai\flutter\bin\flutter.bat analyze`
- `D:\ai\flutter\bin\flutter.bat test`
- `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321 --no-resident`

If port `54321` is occupied, run a fallback port and report the conflict.
