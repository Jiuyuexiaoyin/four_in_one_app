# UI Direction

The visual direction should stay lightweight, premium, restrained, calm, and clearly tied to the source-app references in `docs/source_ui_reference.md`, `docs/visual_gap_audit_v1.md`, and `docs/ui_reference_components.md`.

## Source-App Roles

- DayMark guides `计划`: goal tree, project tree, action progress, hierarchy, progress rollup, focused structure, and later history/stat views.
- HabitDone guides Habits: lightweight habit cards, identity, target count, multiple check-ins, reminders, recent activity, heatmap-like views, and customization friendliness.
- OffScreen guides the premium tone: soft spacing, low-saturation color, large focused metrics, calm data visuals, and restrained review/focus surfaces.
- Tomato ToDo guides execution: reliable focus, clear start behavior, task-linked focus later, pomodoro modes later, and weekly focus overview later.

## Global Visual Rules

- Keep spacing clean and generous.
- Prefer low-saturation colors and soft accent-aware states.
- Avoid card-heavy layouts.
- Avoid admin-dashboard-like screens.
- Avoid crowded controls and dense analytics by default.
- Keep the interface low-friction for daily use.
- Treat theme/accent customization as a core product feature, not optional polish.
- Prefer larger key metrics, calm section rhythm, and clear hierarchy over generic stacked cards.
- Do not show fake analytics or data visuals before the app has real data.

## Feature-Specific UI Direction

- `今日` should feel like a high-frequency daily center, not a dashboard of unrelated modules.
- `计划` should feel structured and DayMark-like, not a flat checklist.
- Habits should feel like HabitDone-style daily tracking, not todo completion.
- `专注` should have a strong visual timer center and later connect to executable actions.
- `复盘` should feel like calm reflection with honest metrics, not placeholder text or fake trends.
- `我的` should feel like a personal/settings center with appearance and future privacy/reminder/backup/version areas.

## Future UI Package Checklist

Before coding any future UI/product package, state:

1. Which source app UI reference is being followed.
2. Which local reference folder/screenshots were inspected.
3. Which concrete UI traits are being inherited.
4. What will not be copied.
5. How the app remains unified instead of becoming four separate apps.
6. How the UI stays minimal, premium, and restrained.

## Alpha Reminder

The current MVP UI is a functional starting point, not the final visual quality bar. Future UI work should improve product feeling while preserving clarity, restraint, and the four-in-one product direction.
