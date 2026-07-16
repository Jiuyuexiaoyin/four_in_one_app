# P8 Before Pixel Rewrite Snapshot

## Current changed files

`git status --short` shows a dirty worktree from previous UI attempts:

- Modified route/UI files: `lib/shared/widgets/app_shell.dart`, `lib/app/router/app_router.dart`, `lib/features/today/presentation/pages/today_page.dart`, `lib/features/habits/presentation/pages/habits_page.dart`, `lib/features/goals/presentation/pages/goals_page.dart`, `lib/features/focus/presentation/pages/focus_page.dart`, `lib/features/settings/presentation/pages/settings_page.dart`, `lib/features/review/presentation/pages/review_page.dart`.
- Modified support files include theme/product widgets and stores: `lib/app/theme/*`, `lib/shared/widgets/product/*`, `lib/features/*/application/*`, storage/model helpers, and `pubspec.lock`.
- Modified tests include smoke, today, habits, focus, goals, review, and settings tests.
- Untracked folders: `.playwright-mcp/`, `lib/shared/widgets/visual_dna/`, `reports/`.

`git diff --stat` reports `30 files changed, 2601 insertions(+), 2335 deletions(-)` before this pixel rewrite phase.

## Previous VisualDna files

Previous VisualDna/Stitch generic component files exist under:

- `lib/shared/widgets/visual_dna/visual_dna_widgets.dart`
- `lib/shared/widgets/visual_dna/stitch_widgets.dart`

These files define generic `VisualDna*` and `Stitch*` components such as `StitchPanel`, `StitchCommandHeader`, `VisualDnaPanel`, and chart/progress helpers.

## Active routed pages currently using previous rejected UI

The active routed pages import/use the previous rejected generic visual layer:

- `TodayPage` uses `StitchPanel`, `StitchCapsLabel`, `StitchLineChart`, and still contains labels such as `Peak Rhythm`.
- `HabitsPage` uses mixed `Stitch*` and `VisualDna*` widgets, including `_HabitsVisualDnaStats`.
- `GoalsPage` uses `StitchCommandHeader`, `StitchPanel`, and strategic-command labels.
- `FocusPage` uses `StitchCommandHeader`, `StitchPanel`, and `Flow Status`.
- `SettingsPage` uses `StitchCommandHeader`, `StitchPanel`, `Theme Studio`, and `Global Controls`.
- `ReviewPage` uses both `Stitch*` and `VisualDna*` widgets.
- `AppShell` has already been changed to a four-tab model, but it is still a generic Flutter `NavigationBar` shell, not an exact export-modeled bottom dock.

## Files likely to be overwritten

This phase will overwrite or structurally replace:

- `lib/shared/widgets/app_shell.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`

This phase will create a new exact export component layer:

- `lib/shared/widgets/stitch_exact/`

The previous `visual_dna` folder may remain in the tree for compatibility, but active route files should move to `StitchExact` components where practical.
