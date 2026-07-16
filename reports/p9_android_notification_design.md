# P9 Android Notification Design

Date: 2026-07-13 (Asia/Shanghai)

## Design intent

The Android notification drawer remains system-owned. P9 gives the app a recognizable, quiet identity through a dedicated status icon, consistent accent, concise Chinese copy, two real channels, private lock-screen visibility, and actions that only open safe in-app destinations.

No full-screen intent, DND bypass, exact alarm, foreground service, ongoing countdown, silent data mutation, or background-isolate persistence is used.

## Visual identity

### Small icon

- Resource: `android/app/src/main/res/drawable/ic_stat_checkin.xml`
- Default plugin icon: `ic_stat_checkin`
- Shape: solid white target ring plus check mark, transparent background
- Viewport: 24 × 24 dp
- Status-bar behavior: Android uses the alpha mask and supplies the system tint
- Shrinker protection: `android/app/src/main/res/raw/keep.xml`

The launcher icon is not reused as the small icon. A large icon is deliberately omitted: the current launcher asset is a generic Flutter mark and would add noise rather than a trustworthy productivity identity. The small icon and accent provide the appropriate branded system treatment until a real product launcher asset exists.

### Accent and privacy

- Default accent: `#2E6B5A`; the runtime service receives the app's current accent at initialization.
- System permission and channel settings identify the app as `Four In One` through `@string/app_name`.
- Lock-screen visibility: `NotificationVisibility.private`.
- Full-color backgrounds and colorized notification bodies are not used.
- BigTextStyle is present only to preserve readable wrapping for real Habit/Focus copy.

## Channels

| Channel ID | Chinese name | Description | Importance | Sound/vibration | Real producer |
| --- | --- | --- | --- | --- | --- |
| `habit_reminders_v1` | `习惯提醒` | `按你设置的日期和时间发送习惯打卡提醒` | default | standard channel controls | Habit reminder rules |
| `focus_completion_v1` | `专注完成` | `在一轮专注结束时提醒你查看记录` | default | standard channel controls | Focus completion only |

There is no Plan reminder implementation, so no Plan channel exists. The test notification reuses the real Habit channel and never creates an unused test channel.

The old `habit_daily_reminders` and `focus_reliability` IDs are not reused because Android channel importance and alert behavior are immutable after creation. Habit startup reconciliation cancels/replaces deterministic pending IDs with the new channel. Focus treats old ID `4102` as a migration ID and replaces it with a target-derived completion ID on the new channel. Android may retain dormant legacy channels on upgraded devices; code does not falsely assume it can mutate their behavior.

## Scheduling policy

- Mode: `AndroidScheduleMode.inexactAllowWhileIdle`.
- Exact-alarm permissions: absent.
- Habit schedule: daily or weekday/time recurrence using `DateTimeComponents`.
- Focus schedule: one absolute completion timestamp; no running/paused drawer notification.
- Stable IDs: entity/rule/weekday-derived Habit IDs; target-end-time-derived Focus completion IDs in an app-owned range; test ID `990001`.
- Replacement: cancel the ID, then schedule/show the replacement.
- Reconciliation: `HabitsStore` remains the source of truth and invokes app-start resync; the adapter compares desired IDs with the real pending list, removes typed/legacy orphans, and replaces desired schedules. Focus serializes schedule/cancel effects, removes stale owned completions, and protects a new round from delayed cleanup of the prior round.
- Reboot/update: plugin boot receiver restores its serialized schedules; later Store reconciliation uses the same deterministic IDs and does not duplicate them.
- Timezone: timezone database plus native Android timezone ID; app resume resyncs Habit schedules only when the timezone ID changes. Calendar-component construction preserves the configured wall-clock time across DST. A fixed-offset fallback is used only if the native ID is unavailable/unknown.

## Notification content

### Habit

- Title: `该打卡了`
- Body: `今天的「<习惯名称>」还未完成`
- Category: reminder
- Action: `去打卡`

The action opens the existing Habits page. It never silently records a check-in. No background snooze action is included because safe background persistence/scheduling was not proven.

### Focus completion

- Title: `专注完成`
- Body: `本轮专注已完成，回来看看刚才的进展`
- Category: reminder
- Action: `查看记录` → existing Review page

Running and paused Focus notifications are removed from real delivery. The unchanged Store still persists the end timestamp and reconstructs countdown state. The adapter tracks the scheduled target so a natural foreground completion does not race-cancel the AlarmManager delivery; pause/reset before the target cancels it.

`再来一轮` is deliberately absent: opening Focus alone does not actually start or prepare a new round, so that label would promise behavior the action cannot safely perform.

### Test

- Title: `通知测试`
- Body: `这是一条测试通知，不会重复发送`
- Immediate ID replacement; never added to the pending/repeating schedule list.
- On Android 8+, the real Habit channel is checked first; a disabled channel produces a truthful fallback and direct channel-settings action. Android 7 skips channel preflight because channels do not exist there.

## Payload and tap behavior

Payload JSON schema version: `1`.

Required validated fields:

- `schemaVersion`
- `type`
- `entityId`
- `route`
- optional `action`

Entity IDs are limited to 128 safe identifier characters. Unknown keys, types, routes, actions, unsafe identifiers, oversized payloads, malformed JSON, and type/route mismatches are rejected.

Routing matrix:

| Payload/action | Destination |
| --- | --- |
| Habit default / `去打卡` | `/habits` |
| Focus default | `/focus` |
| Focus `查看记录` | `/review` |
| Test tap | `/settings` |

The existing route hierarchy and AppShell cases are unchanged. One root navigator key consumes validated destinations. Cold-start details are queued once; live/background-resume callbacks use the same parser. A bounded deduplicator prevents a launch response and callback from pushing twice while allowing later recurring reminders.

## Permission-denial presentation

Scheduling and Store data do not depend on permission grant. On denial:

- the Habit reminder configuration remains saved;
- Focus starts and persists normally;
- Android suppresses notification display;
- the app shows a concise Chinese fallback message and a system-settings action;
- Settings shows the structured real status.

No permission request occurs during app launch, notification initialization, Store restoration, channel creation, or Settings status refresh.

## Manufacturer limitations

Android and OEM firmware may delay inexact alarms, suppress boot broadcasts, restrict background work, or require the user to allow vendor-specific autostart. P9 does not request battery-optimization exemption. The app repairs schedules on next launch/resume and documents ordinary-reminder behavior without promising exact-to-the-minute delivery.
