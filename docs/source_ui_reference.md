# Source UI Reference

This document anchors future UI and product work to the original source-app direction. The app must not drift into a generic Flutter MVP, a stitched set of modules, or a plain habit/todo/timer demo.

## Product Synthesis

The target product feeling is:

- Lightweight like HabitDone.
- Premium and restrained like OffScreen.
- Structured like DayMark.
- Action-oriented like Tomato ToDo.
- Calm, low-saturation, spacious, and clear.
- Feature-rich in capability, but visually simple in daily use.
- Not card-heavy, not an admin dashboard, and not a generic Flutter demo.

Future UI work should inherit concrete traits from the references without copying any app wholesale. The product must feel unified, not like four separate apps placed under one bottom navigation.

## DayMark UI Reference

DayMark should guide the `计划` / planning experience.

Key UI traits:

- Project cards with icon, color, progress/count badge.
- Small progress dots or micro history indicators.
- Project history record page.
- Project statistics with calendar and charts.
- Project graph / yearly heatmap.
- Add/edit project with icon, color, group, subproject, reminder/settings.

Required direction for this app:

- `计划` must not feel like a flat checklist.
- `计划` should feel like goal tree + project tree + action progress.
- Use hierarchy, progress rollup, color identity, focused structure view, and later history/stat views.
- Keep planning clean and readable on phone, not dashboard-heavy.
- Treat task/action as the executable unit, while goals/projects carry structure and progress.

Do not copy:

- DayMark's exact layouts, branding, icons, or visual density.
- Heavy statistics screens before the underlying data is real.
- Complex project settings before the core planning loop is clear.

## HabitDone UI Reference

HabitDone should guide the Habits experience.

Key UI traits:

- Lightweight habit cards.
- Habit identity: icon/emoji, name, description.
- Multiple daily check-ins.
- Target count per day.
- Reminders.
- Heatmap / activity visualization.
- Customization and theme friendliness.
- Personalization controls like heatmap color/background/shadow.

Required direction for this app:

- Habits must not feel like a todo list.
- Habits should feel like daily habit tracking.
- Show `今日 X / Y`, multiple check-ins, recent 7-day activity, monthly heatmap, and reminder state.
- Improve habit card visual identity and heatmap clarity over time.
- Keep the daily check-in loop low-friction and friendly.
- Later add notes, proof/photo, skip/makeup, streak, archive/edit/delete.

Do not copy:

- Busy customization panels too early.
- Full yearly heatmap before monthly/recent activity is clear.
- Social or gamified mechanics that do not fit the calm product tone.

## OffScreen UI Reference

OffScreen should guide the premium visual tone and the Review / Focus data pages.

Key UI traits:

- Soft pastel backgrounds.
- Large whitespace.
- Large focused data visuals.
- Circle charts / bar charts / usage timelines.
- Calm cards, not dense dashboards.
- Focus timer with strong visual center.

Required direction for this app:

- UI should feel premium, restrained, low-saturation, and spacious.
- Review should not stay as plain text blocks.
- Focus timer should be a strong visual center.
- Today and Review should use larger key metrics and calmer spacing.
- Data visualizations should feel soft and focused, not enterprise-dashboard-like.
- Avoid heavy shadows, crowded cards, dense tables, and noisy chart panels.

Do not copy:

- Any visual that implies unavailable digital wellbeing data.
- Heavy analytics before real history exists.
- Overly decorative effects that compete with the daily workflow.

## Tomato ToDo UI Reference

Tomato ToDo should guide the execution layer.

Key UI traits:

- Colorful task/focus blocks.
- Clear Start action on tasks.
- Future countdown / task management.
- Weekly focus overview with time blocks.
- Focus is tied to task execution, not only an isolated timer.

Required direction for this app:

- Focus should later bind to tasks/goals/habits.
- Plan should expose executable actions that can start focus.
- Focus should later support pomodoro mode, count-up/down, strict mode, interruption records, and weekly focus overview.
- Focus should feel like the execution layer of the whole app, not only a timer page.

Do not copy:

- Heavy strict-mode or blocking behavior before user trust and platform constraints are clear.
- Colorful density that conflicts with the app's restrained OffScreen-like tone.
- Task execution flows that bypass the DayMark-style planning hierarchy.

## Current App Problem

The current app has made meaningful progress, but it still risks looking like:

- Generic cards.
- Feature modules stitched together.
- Functionally correct but visually rough.
- Habits and Plan improved, but not yet close enough to the source-app product feel.
- Review and Today too close to text summaries instead of calm data/product surfaces.
- Focus reliable, but not yet tied to planning execution.

Future work must move from "feature exists" toward "product-quality interaction."

## Future UI Acceptance Rule

For every future UI or product package, Codex must state before coding:

1. Which source app UI reference it is following.
2. Which concrete UI traits are being inherited.
3. What it will not copy.
4. How it keeps the app unified instead of becoming four separate apps.
5. How it keeps the UI minimal and premium.

## Unified Design Guardrails

- `今日` stays the high-frequency daily center.
- `计划` carries DayMark-style hierarchy and progress.
- `专注` carries Tomato ToDo-style execution and reliable timer behavior.
- `复盘` carries OffScreen-style calm metrics and honest review.
- `我的` carries personalization, appearance, reminders, privacy, backup/export, and version.
- Habits remain HabitDone-style daily tracking, exposed from Today and Plan without becoming a generic todo list.
- Theme/accent customization is a core product capability, not polish.
- Every screen should use calm hierarchy, readable spacing, and low-saturation accent-aware styling.
