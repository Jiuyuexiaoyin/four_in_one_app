# V6G Digital Wellbeing Research Report

Status: research-only, docs-only. No code changes.

Project: `four_in_one_app`

Current version: `1.1.2+14`

---

## V6 Full-Pass Closure Note

V6G remains research-only and docs-only. No digital wellbeing product implementation, native permission, Android/iOS config change, dependency change, version bump, phone-test APK preparation, or `flutter build apk` was added.

V6 full-pass validation was completed through the only approved entry:

```powershell
.\tooling\v6b.cmd
```

Confirmed validation result:

- V6B read-only validation completed.
- focused goals tests passed.
- targeted analyze passed.
- full analyze passed.
- full tests passed: 172 tests.

Version remains `1.1.2+14`.

Carry-forward review focus:

- do not add `PACKAGE_USAGE_STATS`, FamilyControls, Accessibility Service behavior, or any new plugin without explicit approval;
- keep OffScreen-like claims honest and unavailable-state driven;
- do not fabricate screen time, pickup count, notification count, app usage ranking, app limits, or restrictions.

---

## Research Goal

Determine whether a real optional digital wellbeing module is feasible:

- What platform data is available on Android and iOS?
- What permissions are required and what is the UX for granting them?
- What could a Flutter app access via existing or lightweight plugins?
- What should remain out of scope?
- What is the recommended path forward?

---

## Platform Data Available

### Android

Android exposes phone usage data through `UsageStatsManager` (API level 21+):

- Per-app foreground time in a given time range (`queryUsageStats`)
- Aggregated daily/weekly totals per app
- Last-used timestamps per app
- Event-level timestamps: app foreground, app background (`queryEvents`)

Notification count is not directly available through `UsageStatsManager`. Android `NotificationListenerService` can count delivered notifications but requires the user to explicitly whitelist the app as a notification listener (separate from standard permissions).

Pickup count (screen wake / unlocks) is not directly available in public Android APIs. Approximate unlock events can be derived from `ACTION_USER_PRESENT` broadcast, but that requires a background receiver and has been restricted in recent Android versions (API 26+).

### iOS

iOS does not expose public Screen Time or phone usage data to third-party apps.

Before iOS 16, there was no public API for this. Screen Time APIs existed only as private entitlements for Apple internal use and enterprise MDM scenarios.

iOS 16+ introduced `ManagedSettingsStore` and `DeviceActivityMonitor` (Screen Time Framework, `FamilyControls` entitlement) but these require:

- Apple's `com.apple.developer.family-controls` entitlement (restricted, requires formal Apple approval)
- The app must be positioned as a parental control tool
- Cannot be used for a general productivity app

There is no public first-party API for third-party apps to read screen time, app usage, or pickup counts on iOS without going through the Screen Time framework and FamilyControls entitlement.

---

## Permission Requirements

### Android

`android.permission.PACKAGE_USAGE_STATS` is a **special app op permission**. It cannot be requested at runtime via the standard `requestPermissions` flow. The user must navigate to **Settings → Apps → Special app access → Usage access** and manually enable the permission for the app.

This is intentional by Android's design because usage stats are considered sensitive. The typical flow is:

1. App detects that `AppOpsManager.checkOpNoThrow(OPSTR_GET_USAGE_STATS)` returns `MODE_ALLOWED`.
2. If not granted, app shows an explanation screen.
3. App opens the system Usage Access settings page via `Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)`.
4. User manually enables the toggle.
5. App polls or re-checks the permission after the user returns.

This UX is significantly more friction-heavy than standard `requestPermissions`. Users often find it unfamiliar.

Additionally, the Android `READ_PHONE_STATE` permission (for call log) is a standard runtime permission and is not relevant to screen time or wellbeing.

### iOS

No permission path exists for general third-party usage data without the FamilyControls entitlement.

---

## Flutter Implementation Options

### Option A: Pure Dart / Platform Channels (Custom)

Write a custom Flutter platform channel that calls `UsageStatsManager` from Kotlin/Java and returns usage data to Dart.

Requirements:
- Kotlin plugin code in `android/`
- Custom permission check and intent routing
- No iOS equivalent possible without restricted entitlement

Maintenance: medium. Any Gradle/AGP changes in the project affect plugin compilation.

### Option B: Existing Plugin (e.g., `usage_stats` or `device_apps`)

Community plugins exist for wrapping `UsageStatsManager` (e.g., `flutter_usage_stats`, `device_apps`). However:

- These plugins have varying maintenance status
- Adding a new native plugin increases project complexity and Gradle risk
- The project's current policy is "no new dependency recommended" unless explicitly approved
- iOS stubs would be required to avoid compilation failures

### Option C: Derive Wellbeing Insights from Existing In-App Data

Instead of requesting platform phone usage data, derive attention-awareness signals from what the app already knows:

- Focus session history: how many sessions completed, total focus time
- Habit completion patterns: consistency and active days
- Review data: combined in-app activity trends

This approach produces honest, bounded signals that the user's own in-app behavior generates. It does not claim to measure real phone usage or screen time.

This is already partially implemented:
- Review focus section shows completed sessions and total minutes
- Review habits section shows 7-day activity strip
- Focus weekly overview shows day-level session counts

---

## Reference App (OffScreen) Audit

OffScreen's digital wellbeing features include:

- Daily screen time (total and per-app)
- App usage rankings
- Pickup count (unlocks)
- Notification count
- Focus mode (blocks specified apps)
- Scheduled quiet hours
- Ambient screen time

All of these except the Focus mode require:
- `PACKAGE_USAGE_STATS` permission on Android
- Or FamilyControls entitlement on iOS

OffScreen's Focus mode (app blocking) additionally requires:
- `BIND_ACCESSIBILITY_SERVICE` on Android (high privilege, Play Store restricted for non-accessibility use)
- Screen Time API (FamilyControls entitlement) on iOS

The honest conclusion is that OffScreen-level features are not achievable for a general productivity app in the Play Store without significant platform friction and policy risk.

---

## Verdict

| Feature | Android Feasible | iOS Feasible | Permission Friction |
| --- | --- | --- | --- |
| Per-app screen time | Yes | No (without entitlement) | High (manual Settings toggle) |
| Total screen time | Yes | No | High |
| Daily pickups / unlocks | Partial (derived via broadcast) | No | Medium to high |
| Notification count | Requires NotificationListenerService | No | High (manual Settings toggle) |
| App usage ranking | Yes | No | High |
| App blocking / focus mode | Requires Accessibility Service | Requires FamilyControls | Very high (Play/App Store policy risk) |
| In-app session counts | Already available | Already available | None |
| In-app habit consistency | Already available | Already available | None |

---

## Recommendation

**Do not implement an OffScreen-style digital wellbeing module at this stage.**

Reasons:

1. **iOS gap is fundamental.** Without FamilyControls entitlement (which Apple restricts to parental control tools), iOS users get no parity. Implementing Android-only wellbeing data creates a fragmented, misleading user experience.

2. **Permission UX is disruptive.** `PACKAGE_USAGE_STATS` requires the user to navigate deep into Android Settings and manually flip a toggle. This is not appropriate friction for a calm productivity app. Users expect the app to be trustworthy and low-ceremony.

3. **Policy risk is real.** Accessibility-service-based app blocking is a restricted category in the Play Store. FamilyControls is restricted by Apple. Neither is appropriate without explicit product positioning as a parental control or enterprise tool.

4. **In-app session data is already honest and sufficient.** The app already captures all its own focus sessions, habit check-ins, and activity. The Review and Focus weekly overview features (V6D, V6E) now show real in-app behavioral patterns without requiring any platform permission or external data.

5. **"Fake" wellbeing data is not acceptable.** The product direction explicitly rules out fake analytics. Showing estimated phone usage without `PACKAGE_USAGE_STATS` permission would violate this principle.

---

## What Is Already Done (Honest In-App Wellbeing Signals)

The following is already available as of V6D and V6E without any new permissions:

- Focus weekly session count per day (ActivityStrip on FocusPage)
- Focus week-to-date totals: sessions and minutes (MetricStrip on FocusPage)
- Focus recent 7-day session count strip (ActivityStrip on ReviewPage)
- Habit 7-day check-in activity strip (ActivityStrip on ReviewPage and HabitsPage)
- Cumulative focus minutes on ReviewPage
- Habit consistency rate and active days on ReviewPage

These are the honest, appropriate digital wellbeing indicators for this product.

---

## Path Forward

- **V6G is complete as research-only docs.** No code change is needed.
- **The "后续" placeholder** for digital wellbeing remains in the settings page. It correctly signals that this feature is planned but not yet started.
- **If the user wants to pursue this in a future package (V7+),** the prerequisite steps are:
  1. Decide whether to target Android-only or to accept iOS parity gap.
  2. Evaluate whether a lightweight community plugin (e.g., `usage_stats`) is stable and Gradle-compatible.
  3. Design the permission request UX (explanation screen → system settings → callback).
  4. Add honest empty/unavailable states for all data points when permission is denied.
  5. Do not display screen time estimates or any fabricated numbers.
  6. Get explicit approval before adding any native plugin or `PACKAGE_USAGE_STATS` permission to `AndroidManifest.xml`.

---

## Non-Negotiable Constraints (Carry Forward)

- Do not claim to show screen time without `PACKAGE_USAGE_STATS` permission.
- Do not invent pickup count, notification count, or app usage data.
- Do not add `android.permission.PACKAGE_USAGE_STATS` to `AndroidManifest.xml` without explicit approval.
- Do not add `FamilyControls` entitlement configuration without explicit Apple approval.
- Do not add any new dependency (plugin) for wellbeing data without explicit approval.
- All wellbeing-adjacent UI must have honest zero/unavailable states.
