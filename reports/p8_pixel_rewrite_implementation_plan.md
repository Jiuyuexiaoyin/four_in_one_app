# P8 Pixel Rewrite Implementation Plan

## Component Strategy

- Previous `VisualDna*` components will be abandoned for active routed screens.
- Previous generic `Stitch*` components under `lib/shared/widgets/visual_dna/` may remain on disk for compatibility, but active routes should import/use the new exact export layer.
- Create `lib/shared/widgets/stitch_exact/` with export-derived constants and components:
  - `StitchExactColors`
  - `StitchExactScaffold`
  - `StitchExactHeader`
  - `StitchExactBottomNav`
  - `StitchExactPanel`
  - `StitchExactLabel`
  - `StitchExactMetricTile`
  - `StitchExactProgressBar`
  - `StitchExactRing`
  - `StitchExactMiniBars`
  - `StitchExactHeatmap`
  - `StitchExactActionButton`
  - `StitchExactTimelineRow`
  - `StitchExactProtocolCard`

The new layer will encode the local export tokens: `#131313`, `#000000`, `#121212`, `#201f1f`, cyan `#00daf3/#00e5ff`, green `#6cec00`, purple `#dcb8ff`, 20px mobile padding, 24px panel padding, 8-12px panel radius, 1px low-opacity borders, mono caps labels, and four-tab bottom dock.

## Active Files To Overwrite

- `lib/shared/widgets/app_shell.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`

Supporting tests may be updated only to reflect structural route changes, not to delete behavior coverage.

## Route Mapping

- Stitch Today (`final_synthesis_2`) -> `TodayPage`
- Stitch Habits (`scale_proportion_refinement`) -> `HabitsPage`
- Stitch Plan (`discipline_dashboard`) -> `GoalsPage`
- Stitch Focus (`final_synthesis_1`) -> `FocusPage`
- Stitch My / Settings (`performance_hub`) -> `SettingsPage`
- Review -> preserve and expose from Today and Settings.

## AppShell / Navigation

- Implement a custom `StitchExactBottomNav` instead of Flutter’s default Material `NavigationBar` visual style.
- Use the exported four-tab model:
  - 今天 / Today -> `AppRoute.today`
  - 习惯 / Habits -> `AppRoute.habits`
  - 计划 / Plan -> `AppRoute.goals`
  - 专注 / Focus -> `AppRoute.focus`
- Settings remains opened via profile/settings affordance and may show the fourth tab active, matching the Settings export where the Theme Studio content still shows the four-tab dock with the fourth item highlighted.
- Review is not a bottom-nav tab.

## Today Bindings

- Focus Score: computed from real habit progress, task completion progress, and focus progress.
- Date line: current local date from store time where available.
- Peak Rhythm: real summary sentence based on whether any habits/tasks/focus sessions exist today.
- Momentum Metrics:
  - Completion ring: `HabitsStore.completedCount / totalCount`.
  - Velocity ring: `completedTasks / totalTasks`.
  - Streak ring/icon: recent active habit days / 7.
- Priority Execute:
  - Next open task from `GoalsStore.tasks`, else first pending habit, else focus action.
  - Action button opens Plan/Focus or checks in a pending habit.
- Focus Flux: real recent habit totals + focus day counts.
- Action Plan: real open tasks and pending habits.
- Review icon: opens `AppRoute.review`.

No fake screenshot numbers.

## Habits Bindings

- System Integrity score: `HabitsStore.completedCount / totalCount`.
- Cognitive Load progress: same real completion ratio with empty state when no active habits.
- Metric tiles:
  - Recovery: completed/total.
  - Pressure: remaining count.
  - Records: total check-ins today.
- Current Cadence:
  - First pending active habit, else completed state.
  - Goal: target count per day.
  - Used/Done: today check-in count.
  - Complete button calls `habitsStore.checkIn`.
  - Add habit button preserves create flow.
- Daily Rhythm: real weekly habit counts.
- Active Protocols:
  - Real active habits as protocol cards.
  - Check-in, edit, reminder, record, statistics affordances remain reachable from each habit card or action row.

## Plan Bindings

- Core Intent: first real goal title if present; otherwise empty-state copy.
- Status chips:
  - Intensity: goal/action count.
  - Focus: task completion percentage.
  - Due/overdue: real date helpers.
- Strategic Pillars:
  - Up to four real goals with progress rails.
  - If fewer than four goals, no fake placeholders; show real empty creation affordance.
- Milestone Log:
  - Recent real `GoalsStore.records`; fallback to real tasks if records are empty.
- Preserve existing add/edit goal/project/subproject/task flows and task toggles.

## Focus Bindings

- Flow Status timer: `FocusStore.formattedRemaining`.
- Fractional seconds in export will not be faked; show `.00` only when using real seconds cannot provide fractional precision, or omit fraction where needed.
- Progress: `(activeDurationSeconds - remainingSeconds) / activeDurationSeconds`.
- Current Peak: closest real metric is weekly completed sessions or active target count; label will indicate local session count rather than BPM if BPM does not exist.
- Pause/Start button calls `pause` or `start`; reset remains available.
- Focus Score: derived from weekly focus minutes against a real local target.
- Weekly Dist: `weeklyDayCounts`.
- Heatmap: recent completed focus sessions.
- Target and duration selection remain below the exported dashboard in exact panel style.

## Settings Bindings

- Header and hero match `performance_hub`.
- Color Lab:
  - Sat/Bri matrix approximates the export with a Flutter gradient and live accent marker.
  - Hue/luminance controls use existing Theme Studio/color controls, preserving test keys and real `AppSettingsStore` actions.
  - Hex/RGB tiles bind to `settingsStore.accentColor`.
- Utility rows:
  - Reminder settings placeholder remains functional as an inert local row if no existing settings flow exists.
  - Privacy row is informational.
  - Local data row binds to real habit/task/focus counts rather than fake `1.2 GB`.
- Review access row opens `AppRoute.review`.

## Review

- Restyle with `StitchExact` components.
- Preserve all real summaries from HabitsStore, GoalsStore, and FocusStore.
- Keep route reachable from Today and Settings.

## Visual Elements Without Matching Data

- Avatar images from export use remote placeholder URLs. Do not fetch or embed them. Use local icon/avatar blocks with the same dimensions.
- Export fixed values (`88`, `78%`, `42:15.89`, `124 BPM`, `1.2 GB`) are not real app data and must not be hardcoded.
- BPM has no store source; represent as real focus/session count or active target count with an honest label.
- Decorative wave image in Settings will be approximated with local CustomPaint/gradients, not network assets.
- Export fractional timer has no real millisecond timer source; show the real `MM:SS` timer.
