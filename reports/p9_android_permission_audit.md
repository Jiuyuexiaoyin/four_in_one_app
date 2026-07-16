# P9 Android Permission Audit

Date: 2026-07-13 (Asia/Shanghai)
Workspace: `D:\ai\projects\four_in_one_app`
Mode: read-only source and locally cached plugin inspection; no source edit, validation, or build preceded this report.

## Audit verdict

The app has two real Android notification features: recurring Habit reminders and one-shot Focus completion reminders. It also has user-triggered image selection and a Habit proof-photo flow that delegates capture to the system camera application. There is no Plan notification scheduler, in-app camera preview, voice/audio feature, network product feature, foreground-service requirement, or exact-to-the-minute alarm contract.

The least-privilege release permission set should therefore be:

- `android.permission.POST_NOTIFICATIONS` (declared by `flutter_local_notifications`; runtime request only on API 33+)
- `android.permission.VIBRATE` (declared by `flutter_local_notifications`; normal permission used by real alerting channels)
- `android.permission.RECEIVE_BOOT_COMPLETED` (to be declared by the app for scheduled-notification restoration)

Debug/profile variants additionally declare `android.permission.INTERNET` for Flutter tooling only. The final merged manifests and APK must still be inspected after the debug build.

### Post-build closure

The audit gate above was subsequently closed by the successful P9 debug build and packaged-artifact inspection. `app-debug.apk` built with exit 0 in 156.7 seconds at `build\app\outputs\flutter-apk\app-debug.apk` (154,558,833 bytes; SHA-256 `E8FA25572767E1CE7E8819C92B0E5ABDA5FE4597F14BF392B53ECEB1AB5AE240`). The APK reports package/version `com.example.four_in_one_app` / `1.1.5+17`, minSdk 24, targetSdk 36, and was produced with compileSdk 36.

The packaged debug permission set is exactly `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, and `VIBRATE`, plus AndroidX's package-scoped signature permission `com.example.four_in_one_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. No forbidden permission is present. The three notification receivers are packaged with `exported="false"`, the notification icon and raw keep resource are packaged, and the APK has a valid v2 debug signature. The manifest-only `:app:processReleaseMainManifest` task also passed; its merged release manifest contains the same set except debug-only `INTERNET`, with no forbidden permission. No release APK was built. No Android device or emulator was available, so this closes build/static inspection only; runtime behavior remains unclaimed and the resulting state is `ANDROID_PERMISSIONS_NOTIFICATIONS_READY_FOR_DEVICE_REVIEW`.

## Project and toolchain snapshot

| Item | Audited value | Evidence |
| --- | --- | --- |
| Flutter | 3.44.4 stable | `D:\ai\flutter\bin\flutter.bat --version` |
| Dart | 3.12.2 | Flutter version output |
| Android Gradle Plugin | 8.11.1 | `android/settings.gradle.kts` |
| Kotlin | 2.2.20 | `android/settings.gradle.kts` |
| Gradle | 8.14 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Java/Kotlin target | 17 | `android/app/build.gradle.kts` |
| minSdk | 24 | inherited from Flutter `FlutterExtension.kt` |
| compileSdk | 36 | inherited from Flutter `FlutterExtension.kt` |
| targetSdk | 36 | inherited from Flutter `FlutterExtension.kt` |
| flutter_local_notifications | constraint `^21.0.0`, locked `21.0.0` | `pubspec.yaml`, `pubspec.lock` |
| image_picker | constraint `^1.2.1`, locked `1.2.2` | `pubspec.yaml`, `pubspec.lock` |
| image_picker_android | locked `0.8.13+17` | `pubspec.lock` |
| timezone | transitive, locked `0.11.0` | `pubspec.lock` |
| permission_handler | absent | dependency and import search |

The current working `pubspec.yaml` reports `1.1.5+17`, while `AGENTS.md` reports `1.1.2+14`. This discrepancy predates P9 and must remain untouched; P9 will not bump or normalize the version.

Because minSdk is 24, Android 6/API 23 is not in the project-supported range. Runtime dangerous-permission behavior is still implemented correctly for every supported API, beginning with Android 7/API 24.

## Current Android declarations and transitive merge inputs

### App manifests

- `android/app/src/main/AndroidManifest.xml` declares no permission. It contains the exported launcher `MainActivity`, Flutter embedding metadata, a narrow `PROCESS_TEXT` query, and only `ScheduledNotificationReceiver` with `exported="false"`.
- `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml` each add only `INTERNET` for Flutter debugging/profile tooling.
- `MainActivity.kt` is currently an empty `FlutterActivity`; there is no permission/settings MethodChannel.

### Plugin merge inputs

- `flutter_local_notifications 21.0.0` declares `POST_NOTIFICATIONS` and `VIBRATE`.
- `image_picker_android 0.8.13+17` declares no permission. It contributes an exported-false `FileProvider` and a disabled/exported-false Photo Picker backport metadata service.
- The inspected lifecycle, preferences, JNI, and path-provider plugins contribute no dangerous permission.

Predicted source-level release list before P9: `POST_NOTIFICATIONS`, `VIBRATE`.
Predicted source-level debug/profile list before P9: `INTERNET`, `POST_NOTIFICATIONS`, `VIBRATE`.

## Permission matrix

| Permission / access | Android API range | Actual feature | Exact call site | Manifest declaration required | Runtime request required | Special access required | Denial fallback | Final decision |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `POST_NOTIFICATIONS` | API 33+ runtime; app notification toggle exists on older APIs | Habit reminders; Focus completion; user-triggered test notification | Existing Habit check/request: `lib/features/habits/data/habit_reminder_notification_service.dart:206-229`; existing Focus request: `lib/features/focus/data/focus_notification_service.dart:167-183`; P9 will consolidate these | Yes; currently transitive, P9 will explicitly own it in the app manifest as well | Yes, API 33+ only, after a reminder is enabled, Focus is started, or “开启通知/发送测试通知” is tapped | No | Preserve reminder/timer data and schedules; explain Android will suppress display; expose app notification settings | **keep** |
| `VIBRATE` | All supported APIs; normal permission | Default alert behavior for Habit and Focus completion channels | Current `AndroidNotificationDetails` leave vibration enabled; P9 versioned real channels retain standard alerting | Yes; transitive plugin declaration is sufficient | No | No | User can change sound/vibration per Android channel | **keep** |
| `RECEIVE_BOOT_COMPLETED` | All supported APIs; normal permission | Restore recurring Habit reminders and pending Focus completion after reboot/app replacement | Current schedules: Habit `habit_reminder_notification_service.dart:185-203`; Focus `focus_notification_service.dart:124-134`; plugin boot receiver performs restoration | Yes, app declaration required | No | No | App-start reconciliation still repairs schedules if a manufacturer suppresses boot delivery | **add** |
| `INTERNET` | Debug/profile only | Flutter debugger/hot reload transport | `android/app/src/debug/AndroidManifest.xml`, `android/app/src/profile/AndroidManifest.xml` | Debug/profile only; not main/release | No | No | Not applicable to product behavior | **keep in debug/profile only** |
| `CAMERA` | Dangerous runtime permission on supported APIs | Habit proof photo capture | `lib/features/habits/data/habit_record_attachment_storage.dart:353-360` calls `ImageSource.camera`; Android plugin launches `MediaStore.ACTION_IMAGE_CAPTURE` | No; the external system camera works without the app declaring it | No | No | Gallery remains available; camera app may be unavailable/cancelled and returns no image | **not applicable / do not add** |
| `READ_MEDIA_IMAGES` | API 33+ | Habit/Plan attachment selection | Habit gallery `habit_record_attachment_storage.dart:343-350`; Plan gallery `plan_record_attachment_storage.dart:215-230` | No | No | No | Android Photo Picker or `ACTION_GET_CONTENT` exposes only selected items | **not applicable / do not add** |
| `READ_EXTERNAL_STORAGE` | Legacy APIs | Same attachment selection | Same user-triggered picker call sites | No | No | No | User-scoped picker fallback | **not applicable / do not add** |
| `WRITE_EXTERNAL_STORAGE` | Legacy APIs | No feature; selected/captured files are copied into app documents | Habit private copy `habit_record_attachment_storage.dart:197-242`; Plan private copy `plan_record_attachment_storage.dart:42-74` | No | No | No | Keep files app-private | **not applicable / do not add** |
| `MANAGE_EXTERNAL_STORAGE` | API 30+ special access | No all-files feature | No call site | No | No | No | User-scoped picker and private storage | **not applicable / prohibited** |
| `RECORD_AUDIO` | Dangerous runtime permission | No speech, voice note, recording, transcription, or audio feature exists | No call site/dependency/import | No | No | No | Typed input remains the app interaction model | **MICROPHONE_NOT_REQUIRED / do not add** |
| `SCHEDULE_EXACT_ALARM` | API 31+ special access | No exact-to-the-minute product promise; current reminders are inexact | Habit schedule mode at `habit_reminder_notification_service.dart:201`; Focus at `focus_notification_service.dart:133` | No | No | No | Use `inexactAllowWhileIdle`; explain “普通提醒” in Settings | **not applicable / do not add** |
| `USE_EXACT_ALARM` | API 33+ restricted normal permission/store-policy-sensitive | No qualifying alarm/calendar core use case | No call site | No | No | No | Same inexact policy | **not applicable / prohibited** |
| `FOREGROUND_SERVICE` and service-type permissions | API-dependent | Focus state already persists end timestamp and reconstructs after resume/restart | `focus_store.dart:321`, `:558-584`; `focus_local_storage.dart:115` | No | No | No | Schedule only completion; reconstruct countdown from persisted end timestamp | **not applicable / do not add** |
| `ACCESS_NOTIFICATION_POLICY` | Special access | No DND bypass feature | No call site | No | No | No | Respect system DND/channel policy | **not applicable / prohibited** |
| `USE_FULL_SCREEN_INTENT` | Restricted notification capability | No alarm-call/full-screen use case | No call site | No | No | No | Standard notification | **not applicable / prohibited** |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Special access | No justified exemption | No call site | No | No | No | Inexact-while-idle scheduling plus manufacturer guidance | **not applicable / prohibited** |
| `SYSTEM_ALERT_WINDOW` | Special access | No overlay feature | No call site | No | No | No | Normal in-app UI/notifications | **not applicable / prohibited** |
| Location, contacts, SMS, phone, Bluetooth, nearby devices, package install/query-all | API-dependent | No matching feature | No call site | No | No | No | Not applicable | **not applicable / do not add** |

## Existing notification architecture

### Initialization

`main.dart` creates and initializes two independent `FlutterLocalNotificationsPlugin` instances: Habit at lines 21–23 and Focus at lines 30–31. Each service is only idempotent per instance, so global initialization, timezone setup, and response callback ownership are not consolidated. Both use `@mipmap/ic_launcher` as the Android small icon. Initialization errors can currently prevent `runApp`.

### Habit reminders

- Existing channel: `habit_daily_reminders`, English name `Habit reminders`, default importance.
- Scheduling: timezone-aware API but with a synthetic fixed-offset local zone, `AndroidScheduleMode.inexact`, recurring daily or weekday/time matching.
- IDs: deterministic entity/rule/weekday slots; all candidate IDs are cancelled before replacement.
- Store behavior: reminder data is persisted before scheduling; startup resyncs without prompting; pause/archive/delete cancel; restore reschedules.
- Gaps: mojibake title, no typed payload, no tap routing/action/privacy/accent, no pending-list health, and skipped scheduling while notification permission is denied.

### Focus completion

- Existing channel: `focus_reliability`, used first at low importance for an ongoing countdown and later at default importance for completion. Android channel immutability can leave completion at low importance.
- Existing IDs: running `4101`, completion `4102`.
- Existing behavior posts running/paused notifications as well as scheduling completion. Foreground completion can race with `clearFocusNotifications` and remove the completion notification; process death can leave the running notification stale.
- Focus end timestamp persistence and restart reconstruction already exist, so no foreground service is justified.

### Reboot/application replacement

`ScheduledNotificationReceiver` exists and is safely `exported="false"`, but `RECEIVE_BOOT_COMPLETED` and `ScheduledNotificationBootReceiver` are missing. Scheduled alarms are therefore not restored immediately after reboot/package replacement until the app is opened and Store reconciliation runs.

### Notification taps and payloads

No notification supplies a payload. Initialization has no response callback, background callback, or cold-start `getNotificationAppLaunchDetails` handling. `MaterialApp` has no navigator key dedicated to notification routing. Foreground, background, and terminated-state taps are unsupported.

## Photos, camera, files, and microphone

- Gallery selection is user-triggered. Current Android implementation uses `ACTION_GET_CONTENT` because `ImagePickerAndroid.useAndroidPhotoPicker` remains at its default `false`. P9 should opt into the documented Photo Picker contract, retaining `ACTION_GET_CONTENT`/system fallback where unavailable.
- Habit camera capture delegates to an external camera intent. The installed plugin only asks for `CAMERA` if the app first declares `CAMERA`; therefore declaring it would create an unnecessary permission flow. P9 must keep it absent.
- Selected/captured files are copied into app-private documents. There is no export or broad filesystem feature.
- No audio/microphone feature exists. `MICROPHONE_NOT_REQUIRED`.

## Forbidden-permission source audit

Source/plugin manifest search found no declaration of:

`MANAGE_EXTERNAL_STORAGE`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `RECORD_AUDIO`, `CAMERA`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `READ_CONTACTS`, `READ_PHONE_STATE`, `QUERY_ALL_PACKAGES`, `REQUEST_INSTALL_PACKAGES`, `SYSTEM_ALERT_WINDOW`, `USE_FULL_SCREEN_INTENT`, `ACCESS_NOTIFICATION_POLICY`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, `FOREGROUND_SERVICE`, `SCHEDULE_EXACT_ALARM`, or `USE_EXACT_ALARM`.

This was a source-level conclusion at audit time. The later debug merged-manifest and packaged-APK inspection confirmed it; see **Post-build closure** above. Runtime confirmation still requires an Android device or emulator.

## Existing test evidence and gaps

Existing Habit notification tests cover create/edit/remove, multi-rule schedules, startup resync without prompting, lifecycle cancellation, deterministic IDs, malformed time, and data preservation after denial. Focus tests cover persistence/reconstruction and the outgoing running-notification design. Attachment tests cover gallery/camera/private copying.

Missing evidence before P9 implementation:

- structured granted/denied/settings-required/not-applicable/web-safe permission results;
- contextual explanation and settings actions;
- one global notification initializer;
- pending replacement/cancellation/reconciliation and sanitized health state;
- inexact-while-idle scheduling without exact access;
- typed payload validation, route resolution, cold-start once-only handling, and deduplication;
- versioned channels, packaged icon, safe receivers, private visibility, and reliable UI-opening actions;
- compact Settings permission center and test notification.

## Audit gate conclusion

No broad or dangerous permission beyond Android 13 notification permission is supported by real application behavior. P9 can proceed with a narrow native notification-permission/settings bridge, one centralized local-notification engine, Photo Picker opt-in, boot restoration, and scoped UI/test work. No Store, domain model, persistence schema, version, AppShell, main-tab header, or route hierarchy change is required.
