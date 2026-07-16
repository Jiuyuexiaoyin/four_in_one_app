# P9 Android Permission and Notification Test Matrix

Date: 2026-07-13 (Asia/Shanghai)

## Automated Dart tests

| Area | Case | Evidence | Result |
| --- | --- | --- | --- |
| Permission coordinator | granted returns without request | `test/android_permission_coordinator_test.dart` | pass |
| Permission coordinator | denied performs contextual structured request | same | pass |
| Permission coordinator | settings-required does not loop request | same | pass |
| Permission coordinator | non-Android not applicable | same | pass |
| Permission coordinator | web invokes no Android bridge | same | pass |
| Permission coordinator | settings and channel methods use abstraction | same | pass |
| Permission coordinator | bridge failure becomes unavailable/false | same | pass |
| Habit contextual flow | enabling a reminder shows explanation, then requests | `test/notification_contextual_flow_test.dart` | pass |
| Habit contextual flow | denial preserves the saved reminder and exposes Settings | same | pass |
| Focus contextual flow | denied and settings-required states still start Focus without request loops | same | pass |
| Denial persistence | reminder configuration remains after service denial | `test/habits_reminder_notifications_test.dart` | pass |
| Scheduling | initialize exactly once | `test/app_local_notification_service_test.dart` | pass |
| Scheduling | transient initialization failure retries safely | same; `test/notification_cold_start_integration_test.dart` | pass |
| Scheduling | one schedule produces one pending request | same | pass |
| Scheduling | reschedule replaces same ID | same | pass |
| Scheduling | cancel/deletion removes pending request | same | pass |
| Scheduling | inexact-while-idle used without exact access | same; `test/focus_store_test.dart` | pass |
| Scheduling | pause/archive/delete cancellation and restore reschedule | existing Habit reminder tests | pass |
| Scheduling | pending reconciliation removes typed/legacy Habit orphans | app local notification service test | pass |
| Scheduling | calendar construction preserves wall-clock time across DST | same | pass |
| Scheduling | Focus IDs derive from target end time | same; Focus Store test | pass |
| Scheduling | stale/in-flight Focus operations cannot cancel a newer round | app local notification service test | pass |
| Scheduling | failed pending lookup falls back to captured Focus ID | same | pass |
| Scheduling | stale Focus orphan and idle completion cleanup | same | pass |
| Scheduling health | successful unrelated work does not erase an unacknowledged error | same | pass |
| Scheduling | test notification is immediate/non-repeating | app local notification service test | pass |
| Channels | disabled Habit channel blocks test delivery truthfully | same | pass |
| Android 7 | test notification skips channel preflight | same | pass |
| Presentation | private visibility and reliable Chinese action details | same | pass |
| Payload | schema round-trip | `test/notification_routing_test.dart` | pass |
| Payload | malformed/unknown/incomplete rejected | same | pass |
| Payload | unsafe/oversized ID rejected | same | pass |
| Payload | route/action mismatch rejected | same | pass |
| Routing | Habit → Habits | same | pass |
| Routing | Focus default → Focus; records → Review; unsupported restart rejected | same | pass |
| Routing | test → Settings | same | pass |
| Routing | production-order cold-start consumed once by the app | `test/notification_cold_start_integration_test.dart` | pass |
| Routing | pre-listener live response is buffered | same | pass |
| Routing | duplicate callback suppressed, later recurrence allowed | same | pass |
| Settings | rows reflect coordinator and pending health | `test/settings_notifications_permissions_test.dart` | pass |
| Settings | denied state shows explanation and requests | same | pass |
| Settings | system settings method invoked | same | pass |
| Settings | test action uses notification abstraction | same | pass |
| Settings | Web/not-applicable and Android 7 rows are truthful | same | pass |
| Settings | disabled channel and separate Habit/Focus channel rows | same | pass |
| Existing system | data sync, navigation, headers, persistence, attachments | complete Flutter suite | pass |

Focused P9 regression run: **79/79 passed**.
Final full executed suite: **239/239 passed**. This is the accepted 184-test baseline plus 55 P9 tests.

## Source/native contract checks

`test/android_manifest_contract_test.dart` validates:

- app-owned main-manifest permission set is exactly `POST_NOTIFICATIONS` plus `RECEIVE_BOOT_COMPLETED`;
- the forbidden permission list is absent;
- `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`, and `ActionBroadcastReceiver` exist with `exported="false"`;
- boot and package-replacement actions exist;
- `ic_stat_checkin.xml` exists, is configured as the default plugin icon, and is preserved by `raw/keep.xml`;
- the native bridge avoids hidden permission-state APIs and coalesces concurrent system-dialog callers.

The source check complements the completed debug/release merged-manifest and packaged-debug-APK inspection recorded below.

## Android build and APK inspection

Executed command:

`D:\ai\flutter\bin\flutter.bat build apk --debug`

Result: exit 0 in 156.7 seconds. The debug APK was produced at `build\app\outputs\flutter-apk\app-debug.apk`.

- Size: 154,558,833 bytes
- SHA-256: `E8FA25572767E1CE7E8819C92B0E5ABDA5FE4597F14BF392B53ECEB1AB5AE240`
- Package/version: `com.example.four_in_one_app`, `1.1.5+17`
- SDK range: minSdk 24, targetSdk 36, compileSdk 36
- Signature: valid v2 debug signature

Inspected debug artifacts:

- `build\app\intermediates\merged_manifest\debug\processDebugMainManifest\AndroidManifest.xml`
- `build\app\intermediates\merged_manifests\debug\processDebugManifest\AndroidManifest.xml`
- `build\app\intermediates\packaged_manifests\debug\processDebugManifestForPackage\AndroidManifest.xml`
- `build\app\outputs\logs\manifest-merger-debug-report.txt`

The manifest-only Gradle task `:app:processReleaseMainManifest` also exited 0 and generated `build\app\intermediates\merged_manifest\release\processReleaseMainManifest\AndroidManifest.xml`. That release merged manifest contains `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, and the AndroidX package-scoped signature permission; debug-only `INTERNET` and every forbidden permission are absent. No release APK was built.

The exact packaged debug permission set is:

- `android.permission.INTERNET` — debug Flutter tooling only;
- `android.permission.POST_NOTIFICATIONS`;
- `android.permission.RECEIVE_BOOT_COMPLETED`;
- `android.permission.VIBRATE`;
- `com.example.four_in_one_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` — AndroidX-generated, package-scoped, signature-protected receiver permission; it is not a dangerous/runtime product permission.

Inspection found none of the forbidden permissions. `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`, and `ActionBroadcastReceiver` are all `exported="false"` in both merged variants. `ic_stat_checkin` and its raw keep resource are packaged. Kotlin compilation, manifest merging, resource packaging, APK creation, and APK signing therefore passed for the debug variant; release manifest merging also passed without producing a release APK.

APK installation and runtime notification inspection remain unexecuted because no Android device or emulator is available; no runtime result is claimed.

## Device inventory

`D:\ai\flutter\bin\flutter.bat devices` found only:

- Windows desktop
- Chrome web
- Edge web

A standalone ADB probe found no attached Android device. No emulator was installed or created.

Static/build state: `ANDROID_PERMISSIONS_NOTIFICATIONS_READY_FOR_DEVICE_REVIEW`. Runtime/device verification remains pending.

## Exact manual device checklist

Use the built `build\app\outputs\flutter-apk\app-debug.apk` on a supported Android API 24–36 device when one is available:

1. Uninstall the prior app build or clear app data for a clean install.
2. Launch the app and confirm no permission dialog appears automatically.
3. Open Settings → `通知与权限`; capture the initial status and full section.
4. Create/enable a Habit reminder; capture the Chinese explanation dialog.
5. Continue and capture the Android notification permission dialog on API 33+.
6. Dismiss the system dialog; confirm Habit reminder data remains saved and the app explains that Android will not display it.
7. Repeat with `不允许`; confirm the real status row and settings action.
8. Where supported, reset the permission with ADB/app settings and grant it.
9. Disable the Habit channel and confirm `发送测试通知` reports that it was not sent with a channel-settings action; re-enable it, send again, and capture collapsed/expanded views.
10. Verify the target/check small icon is legible in light and dark system themes.
11. Verify title/body, private lock-screen treatment, accent, and no noisy full-screen behavior.
12. Expand a Habit notification; capture `去打卡`; tap it from foreground, background, and terminated states; confirm Habits opens once.
13. Start a short Focus round; confirm no running/paused drawer countdown is posted.
14. Background/terminate the app before completion; verify one `专注完成` notification.
15. Capture and test `查看记录` → Review; confirm no misleading “再来一轮” action is present.
16. Edit the Habit reminder time; confirm only one replacement remains pending.
17. Clear the reminder; confirm it is cancelled.
18. Pause/archive the Habit; confirm cancellation. Restore it; confirm one schedule returns.
19. Open both direct channel rows and inspect Android settings: only `习惯提醒` and `专注完成` are actively used; verify default importance.
20. Reboot with a future reminder pending; verify restoration without opening the app, then open the app and confirm no duplicate.
21. Update/install-over with a future reminder pending; confirm package-replacement restoration and no duplicate.
22. Change timezone; resume/open the app and verify the Habit reminder tracks the new local time.
23. Deny any available exact-alarm access globally; confirm the app never asks for it and ordinary reminders continue without crash.
24. Use gallery attachment selection; confirm system Photo Picker/fallback and no broad media permission.
25. Use Habit proof `拍照`; confirm external system camera and no app CAMERA permission dialog.

Required screenshots:

- permission explanation;
- Android system permission dialog;
- Settings `通知与权限`;
- collapsed notification;
- expanded notification;
- notification actions;
- channel settings.

These screenshots are deferred solely because no Android device or emulator is available; the debug APK itself is built and inspected.

## Residual manufacturer matrix

| Risk | Expected behavior |
| --- | --- |
| Aggressive battery management | inexact delivery may be delayed; no exemption prompt |
| Boot/autostart suppression | next app launch repairs Habit schedules |
| Channel customized/disabled by user | Settings opens app/channel controls; app does not overwrite choices |
| Permission revoked externally | resume refreshes real status; data remains intact |
| OEM camera unavailable | capture returns safely; gallery remains available |
| Photo Picker unavailable/backport missing | plugin falls back to user-scoped system selection |
