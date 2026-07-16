# P8 Failed Stitch Attempt Reset Audit

## Commands Run

- `git status --short`
- `git diff --stat`
- `git diff --name-only`
- `rg "VisualDna|VisualDNA|Stitch|Command|Metric|Heatmap|Neon|ThemeStudio|My" lib reports`

## Reports Read

- `reports/p8_stitch_local_ui_implementation_report.md`
- `reports/p8_stitch_route_replacement_report.md`
- `reports/p8_previous_stitch_attempt_audit.md`
- `reports/stitch_mcp_screen_extract.md`

Requested but missing:

- `reports/stitch_project_id_access_report.md`

## 1. Files Changed By The Failed UI Attempt

Current `git diff --name-only` reports modified tracked files in:

- app routing/theme: `lib/app/router/app_router.dart`, `lib/app/theme/app_theme.dart`, `lib/app/theme/app_theme_tokens.dart`
- active routed pages: `today_page.dart`, `habits_page.dart`, `goals_page.dart`, `focus_page.dart`, `settings_page.dart`, `review_page.dart`
- shell/navigation: `lib/shared/widgets/app_shell.dart`
- shared product widgets and VisualDna-related surfaces
- test files covering smoke, Today, Habits, Goals, Focus, Settings, and Review

Untracked paths include:

- `lib/shared/widgets/visual_dna/`
- `reports/`
- `.playwright-mcp/`

The diff also lists non-presentation files that were already dirty in this workspace, including store/storage/model files and `pubspec.lock`. These must not be blindly reverted.

## 2. Active Routed Pages Actually Modified

The failed attempt did modify all active target page files:

- Today: `lib/features/today/presentation/pages/today_page.dart`
- Habits: `lib/features/habits/presentation/pages/habits_page.dart`
- Plan: `lib/features/goals/presentation/pages/goals_page.dart`
- Focus: `lib/features/focus/presentation/pages/focus_page.dart`
- My / Settings: `lib/features/settings/presentation/pages/settings_page.dart`
- Review: `lib/features/review/presentation/pages/review_page.dart`
- Shell: `lib/shared/widgets/app_shell.dart`

However, the user rejected the result because the running UI did not match the Stitch target closely enough. The current code should be treated as an implementation substrate only, not as a visual source of truth.

## 3. Local Stitch References That May Be Stale

All previous local Stitch references may be stale:

- `.ai_reference/stitch/spec/stitch_visual_spec.md`
- `.ai_reference/stitch/metadata/screen_index.json`
- `.ai_reference/stitch/screenshots/*`
- `.ai_reference/stitch/html/*`

Reason:

- Earlier reports reference older project IDs and draft-heavy projects, including `9831732537281731917`.
- The current user states the cleaned source of truth is project `9558614255557019910`.
- The previous project may have contained extra draft screens and Codex may have read the wrong UI.

## 4. Whether The Previous Implementation Should Be Overwritten

Yes. The previous visible route-level UI should be overwritten from the fresh cleaned Stitch project.

Rules for overwrite:

- Do not delete Flutter source files.
- Do not replace real stores with fake data.
- Preserve real actions and tests.
- Treat the fresh 5-screen Stitch extraction as the only visual source of truth.
- Reuse or rewrite `lib/shared/widgets/visual_dna/` only where it helps match the fresh references.

## Gate For Next Phase

Proceed to backing up only `.ai_reference/stitch/` and creating a fresh reference folder structure.
