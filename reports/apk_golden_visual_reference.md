# APK Golden Visual Reference

Date: 2026-07-08
Primary source requested: `.ai_reference\apk\golden_latest.apk`
Candidate inspected: `.ai_reference\apk\golden_latest.apk.1`

## 1. APK Path

- Requested path: `.ai_reference\apk\golden_latest.apk`
- Requested path exists: `false`
- Candidate path used for metadata: `.ai_reference\apk\golden_latest.apk.1`

The candidate was not renamed, copied, uploaded, or modified.

## 2. APK SHA256

`3186F9BB479188B2EF931815BA3AA2ADCB9CC53A48B015F8E6DEE99F6BE4CED7`

## 3. Package/App Metadata

- Package: `com.example.four_in_one_app`
- App label: `four_in_one_app`
- Version: `2.1.0` (`210`)
- minSdk: `24`
- targetSdk: `36`
- Launcher activity: `com.example.four_in_one_app.MainActivity`

## 4. Screenshots Captured Or Manual Screenshot Requirements

Screenshots captured: none.

Reason:

- `adb` is not available on PATH.
- No Android SDK platform-tools were found in common local SDK roots.
- `adb version` and `adb devices` both failed because `adb` is not recognized.
- No emulator/device install was attempted.

Manual screenshot requirements:

1. Place the APK at the exact requested path if possible: `.ai_reference\apk\golden_latest.apk`.
2. On a machine with Android platform-tools, run: `adb version`
3. Connect a phone or emulator and confirm: `adb devices`
4. Install without uploading: `adb install -r .ai_reference\apk\golden_latest.apk`
5. Launch: `adb shell monkey -p com.example.four_in_one_app -c android.intent.category.LAUNCHER 1`
6. Capture each screen with: `adb exec-out screencap -p > .ai_reference\apk\screenshots\NN_screen_name.png`
7. Capture at minimum:
   - `01_today_home.png`
   - `02_habits.png`
   - `03_create_habit.png`
   - `04_plan_goals.png`
   - `05_focus.png`
   - `06_review_recap.png`
   - `07_my_settings.png`
   - Any extra important screen reachable from the APK bottom nav or primary actions.
8. Also capture `adb shell uiautomator dump /sdcard/window.xml` after each screen if text hierarchy is needed, then pull it to `.ai_reference\apk\screenshots\NN_screen_name.xml`.

## 5. Screen-By-Screen Golden UI Summary

Cannot be produced reliably in this environment because the APK could not be run and no APK screenshots are available.

What is known from metadata only:

- This is a Flutter APK.
- It contains Flutter snapshots/assets and a single Android launcher activity.
- Static APK contents do not expose the rendered route-level UI in a reliable way.

## 6. Differences From Current Flutter UI

Cannot be determined against the APK visual target without screenshots.

Known current Flutter state from route inspection:

- Current bottom nav is `Today / Habits / Plan / Focus / My`.
- Current routed pages use the previous Stitch-style `StitchPanel`, `StitchCommandHeader`, `StitchMetricGrid`, charts, heatmaps, and neon navigation.
- Review remains reachable outside bottom nav.

Because the previous Stitch rebuild was visually rejected, the current Flutter UI should not be treated as golden even though it is functionally wired.

## 7. Differences From Stitch UI

Cannot be determined against the APK visual target without screenshots.

Available Stitch reference remains secondary:

- `.ai_reference\stitch\spec\stitch_visual_spec.md`
- `.ai_reference\stitch\screenshots\01_today.png` through `05_my_settings.png`
- `.ai_reference\stitch\html\01_today.html` through `05_my_settings.html`

Stitch describes a dark neon dashboard system, but the APK must override it once real screenshots are captured.

## 8. Rebuild Priority

Priority is blocked until APK screenshots exist.

Once screenshots are available:

1. Rebuild AppShell/bottom nav to match APK exactly.
2. Rebuild Today/Home first.
3. Rebuild Habits and Create Habit.
4. Rebuild Plan/Goals hierarchy.
5. Rebuild Focus.
6. Rebuild Review/Recap if present.
7. Rebuild My/Settings.
8. Preserve real stores and actions while replacing visible structure.

## 9. What Cannot Be Recovered From APK

- Original Flutter source code.
- Exact widget tree names and Dart implementation.
- Store model changes not visible in runtime UI.
- Design token intent beyond rendered pixels.
- Dynamic states that are not manually navigated and captured.
- Secrets, credentials, or private runtime data.

No attempt was made to recover full source code from the APK.

## 10. Exact Next Implementation Plan

Do not edit Flutter UI yet.

Next phase should be:

1. Provide or expose a device/emulator with `adb`.
2. Rename or place the APK at `.ai_reference\apk\golden_latest.apk`, or explicitly approve using `.ai_reference\apk\golden_latest.apk.1`.
3. Install and launch the APK locally.
4. Capture the required screen set into `.ai_reference\apk\screenshots\`.
5. Create a new visual spec from APK screenshots.
6. Only then write a route-level implementation plan against the APK screenshots.

## Final Verdict

BLOCKED_BY_NO_DEVICE_OR_SCREENSHOTS
