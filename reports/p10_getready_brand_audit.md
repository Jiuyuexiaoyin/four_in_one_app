# P10 getready brand audit

Audit date: 2026-07-14

Repository: `D:\ai\projects\four_in_one_app`

Approved reference: `.ai_reference\branding\getready_brand_board.png`

Reference SHA-256: `BACA2369F76B8549276E6B932048E78D4397E589124BEB15BC1FB4E4F5BE019C`

This report records the state observed before P10 integration. The working tree already contained a large, uncommitted P8/P9 change set. P10 treats those files as user-owned baseline and changes only branding-specific lines and resources.

## 1. Current application display names

| Surface | Pre-P10 value | Source |
|---|---|---|
| Android launcher/application label | `Four In One` | `android/app/src/main/res/values/strings.xml` via `@string/app_name` |
| Flutter `MaterialApp.title` | `Four In One` | `lib/app/app.dart` |
| iOS display name | `Four In One App` | `ios/Runner/Info.plist` |
| Dart package identity | `four_in_one_app` | `pubspec.yaml` |

The requested product target is Flutter Android. The Dart package identity, Android namespace/application ID, Kotlin package, native method-channel names, and iOS metadata are not display-name changes authorized by this phase and remain unchanged. The actual pre-P10 `pubspec.yaml` version is `1.1.5+17`; it is preserved even though `AGENTS.md` still names an older version.

## 2. Current launcher icon resources

The manifest used `android:icon="@mipmap/ic_launcher"`. Five stock Flutter launcher PNGs existed:

| Density | Resource | Pixel size |
|---|---|---:|
| mdpi | `mipmap-mdpi/ic_launcher.png` | 48×48 |
| hdpi | `mipmap-hdpi/ic_launcher.png` | 72×72 |
| xhdpi | `mipmap-xhdpi/ic_launcher.png` | 96×96 |
| xxhdpi | `mipmap-xxhdpi/ic_launcher.png` | 144×144 |
| xxxhdpi | `mipmap-xxxhdpi/ic_launcher.png` | 192×192 |

There was no `android:roundIcon` and no round launcher resource.

## 3. Current adaptive icon resources

No `mipmap-anydpi-v26` or `mipmap-anydpi-v33` launcher XML existed. There was no adaptive background, adaptive foreground, Android 13 monochrome layer, or themed-icon resource. Local Flutter/Android configuration resolves to min SDK 24, compile SDK 36, and target SDK 36, so legacy, adaptive, and themed resource tiers are all relevant.

## 4. Current splash resources

`LaunchTheme` pointed to `@drawable/launch_background`. The base drawable was plain white and the v21 drawable used `?android:colorBackground`. There was no brand mark, wordmark, Android 12 `values-v31` splash style, or Flutter first-frame splash widget.

## 5. Current notification icon

P9 used `android/app/src/main/res/drawable/ic_stat_checkin.xml`, a white circle/check vector. The runtime default was `AppLocalNotificationService.notificationIcon = 'ic_stat_checkin'`; `raw/keep.xml` protected that drawable. P9 notification channels, receivers, permission behavior, scheduling, routing, and deep links were already implemented and are protected from behavioral change.

## 6. Current web title/favicon

The repository has no `web/` platform folder and no tracked web title or favicon. It also has no `windows/` platform folder or Windows runner branding. P10 does not generate whole platform targets merely to add branding.

## 7. Files that must change or be created

Brand masters and generation:

- `assets/branding/*.svg`
- `assets/branding/generated/*.png`
- `tools/branding/*`
- `reports/p10_getready_brand_assets/*.png`

Android integration:

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/values/strings.xml`
- `android/app/src/main/res/values/colors.xml`
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/drawable-v21/launch_background.xml`
- launcher foreground, monochrome, splash, and notification vector drawables
- legacy launcher and round PNGs for all five mipmap densities
- adaptive v26 and themed v33 launcher XML resources
- Android 12 light/night splash style resources
- `android/app/src/main/res/raw/keep.xml`

Flutter-visible branding and contracts:

- `pubspec.yaml` asset declaration only; package name, dependencies, and version remain unchanged
- `lib/app/app.dart` display title only
- `lib/features/settings/presentation/pages/settings_page.dart` existing About placeholder only
- `lib/core/notifications/app_local_notification_service.dart` icon resource name only
- focused notification/resource tests plus a new static brand-asset contract test

## 8. Files explicitly protected from change

- `lib/shared/widgets/app_shell.dart`
- `lib/shared/widgets/stitch_exact/main_page_header.dart`
- main-page header call sites and AppShell route titles
- Stores, domain models, persistence, permissions, receivers, notification channels, schedules, routing, and deep links
- `android/app/build.gradle.kts` namespace/application ID and Kotlin package paths
- `pubspec.yaml` package name, dependency set, and version
- iOS bundle/application metadata in this Android-targeted phase
- all Git metadata and all existing P8/P9 worktree changes unrelated to branding
- build outputs, `.dart_tool`, Pub cache, and Gradle caches

The old `ic_stat_checkin.xml` is intentionally retained as an unreferenced migration artifact because deletion was not authorized. P10 removes its runtime and shrinker references.
