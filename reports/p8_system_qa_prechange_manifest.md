# P8 Application System QA Prechange Manifest

Date: 2026-07-12 (Asia/Shanghai)
Workspace: `D:\ai\projects\four_in_one_app`
Scope: baseline captured before P8-APP-SYSTEM-QA-B source or test edits.

## 1. Current modified tracked files

`git status --short` reported these 30 tracked files as already modified:

- `lib/app/router/app_router.dart`
- `lib/app/settings/application/app_settings_store.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_theme_tokens.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/goals/data/plan_record_attachment_storage.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/habits/application/habits_store.dart`
- `lib/features/habits/data/habits_local_storage.dart`
- `lib/features/habits/domain/models/habit_check_in_template.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/shared/widgets/app_shell.dart`
- `lib/shared/widgets/product/app_section_panel.dart`
- `lib/shared/widgets/product/focus_timer_hero.dart`
- `lib/shared/widgets/product/my_settings_section.dart`
- `lib/shared/widgets/product/plan_goal_card.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- `lib/shared/widgets/product/soft_surface.dart`
- `pubspec.lock`
- `test/app_smoke_test.dart`
- `test/focus_flow_test.dart`
- `test/goals_attachment_widget_test.dart`
- `test/goals_flow_test.dart`
- `test/habits_flow_test.dart`
- `test/review_overview_test.dart`
- `test/settings_theme_test.dart`
- `test/today_overview_test.dart`

Prechange tracked diff summary: 30 files, 4,909 insertions, 4,292 deletions. These edits predate this QA phase and are treated as user-owned baseline work.

## 2. Current untracked files

`git ls-files --others --exclude-standard` reported:

- `.playwright-mcp/download.htm`
- `.playwright-mcp/page-2026-07-07T13-14-59-528Z.yml`
- `.playwright-mcp/page-2026-07-08T08-38-11-272Z.yml`
- `.playwright-mcp/page-2026-07-08T08-41-15-607Z.yml`
- `.playwright-mcp/page-2026-07-08T08-42-11-780Z.yml`
- `.playwright-mcp/page-2026-07-08T08-42-25-691Z.yml`
- `.playwright-mcp/page-2026-07-08T08-42-36-134Z.yml`
- `.playwright-mcp/page-2026-07-08T08-42-51-509Z.yml`
- `.playwright-mcp/page-2026-07-08T08-43-01-983Z.yml`
- `.playwright-mcp/page-2026-07-08T08-43-12-610Z.yml`
- `.playwright-mcp/page-2026-07-08T08-43-21-245Z.yml`
- `.playwright-mcp/page-2026-07-08T08-43-46-799Z.yml`
- `lib/shared/widgets/stitch_exact/stitch_exact.dart`
- `lib/shared/widgets/visual_dna/stitch_widgets.dart`
- `lib/shared/widgets/visual_dna/visual_dna_widgets.dart`
- `reports/apk_golden_metadata.md`
- `reports/apk_golden_visual_reference.md`
- `reports/apk_vs_current_vs_stitch_gap_report.md`
- `reports/dart_flutter_timeout_diagnosis_report.md`
- `reports/flutter_sdk_restore_report.md`
- `reports/manual_premium_spacing_review/01_today_current.png`
- `reports/manual_premium_spacing_review/02_habits_current.png`
- `reports/manual_premium_spacing_review/03_plan_current.png`
- `reports/manual_premium_spacing_review/04_focus_current.png`
- `reports/p8_after_hard_apply_screenshots/MANUAL_CAPTURE_INSTRUCTIONS.md`
- `reports/p8_before_hard_apply_screenshots/MANUAL_CAPTURE_INSTRUCTIONS.md`
- `reports/p8_before_pixel_rewrite_snapshot.md`
- `reports/p8_clean_stitch_mcp_extract.md`
- `reports/p8_clean_stitch_route_replacement_plan.md`
- `reports/p8_clean_stitch_ui_rebuild_report.md`
- `reports/p8_failed_stitch_attempt_reset_audit.md`
- `reports/p8_flutter_baseline_screenshots/01_today.png`
- `reports/p8_flutter_baseline_screenshots/02_habits.png`
- `reports/p8_flutter_baseline_screenshots/03_create_habit_flow.png`
- `reports/p8_flutter_baseline_screenshots/04_plan.png`
- `reports/p8_flutter_baseline_screenshots/05_focus.png`
- `reports/p8_flutter_baseline_screenshots/06_review.png`
- `reports/p8_flutter_baseline_screenshots/07_settings.png`
- `reports/p8_habits_pixel_proof_report.md`
- `reports/p8_habits_pixel_rewrite_plan.md`
- `reports/p8_habits_stitch_source_audit.md`
- `reports/p8_nav_i18n_audit.md`
- `reports/p8_nav_i18n_fix_plan.md`
- `reports/p8_nav_i18n_fix_report.md`
- `reports/p8_pixel_rewrite_implementation_plan.md`
- `reports/p8_plan_pixel_fix_plan.md`
- `reports/p8_plan_pixel_fix_report.md`
- `reports/p8_plan_stitch_reference_audit.md`
- `reports/p8_plan_ux_simplify_audit.md`
- `reports/p8_plan_ux_simplify_plan.md`
- `reports/p8_plan_ux_simplify_report.md`
- `reports/p8_premium_spacing_rules.md`
- `reports/p8_premium_whitespace_audit.md`
- `reports/p8_premium_whitespace_tuning_report.md`
- `reports/p8_previous_stitch_attempt_audit.md`
- `reports/p8_runtime_blocker_precheck_snapshot.md`
- `reports/p8_stitch_export_pixel_spec.md`
- `reports/p8_stitch_export_route_plan.md`
- `reports/p8_stitch_export_screen_analysis.md`
- `reports/p8_stitch_export_ui_rebuild_report.md`
- `reports/p8_stitch_local_reference_implementation_plan.md`
- `reports/p8_stitch_local_ui_implementation_report.md`
- `reports/p8_stitch_pixel_rewrite_report.md`
- `reports/p8_stitch_route_replacement_report.md`
- `reports/p8_stitch_ui_forensic_audit.md`
- `reports/p8_stitch_ui_hard_apply_report.md`
- `reports/p8_stitch_ui_rebuild_report.md`
- `reports/p8_today_pixel_proof_report.md`
- `reports/p8_today_pixel_rewrite_plan.md`
- `reports/p8_today_stitch_source_audit.md`
- `reports/p8_visual_audit_report.md`
- `reports/p8_visual_audit_screenshots/01_initial_today.png`
- `reports/p8_visual_audit_screenshots/02_habits.png`
- `reports/p8_visual_audit_screenshots/03_create_habit_dialog.png`
- `reports/p8_visual_audit_screenshots/04_habits_after_create.png`
- `reports/p8_visual_audit_screenshots/05_habits_after_checkin.png`
- `reports/p8_visual_audit_screenshots/06_today_after_checkin.png`
- `reports/p8_visual_audit_screenshots/07_review_after_checkin.png`
- `reports/p8_visual_audit_screenshots/08_settings.png`
- `reports/stitch_mcp_access_proof.md`
- `reports/stitch_mcp_screen_extract.md`
- `reports/stitch_to_flutter_mapping.md`

This manifest itself is the first new file of P8-APP-SYSTEM-QA-B and therefore is not part of the prechange list above.

## 3. Current routes

| Route | Page | Shell mode |
| --- | --- | --- |
| `/` | Today | Main tab, index 0 |
| `/today` | Today | Main tab, index 0 |
| `/habits` | Habits | Main tab, index 1 |
| `/goals` | Plan | Main tab, index 2 |
| `/focus` | Focus | Main tab, index 3 |
| `/review` | Review | Secondary page, no bottom navigation |
| `/settings` | My/Settings | Secondary page, no bottom navigation |

Unknown routes currently fall back to `/today`. Main-tab changes use named-route replacement; secondary pages use normal named-route pushes.

## 4. Current shared UI layers

- Shell/navigation: `lib/shared/widgets/app_shell.dart`.
- Active Stitch/P8 visual system: `lib/shared/widgets/stitch_exact/stitch_exact.dart`.
- Compatibility visual-DNA exports: `lib/shared/widgets/visual_dna/`.
- Product components: `lib/shared/widgets/product/` (activity, analytics, chips, empty states, panels, timer hero, habit identity, heatmap, metrics, settings, plan cards/tree, progress, surfaces).
- Theme construction and settings-bound tokens: `lib/app/theme/app_theme.dart`, `lib/app/theme/app_theme_tokens.dart`.
- Legacy/shared palette and typography: `lib/shared/theme/app_dark_palette.dart`, `lib/shared/theme/app_text_styles.dart`.
- Store rebuild boundaries: `HabitsScope`, `GoalsScope`, `FocusStoreScope`, and `AppSettingsScope`, each implemented with `InheritedNotifier`; `app.dart` also rebuilds `MaterialApp` through `AnimatedBuilder` on `AppSettingsStore`.

## 5. Current tests

- `test/app_settings_store_test.dart`
- `test/app_smoke_test.dart`
- `test/focus_flow_test.dart`
- `test/focus_persistence_test.dart`
- `test/focus_store_test.dart`
- `test/goals_attachment_widget_test.dart`
- `test/goals_flow_test.dart`
- `test/goals_persistence_test.dart`
- `test/habit_plan_linking_test.dart`
- `test/habit_record_attachment_storage_test.dart`
- `test/habit_statistics_test.dart`
- `test/habits_flow_test.dart`
- `test/habits_persistence_test.dart`
- `test/habits_reminder_notifications_test.dart`
- `test/plan_record_attachment_storage_test.dart`
- `test/review_overview_test.dart`
- `test/settings_theme_test.dart`
- `test/today_overview_test.dart`

There is no `integration_test/` directory in the current workspace.

## 6. Runtime and formatting caveats

- Runtime restore report verdict: `CODEX_RUNTIME_RESTORED_READY_FOR_SYSTEM_QA`; Codex 0.144.1 helpers, primary/worker sandbox probes, doctor, and isolated Playwright lifecycle test passed.
- The isolated Playwright registration is loaded only by a new normal session; this QA phase is running in the requested new workspace-scoped session.
- Prior P8 runs reported Dart/Flutter wrapper timeouts and Windows formatter overwrite error 1224 on mapped files. Those symptoms predate runtime restoration and must be rechecked, not assumed fixed.
- `git diff --check` passes at baseline. Git emits LF-to-CRLF warnings for several already-dirty Dart files; no line-ending normalization is authorized.
- `AGENTS.md` says the current version is `1.1.2+14`, while the already-dirty/current `pubspec.yaml` reads `1.1.5+17`. This phase will not resolve or alter that pre-existing mismatch because version changes are forbidden.
- Earlier Chrome smoke reports print `This application is not configured to build on the web.` but still launched the app successfully.
- The `.playwright-mcp/` files are pre-existing untracked artifacts. They will not be deleted or reused as the isolated browser profile.
- No Git patch was created because this phase must not write into `.git`; only read-only Git status/diff commands are used.

## Baseline command results

- `git status --short`: exit 0.
- `git diff --stat`: exit 0.
- `git diff --name-only`: exit 0.
- `git diff --check`: exit 0; line-ending warnings only, no whitespace error.
