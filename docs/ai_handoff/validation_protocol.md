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

## V6B Validation — Canonical Command

```
.\tooling\v6b.cmd
```

Run from the project root. This is the **only** approved V6B validation entry.

It calls `tooling\check_v6b_readonly.ps1`, which is read-only:
no file formatting, no log writes, no APK build.

Output includes `FAILED_STEP: <name>` on failure.

## DEPRECATED: validate_v6b.ps1

`tooling\validate_v6b.ps1` is **forbidden** for the current V6B workflow.

It formats files, writes logs, and builds a debug APK.
Do not run it unless the user explicitly starts a phone-test APK release process.

## If the Shell Stalls

Stop and report to the user. Do not repeat the command.
The user can run `.\tooling\v6b.cmd` manually and paste the `FAILED_STEP` line.

## Manual Fallback Is User-Run Only

Codex must not switch to direct Flutter or Dart commands automatically.

Codex must not bypass `.\tooling\v6b.cmd`.

If `.\tooling\v6b.cmd` is unreliable in Codex App shell, stop and ask the user to run it manually in normal PowerShell and paste `FAILED_STEP`.

The user may run direct fallback commands manually only if they decide `v6b.cmd` itself is broken.
