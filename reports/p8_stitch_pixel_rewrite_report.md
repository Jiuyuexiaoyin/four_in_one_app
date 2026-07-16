# P8 Stitch Pixel Rewrite Report

## 1. Local Stitch Export Files Used

- `.ai_reference/stitch/export_20260708/项目简介.txt` (present, empty)
- `.ai_reference/stitch/export_20260708/程式码.txt`
- `.ai_reference/stitch/export_20260708/stitch_app.zip`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/premium_performance/DESIGN.md`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/*/code.html`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/*/screen.png`

Deep-read artifacts created before code edits:

- `reports/p8_before_pixel_rewrite_snapshot.md`
- `reports/p8_stitch_export_pixel_spec.md`
- `reports/p8_pixel_rewrite_implementation_plan.md`

## 2. Screen-By-Screen Pixel Spec Summary

- Today: exported from `final_synthesis_2`, 339x1600 PNG. Rebuilt around `今日 / TODAY`, focus score, momentum rings, priority card, flux chart, action timeline, and the four-tab dark dock.
- Habits: exported from `scale_proportion_refinement`, 411x1600 PNG. Rebuilt around `STRIVE`, system integrity, current cadence, rhythm bars, protocol cards, and real habit operations.
- Plan: exported from `discipline_dashboard`, 285x1600 PNG. Rebuilt around the black/grid discipline dashboard, goal/project/task metrics, hierarchy summaries, and timeline-style actions.
- Focus: exported from `final_synthesis_1`, 486x1600 PNG. Rebuilt around `OPTIMIZE`, flow status, large timer, progress rail, weekly distribution, and heatmap.
- My / Settings: exported from `performance_hub`, 381x1600 PNG. Rebuilt as a Theme Studio / personal hub surface with settings controls and local summary.

Global tokens followed: `#131313` / `#000000` backgrounds, dark panels, cyan `#00daf3/#00e5ff`, green `#6cec00`, purple `#dcb8ff`, 20px page padding, 24px panel padding, 8-12px radius, low-opacity borders, mono/caps labels, and a four-item floating bottom dock.

## 3. Old Rejected UI Elements Removed

- Active routed pages no longer import `lib/shared/widgets/visual_dna/*`.
- Active routed pages import/use `lib/shared/widgets/stitch_exact/stitch_exact.dart`.
- AppShell no longer uses Material `NavigationBar` or the old Review bottom tab.
- Previous generic VisualDna files remain on disk for compatibility with older shared product widgets, but they are not the active route visual target.

## 4. Files Overwritten Or Created

Created:

- `lib/shared/widgets/stitch_exact/stitch_exact.dart`

Structurally replaced or restyled:

- `lib/shared/widgets/app_shell.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`

Tests updated for the export-style four-tab shell and preserved behavior assertions:

- `test/app_smoke_test.dart`
- `test/focus_flow_test.dart`
- `test/goals_flow_test.dart`

Note: the worktree already contained other modified files from prior rejected attempts; they were not reverted.

## 5. Active Routes Changed

- Today route uses `StitchExact` panels, circular metrics, timeline rows, chart, Review and Settings entries.
- Habits route uses `StitchExact` system/cadence panels and preserves habit list, creation, edit, check-in, reminders, records, and stats.
- Plan route uses `StitchExact` plan dashboard components and preserves the GoalsStore hierarchy.
- Focus route uses `StitchExact` timer/status dashboard and preserves start/pause/reset, duration, and target selection.
- Settings route uses `StitchExact` Theme Studio/personal hub styling and preserves theme mode, color studio, and data summary.
- Review route is still registered and restyled with the same visual language.

## 6. AppShell / Nav Result

- Bottom navigation is now the exported four-tab model: `今天`, `习惯`, `计划`, `专注`.
- Review is not a bottom-nav tab.
- Settings is reachable through Today and through route/AppBar paths.
- Review is reachable from Today and Settings.

## 7. Real Store Bindings Preserved

- Today binds to real `HabitsStore`, `GoalsStore`, and `FocusStore`.
- Habits binds to real habit completion, records, weekly/month stats, lifecycle, reminders, and forms.
- Plan binds to real goals, projects, subprojects, tasks, progress, and record metadata.
- Focus binds to real timer state, active duration, remaining seconds, weekly sessions/minutes, completed sessions, and selected task target.
- Settings binds to real `AppSettingsStore` theme mode, accent/background/surface color controls, and local data summary.

## 8. Real User Actions Preserved

- Habit create/edit/check-in/reminder/record/statistics flows remain covered by tests.
- Goal/project/subproject/task creation, editing, filtering, and detail sheets remain covered by tests.
- Focus start/pause/resume/reset, custom duration, target select/clear, and locked target behavior remain covered by tests.
- Settings theme mode, color input/reset, and data summary remain covered by tests.
- Review remains functional and reachable.

## 9. Final Format Result

- Ran `D:\ai\flutter\bin\dart.bat format .`.
- Exit code: `0`.
- Result: formatted 19 files.
- Follow-up check: `D:\ai\flutter\bin\dart.bat format -o none .` reports `Formatted 81 files (0 changed)`.
- Note: Windows temporarily reported error code `1224` (`user-mapped section open`) while formatting `lib\shared\widgets\app_shell.dart`; the file was updated through same-directory atomic replacement, then the final dry formatter check passed cleanly.

## 10. Final Analyze Result

- Command: `D:\ai\flutter\bin\flutter.bat analyze`
- Result: pass, `No issues found!`

## 11. Final Test Result

- Command: `D:\ai\flutter\bin\flutter.bat test`
- Result: pass, `All tests passed!` (`172` tests)

## 12. Chrome Run Result

- Command: `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321 --no-resident`
- Result: exit code `0`.
- Output included Flutter's web-support warning and then `Application finished.`

## 13. Remaining Visual Mismatches

- Flutter font rendering approximates the export fonts instead of exactly matching Hanken Grotesk / Inter / JetBrains Mono.
- No bitmap export assets were embedded; profile/avatar imagery is represented with local Flutter shapes/icons.
- Charts and heatmaps are real-data approximations of the exported chart shapes; screenshot-only values were not hardcoded.
- The app remains functional and scrollable, so some panel heights differ from the fixed exported 1600px mock screens.

## 14. Exact Manual Screenshot Instructions

1. From `D:\ai\projects\four_in_one_app`, run `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321`.
2. Capture 390-412px wide mobile screenshots for these routes: Today, Habits, Plan, Focus, Settings, Review.
3. Compare against:
   - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/final_synthesis_2/screen.png`
   - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/scale_proportion_refinement/screen.png`
   - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/discipline_dashboard/screen.png`
   - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/final_synthesis_1/screen.png`
   - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/performance_hub/screen.png`
4. Verify bottom nav shows only `今天 / 习惯 / 计划 / 专注`.
5. Verify Review opens from Today or Settings and is not a bottom tab.

Final verdict: STITCH_PIXEL_REWRITE_READY_FOR_MANUAL_REVIEW
