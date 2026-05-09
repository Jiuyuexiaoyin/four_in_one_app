# Validation Protocol

This project previously had command-construction and Flutter wrapper issues. Be conservative.

## Do Not Do These

- Do not manually type long Flutter/Dart command chains.
- Do not use `Start-Process`.
- Do not paste long environment variable blocks directly into the shell for validation.
- Do not delete `build/`.
- Do not delete `.dart_tool/`.
- Do not delete Pub cache.
- Do not delete Gradle cache.
- Do not clean Android cache.
- Do not bump version unless preparing an approved phone-test APK.
- Do not prepare APK unless explicitly approved.

## Correct Tool Paths

Flutter:

```text
D:\AI\Tools\Flutter\flutter\bin\flutter.bat
```

Dart:

```text
D:\AI\Tools\Flutter\flutter\bin\cache\dart-sdk\bin\dart.exe
```

Current SDK:

- Flutter `3.41.7`
- Dart `3.11.5`

## Previous Flutter SDK Repair

Previous diagnosis:

- direct Dart VM worked;
- `dart.bat` and `flutter.bat` wrappers hung;
- `shared.bat` had a bad Unix-style `$git` issue;
- `flutter_tools.stamp` was abnormal and contained only `:`;
- Flutter SDK folder was repaired/replaced;
- validation later succeeded.

If wrappers hang again, diagnose Flutter SDK wrapper health before touching project code.

## Preferred V6B Validation

Use the script:

```powershell
Set-Location "D:\AI\Projects\four_in_one_app"
.\tooling\validate_v6b.ps1
```

This script uses exact paths and one command per line.

If the script fails, copy the exact failed command and output into the report. Fix only the related V6B code.

## Manual Fallback

Only if the script cannot run, use direct invocations one at a time.

Example:

```powershell
& 'D:\AI\Tools\Flutter\flutter\bin\flutter.bat' test --no-pub 'test\goals_persistence_test.dart'
```

Inspect every command before execution:

- executable path;
- subcommand;
- `--no-pub`;
- exact test or source path;
- no accidental path concatenation;
- no extra parameters unless the user approved them.

