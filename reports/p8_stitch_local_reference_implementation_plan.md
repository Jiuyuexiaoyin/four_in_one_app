# P8 Stitch Local Reference Implementation Plan

## Reference Pack Read

- Visual spec: `.ai_reference/stitch/spec/stitch_visual_spec.md`
- Metadata: `.ai_reference/stitch/metadata/screen_index.json`
- Screenshots:
  - `.ai_reference/stitch/screenshots/01_today.png`
  - `.ai_reference/stitch/screenshots/02_habits.png`
  - `.ai_reference/stitch/screenshots/03_plan.png`
  - `.ai_reference/stitch/screenshots/04_focus.png`
  - `.ai_reference/stitch/screenshots/05_my_settings.png`
- HTML:
  - `.ai_reference/stitch/html/01_today.html`
  - `.ai_reference/stitch/html/02_habits.html`
  - `.ai_reference/stitch/html/03_plan.html`
  - `.ai_reference/stitch/html/04_focus.html`
  - `.ai_reference/stitch/html/05_my_settings.html`

## Shared Visual System

- Modify `lib/shared/widgets/visual_dna/visual_dna_widgets.dart`.
- Use `lib/app/theme/app_theme.dart` and `lib/app/theme/app_theme_tokens.dart` only for shared theme/token changes.
- Build or extend reusable components for Stitch-style:
  - dark full-screen shell and narrow mobile dashboard spacing
  - cyan neon edge/highlight and active states
  - 1 px bordered command/status cards
  - metric cards with mono labels and tabular numeric values
  - compact progress rows
  - mini bar charts, line-chart painter, and square heatmap blocks
  - rectangular icon/status pills
  - section headers and page headers
  - docked bottom nav styling
- No new heavy dependencies. Charts and heatmaps use Flutter widgets or `CustomPaint`.

## Route Mapping

### 1. Stitch Today -> TodayPage

- Local reference: `.ai_reference/stitch/screenshots/01_today.png`, `.ai_reference/stitch/html/01_today.html`.
- Flutter file: `lib/features/today/presentation/pages/today_page.dart`.
- Sections to implement:
  - `今日 / TODAY` command header with compact status shortcuts.
  - Large score/progress metric derived from real habit, plan, and focus progress.
  - Insight/status card using real current state.
  - Three compact metric capsules for habit completion, plan velocity, and focus/streak signal.
  - Priority execute card driven by the next incomplete plan task or next pending habit.
  - Focus Flux style mini line chart from real recent focus/habit counts.
  - Action Plan rows from real pending goals/tasks/habits/focus state.
  - End-of-day Review card linking to `AppRoute.review`.
- Store fields used:
  - `HabitsStore.habits`, `completedCount`, `totalCount`, `totalCheckInsToday`, `isCompletedToday`, `todayCheckInCount`, `recentActivityDays`, `checkIn`.
  - `GoalsStore.goals`, `projects`, `subprojects`, `tasks`, `records`, `toggleTask`, `computeGoalProgress`.
  - `FocusStore.sessions`, `formattedRemaining`, `selectedDurationSeconds`, `status`, `recentDayCounts`.
- Real actions preserved:
  - quick habit check-in
  - route to Habits, Plan, Focus
  - Review route access
  - no static task completion or static metric mutation
- Widgets/components to create/use:
  - `VisualDnaPage`, `VisualDnaCommandHeader`, `VisualDnaStatusPill`, `VisualDnaMetricStrip`, `VisualDnaProgressRow`, `VisualDnaLineChart`, `VisualDnaActionRow`.
- Old UI sections to remove:
  - old oversized custom hero/stage layout and rhythm canvas that does not match the Stitch dashboard.
- Must not be faked:
  - score, counts, progress, chart bars/line, action rows, focus minutes, and review summary.

### 2. Stitch Habits -> HabitsPage

- Local reference: `.ai_reference/stitch/screenshots/02_habits.png`, `.ai_reference/stitch/html/02_habits.html`.
- Flutter file: `lib/features/habits/presentation/pages/habits_page.dart`.
- Sections to implement:
  - compact habit status header and circular progress/check-in stage.
  - segmented action surface for daily check-in, makeup, and skip.
  - metric/status panels from real templates and records.
  - rebuilt habit cards with dark narrow panels, ring/heatmap/activity visuals, reminders, lifecycle, and plan link state.
  - existing detail sheets for record preview, image proof, stats, reminders, and lifecycle retained.
- Store fields used:
  - `HabitsStore.habits`, `pausedHabits`, `archivedHabits`, `completedCount`, `remainingCount`, `totalCheckInsToday`, `templatesForHabit`, `recordsForHabit`, `recordDateGroupsForHabit`, `metricSummaryForHabit`, `recentActivityDays`, `currentMonthActivity`.
- Real actions preserved:
  - create habit, edit habit, daily check-in, makeup, skip, reminders, lifecycle, monthly records, statistics, image attachments, metric inputs, plan linking.
- Widgets/components to create/use:
  - `VisualDnaRingGauge`, `VisualDnaSegmentedActions`, `VisualDnaHeatmap`, `VisualDnaMetricGrid`, `VisualDnaCommandCard`, `VisualDnaStatusPill`.
- Old UI sections to remove:
  - old soft/product-style habit cards where they conflict with the Stitch record/check-in console.
- Must not be faked:
  - habit count, completion ring, metric values, record preview, heatmaps, lifecycle counts, plan-link state.

### 3. Stitch Plan -> GoalsPage

- Local reference: `.ai_reference/stitch/screenshots/03_plan.png`, `.ai_reference/stitch/html/03_plan.html`.
- Flutter file: `lib/features/goals/presentation/pages/goals_page.dart`.
- Sections to implement:
  - strategic command header and "Discipline is the Bridge to Goals." hero.
  - system status/intensity/focus chips based on real task progress and overdue/due-today state.
  - strategic pillar cards backed by real goals/projects/task groups.
  - progress bars and allocation cards derived from real task/project counts.
  - milestone log rows from real projects/tasks/records.
  - existing hierarchy cards and dialogs retained below dashboard sections.
- Store fields used:
  - `GoalsStore.goals`, `projects`, `subprojects`, `tasks`, `records`, `completedCount`, `totalCount`, `computeGoalProgress`, `computeProjectProgress`, `recordsForProject`, `isProjectDueToday`, `isTaskDueToday`, `isProjectOverdue`, `isTaskOverdue`.
- Real actions preserved:
  - create/edit goal, project, subproject, task
  - task toggle
  - project/task records and attachments
  - search/filter/sort
- Widgets/components to create/use:
  - `VisualDnaCommandHeader`, `VisualDnaMetricGrid`, `VisualDnaProgressRow`, `VisualDnaMiniBars`, `VisualDnaActionRow`, `VisualDnaStatusPill`.
- Old UI sections to remove:
  - generic "计划你的长期推进" header as the primary first screen.
- Must not be faked:
  - pillar values, progress percentages, milestone rows, status chips, due/overdue counts.

### 4. Stitch Focus -> FocusPage

- Local reference: `.ai_reference/stitch/screenshots/04_focus.png`, `.ai_reference/stitch/html/04_focus.html`.
- Flutter file: `lib/features/focus/presentation/pages/focus_page.dart`.
- Sections to implement:
  - black/cyan Focus command header.
  - large circular timer ring with real `formattedRemaining`.
  - primary pause/start/resume and stop/reset controls.
  - focus score/status panel from real weekly sessions and current status.
  - weekly distribution bar chart from `weeklyDayCounts`.
  - heatmap grid from real recent sessions.
  - target and duration controls retained as functional panels.
- Store fields used:
  - `FocusStore.formattedRemaining`, `remainingSeconds`, `activeDurationSeconds`, `selectedDurationSeconds`, `status`, `canStart`, `canPause`, `canReset`, `weeklySessionCount`, `weeklyFocusMinutes`, `weeklyDayCounts`, `recentDayCounts`, `sessions`, `currentTarget`.
  - `GoalsStore.tasks` for selectable targets.
- Real actions preserved:
  - select target, clear target, select duration, custom duration, start, pause, reset.
- Widgets/components to create/use:
  - `VisualDnaRingGauge`, `VisualDnaMetricGrid`, `VisualDnaMiniBars`, `VisualDnaHeatmap`, `VisualDnaCommandCard`.
- Old UI sections to remove:
  - old text-first focus header and non-Stitch timer panel framing.
- Must not be faked:
  - timer, status, target count, weekly bars, heatmap, session counts.

### 5. Stitch My / Settings -> SettingsPage

- Local reference: `.ai_reference/stitch/screenshots/05_my_settings.png`, `.ai_reference/stitch/html/05_my_settings.html`.
- Flutter file: `lib/features/settings/presentation/pages/settings_page.dart`.
- Sections to implement:
  - OPTIMIZE/system-control header.
  - Appearance card with active state, theme mode controls, primary accent, hex label, density/status labels.
  - Data protection/local-only card adapted to this app without cloud/login features; no cloud sync implementation.
  - Account/local profile card adapted as local device summary.
  - Theme Studio color controls retained and visually restyled.
  - local data summary retained.
  - Review access row/link.
- Store fields used:
  - `AppSettingsStore.themeMode`, `accentColor`, `customBackgroundColor`, `customSurfaceColor`, setters/resetters.
  - `HabitsStore.habits`, `GoalsStore.tasks`, `FocusStore.completedSessionCount`.
- Real actions preserved:
  - theme mode change, accent/background/surface color change, reset controls.
  - no login/logout/cloud sync/biometric feature added.
- Widgets/components to create/use:
  - `VisualDnaCommandHeader`, `VisualDnaStatusPill`, `VisualDnaSwatchRow`, `VisualDnaCommandCard`, `VisualDnaMetricGrid`.
- Old UI sections to remove:
  - generic future placeholder sections as primary visual content.
- Must not be faked:
  - theme state, color hex, local counts, theme studio controls.

### 6. ReviewPage -> Preserved And Reachable

- Flutter file: `lib/features/review/presentation/pages/review_page.dart`.
- Reference language: same Stitch cards, metrics, progress rows, mini bars, and dark console shell.
- Access path:
  - Today end-of-day/reflection card opens `AppRoute.review`.
  - My/Settings review row opens `AppRoute.review`.
- Store fields used:
  - existing `_ReviewData.fromStores` from `HabitsStore`, `GoalsStore`, and `FocusStore`.
- Real actions preserved:
  - read-only review summaries remain based on real store data.
- Old UI sections to remove:
  - product-style section panels that do not match dark Stitch console where practical.
- Must not be faked:
  - all review metrics and progress values.

## AppShell And Navigation

- Flutter file: `lib/shared/widgets/app_shell.dart`.
- Bottom navigation must be five core tabs:
  - Today -> `AppRoute.today`
  - Habits -> `AppRoute.habits`
  - Plan -> `AppRoute.goals`
  - Focus -> `AppRoute.focus`
  - My -> `AppRoute.settings`
- Review is removed from bottom navigation but remains reachable from Today and Settings.
- Router current indexes update:
  - Today 0, Habits 1, Goals/Plan 2, Focus 3, Settings/My 4.
  - Review can use no bottom nav or a neutral shell while reachable through links.

## Verification Plan

- Prove usage with:
  - `rg "VisualDna|VisualDNA|Stitch|Command|Metric|Heatmap|Neon|ThemeStudio|My" lib/features lib/shared lib/app`
  - `git diff --stat`
  - `git diff --name-only`
- Requested verification:
  - `D:\ai\flutter\bin\dart.bat format .`
  - `D:\ai\flutter\bin\flutter.bat analyze`
  - `D:\ai\flutter\bin\flutter.bat test`
  - `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321 --no-resident`
- Project rule note: repository `AGENTS.md` forbids `dart format` without `-o none` unless a specific file is explicitly formatted. If the exact requested format command conflicts at verification time, run the non-mutating format check variant and report the constraint.
