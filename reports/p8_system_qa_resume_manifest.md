# P8 Application System QA Resume Manifest

Date: 2026-07-12 (Asia/Shanghai)
Workspace: `D:\ai\projects\four_in_one_app`
Scope: resume baseline for `P8-APP-SYSTEM-QA-C`, captured before resumed source or test edits.

## 1. Partial QA work retained

The QA-B implementation remains present and is not being repeated or reverted. Retained changes include:

- Focus completion/history notification ordering and pause-at-expiry handling.
- Idle Focus target reconciliation with current incomplete Plan actions.
- The shared `MainPageHeader` contract and Focus integration.
- Shared motion durations and bounded metric, progress, navigation, and Focus-state transitions.
- Theme-aware shared surfaces, normalized bottom clearance, and Settings/Focus hierarchy cleanup.
- Review ordering, retained Habit history, real Focus minute aggregation, and translated/status copy fixes.
- Removal of misleading Settings/Focus controls and hardcoded Focus score/version labels.
- Cross-Store synchronization and navigation regression tests in `test/app_system_sync_test.dart` plus Focus Store regressions.

## 2. Unfinished work at resume

The previous report identified these source changes as blocked by Windows mapped sections:

- Correct the AppShell SafeArea inversion.
- Migrate Today, Habits, and Plan to the shared main-page header.
- Use replacement navigation for Today links to main tabs.
- Add an explicit Create Habit cancel action.
- Correct Plan's empty-project action copy.
- Remove Today's fake schedule times.
- Correct Today and Habits seven-day axis/order labels.
- Complete visible header-route, secondary-return, and theme-propagation coverage.
- Run full Flutter tests and resident Chrome/browser QA with screenshots.

## 3. Current modified state

`git status --short` reports 33 modified tracked files, the pre-existing untracked report/UI artifact trees, and the QA-B additions. The source files currently modified are:

- `lib/app/router/app_router.dart`
- `lib/app/settings/application/app_settings_store.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_theme_tokens.dart`
- `lib/features/focus/application/focus_store.dart`
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
- `lib/shared/widgets/stitch_exact/main_page_header.dart` (untracked QA-B addition)
- `lib/shared/widgets/stitch_exact/stitch_exact.dart` (untracked existing/QA-B integration)

No Store, model, schema, dependency, version, or Git metadata change is authorized by this resume phase.

## 4. Tests already added or extended

- `test/app_system_sync_test.dart`: Habit, Plan, Focus cross-page synchronization plus main/secondary navigation behavior.
- `test/focus_store_test.dart`: pause-at-expiry, completion notification coherence, idle target reconciliation, and active snapshot preservation.
- `test/focus_persistence_test.dart`: incomplete pause/reset persistence assertion adjusted to remain pre-expiry.

Existing flow, smoke, Review, Today, Settings, Habits, Goals, and Focus tests remain intact and must not be weakened.

## 5. Resume gate evidence

### Git checks

- `git status --short`: exit 0.
- `git diff --stat`: exit 0; 33 tracked files changed, 5,044 insertions and 4,340 deletions at resume.
- `git diff --name-only`: exit 0.
- `git diff --check`: exit 0; only pre-existing LF-to-CRLF notices.

### Mapped-file lock inspection

- No `dart` or `flutter` process was running.
- The matching isolated Playwright processes belong to this current QA session and were not stopped.
- No old Flutter app run, repo analyzer, or disposable browser profile owner was found.
- Reversible rename-and-restore probes passed for:
  - `lib/shared/widgets/app_shell.dart`
  - `lib/features/today/presentation/pages/today_page.dart`
  - `lib/features/habits/presentation/pages/habits_page.dart`
  - `lib/features/goals/presentation/pages/goals_page.dart`

Result: the previous mapped-file blocker is cleared.

### Flutter cache access

- Direct Dart: `Dart SDK version 3.12.2`.
- Flutter under the approved normal user identity: `Flutter 3.44.4`, Dart 3.12.2.
- `D:\ai\flutter\bin\cache\codex_qa_write_probe.tmp` was created, read back, and removed successfully.

Result: narrow Flutter cache access is available. No cache rebuild or precache was run.

## 6. Exact remaining blockers

There is no mapped-file or cache-access blocker at resume. Completion now depends on:

1. implementing the listed unresolved header, navigation, copy, date-axis, motion, and spacing fixes without disturbing the retained QA-B work;
2. completing action/value-focused widget coverage;
3. passing targeted formatting, full analysis, full tests, and `git diff --check`;
4. starting a reachable resident Chrome app and completing isolated browser verification/screenshots.
