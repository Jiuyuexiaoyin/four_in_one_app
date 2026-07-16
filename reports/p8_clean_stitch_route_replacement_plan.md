# P8 Clean Stitch Route Replacement Plan

## Source Of Truth

- Stitch project: `projects/9558614255557019910`
- Project name: `app`
- Fresh metadata: `.ai_reference/stitch/metadata/screen_index.json`
- Fresh spec: `.ai_reference/stitch/spec/stitch_visual_spec.md`
- Stale backup: `.ai_reference/stitch_backup_before_clean_20260708_162024`

No previous extraction report or previous route implementation is treated as visual truth.

## Shared Implementation

Files:
- Modify `lib/shared/widgets/app_shell.dart`
- Create/update `lib/shared/widgets/visual_dna/`
- Theme files allowed if needed: `lib/app/theme/app_theme.dart`, `lib/app/theme/app_theme_tokens.dart`

Components needed:
- Stitch page scaffold padding and dark canvas helpers.
- Fixed-style dark neon bottom nav for `Today / Habits / Plan / Focus / My`.
- Command header, section label, dark command panel, metric tiles, circular metrics, progress rails, mini bars, line chart, heatmap grid, protocol rows, utility rows, and icon pills.

AppShell changes:
- Replace Material `NavigationBar` look with a custom frosted Stitch-style nav.
- Keep route order: Today, Habits, Plan, Focus, My.
- Keep Review outside bottom nav.
- Preserve `AppRoute.review` through Today and My entries.

Must not fake:
- No fake metrics, counts, chart values, progress values, heatmap values, or storage summaries.
- No replacement of `HabitsStore`, `GoalsStore`, `FocusStore`, or `AppSettingsStore`.
- No login, sync, backend, migration, version bump, or release build.

## 1. Stitch Today -> TodayPage

Fresh local files:
- Screenshot: `.ai_reference/stitch/screenshots/01_today.png`
- HTML: `.ai_reference/stitch/html/01_today.html`

Flutter file:
- `lib/features/today/presentation/pages/today_page.dart`

Old UI sections to remove/overwrite:
- Generic VisualDna command header and multi-card dashboard from the rejected attempt.
- Extra plan/focus summary cards that push the screen away from the Stitch dashboard hierarchy.

New Stitch sections to implement:
- Top command row with `今日 / TODAY` and My shortcut.
- Huge Focus Score percentage from real aggregate progress.
- Peak Rhythm status cue from real activity state.
- Three momentum circular metrics: habit completion, plan progress, recent streak/activity.
- Priority Execute card bound to next incomplete task, next pending habit, or focus fallback.
- Focus Flux line chart from real recent habit + focus activity.
- Action Plan timeline from real tasks and pending habits.
- Review access card or utility row.

Real Store fields used:
- `HabitsStore.habits`, `completedCount`, `totalCount`, `totalCheckInsToday`, `currentDayKey`, `isCompletedToday`, `todayCheckInCount`, `recentActivityDays`, `checkIn`.
- `GoalsStore.tasks`, `records`, `goals`, `projects`, `subprojects`, `computeGoalProgress`.
- `FocusStore.sessions`, `recentDayCounts`, `selectedDurationSeconds`, `status`, `formattedRemaining`, `isRunning`, `isPaused`, `currentTarget`.

Real actions preserved:
- Habit check-in for the next pending habit.
- Navigate to Habits, Plan, Focus, My, and Review.
- No direct fake task completion from Today unless using existing store action deliberately.

Visual components needed:
- `StitchHeroScore`, `StitchCircularMetric`, `StitchStatusCue`, `StitchActionTimeline`, `StitchLineChart`.

What must not be faked:
- Score, completion rings, timeline content, and flux values must derive from store data. Empty state text is acceptable when data is absent.

## 2. Stitch Habits -> HabitsPage

Fresh local files:
- Screenshot: `.ai_reference/stitch/screenshots/02_habits.png`
- HTML: `.ai_reference/stitch/html/02_habits.html`

Flutter file:
- `lib/features/habits/presentation/pages/habits_page.dart`

Old UI sections to remove/overwrite:
- Rejected `_HabitsStitchStage`/generic VisualDna stats ordering if it does not match the clean Stitch structure.
- Product-style old list-card feel for active habits.

New Stitch sections to implement:
- `STRIVE` command header with add habit action.
- System Integrity card using real daily readiness/completion.
- Current Cadence card using next incomplete habit, real target and today count.
- Daily Rhythm weekly bar chart from real weekly habit counts.
- Active Protocols habit cards with icon tile, name/subtitle, streak/activity count, seven-day sequence dots, and action buttons.
- Lifecycle sections for paused and archived habits restyled in the same command language.

Real Store fields used:
- `HabitsStore.habits`, `pausedHabits`, `archivedHabits`, `totalCount`, `completedCount`, `remainingCount`, `totalCheckInsToday`, `records`, `todayCheckInCount`, `isCompletedToday`, `isSkippedToday`, `recentActivityDays`, `currentMonthActivity`, `statisticsForHabit`, `templatesForHabit`, `metricSummaryForHabit`.
- `GoalsStore` only for existing habit-plan link summaries/actions.

Real actions preserved:
- Create habit dialog.
- Edit habit dialog.
- Check-in action.
- Reminder picker.
- Month activity dialog.
- Record details sheet.
- Statistics sheet.
- Lifecycle sheet.
- Existing attachment and metric flows.

Visual components needed:
- `StitchReadinessCard`, `StitchCadenceCard`, `StitchMiniBars`, `StitchProtocolCard`, `StitchSequenceDots`.

What must not be faked:
- Daily readiness, rhythm bars, sequence dots, streak/activity counts, and card completion states must be derived from `HabitsStore`.

## 3. Stitch Plan -> GoalsPage

Fresh local files:
- Screenshot: `.ai_reference/stitch/screenshots/03_plan.png`
- HTML: `.ai_reference/stitch/html/03_plan.html`

Flutter file:
- `lib/features/goals/presentation/pages/goals_page.dart`

Old UI sections to remove/overwrite:
- Generic `strategic command` top card from rejected attempt.
- Old product-style hierarchy as the first visible experience.

New Stitch sections to implement:
- Mobile header/hero with `核心意图 // CORE INTENT` and `Discipline is the Bridge to Goals.`
- Intent description panel with real intensity/focus/due/overdue chips.
- Strategic Pillars grid using the first real goals/projects/tasks.
- Milestone Log from real records and incomplete/completed tasks.
- Restyled full hierarchy remains below or in sheets so all create/edit actions stay reachable.

Real Store fields used:
- `GoalsStore.goals`, `projects`, `subprojects`, `tasks`, `records`, `totalCount`, `completedCount`, `computeGoalProgress`, `computeProjectProgress`, `computeSubprojectProgress`, `projectCountForGoal`, `taskCountForGoal`, `isProjectDueToday`, `isTaskDueToday`, `isProjectOverdue`, `isTaskOverdue`, `recordsForProject`, `recordsForTask`, `computeProjectRecordStats`.

Real actions preserved:
- Create/edit goal.
- Create/edit project.
- Create/edit subproject.
- Create/edit/toggle task.
- Create project/task records.
- Record attachment flow.
- Goal structure and project detail sheets.

Visual components needed:
- `StitchIntentHero`, `StitchPillarGrid`, `StitchPillarCard`, `StitchMilestoneLog`, `StitchProgressRail`.

What must not be faked:
- Pillar count/progress/log statuses must use real goals/projects/tasks/records. Empty state cards must invite real creation.

## 4. Stitch Focus -> FocusPage

Fresh local files:
- Screenshot: `.ai_reference/stitch/screenshots/04_focus.png`
- HTML: `.ai_reference/stitch/html/04_focus.html`

Flutter file:
- `lib/features/focus/presentation/pages/focus_page.dart`

Old UI sections to remove/overwrite:
- Large ring gauge as the dominant hero.
- Generic dashboard card stack that does not match the fresh cockpit.

New Stitch sections to implement:
- Hero Execution Cockpit with `实时心流状态 / FLOW STATUS`.
- Huge timer text from `FocusStore.formattedRemaining`.
- Horizontal elapsed progress rail from active/remaining seconds.
- Current peak/status metric from real status/target.
- Start/Pause/Resume/Reset controls in Stitch pill style.
- Focus Score card from real weekly minutes/sessions.
- Weekly Distribution bar chart from `weeklyDayCounts`.
- Heatmap from real recent focus sessions.
- Target selector and duration selector restyled under cockpit.

Real Store fields used:
- `FocusStore.status`, `remainingSeconds`, `selectedDurationSeconds`, `activeDurationSeconds`, `formattedRemaining`, `canStart`, `canPause`, `canReset`, `isIdle`, `isRunning`, `isPaused`, `currentTarget`, `selectedTarget`, `sessions`, `completedSessionCount`, `weeklyDayCounts`, `weeklyFocusMinutes`, `weeklySessionCount`.
- `GoalsStore.tasks`, `projects`, `goals`, `subprojects` for target selection.

Real actions preserved:
- Start.
- Pause.
- Resume via start when paused.
- Reset.
- Select/clear target.
- Duration choices and custom duration dialog.

Visual components needed:
- `StitchFocusCockpit`, `StitchTimerText`, `StitchMiniBars`, `StitchHeatmap`, `StitchControlButtons`.

What must not be faked:
- Focus score, weekly distribution, and heatmap must use real focus sessions. Empty focus history remains empty.

## 5. Stitch My / Settings -> SettingsPage

Fresh local files:
- Screenshot: `.ai_reference/stitch/screenshots/05_my_settings.png`
- HTML: `.ai_reference/stitch/html/05_my_settings.html`

Flutter file:
- `lib/features/settings/presentation/pages/settings_page.dart`

Old UI sections to remove/overwrite:
- Current ordering with generic control console first.
- Product `MySettingsSection` visual style where it conflicts with the clean Theme Studio layout.

New Stitch sections to implement:
- Sticky-like command header feel with `STRATEGIC COMMAND`.
- Theme Studio hero.
- Color Lab section with matrix-style visual picker, hue/luminance/readout mapping to existing theme controls.
- Global Controls for theme mode and safe color controls.
- Utility rows for reminders placeholder, privacy/security placeholder, local data summary, and Review access.

Real Store fields used:
- `AppSettingsStore.themeMode`, `accentColor`, `customBackgroundColor`, `customSurfaceColor`, `setThemeMode`, `setAccentColor`, `setBackgroundColor`, `setSurfaceColor`, `resetAllColors`.
- `HabitsStore.habits`, `records`.
- `GoalsStore.goals`, `projects`, `subprojects`, `tasks`, `records`.
- `FocusStore.completedSessionCount`, `sessions`.

Real actions preserved:
- Theme mode selection.
- Color studio visual picker and preset/advanced inputs.
- Reset theme colors.
- Navigate to Review.
- Local data summary.

Visual components needed:
- `StitchThemeHero`, `StitchColorLab`, `StitchUtilityRow`, `StitchSwatchRow`.

What must not be faked:
- Hex/RGB readouts must reflect `AppSettingsStore.accentColor`.
- Local storage summary must use real local counts, not the Stitch `1.2 GB`.

## 6. ReviewPage -> Preserve And Expose

Fresh local files:
- No Stitch route. Must use the same visual language.

Flutter file:
- `lib/features/review/presentation/pages/review_page.dart`

Old UI sections to remove/overwrite:
- Generic product panels if they visually break from the Stitch system.

New Stitch sections to implement:
- Audit-log command header.
- Dashboard metrics using real review data.
- Habit, Plan, and Focus review panels using progress rails, bars, and heatmaps.

Real Store fields used:
- Existing `_ReviewData.fromStores` derived from `HabitsStore`, `GoalsStore`, and `FocusStore`.

Real actions preserved:
- Review remains navigable at `AppRoute.review`.
- Entry points from Today and My/Settings.

What must not be faked:
- Review metrics and charts must remain store-derived.
