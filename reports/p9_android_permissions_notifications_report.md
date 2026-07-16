# P9 Android Permissions and Notifications Report

Date: 2026-07-13 (Asia/Shanghai)
Workspace: `D:\ai\projects\four_in_one_app`
Implementation status: source implementation, automated verification, debug APK build, debug APK inspection, and debug/release merged-manifest inspection complete; Android device review remains pending.

## Final verdict

`ANDROID_PERMISSIONS_NOTIFICATIONS_READY_FOR_DEVICE_REVIEW`

Flutter static analysis and all 239 tests pass. A real debug APK was built, signed, and inspected; Kotlin/JNI compilation, both debug and release merged manifests, packaged permissions, receivers, and notification resources are verified. No Android device or emulator is available, so runtime permission dialogs, notification presentation/actions, and screenshots remain explicitly unverified.

## 1. Original permissions

Before P9, the app-owned main manifest declared no permissions. Dependency/source audit predicted these merged permissions:

| Variant | Original predicted permission | Source/purpose |
| --- | --- | --- |
| release | `POST_NOTIFICATIONS` | `flutter_local_notifications`; Habit and Focus notifications |
| release | `VIBRATE` | `flutter_local_notifications`; ordinary channel alert behavior |
| debug/profile only | `INTERNET` | Flutter tooling manifests |

The final artifact also contains AndroidX's package-scoped signature permission `<package>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. Because P9 did not add or upgrade the AndroidX dependency that contributes it, this is inferred to be pre-existing transitive receiver hardening; no pre-P9 APK was available for direct comparison. It grants no dangerous/runtime product access.

The original app declared neither `RECEIVE_BOOT_COMPLETED` nor the plugin boot receiver, so pending schedules were not restored immediately after reboot or package replacement.

## 2. Final permissions

The debug APK and generated release merged manifest were both inspected. No release APK was built.

| Variant | Final permission | Ownership and reason |
| --- | --- | --- |
| main/release | `POST_NOTIFICATIONS` | Explicit app declaration plus plugin merge input; runtime request only on API 33+ and only in context |
| main/release | `VIBRATE` | Plugin merge input; normal permission used by the two real notification channels |
| main/release | `RECEIVE_BOOT_COMPLETED` | Explicit app declaration for restoration of real scheduled reminders |
| main/release | `<package>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX-generated, package-scoped signature permission declared and self-used to protect non-exported dynamic receivers; not a dangerous/runtime permission |
| debug only | `INTERNET` | Existing Flutter debug tooling manifest; absent from the release merged manifest |

`android/app/src/main/AndroidManifest.xml` explicitly owns exactly `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED`. The automated source contract test verifies that set, and artifact inspection verifies the merged results above.

## 3. Permissions removed

None. The original app-owned main manifest had no dangerous or broad permission to remove. P9 preserved the narrow plugin-provided `POST_NOTIFICATIONS`/`VIBRATE` inputs and added only boot restoration.

## 4. Permissions deliberately not added

No call site or product contract justified any of the following, so they remain absent:

- `MANAGE_EXTERNAL_STORAGE`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`
- `CAMERA`, `RECORD_AUDIO`
- `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`
- `FOREGROUND_SERVICE` and foreground-service type permissions
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `READ_CONTACTS`, `READ_PHONE_STATE`
- SMS, phone, Bluetooth, nearby-device, or call permissions
- `QUERY_ALL_PACKAGES`, `REQUEST_INSTALL_PACKAGES`
- `SYSTEM_ALERT_WINDOW`, `USE_FULL_SCREEN_INTENT`, `ACCESS_NOTIFICATION_POLICY`
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`

No Plan notification permission/channel/scheduler was invented because Plan reminders do not exist.

## 5. Feature-to-permission mapping

| Feature | Exact implementation call site | Permission/access | Denial or unavailable fallback |
| --- | --- | --- | --- |
| Habit reminder | `HabitReminderLocalNotificationService.scheduleDailyReminder` | API 33+ `POST_NOTIFICATIONS`; boot restoration | Reminder configuration and inexact schedule remain stored; UI explains Android may suppress display |
| Focus completion | `FocusLocalNotificationService.scheduleCompletionReminder` | API 33+ `POST_NOTIFICATIONS`; boot restoration for a pending alarm | Timer continues and reconstructs from persisted end time; no foreground service |
| Test notification | `NotificationRuntimeController.sendTestNotification` | API 33+ `POST_NOTIFICATIONS` | No test is sent; clear Chinese message and settings path |
| Gallery attachment | `configureAndroidPhotoPicker` plus existing Image Picker call sites | User-selected Photo Picker/system document access; no media/storage permission | Plugin uses user-scoped system fallback |
| Habit proof photo | Existing `ImageSource.camera` call site | External system camera intent; no app `CAMERA` permission | Cancellation/unavailable camera is safe; gallery remains available |

## 6. Notification permission flow

- Nothing requests a permission during first launch, Store load, schedule reconciliation, Settings rendering, or notification initialization.
- Habit save requests only when reminders have just become enabled.
- Initial Focus start requests because it creates a completion schedule; continuing an already-paused round does not loop the request.
- `通知权限` and `通知测试` are explicit user-triggered entry points.
- A short Chinese explanation precedes the API 33+ system dialog.
- Structured results distinguish `granted`, `denied`, `settingsRequired`, `restricted`, `unavailable`, and `notApplicable`.
- Denial/dismissal never rolls back Habit configuration or Focus state. `settingsRequired` directs the user to Android app-notification settings instead of repeatedly opening the system dialog.
- Web and non-Android platforms invoke no Android plugin channel and fail safely.

## 7. Camera decision

The app has no direct camera preview. Habit proof-photo capture delegates to the installed system camera through Image Picker. The plugin does not require the app to declare `CAMERA` for that external intent, so `CAMERA` was deliberately not added or requested. Settings presents an explanation, not a fake permission switch.

## 8. Photo Picker decision

Android Photo Picker is explicitly enabled through the installed `image_picker_android` implementation. Only user-selected media is exposed, existing code copies selected/captured files into app-private storage, and the plugin retains a user-scoped fallback. No broad storage or media permission is declared.

## 9. Microphone decision

No speech input, voice note, recording, transcription, or audio feature exists. `RECORD_AUDIO` is absent and no microphone control is shown. Decision: `MICROPHONE_NOT_REQUIRED`.

## 10. Exact-alarm decision

The product has no exact-to-the-minute alarm contract. Habit and Focus schedules use `AndroidScheduleMode.inexactAllowWhileIdle`; neither `SCHEDULE_EXACT_ALARM` nor `USE_EXACT_ALARM` is declared, checked, or requested. Therefore no special-access denial can produce an exact-alarm `SecurityException`. Settings accurately reports `使用普通提醒` and explains possible battery-related adjustment.

## 11. Reboot and update restoration

- `RECEIVE_BOOT_COMPLETED` is declared.
- `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`, and `ActionBroadcastReceiver` are all `exported="false"`.
- The boot receiver handles `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, Android quick boot, and HTC quick boot.
- The notification plugin restores saved schedules after supported broadcasts.
- Habit Store startup reconciliation remains authoritative. Its adapter reads the real pending list, removes typed/legacy orphan IDs, and performs deterministic replacement, preventing duplicates and repairing state if an OEM suppresses boot delivery.
- Focus persists its end timestamp and reconstructs the active round on startup. Completion IDs derive from the target timestamp, schedule/cancel effects are serialized, stale owned completions are reconciled, and idle bootstrap cleanup repairs an interrupted reset. No foreground service was added.

## 12. Notification channels

| ID | Chinese name | Description | Importance |
| --- | --- | --- | --- |
| `habit_reminders_v1` | `习惯提醒` | 按你设置的日期和时间发送习惯打卡提醒 | default |
| `focus_completion_v1` | `专注完成` | 在一轮专注结束时提醒你查看记录 | default |

There is no Plan channel. The old `habit_daily_reminders` and `focus_reliability` IDs are not reused because Android channel behavior is immutable after creation. Old channel records can remain in Android settings on upgraded devices, but P9 schedules use only the versioned IDs.

## 13. Notification visual identity

- `android/app/src/main/res/drawable/ic_stat_checkin.xml` is a transparent monochrome target/check silhouette designed for small status-bar rendering.
- `android/app/src/main/res/raw/keep.xml` preserves the string-referenced drawable from resource shrinking.
- Android details use the dedicated small icon, the app accent `#2E6B5A`, standard priority, private lock-screen visibility, and BigText only for concise body text.
- Android permission dialogs and notification settings use the product label `Four In One` from `res/values/strings.xml`.
- The current launcher asset is a generic Flutter icon, so it was deliberately not reused as a large icon; presenting it as brand identity would be misleading.
- No full-screen, DND-bypass, continuous countdown, or progress-spam presentation exists.

## 14. Notification actions

- Habit: `去打卡` opens the Habits destination. It does not silently mark completion.
- Focus: `查看记录` opens Review.
- All actions have Chinese labels, show the application UI, and do not mutate Store/persistence data from a background isolate.
- `稍后提醒` was deliberately omitted: safe background initialization and one-replacement persistence were not proven, so a superficially working snooze action would violate the reliability rule.
- `再来一轮` was deliberately removed after review: opening Focus did not actually start or prepare another round, so the label was not truthful.
- No background callback is registered because there is no non-UI background action; normal taps/UI-opening actions use the foreground/background activity response path, while terminated launches use launch details.

## 15. Deep-link behavior

Payloads use a strict JSON schema with version, notification type, safe entity ID, expected existing route, and optional action. Unknown fields/types/routes/actions, malformed JSON, oversized values, and unsafe identifiers are rejected without navigation.

- Habit body/action -> existing `/habits` route, with entity ID passed as an argument; the allowed page fallback is used because no target-detail hierarchy exists.
- Focus body -> existing `/focus` route.
- Focus `查看记录` -> existing `/review` route.
- Test -> existing `/settings` route.
- Cold-start responses are consumed once; duplicate live/launch responses are suppressed within a bounded window.

No new route hierarchy, AppShell change, or main-tab header change was introduced.

## 16. Settings permission center

The existing Settings/My surface now includes one compact `通知与权限` section with:

- real notification status and contextual request/settings behavior;
- ordinary reminder precision explanation;
- Photo Picker and external-system-camera explanations;
- one immediate, clearly labeled, non-repeating test notification;
- Android application settings plus separate Habit and Focus channel settings entry points;
- a disabled Habit channel blocks test delivery and produces a truthful message with a direct settings action;
- collapsed health disclosure showing permission, per-channel availability, pending count, ordinary precision, and a sanitized last-scheduling state;
- truthful not-applicable behavior on Web/non-Android and Android 7 channel rows.

No fake microphone, camera, storage, or exact-alarm switch is shown.

## 17. Files changed by P9

### Android

- `android/gradle.properties` (Flutter 3.44 compatibility flags added automatically during the requested build)
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/example/four_in_one_app/MainActivity.kt`
- `android/app/src/main/res/drawable/ic_stat_checkin.xml`
- `android/app/src/main/res/raw/keep.xml`
- `android/app/src/main/res/values/strings.xml`

### Flutter implementation

- `lib/main.dart`
- `lib/app/app.dart`
- `lib/core/media/android_photo_picker.dart`
- `lib/core/permissions/app_permission.dart`
- `lib/core/permissions/app_permission_status.dart`
- `lib/core/permissions/android_permission_coordinator.dart`
- `lib/core/permissions/notification_permission_prompt.dart`
- `lib/core/permissions/permission_explanation.dart`
- `lib/core/notifications/app_local_notification_service.dart`
- `lib/core/notifications/app_notification_payload.dart`
- `lib/core/notifications/app_notification_routing.dart`
- `lib/core/notifications/device_time_zone_provider.dart`
- `lib/core/notifications/local_notifications_gateway.dart`
- `lib/core/notifications/notification_runtime_controller.dart`
- `lib/core/notifications/notification_runtime_scope.dart`
- `lib/features/habits/data/habit_reminder_notification_service.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/focus/data/focus_notification_service.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/settings/presentation/widgets/notification_permissions_section.dart`
- `pubspec.yaml`, `pubspec.lock`

Direct dependencies were added only for APIs imported by P9 (`image_picker_android`, `image_picker_platform_interface`, and `timezone`); their already-locked versions were retained and no package was upgraded.

### Tests and documentation

- `test/android_manifest_contract_test.dart`
- `test/android_permission_coordinator_test.dart`
- `test/app_local_notification_service_test.dart`
- `test/notification_cold_start_integration_test.dart`
- `test/notification_contextual_flow_test.dart`
- `test/notification_routing_test.dart`
- `test/settings_notifications_permissions_test.dart`
- scoped expectation updates in `test/focus_store_test.dart` and `test/habits_reminder_notifications_test.dart`
- all five `reports/p9_android_*.md` files

The repository was already dirty with accepted P8/Stitch work. P9 preserved unrelated changes and performed no commit, reset, stash, clean, checkout, or Git configuration change. Stores, domain models, persistence schema, version, AppShell, main headers, and route hierarchy were not changed by P9.

## 18. Format result

- Initial targeted pass: 28 P9 Dart files processed, 20 changed.
- Final-review targeted pass: 16 P9 Dart files processed, 8 changed.
- Analyzer/test follow-up passes formatted only the three adjusted files and the one contextual-flow test; they were already formatter-clean.
- No repository-wide format and no forbidden unscoped `dart format` was run.

## 19. Analyze result

Command: `D:\ai\flutter\bin\flutter.bat analyze`
Result: exit 0, `No issues found!`

## 20. Complete Flutter test count

Command: `D:\ai\flutter\bin\flutter.bat test`
Result: **239/239 passed**. The accepted 184-test baseline remains passing; P9 adds 55 tests. The focused P9 regression command also passed **79/79**.

Coverage includes structured permission states, Web safety, contextual Habit/Focus denial preservation, Android 7 behavior, retryable initialization, inexact mode, pending/orphan reconciliation, DST wall-clock stability, delayed Focus race/failure fallback, target-derived IDs, durable scheduling errors, disabled-channel health, private/action presentation, payload validation, production-order cold-start once-only handling, pre-listener buffering, duplicate suppression, Settings health/test/channel actions, and source Android manifest/icon/receiver/native-API contracts.

## 21. Debug APK result

Command: `D:\ai\flutter\bin\flutter.bat build apk --debug`
Final result: exit 0 in 156.7 seconds, `Built build\app\outputs\flutter-apk\app-debug.apk`.

Artifact:

- path: `build\app\outputs\flutter-apk\app-debug.apk`
- size: 154,558,833 bytes (147.40 MiB)
- SHA-256: `E8FA25572767E1CE7E8819C92B0E5ABDA5FE4597F14BF392B53ECEB1AB5AE240`
- package/version: `com.example.four_in_one_app`, `1.1.5+17`
- SDK range: min 24, target/compile 36
- ABIs: `armeabi-v7a`, `arm64-v8a`, `x86_64`

The machine contained a complete SDK at `C:\Program Files (x86)\Android\android-sdk`, while Flutter's existing global setting pointed to partial `D:\Android\Sdk`. The final build used process-local `APPDATA`, `ANDROID_HOME`, `ANDROID_SDK_ROOT`, and `JAVA_HOME` overrides; global Flutter configuration was not changed.

After explicit approvals, the already-accepted license markers were transferred to the complete SDK and the exact project-required packages were installed: NDK `28.2.13676358`, CMake `3.22.1`, and Build-Tools `35.0.0`. The first Build-Tools 35 archive downloaded by Gradle was corrupt; SDK Manager redownloaded it successfully. CMake `3.10.2.4988404` was also installed based on an outdated comment in the locked `jni` plugin before local AGP 8.11.1 bytecode confirmed that its actual default is 3.22.1; the unused 3.10.2 install was left intact rather than deleted without authorization.

Kotlin incremental caches for two Pub Cache plugins reported a cross-drive `C:`/`D:` path error. Gradle automatically fell back to non-incremental compilation and still exited 0 with a valid APK. Flutter also added `android.builtInKotlin=false` and `android.newDsl=false` compatibility flags to `android/gradle.properties`; no version was bumped and no release APK was built.

## 22. APK permission inspection

Inspection completed with Android Build-Tools 36 `aapt`, `aapt2`, and `apksigner`, plus generated manifest files.

Exact debug APK permission surface:

- `android.permission.INTERNET` (debug-only)
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.VIBRATE`
- `com.example.four_in_one_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, declared with signature protection and self-used by AndroidX

The forbidden-permission scan returned no matches for storage/media, camera, microphone, location, contacts, phone, package-install/query, overlay, full-screen, DND, battery-optimization, exact-alarm, or foreground-service permissions.

Generated debug evidence:

- merged manifest: `build\app\intermediates\merged_manifests\debug\processDebugManifest\AndroidManifest.xml`
- packaged manifest: `build\app\intermediates\packaged_manifests\debug\processDebugManifestForPackage\AndroidManifest.xml`
- merger report: `build\app\outputs\logs\manifest-merger-debug-report.txt`

The manifest-only Gradle task `:app:processReleaseMainManifest` also exited 0. Its generated release manifest at `build\app\intermediates\merged_manifest\release\processReleaseMainManifest\AndroidManifest.xml` contains exactly `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, and the package-scoped AndroidX signature permission; it does not contain debug-only `INTERNET` or any forbidden permission. No release APK was produced.

`ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`, and `ActionBroadcastReceiver` are all `exported="false"` in both merged variants. The boot receiver includes boot, package-replacement, and supported quick-boot actions. Image Picker's provider and Photo Picker metadata service are non-exported. AndroidX Profile Installer's transitive receiver is exported but guarded by system `android.permission.DUMP`.

The APK resource table contains `drawable/ic_stat_checkin` and `raw/keep`. Signature verification passes with APK Signature Scheme v2 and one standard RSA-2048 Android debug signer, which is compatible with minSdk 24.

## 23. Real device/emulator result

Command: `D:\ai\flutter\bin\flutter.bat devices`
Result after the successful APK build: Windows, Chrome, and Edge only; no Android device or emulator. The complete SDK's `adb devices -l` also returned no attached Android target. No emulator was installed or created.

No installation, permission-dialog, drawer, action, channel, reboot, timezone, or runtime deep-link test was claimed.

## 24. Screenshots and manual test checklist

No Android screenshots were captured because no Android target was available. The built debug APK is ready for the exact 25-step device checklist and required seven screenshots recorded in `reports/p9_android_permission_test_matrix.md`. It covers clean install, no startup prompt, dismiss/deny/grant flows, test notification, disabled-channel handling, small icon in light/dark themes, foreground/background/terminated taps, the truthful Focus action, cancel/edit/pause/archive/restore, channels, reboot/update, timezone change, exact-access absence, Photo Picker, and external camera behavior.

## 25. Known manufacturer/device limitations

- Inexact delivery can be delayed by Doze or aggressive OEM battery policies; the app intentionally does not request a battery-optimization exemption.
- Some OEMs suppress boot/autostart broadcasts. Opening the app runs deterministic Habit reconciliation as the repair path.
- Users/OEMs can disable or customize an immutable channel; the app exposes system controls and does not overwrite user choices.
- Photo Picker backport availability varies; Image Picker retains a user-scoped system fallback.
- External camera availability varies; cancellation/unavailability is safe and gallery selection remains available.
- Old channel IDs can remain visible after an upgrade because Android owns channel history.

## 26. Remaining risks

1. No Android device/emulator was available, so all runtime behavior and screenshots require manual review.
2. OEM boot/background policies can delay ordinary reminders despite correct source and packaged configuration.
3. Notification accent rendering, private lock-screen presentation, and small-icon legibility depend on actual device/system theme validation.
4. Public-API Android 13 dismissal/first-denial/repeated-denial transitions need confirmation on a real API 33+ device; source logic and Dart abstractions are covered, but no native UI test ran.
5. Kotlin incremental compilation for Pub Cache plugins can fall back to slower non-incremental mode because cache sources are on `C:` while the project is on `D:`. The final build succeeded, but future builds may repeat the warning. Flutter also warns that the app and two locked plugins must migrate from the Kotlin Gradle Plugin to Built-in Kotlin before a future Flutter version makes that mandatory.
6. Flutter's existing global Android SDK setting still points to incomplete `D:\Android\Sdk`; this report's process-local override to the complete `C:\Program Files (x86)\Android\android-sdk` is required unless the user later approves a global Flutter configuration change.
7. The working `pubspec.yaml` already reported version `1.1.5+17` while project instructions reported `1.1.2+14`; P9 did not change either value, and the debug APK correctly reflects the working value.

`git diff --check` exits 0; Git reports only existing LF-to-CRLF conversion warnings and no whitespace errors.

## Final verdict

`ANDROID_PERMISSIONS_NOTIFICATIONS_READY_FOR_DEVICE_REVIEW`
