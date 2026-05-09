# UI Reference Components

This component guide translates the source-app screenshots into reusable app-native component directions. These are product/UI targets, not implementation code.

## TodayHero

- Source inspiration: OffScreen large metric surfaces; HabitDone daily overview.
- Purpose: Make `今日` feel like the daily command center.
- Visual traits: Soft surface, large short headline, 2-3 key metrics, low-saturation accent, generous whitespace.
- Where used: Top of `今日`.
- Must not become: A dense dashboard, screen-time report, or full analytics page.
- First implementation package: Package B, Today + Plan Source UI Alignment.

## DailyMetricStrip

- Source inspiration: OffScreen metric cards; HabitDone overview counters.
- Purpose: Show today's most important status at a glance.
- Visual traits: Compact metric cells, large number, short label, no long explanations.
- Where used: `今日`, later `复盘`.
- Must not become: A grid of every possible statistic.
- First implementation package: Package B.

## HabitIdentityCard

- Source inspiration: HabitDone habit cards and create/edit surfaces.
- Purpose: Make each habit read as a personalized repeatable behavior.
- Visual traits: Emoji/icon identity, name, description, `今日 X / Y`, reminder line, mini activity strip, accent-aware state.
- Where used: `/habits`, Today habit previews in smaller form.
- Must not become: A todo row, heavy settings card, or archive/edit/delete surface.
- First implementation package: Package A, Habits Month Heatmap Bug + Habit Visual Polish.

## HabitMiniHeatmap

- Source inspiration: HabitDone heatmap/activity grids.
- Purpose: Show recent activity without opening analytics.
- Visual traits: Small 7-day count-aware cells; clear 0 / 1 / 2 / 3+ intensity; theme-aware calm colors.
- Where used: HabitIdentityCard, Today habit preview only if it stays light.
- Must not become: Full yearly heatmap or chart dashboard.
- First implementation package: Package A.

## HabitMonthHeatmap

- Source inspiration: HabitDone calendar/month views and activity grids.
- Purpose: Show current-month habit activity clearly.
- Visual traits: Month grid, readable day cells, count intensity, no overflow, short legend.
- Where used: Habits page dialog/bottom sheet.
- Must not become: Full analytics center, yearly heatmap, streak protection, makeup editor, or chart package.
- First implementation package: Package A.

## PlanGoalCard

- Source inspiration: DayMark project list cards; OffScreen restrained surfaces.
- Purpose: Represent a goal as a structured planning object.
- Visual traits: Goal identity marker, title hierarchy, project/action count, progress badge or progress rail, one focused structure entry.
- Where used: `计划` goal list.
- Must not become: A direct checkbox goal row or dense project settings panel.
- First implementation package: Package B.

## PlanTreeView

- Source inspiration: DayMark hierarchy/project/subproject structure.
- Purpose: Make Goal -> Project -> Subproject -> Action readable on phone.
- Visual traits: Indentation, quiet dividers, subtle connector lines, progress rollup, neutral empty cues.
- Where used: `计划` in-page hierarchy and focused structure view.
- Must not become: Infinite nested tree editor or admin planning dashboard.
- First implementation package: Package B.

## FocusTimerHero

- Source inspiration: OffScreen focus timer hero; Tomato ToDo execution center.
- Purpose: Make the focus timer visually central and action-oriented.
- Visual traits: Large timer, strong circular/hero surface, calm status label, clear controls, duration choices below.
- Where used: `专注`.
- Must not become: Foreground service UI, strict mode, white noise, task-binding flow, or colorful Tomato ToDo clone.
- First implementation package: Package C, Focus + Review Source UI Alignment.

## ReviewMetricPanel

- Source inspiration: OffScreen data charts and large metric panels.
- Purpose: Make `复盘` feel like a calm data review page.
- Visual traits: Large factual metric, short supporting copy, soft panel, simple real-data visual only when available.
- Where used: `复盘`, later detailed review pages.
- Must not become: Fake analytics, chart-heavy dashboard, or digital wellbeing report before data exists.
- First implementation package: Package C.

## MySettingsSection

- Source inspiration: HabitDone personalization settings; OffScreen restraint.
- Purpose: Make `我的` feel like a personal center without fake functionality.
- Visual traits: Clean list section, clear functional rows, honest disabled/future rows, accent preview.
- Where used: `我的`.
- Must not become: Theme marketplace, advanced customization panel, or crowded settings catalog.
- First implementation package: Later P2 My personalization polish.

## Cross-Component Rules

- Use source-app traits, not source-app cloning.
- Keep Chinese copy short and product-like.
- Prefer soft surfaces and clear hierarchy over more cards.
- Keep high-frequency actions one step away.
- Do not introduce fake data visuals.
- Keep all components aligned through shared spacing, radius, typography, and accent behavior.
