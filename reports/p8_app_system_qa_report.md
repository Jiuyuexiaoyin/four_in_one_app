# P8 Application System QA Report

Date: 2026-07-12
Workspace: `D:\ai\projects\four_in_one_app`

## QA-C completion update

Phase `P8-APP-SYSTEM-QA-C` resumed this partial QA result and completed the previously blocked work. This update supersedes the historical blocker verdict and forward-looking language retained below for traceability.

- All four mapped-file write probes passed without replacing or deleting source files.
- Narrow Flutter-cache write/read/remove access passed.
- Today, Habits, Plan, and Focus now use the shared main-page header.
- Remaining interaction, synchronization, motion, truthful-label, and spacing work was completed.
- Targeted formatting passed for the 11 Dart files modified by QA-C.
- Full Flutter analysis passed with no issues; all 183 tests passed.
- Resident Chrome and isolated Playwright verification completed, with seven final screenshots captured.
- The final browser pass had zero console errors, no Flutter overflow, and no bottom-navigation overlap.

The authoritative completion evidence is in `reports/p8_app_system_qa_completion_report.md`. The remainder of this document preserves the earlier QA-B partial record; claims that work “could not” be completed are historical rather than current.

## Historical QA-B partial record

## 1. Audits completed

- Prechange manifest: `reports/p8_system_qa_prechange_manifest.md`
- Interaction/navigation audit: `reports/p8_interaction_navigation_audit.md`
- Display synchronization audit: `reports/p8_data_sync_audit.md`
- Motion/feedback audit: `reports/p8_motion_audit.md`
- Premium UI consistency audit: `reports/p8_premium_ui_consistency_audit.md`

The audits covered the six pages, seven routes, four Stores, visible interaction paths, shared UI layers, existing tests, date ordering, rebuild triggers, hardcoded/placeholder risks, motion, spacing, and browser/runtime readiness.

## 2. Files changed in this QA phase

Application/UI:

- `lib/app/theme/app_theme.dart`
- `lib/features/focus/application/focus_store.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/shared/widgets/stitch_exact/main_page_header.dart` (new)
- `lib/shared/widgets/stitch_exact/stitch_exact.dart`

Tests:

- `test/app_system_sync_test.dart` (new)
- `test/focus_store_test.dart`
- `test/focus_persistence_test.dart`

Reports/artifacts:

- `reports/p8_system_qa_prechange_manifest.md`
- `reports/p8_interaction_navigation_audit.md`
- `reports/p8_data_sync_audit.md`
- `reports/p8_motion_audit.md`
- `reports/p8_premium_ui_consistency_audit.md`
- `reports/p8_system_qa_screenshots/README.md`
- `reports/p8_app_system_qa_report.md`

The worktree was already broadly dirty before this phase. No pre-existing edits were reverted, normalized, committed, stashed, or moved.

## 3. Broken interactions fixed

- Focus now uses the shared main-page header with real “选择专注对象” and “我的与设置” actions.
- The Focus target action has a Chinese disabled-state explanation while a round is active.
- Settings’ decorative/no-op “主题工作室” icon button was removed.
- Focus’s duplicate start/pause/resume/reset command set was consolidated to one action panel.
- Disabled Focus commands now explain why they are unavailable.
- A delayed timer can no longer lose a completed round when Pause is tapped at/after the target end.
- Focus completion history is inserted before the completion notification, preventing an idle UI with stale Today/Review metrics.

Blocked interaction fixes are listed in section 16.

## 4. Final header rules

The new shared header contract is:

- left-aligned 24 px title;
- non-interactive 48 px identity icon;
- zero to two real 48 px actions only;
- 20 px action icons, 10 px radius, 8 px action gap;
- mandatory non-empty Chinese tooltip;
- optional disabled tooltip that explains the state;
- no fake balancing button or implicit back button.

Focus is migrated. Today, Habits, and Plan could not be migrated because those pre-existing mapped files reject safe patch writes. Main-tab no-back behavior remains intact in the existing AppShell, but AppShell’s inverted top SafeArea could not be corrected.

## 5. Data synchronization mapping

- Habit mutations notify `HabitsStore`; Habits, Today, and Review depend on the same `InheritedNotifier` and derive values during build.
- Plan task completion notifies `GoalsStore`; Plan, Today, Review, and Focus’s incomplete-target list rebuild.
- Focus completion now inserts the real `FocusSessionItem` before notifying; Focus history, Today minutes, and Review metrics observe one coherent completion state.
- AppSettings mutations notify before persistence; `FourInOneApp` rebuilds `MaterialApp` with `AnimatedBuilder`.
- Focus idle target snapshots now reconcile with live incomplete Plan tasks, refresh renamed task/context copy, and clear when the task is completed. Active/paused snapshots remain preserved for the current round/history.

Full getter/source mapping is in `reports/p8_data_sync_audit.md`.

## 6. Stale and hardcoded data fixed

Fixed:

- Review Habit seven-day values now match its today→past labels.
- Review retains paused/archived Habit history while excluding soft-deleted habits.
- Review Focus minutes sum real seconds before converting to whole minutes.
- Focus no longer exposes an arbitrary 300-minute “score”; it displays real today, weekly, and historical counts.
- Idle Focus targets no longer remain stale after Plan completion/rename.
- Settings no longer displays fake “版本 01”.
- Settings no longer exposes raw `system/light/dark` storage strings to users.
- Review’s `recap`, `REAL`, and `EMPTY` labels were translated.

Still blocked by mapped files:

- Today’s fake `09:00`, `11:30`, and `14:00` schedule labels.
- Today’s opposite-order Habit/Focus trend merge.
- Habits’ rolling seven-day data labelled as fixed Monday–Sunday.

No storage schema or domain model was changed.

## 7. Synchronization tests added

`test/app_system_sync_test.dart` adds:

- Habit check-in → Habits + Today + Review verification.
- Plan action completion → Plan progress + Today + Review + Focus target availability verification.
- 60-second fake-clock Focus completion → Focus history + Today one minute + Review values verification.
- Main-tab no-back and secondary-route return verification.

`test/focus_store_test.dart` adds:

- Pause-at-expiry completion regression.
- Listener coherence: idle completion is never announced with stale history.
- Idle target refresh/clear reconciliation.
- Active target snapshot preservation.

`test/focus_persistence_test.dart` retains the incomplete pause/reset no-record assertion by pausing before expiry.

The new tests pass static analysis but could not be executed because Flutter cannot write its SDK cache in this sandbox.

## 8. Animation changes

- Added shared motion tokens: 160 ms fast, 240 ms standard, 360 ms emphasis.
- Added bounded bottom-nav, metric-value, progress-rail, ring-progress, and status-selection transitions.
- Added Focus start/continue label transition.
- Kept timer digits free of per-second transition animation so tests can settle.
- No continuous decorative animation or delayed input was added.

## 9. Premium spacing changes

- Shared main-page bottom clearance normalized from 160 to 128 px.
- Secondary-page bottom clearance normalized from 144 to 56 px because there is no dock.
- Shared header uses consistent 48 px identity/action targets and 28 px following space.
- Settings hero is constrained to 640 px on wide Chrome layouts.
- Duplicate Settings hero title was removed.
- Focus’s weekly distribution and 28-day heatmap were consolidated into one lower analytics section; primary timer/setup/actions retain the top hierarchy.
- Shared dominant page, grid, panel, nav, label, metric, and progress colors now derive from the current theme while preserving dark defaults.

## 10. Functionality preserved

- `HabitsStore`, `GoalsStore`, `FocusStore`, and `AppSettingsStore` remain the sources of truth.
- Habit, Plan, Focus, Review, Settings, persistence, attachments, reminder, and lifecycle schemas were not changed.
- No login, cloud sync, backend, migration, dependency, version bump, APK preparation, or release build was added.
- No fake user data was inserted.
- No tests were deleted or weakened.
- No Git metadata was written.

## 11. Format result

Requested batch command:

`D:\ai\flutter\bin\dart.bat format <10 modified Dart files>`

Result: the wrapper produced no output for 60 seconds and was terminated cleanly.

Safe local fallback:

`D:\ai\flutter\bin\cache\dart-sdk\bin\dart.exe format <10 modified Dart files>`

Result: exit 0; all ten files formatted. Final check with `format -o none --set-exit-if-changed` completed in 0.09 seconds with zero changes.

## 12. Analyze result

Requested `D:\ai\flutter\bin\flutter.bat analyze` could not start because the batch launcher loops on an SDK-cache lock that is outside the workspace write boundary.

Fallback full workspace analysis:

`D:\ai\flutter\bin\cache\dart-sdk\bin\dart.exe analyze`

with a process-local analyzer state path under `.dart_tool`.

Result: exit 0, `No issues found!`

## 13. Test result

Requested focused Flutter test command produced no output for 60 seconds and was terminated cleanly.

The direct Flutter tool confirmed the blocker:

- access denied to `D:\ai\flutter\bin\cache\lockfile`;
- with the documented re-entrant lock flag, access denied to `D:\ai\flutter\bin\cache\libimobiledevice.stamp`.

The normal workspace sandbox can read the SDK but cannot perform Flutter’s required cache/stamp writes. Targeted and full Flutter tests therefore did not execute. No failing test result is being hidden; execution was blocked before the test runner started.

## 14. Browser / Playwright result

- Ports 54321 and 54322 had no listener.
- Resident `flutter run -d chrome` could not start for the same SDK-cache write boundary.
- The isolated Playwright MCP was callable and attempted `http://127.0.0.1:54321`.
- Result: `net::ERR_CONNECTION_REFUSED`; the tab was closed and no app state was changed.
- The separate in-app-browser surface was not registered in this session; only the Chrome extension surface appeared there. No unrelated browser backend was substituted for the requested isolated Playwright run.

## 15. Screenshots saved

No current-build screenshots were fabricated or copied from older runs. The expected capture list and blocker are recorded at:

`reports/p8_system_qa_screenshots/README.md`

Required page and interaction screenshots remain outstanding.

## 16. Remaining issues

Runtime/file-write blockers:

1. These pre-existing mapped files reject `apply_patch` writes despite correct Modify ACLs and non-read-only attributes:
   - `lib/shared/widgets/app_shell.dart`
   - `lib/features/today/presentation/pages/today_page.dart`
   - `lib/features/habits/presentation/pages/habits_page.dart`
   - `lib/features/goals/presentation/pages/goals_page.dart`
2. The normal aid sandbox cannot write required Flutter SDK cache/stamp files under `D:\ai\flutter\bin\cache`.
3. Because of (1), remaining fixes are: AppShell SafeArea inversion, Today/Habits/Plan shared headers, Today main-route replacement semantics, explicit Create Habit Cancel, Plan empty-project label, fake Today schedule labels, and Habits/Today date-axis corrections.
4. Because of (2), Flutter tests, resident Chrome smoke, isolated Playwright application QA, overflow checks, and screenshots could not run.

Non-blocking follow-up risks:

- Resident pages still rely on navigation/Store activity for a midnight rebuild.
- The Settings theme remains deliberately within the accepted dark-premium direction; its “soft” mode is a lighter charcoal palette, not a white redesign.
- The baseline version discrepancy remains untouched: `AGENTS.md` says 1.1.2+14 while tracked `pubspec.yaml` says 1.1.5+17.

Final Git checks:

- `git diff --check`: exit 0; pre-existing LF→CRLF warnings only.
- `git diff --stat`: exit 0.
- `git diff --name-only`: exit 0.
- No Git metadata mutation command was run.

## 17. Historical recommended next phase (completed in QA-C)

Resume this same P8 system-QA phase after both runtime conditions are corrected:

1. Release the Windows mapped sections for the four listed Dart files without deleting/replacing them.
2. Give normal workspace-scoped Flutter commands the narrow SDK-cache write access required by the existing `D:\ai\flutter` installation, without broadening project/Git permissions.
3. Apply the remaining four-page/header/date-axis fixes.
4. Run targeted format, full Flutter analyze/test, resident Chrome on 54321/54322, isolated Playwright interaction QA, and the eight required screenshots.

All listed steps were completed in QA-C. Seven required named views were captured: Today, Habits, Plan, Focus, Review, Settings, and one interaction state.

APP_SYSTEM_QA_READY_FOR_MANUAL_REVIEW
