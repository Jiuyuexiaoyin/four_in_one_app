# P10 getready brand integration report

Date: 2026-07-14

Scope: production getready vector/raster assets and Flutter Android integration. Product behavior, Stores, models, persistence, permission logic, notification channels/scheduling/routing, AppShell, main-page headers, package/application ID, dependencies, and version were preserved.

## 1. Approved logo direction

The integrated mark follows the approved board: three equal horizontal rounded steps rising from lower-left to upper-right; off-white top/bottom, technology-green middle; premium deep-space-black rounded-square launcher tile; lowercase `getready` wordmark with neutral `get` and green `ready`.

Production artwork was redrawn as exact flat geometry. No production icon was cropped from `.ai_reference\branding\getready_brand_board.png`; no board raster, glow, gradient, blur, or texture is embedded in a master.

Reference SHA-256: `BACA2369F76B8549276E6B932048E78D4397E589124BEB15BC1FB4E4F5BE019C`.

## 2. Geometry specification

Canonical mark canvas: 1000×1000. Each step is 300×110 with radius 55.

| Step | Position |
|---|---|
| top | x=500, y=275 |
| middle | x=350, y=445 |
| bottom | x=200, y=615 |

The combined mark bounds are x=200…800 and y=275…725: exactly 20% horizontal safe area and 27.5% vertical clearance. Full geometry, wordmark spacing, adaptive mapping, minimum sizes, and prohibited distortions are documented in `reports/p10_getready_geometry_spec.md`.

## 3. Colors

| Color | Hex |
|---|---|
| Deep space black | `#0D1117` |
| Deep gray-blue | `#1A1F28` |
| Technology green | `#22C55E` |
| Off-white | `#F1F3F5` |

Masters use only flat approved solids. The notification resource is a pure white Android alpha mask.

## 4. Master vector files

Required masters:

- `assets/branding/getready_mark.svg`
- `assets/branding/getready_mark_dark.svg`
- `assets/branding/getready_mark_light.svg`
- `assets/branding/getready_mark_monochrome.svg`
- `assets/branding/getready_wordmark_horizontal.svg`
- `assets/branding/getready_logo_vertical.svg`
- `assets/branding/getready_splash_logo.svg`

An additional optical master, `assets/branding/getready_notification_mark.svg`, documents the actual 24×24 status-bar geometry. Every SVG uses controlled geometric `<rect>` and system-font `<text>` elements, with no embedded raster, filter, gradient, external reference, or converted commercial glyph outline.

## 5. Generated raster files

Required production rasters:

- `assets/branding/generated/getready_mark_1024.png` — 1024×1024
- `assets/branding/generated/getready_mark_512.png` — 512×512
- `assets/branding/generated/getready_mark_256.png` — 256×256
- `assets/branding/generated/getready_mark_128.png` — 128×128
- `assets/branding/generated/getready_mark_64.png` — 64×64
- `assets/branding/generated/getready_wordmark_horizontal.png` — 1600×400
- `assets/branding/generated/getready_splash_dark.png` — 1440×2560
- `assets/branding/generated/getready_splash_light.png` — 1440×2560

`tools/branding/GenerateGetreadyAssets.java` and `generate_getready_assets.ps1` regenerate all rasters, Android launcher PNGs, splash lockup, proof sheets, and `getready_asset_manifest.json` from the SVG masters. The OpenJDK 21 pipeline uses secure JAXP plus Java2D/ImageIO, 4× supersampling, bicubic downsampling, explicit sRGB/gAMA metadata, alpha-zero RGB cleanup, post-write validation, atomic writes, and allowed-path enforcement. It requires installed `Segoe UI` and `Noto Sans SC` system fonts but bundles no font.

A same-input rerun was byte-deterministic. Final manifest SHA-256: `114769088A83DF412758FA48509C2B4D5FDDBDE7D94611C4CE5372F1D9E12669`.

## 6. Android launcher integration

The five stock Flutter launcher PNGs were replaced with getready production icons at mdpi 48, hdpi 72, xhdpi 96, xxhdpi 144, and xxxhdpi 192. Matching round PNG resources were added at every density.

`AndroidManifest.xml` keeps `android:icon="@mipmap/ic_launcher"` and now adds `android:roundIcon="@mipmap/ic_launcher_round"`. The package/application ID remains `com.example.four_in_one_app`.

## 7. Adaptive/themed icon integration

API 26+ adaptive resources use a separate `#0D1117` background and transparent `ic_launcher_foreground`; no rounded-square background is baked into the foreground. API 33+ overrides add `ic_launcher_monochrome` for themed icons. Both standard and round resource names have v26 and v33 definitions.

APK resource-table inspection confirms five legacy densities plus `anydpi-v26` and `anydpi-v33` configurations for both launcher names. Compiled v33 XML contains `<background>`, `<foreground>`, and `<monochrome>` children.

## 8. Notification icon integration

`android/app/src/main/res/drawable/ic_stat_getready.xml` is a transparent 24×24 vector with three solid white 9×3 rounded steps. It has no tile, green, gradient, shadow, or wordmark.

`AppLocalNotificationService.notificationIcon` and `raw/keep.xml` now use `ic_stat_getready`. Existing P9 initialization, channels, receivers, scheduling, actions, permissions, and deep links are unchanged. The previous `ic_stat_checkin.xml` is intentionally retained but unreferenced by new runtime/keep configuration so an upgraded device with a serialized pre-P10 notification request still has its historical drawable available.

## 9. Splash integration

Legacy Android startup uses a static `#0D1117` background plus a centered transparent vertical getready mark/wordmark lockup. Android 12+ light and night styles use the centered three-step vector on `#0D1117`, without a tagline or wordmark that would violate the platform icon constraint.

No Flutter first-frame splash, progress bar, artificial delay, or startup restructuring was added. The full dark/light splash compositions and tagline are production/proof assets; the proof sheet labels the first-frame layout as a concept not integrated in P10.

## 10. Application display-name changes

Changed visible names:

- Android `@string/app_name`: `Four In One` → `getready`
- Flutter `MaterialApp.title`: `Four In One` → `getready`

The repository has no `web/` or `windows/` platform folder, so no web title/favicon or Windows product name exists to update. iOS remains `Four In One App`; iOS was outside this Flutter Android phase. Internal Dart package name, widget class names, Kotlin package, method channels, namespace, and application ID remain unchanged.

## 11. In-app branding changes

Only the existing disabled About/version placeholder in Settings/My was replaced. The compact row shows the 64 px getready mark, lowercase split-color wordmark, current version `1.1.5+17`, and tagline `一步一个脚印，持续前进`.

No AppShell, main-page header, accepted page layout, functional icon, Store, model, or navigation behavior was changed.

## 12. Files changed

P10-specific source and report changes:

- eight SVG files under `assets/branding/`
- eight required PNGs plus one JSON manifest under `assets/branding/generated/`
- three generator/readme files under `tools/branding/`
- `reports/p10_getready_brand_audit.md`
- `reports/p10_getready_geometry_spec.md`
- this integration report and six proof PNGs
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/values/strings.xml`
- `android/app/src/main/res/values/colors.xml`
- base and v21 `launch_background.xml`
- `ic_launcher_foreground.xml`, `ic_launcher_monochrome.xml`, `ic_splash_getready.xml`, and `ic_stat_getready.xml`
- four adaptive icon XML files under `mipmap-anydpi-v26` and `mipmap-anydpi-v33`
- ten launcher/round PNG files across five mipmap densities
- `drawable-nodpi/getready_splash_brand.png`
- light/night Android 12 splash style files
- `android/app/src/main/res/raw/keep.xml`
- `pubspec.yaml` asset declaration only
- `lib/app/app.dart` display title only
- `lib/features/settings/presentation/pages/settings_page.dart` About placeholder only
- `lib/core/notifications/app_local_notification_service.dart` notification icon name only
- `test/android_manifest_contract_test.dart`
- `test/app_local_notification_service_test.dart`
- new `test/getready_brand_assets_test.dart`

The repository was already heavily dirty with accepted P8/P9 changes. P10 did not commit, reset, stash, clean, checkout, modify Git configuration, or overwrite unrelated changes. No backup was created because changes were non-destructive/additive and the dirty user-owned baseline had to remain intact.

## 13. Analyze result

Command: `D:\ai\flutter\bin\flutter.bat analyze`

Result: exit 0, `No issues found!` in 5.6 seconds. Final targeted format check processed six P10 Dart files with zero remaining changes.

## 14. Complete test count

Command: `D:\ai\flutter\bin\flutter.bat test`

Result: **247/247 passed** in 17 seconds. All 239 pre-P10 declarations remain present and passing; P10 adds eight static vector/raster/dimension/sRGB/launcher/adaptive/notification/splash/display-name contracts. The final declaration split is 179 unit tests and 68 widget tests.

## 15. Debug APK result

Command: `D:\ai\flutter\bin\flutter.bat build apk --debug`

Result: exit 0 in 808.1 seconds. No release APK was built.

Artifact: `build\app\outputs\flutter-apk\app-debug.apk`

- size: 173,699,500 bytes
- SHA-256: `1C1DA3987774169945055F20FBB2CA5483822CB4BCCD9656EA47142CE7A4508A`
- package: `com.example.four_in_one_app`
- version: `1.1.5` / code 17, unchanged
- min/target/compile SDK: 24 / 36 / 36
- ABIs: arm64-v8a, armeabi-v7a, x86_64
- APK Signature Scheme v2: verified with one standard Android debug RSA-2048 signer
- zip alignment: verified

The exact build caused Flutter/Gradle to install missing Android toolchain components into `D:\Android\Sdk`: NDK 28.2.13676358, Build-Tools 35.0.0, Platform 36 revision 2, Platform-Tools 37.0.0, Platform 35 revision 2, and CMake 3.22.1. No project dependency declaration, lockfile content/timestamp, SDK configuration, signing configuration, package ID, or version was changed by P10. The build emitted a future-compatibility warning about Kotlin Gradle Plugin migration but completed successfully.

## 16. APK resource inspection

Android Build-Tools 35 `aapt`, `aapt2`, `apksigner`, and `zipalign` inspected the compiled APK.

Verified packaged state:

- application label: lowercase `getready` across resource locales
- manifest icon: `mipmap/ic_launcher`
- manifest round icon: `mipmap/ic_launcher_round`
- five legacy PNG densities for standard and round icons
- adaptive v26 standard/round XML
- themed v33 standard/round XML with packaged monochrome drawable
- packaged adaptive foreground and deep-space-black background color
- packaged legacy splash lockup and Android 12 splash vector/styles
- packaged `drawable/ic_stat_getready` with three white vector paths
- packaged Flutter About-row asset `assets/branding/generated/getready_mark_64.png`

Exact debug permission surface matches accepted P9:

- `android.permission.INTERNET` (debug only)
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.VIBRATE`
- `com.example.four_in_one_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

No permission was added or removed by P10. `git diff --check` exited 0; it printed only existing Windows line-ending conversion warnings.

## 17. Proof-sheet paths

- `reports/p10_getready_brand_assets/getready_asset_contact_sheet.png`
- `reports/p10_getready_brand_assets/getready_launcher_mask_preview.png`
- `reports/p10_getready_brand_assets/getready_small_size_preview.png`
- `reports/p10_getready_brand_assets/getready_dark_light_preview.png`
- `reports/p10_getready_brand_assets/getready_notification_icon_preview.png`
- `reports/p10_getready_brand_assets/getready_splash_preview.png`

Visual QA passed all six proof sheets after one proof-only clipped inset was corrected in the generator. Proofs cover 1024/512/256/128/64/32/24 px, round/circle/squircle masks, dark/light systems, monochrome notification form, horizontal/vertical combinations, and native splash constraints.

## 18. Device-review checklist

No Android device or emulator is attached (`flutter devices` reports only Windows, Chrome, and Edge; `adb devices -l` is empty). Perform these checks on real Android hardware before device verification:

1. Clean-install the debug APK and confirm the launcher label is lowercase `getready`.
2. Inspect the standard icon under circle, squircle, rounded-square, and vendor masks; verify no step is clipped and the mark is optically centered.
3. On API 24–25, confirm the legacy icon and round resource are sharp.
4. On API 26–32, confirm adaptive foreground/background parallax and masking.
5. On API 33+, enable themed icons and verify the monochrome icon in light/dark wallpaper palettes.
6. On API 24–30, verify the dark legacy splash, centered mark/wordmark, and no white flash or artificial delay.
7. On API 31+, verify the dark native splash and centered mark-only treatment.
8. Open Settings/My and verify the compact About row, lowercase wordmark, version, tagline, scale, and accessibility semantics.
9. Send Habit, Focus, and test notifications in light/dark status bars; verify the small icon is three clean white steps with no square tile or green fill.
10. Tap notification bodies/actions from foreground, background, and terminated states to confirm P9 routing/deep links remain unchanged.
11. Test an upgrade over a P9 build with a pending notification; verify retained `ic_stat_checkin` prevents migration failure and new schedules use `ic_stat_getready`.
12. Recheck permission request/deny/grant flows, channels, reboot restoration, and package-update restoration against the accepted P9 matrix.
13. Capture launcher, themed launcher, legacy splash, Android 12 splash, Settings About row, notification shade, and status-bar screenshots for review.

## 19. Remaining risks

- Real vendor launcher masks, OEM icon scaling, Android 12 splash rendering, status-bar rasterization, and upgrade behavior are not device-verified.
- The Settings version is intentionally dependency-free and therefore hard-coded to the preserved current value `1.1.5+17`; a future release bump must update it in the same release batch.
- iOS still exposes the old display name because this phase targets Flutter Android. Web and Windows targets do not exist.
- Text raster reproducibility depends on the documented OpenJDK/system-font stack. The generator fails closed if those fonts or supported SVG grammar are unavailable.
- A pre-P10 serialized notification may display the retained historical check icon until P9 reconciliation/rescheduling replaces it; new notifications use the getready mark.
- Flutter warns that future releases will require migration away from the current Kotlin Gradle Plugin application pattern; this is unrelated to P10 and did not affect the successful build.
- The working tree contains extensive pre-existing uncommitted P8/P9 changes; P10 did not attempt to separate or commit them.

## Final verdict

GETREADY_BRAND_ASSETS_READY_FOR_DEVICE_REVIEW
