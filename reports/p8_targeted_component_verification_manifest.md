# P8 Targeted Component Verification Manifest

Date: 2026-07-13

## Verification scope

This session validates the already-implemented Settings palette, Plan search/filter, and Focus duration redesigns. It does not authorize another redesign or changes to AppShell, main-tab headers, Today, Habits, navigation, Stores, models, schema, persistence, dependencies, or version.

No source file had been edited by this verification session when this manifest was created.

## Exact P8 targeted-component Dart files

The previous P8 report identifies exactly these seven Dart files as the targeted-component implementation slice:

1. `lib/features/settings/presentation/pages/settings_page.dart`
2. `lib/features/goals/presentation/pages/goals_page.dart`
3. `lib/features/focus/presentation/pages/focus_page.dart`
4. `lib/shared/widgets/stitch_exact/compact_plan_filter_bar.dart` (new)
5. `test/settings_theme_test.dart`
6. `test/goals_flow_test.dart`
7. `test/focus_flow_test.dart`

Associated existing P8 artifacts are:

- `reports/p8_targeted_component_polish_audit.md`
- `reports/p8_targeted_stitch_design_record.md`
- `reports/p8_targeted_component_polish_report.md`
- `.ai_reference/stitch/targeted_component_polish_20260712/stitch_screen_manifest.md`

## Implementation already completed

### Settings / My

- Compact current-palette preview.
- Five common palettes visible without the full preset wall.
- `更多色卡` modal sheet exposing all five categories and all fifteen prior presets.
- Preset selection continues through the existing target-specific `AppSettingsStore` setters.
- Low-emphasis current-target and all-color reset actions.
- Existing advanced HEX/RGB/ARGB input remains collapsed initially and expandable.

### Plan

- Always-visible compact search input.
- Compact filter button with committed active-filter count.
- Only committed active filters appear as removable chips.
- Modal sheet edits a draft filter/sort state; close/cancel does not commit it.
- `应用筛选` commits draft values; `重置` clears them.
- Compact sort menu and real filtered result rows remain connected to the existing Plan data.

### Focus

- One-row selector for 5, 15, 25, and 45 minutes plus custom duration.
- Current selection is displayed explicitly and bound to `selectedDurationSeconds`.
- Presets and valid custom minutes call the real `FocusStore.selectDuration` flow.
- Custom input retains the 1–180 whole-minute validation rule.
- The selector-level unclear `下一轮` copy was removed.

## Existing focused test coverage

### Settings / My

- `test/settings_theme_test.dart`
  - `Settings page can change accent color`
  - `Theme Studio accepts HEX, RGB, ARGB, and reset inputs`
  - `Theme Studio renders on common phone widths with larger text`
- Supporting state/integration coverage:
  - `test/app_settings_store_test.dart`
  - `test/app_system_sync_test.dart` (`theme mode updates the visible page without restart`)

### Plan

- `test/goals_flow_test.dart`
  - `Plan search filters and sorting show flat contextual results`
  - `Plan simplified surfaces and detail fit common phone widths`
- The focused search/filter test covers initially visible search, modal draft behavior, tag and overdue filters, reset, active chip/badge state, real result filtering, and compact priority sorting.

### Focus

- `test/focus_flow_test.dart`
  - `duration rail presets update the configured timer duration`
  - `custom duration dialog validates and applies minutes`
  - `supports a minimal focus countdown loop`
- Supporting Store/persistence coverage:
  - `test/focus_store_test.dart`
  - `test/focus_persistence_test.dart`

## Initial Git evidence

- `git status --short`: exit 0; broad pre-existing tracked and untracked work is present.
- `git diff --stat`: exit 0; 35 tracked files, 5,799 insertions and 4,739 deletions at session start.
- `git diff --name-only`: exit 0; the 35 tracked paths listed below.
- `git diff --check`: exit 0; no whitespace errors. It reports pre-existing LF-to-CRLF warnings for six paths.

Tracked paths already modified at session start:

1. `lib/app/router/app_router.dart`
2. `lib/app/settings/application/app_settings_store.dart`
3. `lib/app/theme/app_theme.dart`
4. `lib/app/theme/app_theme_tokens.dart`
5. `lib/features/focus/application/focus_store.dart`
6. `lib/features/focus/data/focus_notification_service.dart`
7. `lib/features/focus/presentation/pages/focus_page.dart`
8. `lib/features/goals/data/plan_record_attachment_storage.dart`
9. `lib/features/goals/presentation/pages/goals_page.dart`
10. `lib/features/habits/application/habits_store.dart`
11. `lib/features/habits/data/habit_reminder_notification_service.dart`
12. `lib/features/habits/data/habits_local_storage.dart`
13. `lib/features/habits/domain/models/habit_check_in_template.dart`
14. `lib/features/habits/presentation/pages/habits_page.dart`
15. `lib/features/review/presentation/pages/review_page.dart`
16. `lib/features/settings/presentation/pages/settings_page.dart`
17. `lib/features/today/presentation/pages/today_page.dart`
18. `lib/shared/widgets/app_shell.dart`
19. `lib/shared/widgets/product/app_section_panel.dart`
20. `lib/shared/widgets/product/focus_timer_hero.dart`
21. `lib/shared/widgets/product/my_settings_section.dart`
22. `lib/shared/widgets/product/plan_goal_card.dart`
23. `lib/shared/widgets/product/plan_tree_row.dart`
24. `lib/shared/widgets/product/soft_surface.dart`
25. `pubspec.lock`
26. `test/app_smoke_test.dart`
27. `test/focus_flow_test.dart`
28. `test/focus_persistence_test.dart`
29. `test/focus_store_test.dart`
30. `test/goals_attachment_widget_test.dart`
31. `test/goals_flow_test.dart`
32. `test/habits_flow_test.dart`
33. `test/review_overview_test.dart`
34. `test/settings_theme_test.dart`
35. `test/today_overview_test.dart`

The untracked baseline also includes the new compact Plan widget, shared Stitch/visual-DNA files, `test/app_system_sync_test.dart`, many pre-existing reports/screenshots, and historical `.playwright-mcp` diagnostics. These are preserved as user-owned work.

## Unrelated-change assessment

Yes, unrelated files were already changed before this verification phase. In particular, Git currently reports pre-existing changes in AppShell, Today, Habits, navigation, Stores, data/domain files, `pubspec.lock`, shared widgets, and non-target tests. The preceding P8 targeted report states those paths were not changed by the targeted-component phase. This session will use its own manifest baseline and will not edit those paths.

## Remaining verification work

1. Prove Flutter launcher and direct Dart SDK access, including a create/delete cache probe.
2. Format only the seven P8 Dart files requested by the user.
3. Run `flutter analyze`, the complete `flutter test` suite, and `git diff --check`.
4. Fix only a defect proven by those checks or browser interaction, and only within the three targeted component areas or their focused tests.
5. Start a resident Chrome Flutter session and verify that localhost responds.
6. Perform isolated browser interaction checks for Settings, Plan, and Focus, including console, overflow, clipping, modal, hit-target, keyboard, and state-binding evidence.
7. Capture the seven required after/sheet screenshots from the running app.
8. Create the three comparison images only from genuine available before and after captures; do not fabricate a missing baseline.
9. Re-run scope evidence and produce the final verification report.
