# APK vs Current vs Stitch Gap Report

Date: 2026-07-08

## Inputs Read

APK:

- Requested `.ai_reference\apk\golden_latest.apk`: missing
- Candidate `.ai_reference\apk\golden_latest.apk.1`: valid APK, metadata extracted

Current Flutter route files:

- `lib/app/router/app_router.dart`
- `lib/shared/widgets/app_shell.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`

Stitch references:

- `.ai_reference\stitch\spec\stitch_visual_spec.md`
- `.ai_reference\stitch\screenshots\01_today.png` through `05_my_settings.png`
- `.ai_reference\stitch\html\01_today.html` through `05_my_settings.html`

## Golden APK Visual Structure

Blocked.

The candidate APK metadata is available, but no route screenshots were captured because `adb` is not available and no device/emulator could be queried.

Therefore, any claim about the APK's rendered Today/Habits/Plan/Focus/My/Review visuals would be an invention and is intentionally omitted.

## Current Flutter Implementation

Current route structure:

- `AppShell` uses five bottom-nav tabs: `Today`, `Habits`, `Plan`, `Focus`, `My`.
- `Review` is routed with `showBottomNavigation: false`.
- Active pages use the previous Stitch-style component layer under `lib/shared/widgets/visual_dna/`.
- The app remains wired to real `HabitsStore`, `GoalsStore`, `FocusStore`, and `AppSettingsStore`.

Current visual direction:

- Dark/neon dashboard shell.
- `StitchPanel`, `StitchCommandHeader`, metric grids, progress rails, mini charts, and heatmaps.
- Route-level pages were already rewritten in the previous Stitch attempt, but the user rejected the visual result.

## Stitch Target Structure

Stitch provides a secondary dark neon dashboard reference:

- Today: huge focus score, peak rhythm card, circular metrics, priority execute card, flux chart, action timeline.
- Habits: STRIVE header, system integrity, current cadence, rhythm chart, active protocols.
- Plan: strategic command, core intent, strategic pillars, milestone log.
- Focus: flow-status cockpit, large timer, progress rail, weekly distribution, heatmap.
- My/Settings: Theme Studio, Color Lab, utility rows, local data.

## Where Current UI Is Wrong

Against APK:

- Unknown until screenshots are captured.
- The user has already stated the current Flutter UI does not match the desired newer APK app, so current UI must not be used as the visual source of truth.

Against Stitch:

- The current implementation follows Stitch vocabulary but was visually rejected.
- It likely over-indexes on generic Stitch component reuse instead of matching the actual newer APK composition.
- Because APK is primary now, Stitch should only supply fallback styling ideas after APK screenshots are available.

## What Should Be Rebuilt From APK

Blocked until screenshots exist.

Expected rebuild targets once captured:

- AppShell navigation shape, labels, active state, background, and route order.
- Today/Home dashboard hierarchy.
- Habits list/statistics and Create Habit flow.
- Plan/Goals hierarchy and action entry points.
- Focus timer layout and control positions.
- Review/Recap visibility and layout, if present.
- My/Settings profile/theme/data sections.

## What Can Be Borrowed From Stitch

Only if it matches the APK screenshots:

- Dark background and cyan accent system.
- Compact dashboard card language.
- Progress rails, small charts, and heatmap components.
- Five-core bottom navigation model with Review outside nav.

Stitch must not override APK visual evidence.

## Manual Capture Gate

The next useful work is not Flutter editing. It is screenshot capture from the APK.

Required local device flow:

1. Ensure `adb` is installed and on PATH, or provide its full local path.
2. Confirm a device/emulator with `adb devices`.
3. Install the APK locally.
4. Capture PNG screenshots for each main screen into `.ai_reference\apk\screenshots\`.
5. Capture optional UI XML dumps for text/route labels.

## Final Verdict

BLOCKED_BY_NO_DEVICE_OR_SCREENSHOTS
