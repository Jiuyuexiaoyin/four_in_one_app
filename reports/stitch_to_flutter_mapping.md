# Stitch To Flutter Mapping

Date: 2026-07-07

## Baseline State

- Repo: `D:\ai\projects\four_in_one_app`
- Branch: `p7-ui-foundation`
- Existing dirty state before this phase: `pubspec.lock` modified, `reports/` untracked
- Flutter SDK used by baseline: `D:\ai\flutter`, Flutter `3.44.4`, Dart `3.12.2`
- Current routes: `/`, `/today`, `/habits`, `/goals`, `/focus`, `/review`, `/settings`
- Current bottom navigation: Today, Habits, Plan, Focus, Review; Settings is reached from the app bar/settings icon and is not a bottom tab
- Existing analyze failure: `lib/features/today/presentation/pages/today_page.dart:72`, deprecated `cacheExtent`; Flutter recommends `scrollCacheExtent`
- Existing test failures: `flutter test` reported `+165 -7`; main failure class is Flutter `ListTile` decorated-background assertions in areas including `app_smoke_test.dart` and `settings_theme_test.dart`
- Chrome baseline launch: succeeded; screenshots are in `reports/p8_flutter_baseline_screenshots/`

## Stitch Access

- Stitch project found: `projects/9831732537281731917`
- Project title: `Duplicate of Duplicate of Visual DNA Analysis`
- Access result: available through Stitch MCP
- Generated HTML body fetch: blocked by local network sandbox; MCP still provided project metadata, screen metadata, screenshot URLs, and design system data

## Stitch Visual DNA Extracted

- Design system name: `Premium Performance`
- Color mode: dark
- Palette: true-dark graphite and black surfaces, electric cyan primary (`#00e5ff` / `#c3f5ff`), neon purple secondary (`#8a2be2` / `#dcb8ff`), acid green tertiary (`#76ff03` / `#bcff90`), low-opacity white borders
- Typography: Hanken Grotesk for display/data, Inter for body, JetBrains Mono for labels/data accents
- Spacing: 8px grid, compact stacks, mobile container padding around 20px
- Radius: 4px to 8px for cards/panels, pills reserved for buttons/chips/toggles
- Depth: tonal layering, translucent dark overlays, subtle cyan/purple/green glows, thin low-contrast borders instead of heavy shadows
- Patterns: compact metric tiles, glowing outlined panels, edge-to-edge progress bars, mini charts with thin grid lines, heatmap/activity strips, floating blurred bottom navigation with active cyan glow

## Selected Stitch Screen Targets

The project contains many variants. The implementation will use the following prepared targets because they best match the requested five app screens and existing Flutter functionality:

1. Today dashboard: `Today: Hero Metric Direction`, screen `0ae315275e0e4884a5f112e91dee855f`
2. Habits / stats page: `习惯：高阶节奏指挥中心 (Final Synthesis)`, screen `66bef2188f8b40b287e7253fec504190`
3. Plan page: `计划：执行路径 (Execution Pathway)`, screen `feda35ea5b8a46e281b12599764e49c5`
4. Focus page: `专注：高阶执行指挥中心 (Final Synthesis)`, screen `c87c9f96d44843368bfe0bb78e1a5b28`
5. My / personal settings page: `我的：主题工作室 (Theme Studio Hero)`, screen `e03b33d46f8646f39fec5cf10373156a`
6. Review: no dedicated Stitch screen; restyle with the same Visual DNA and keep reachable from bottom navigation

## Screen Mapping

### 1. Stitch Today -> TodayPage

- Flutter file: `lib/features/today/presentation/pages/today_page.dart`
- Store data required: `HabitsStore.habits`, `completedCount`, `totalCount`, `totalCheckInsToday`, `currentDayKey`; `GoalsStore.goals`, `projects`, `subprojects`, `tasks`, `records`; `FocusStore.sessions`, `status`, `formattedRemaining`, `selectedDurationSeconds`, `currentTarget`
- Real actions required: navigate to Habits, Goals, Focus, and Review; habit quick check-in may call `HabitsStore.checkIn` only for real active habits
- Charts/progress/heatmap source: today completion ratio from habit/action/focus data; mini activity from habit recent activity and focus sessions
- Components to create/reuse: Visual DNA page header, hero metric panel, metric tiles, progress rail, mini bar chart, activity strip, glowing panel, compact action row
- Preservation rule: all counts and progress must be computed from stores; navigation must use existing routes
- Risk of fake UI: high if hero metric or chart values are hardcoded; avoid by deriving every number from stores

### 2. Stitch Habits -> HabitsPage

- Flutter file: `lib/features/habits/presentation/pages/habits_page.dart`
- Store data required: active, paused, archived habits; check-in records; templates; reminder rules; statistics summaries; current month and recent activity data
- Real actions required: create/edit habit, check in, view records, statistics, month activity, reminder picker, lifecycle actions, plan link handling
- Charts/progress/heatmap source: `HabitsStore.recentActivityDays`, `currentMonthActivity`, `statisticsForHabit`, `todayCheckInCount`, `targetCountPerDay`
- Components to create/reuse: Visual DNA command header, habit stat deck, compact habit cards, heatmap grid, mini bar chart, outlined action buttons
- Preservation rule: habit cards must keep existing keys and call existing `HabitsStore` methods; dialogs/sheets remain functional
- Risk of fake UI: high if stats cards duplicate static sample streaks; only use real records and empty states when no records exist

### 3. Stitch Plan -> GoalsPage

- Flutter file: `lib/features/goals/presentation/pages/goals_page.dart`
- Store data required: goals, projects, subprojects, tasks, plan records, attachments, computed goal/project/subproject progress
- Real actions required: create/edit goal, project, subproject, task; toggle task completion; create project/task records; open record attachment flows; search/filter plan items
- Charts/progress/heatmap source: `GoalsStore.computeGoalProgress`, `computeProjectProgress`, `computeSubprojectProgress`, `computeProjectRecordStats`, `recordsForProject`
- Components to create/reuse: Visual DNA plan overview, metric tiles, search/filter panel, hierarchy cards, progress bars, record heatmap
- Preservation rule: hierarchy and record flows must remain intact; visual changes wrap existing behavior rather than replacing the store model
- Risk of fake UI: medium-high if roadmap/progress blocks are disconnected from `GoalsStore`; bind all hierarchy metrics to current store lists

### 4. Stitch Focus -> FocusPage

- Flutter file: `lib/features/focus/presentation/pages/focus_page.dart`
- Store data required: timer status, remaining seconds, selected and active duration, selected/current target, sessions, weekly counts, weekly minutes
- Real actions required: choose target from incomplete `GoalsStore` tasks, clear target, choose preset/custom duration, start, pause, reset
- Charts/progress/heatmap source: `FocusStore.weeklyDayCounts`, `weeklySessionCount`, `weeklyFocusMinutes`, `recentDayCounts`, timer progress from `remainingSeconds / activeDurationSeconds`
- Components to create/reuse: Visual DNA timer cockpit, circular timer painter, target selector panel, duration chips, action bar, weekly chart
- Preservation rule: timer controls must call `FocusStore.start`, `pause`, `reset`, `selectDuration`, and target methods directly
- Risk of fake UI: medium if timer ring is visual-only; keep it driven by store state

### 5. Stitch My -> SettingsPage

- Flutter file: `lib/features/settings/presentation/pages/settings_page.dart`
- Store data required: `AppSettingsStore.themeMode`, accent/background/surface colors, Habits/Goals/Focus counts for local data summary
- Real actions required: set theme mode, select color target, visual color picker, palette selection, HEX/RGB/ARGB inputs, reset current/all colors
- Charts/progress/heatmap source: none; data summary uses store counts only
- Components to create/reuse: Visual DNA settings header, segmented theme selector, dark theme preview, color studio panel, swatches, local data metric cards
- Preservation rule: theme and color controls must continue to call `AppSettingsStore` setters/resetters; existing test keys must remain available
- Risk of fake UI: medium if the theme preview becomes decorative only; keep controls live and update from store values

### 6. No Stitch Review Screen -> ReviewPage

- Flutter file: `lib/features/review/presentation/pages/review_page.dart`
- Store data required: habits totals/recent counts, goals hierarchy/action progress, focus sessions/minutes/status/recent counts
- Real actions required: review remains reachable from bottom navigation; current page is read-only and should stay read-only unless existing behavior says otherwise
- Charts/progress/heatmap source: `_ReviewData.fromStores`, `HabitsStore.recentActivityDays`, `FocusStore.recentDayCounts`, `GoalsStore.tasks`
- Components to create/reuse: Visual DNA review panels, metric strips, progress rails, activity strips
- Preservation rule: do not delete Review; restyle with the same Visual DNA while preserving real summaries
- Risk of fake UI: low-medium if the page keeps existing derived data and only changes presentation
