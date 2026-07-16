# P9 Android Permission and Notification Plan

Date: 2026-07-13 (Asia/Shanghai)
Basis: `reports/p9_android_permission_audit.md`

## Decision summary

Risk rating: **medium and controlled**. Android manifest permissions, runtime dialogs, notification settings intents, and boot receivers affect user trust and operating-system behavior. The user explicitly authorized this exact scoped work. All changes remain project-local and reversible through ordinary file diffs; no credential, global SDK, signing, release, Git metadata, or protected runtime change is involved.

Proceed with:

1. one narrow Android MethodChannel for notification status/request/settings and device timezone ID;
2. one process-wide local-notification initializer and typed response pipeline;
3. versioned Habit and Focus-completion channels only;
4. inexact-while-idle scheduling only;
5. boot/package-replacement restoration;
6. Android Photo Picker opt-in with user-selected access;
7. contextual Chinese permission explanations at real user actions;
8. one compact `通知与权限` Settings section;
9. focused Dart/native/manifest/APK evidence.

Do not add camera, storage/media, microphone, exact-alarm, foreground-service, full-screen, DND, overlay, battery-exemption, location, contacts, SMS, phone, Bluetooth, nearby-device, package-install, or broad-package-query permissions.

## Permission policy

### Notifications

- Explicitly declare `POST_NOTIFICATIONS` for audit ownership even though the plugin also contributes it.
- On API 33+, check status before every protected user operation and request only after:
  - a Habit reminder is newly enabled or retained during a user save;
  - the user starts/continues a Focus round that schedules completion;
  - the user taps `开启通知` or `发送测试通知`.
- Never request during app initialization, Store restoration, startup reconciliation, or Settings page display.
- Show a short Chinese pre-dialog before the Android system dialog.
- Native structured status will distinguish `granted`, requestable `denied` (including dismissed/unchanged), `settingsRequired` (user-fixed/app notifications disabled), `restricted`, `unavailable`, and `notApplicable`.
- Denial never rolls back Habit reminder configuration or Focus state. Schedules remain reconciled, while UI states clearly say Android will suppress display.
- Expose app notification settings and versioned Habit channel settings. Do not loop the system request when settings are required.

### Photos and files

- Make the already-resolved `image_picker_android` package an explicit direct dependency only because its documented Photo Picker opt-in API is imported directly; do not upgrade it.
- Before image-picker use, set `ImagePickerAndroid.useAndroidPhotoPicker = true` when the active platform implementation is Android.
- Retain plugin/system fallback behavior on devices without Photo Picker.
- Keep copies in existing app-private documents directories.
- Add no media/storage permission.

### Camera

- Keep the current external `MediaStore.ACTION_IMAGE_CAPTURE` behavior.
- Do not declare or request `CAMERA`.
- Keep gallery selection as the existing fallback.
- Settings will explain `使用系统相机，无需本应用单独访问相机` rather than presenting a fake permission switch.

### Microphone

- No feature exists. Do not declare `RECORD_AUDIO` and do not show a microphone row.
- Documentation verdict: `MICROPHONE_NOT_REQUIRED`.

### Exact alarms

- Do not declare `USE_EXACT_ALARM` or `SCHEDULE_EXACT_ALARM`.
- Use `AndroidScheduleMode.inexactAllowWhileIdle` for Habit and Focus completion schedules.
- No exact-alarm settings intent or special-access request will exist.
- Settings reports `使用普通提醒` and explains that Android may adjust delivery slightly for battery health.
- Schedule code catches platform failures and records a sanitized health error; there is no exact-mode `SecurityException` path.

### Reboot and application replacement

- Add `RECEIVE_BOOT_COMPLETED`.
- Keep `ScheduledNotificationReceiver` exported false.
- Add `ScheduledNotificationBootReceiver` exported false with only the plugin-documented `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON`, and HTC quick-boot actions.
- Store startup reconciliation will cancel/replace deterministic IDs, so boot restoration plus later app reconciliation does not create duplicate reminders.

### Foreground services

- Add no service and no service permission.
- Real Focus service methods for running/paused drawer notifications will become safe no-ops/legacy cleanup while the unchanged `FocusStore` continues persisting the target end timestamp.
- Schedule only the completion notification. Track its due time inside the adapter so natural completion does not race-cancel the alarm, while pause/reset before the deadline still cancels it.

## Permission coordinator design

Create a small `lib/core/permissions/` layer:

- `app_permission.dart`
- `app_permission_status.dart`
- `android_permission_coordinator.dart`
- `permission_explanation.dart`

The coordinator will:

- use an injectable bridge for deterministic tests;
- guard web and non-Android platforms before any MethodChannel call;
- return structured results instead of booleans;
- check before request;
- never throw on missing plugins/unsupported APIs;
- open only relevant app notification/channel settings;
- never request at construction or initialization.

`MainActivity.kt` will expose only:

- notification status;
- notification request on API 33+;
- app notification settings;
- channel settings on API 26+;
- current Android timezone ID.

It will not expose filesystem, package, credential, overlay, battery, or unrelated permission capabilities.

## Local-notification architecture

Create a focused `lib/core/notifications/` implementation shared by the existing Habit and Focus service interfaces.

Required behavior:

- one `FlutterLocalNotificationsPlugin` owner and idempotent initialization future;
- timezone database initialized once, with the native IANA timezone ID when available and a safe fixed-offset fallback;
- a lifecycle refresh that resyncs Habit schedules only when the timezone ID changes;
- deterministic IDs and cancel-before-replace behavior;
- pending request listing and count;
- sanitized last-operation error;
- explicit channel creation and channel-health inspection;
- typed JSON payload with schema version, type, entity ID, expected route, and optional action;
- strict payload/route/action validation;
- foreground/background response stream plus cold-start launch-detail capture;
- once-only cold-start consumption and duplicate-response suppression;
- no background-isolate data mutation.

The unchanged Store interfaces continue to trigger scheduling/cancellation. Habit startup reconciliation remains the source-of-truth mapping from stored entities to pending schedules.

## Channels and presentation

Create only:

| ID | Chinese name | Importance | Purpose |
| --- | --- | --- | --- |
| `habit_reminders_v1` | `习惯提醒` | default | User-configured recurring Habit reminders |
| `focus_completion_v1` | `专注完成` | default | One notification when a Focus round reaches its end |

The old `habit_daily_reminders` and `focus_reliability` IDs are not reused. Deterministic app-start cancellation/rescheduling migrates pending reminders to the new IDs. Old, unused channels may remain visible on upgraded devices because Android owns created-channel history; this will be documented rather than silently assuming mutable channel behavior.

Presentation policy:

- dedicated monochrome `@drawable/ic_stat_checkin` with transparent background;
- explicit keep resource so string-based plugin lookup survives shrinking;
- current default accent `#2E6B5A` (initial runtime app accent may be supplied to notification details);
- `NotificationVisibility.private`;
- reminder category, concise Chinese title/body, BigText only where useful;
- no full-screen intent, DND bypass, ongoing countdown, or progress spam.

Reliable UI-opening actions only:

- Habit: `去打卡` → Habits page.
- Focus: `查看记录` → Review page; `再来一轮` → Focus page.
- No silent completion mutation and no background snooze scheduling.
- Add `ActionBroadcastReceiver` exported false because these actions are implemented with `showsUserInterface: true`.

## Navigation plan

- Keep the existing route names and AppShell composition.
- Add a stable navigator key at the app root.
- Resolve validated Habit payloads to `AppRoute.habits` (the allowed Habits-page fallback; no new target-detail hierarchy).
- Resolve Focus payloads to `AppRoute.focus`; action `查看记录` resolves to existing `AppRoute.review`.
- Reject malformed/mismatched payloads without navigation.
- Queue responses until navigator readiness and deduplicate the same launch response.

## Contextual UI plan

Add no new page and no header change.

- Habit create/edit/reminder-save flows call the permission explanation only when enabled rules exist, then save regardless of denial.
- Focus start/continue calls the explanation before starting, then continues regardless of denial.
- Replace only the existing disabled Settings reminder placeholder with a new focused widget using `MySettingsSection`/`MySettingsRow`.

Settings rows:

1. `通知权限` — real state and contextual request/settings action.
2. `提醒精度` — `使用普通提醒`; no exact-access control.
3. `图片访问` — Photo Picker/user-selected explanation.
4. `相机` — external system camera explanation, not a permission switch.
5. `通知测试` — one clearly labelled immediate notification.
6. `系统设置` — app notification settings.
7. `提醒渠道` — relevant Habit channel settings where supported.
8. collapsed `提醒健康状态` — permission, channel state, ordinary precision, pending count, and sanitized last error.

No microphone row and no technical dashboard expansion by default.

## Test plan

Add focused tests for:

- coordinator granted, denied, settings-required, restricted/unavailable, not-applicable, and web-safe behavior;
- contextual request invocation and denial-preserves-data behavior;
- settings method abstraction;
- single schedule, replacement, deletion/lifecycle cancellation through existing Store tests;
- inexact-while-idle policy when exact access is absent/not applicable;
- strict malformed payload rejection;
- Habit/Focus/action route resolution;
- cold-start once-only consumption and duplicate suppression;
- Settings rows/status/test-notification behavior;
- manifest permission absence, receiver exported values, and icon resource presence using source/APK inspection.

Do not weaken existing assertions. The repository currently contains 184 statically declared test/testWidget cases; the full executed total will be recorded after implementation.

## Verification and build plan

After edits:

1. format only modified Dart files with targeted `D:\ai\flutter\bin\dart.bat format <files>`;
2. run `D:\ai\flutter\bin\flutter.bat analyze`;
3. run `D:\ai\flutter\bin\flutter.bat test`;
4. run `git diff --check`;
5. build only `D:\ai\flutter\bin\flutter.bat build apk --debug` (explicitly authorized by this P9 request); no release build and no version bump;
6. inspect merged debug/release manifests where generated and the debug APK with available Android SDK tools;
7. run `D:\ai\flutter\bin\flutter.bat devices`;
8. perform device/emulator runtime checks only if an existing Android target is available; do not install a large emulator.

If no target exists, deliver the built/inspected APK evidence, an exact manual device checklist, and verdict `ANDROID_PERMISSIONS_NOTIFICATIONS_READY_FOR_DEVICE_REVIEW`.

## Rollback and protected boundaries

- Rollback path: remove only P9-added files and reverse only P9 hunks; do not reset or overwrite the already-dirty P8 worktree.
- No Git metadata operation, deletion, global install, SDK/toolchain change, release signing/build, account access, or secret handling.
- No AppShell/main-header redesign, Store/domain/schema/version change, Plan notification invention, or unrelated UI work.

## Post-review implementation amendment

Final reliability review tightened the implementation without changing the least-privilege policy:

- Focus completion IDs are derived from the target end timestamp instead of reusing singleton ID `4102`; `4102` remains cleanup-only migration state.
- Habit reconciliation reads the real pending list, removes typed/legacy orphans, and reconstructs calendar dates without DST wall-clock drift.
- Focus schedule/cancel operations are serialized and tested against delayed old-round cleanup and pending-query failure.
- Channel health distinguishes Habit and Focus channels and detects `Importance.none`; Settings exposes both channel controls.
- The proposed `再来一轮` action was removed because opening Focus alone did not fulfill that label. Only `查看记录` remains.
- Initialization is retryable, pre-listener notification destinations are buffered, and a disabled Habit channel prevents a falsely successful test-notification message.
