# APK Golden Metadata

Date: 2026-07-08
Repo: `D:\ai\projects\four_in_one_app`

## Status

The exact requested APK path is missing:

- Requested: `.ai_reference\apk\golden_latest.apk`
- Exists: `false`

A likely local download-suffix candidate exists and was inspected without renaming or modifying it:

- Candidate used: `.ai_reference\apk\golden_latest.apk.1`
- Size: `154,516,701` bytes
- SHA256: `3186F9BB479188B2EF931815BA3AA2ADCB9CC53A48B015F8E6DEE99F6BE4CED7`
- ZIP/APK validity: valid ZIP archive
- Entry count: `555`
- Required APK entries found: `AndroidManifest.xml`, `resources.arsc`, `classes.dex` through `classes14.dex`

## Tool Availability

Available:

- PowerShell/.NET ZIP APIs
- `node.exe`
- `py.exe` launcher, but no installed Python runtime behind it

Not available from PATH or common local SDK roots:

- `adb`
- `aapt`
- `aapt2`
- `apkanalyzer`
- `jadx`
- `apktool`

Explicit checks:

- `adb version`: failed, `adb` not recognized
- `adb devices`: failed, `adb` not recognized

## Safe Manifest Metadata

Extracted from binary `AndroidManifest.xml` using a local PowerShell parser.

| Field | Value |
|---|---|
| package | `com.example.four_in_one_app` |
| app label | `four_in_one_app` |
| versionName | `2.1.0` |
| versionCode | `210` |
| minSdkVersion | `24` |
| targetSdkVersion | `36` |
| compileSdkVersion | `36` |
| compileSdkVersionCodename | `16` |
| launcher activity | `com.example.four_in_one_app.MainActivity` |
| activity count | `1` |
| app icon ref | `@0x7f0c0000` |

Permissions:

- `android.permission.INTERNET`
- `android.permission.VIBRATE`
- `android.permission.POST_NOTIFICATIONS`
- `com.example.four_in_one_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

## Visible Assets And Fonts

Flutter asset entries:

- `assets/flutter_assets/AssetManifest.bin`
- `assets/flutter_assets/FontManifest.json`
- `assets/flutter_assets/NOTICES.Z`
- `assets/flutter_assets/NativeAssetsManifest.json`
- `assets/flutter_assets/fonts/MaterialIcons-Regular.otf`
- `assets/flutter_assets/isolate_snapshot_data`
- `assets/flutter_assets/kernel_blob.bin`
- `assets/flutter_assets/shaders/ink_sparkle.frag`
- `assets/flutter_assets/shaders/stretch_effect.frag`
- `assets/flutter_assets/vm_snapshot_data`

Launcher icon entries:

- `res/mipmap-hdpi-v4/ic_launcher.png`
- `res/mipmap-mdpi-v4/ic_launcher.png`
- `res/mipmap-xhdpi-v4/ic_launcher.png`
- `res/mipmap-xxhdpi-v4/ic_launcher.png`
- `res/mipmap-xxxhdpi-v4/ic_launcher.png`

No full source recovery, dex decompilation, secret extraction, or credential inspection was attempted.

## Result

Metadata extraction from the valid local candidate APK succeeded, but APK screenshot extraction is blocked because no ADB/device runtime is available in this environment.
