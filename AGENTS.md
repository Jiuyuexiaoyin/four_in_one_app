# four_in_one_app Codex Rules

## Project

Project path:
D:\AI\Projects\four_in_one_app

Current version:
2.6.0+18

Do not bump version unless the user explicitly starts a phone-test APK release process.
Do not prepare APK unless the user explicitly asks.
Do not run flutter build apk unless the user explicitly asks.

## Shell Rules

This project is on Windows 10 22H2.
Use Windows PowerShell only.
Never use bash, Linux, macOS, or CMD syntax.
Never insert spaces into paths.
Never change D:\AI into D: \AI.
Never change tooling\check_v6b_readonly.ps1 into tooling \check_v6b_readonly-ps1.
Never change validate_v6b.ps1 into validate_ v6b.ps1.
Never change goals_flow_test.dart into goals flow test.dart.

## Execution Rules

Do not automatically run validation commands.
Prefer command review mode.
If a command path is corrupted once, stop running commands immediately.
After a corrupted command, only edit code and report changes. The user will run validation manually.

## V6B Validation

The only allowed V6B validation entry is:
.\tooling\v6b.cmd

Do not run:
tooling\validate_v6b.ps1
tooling\check_v6b_readonly.ps1
flutter build apk

Reason:
validate_v6b.ps1 may format files, write logs, and build debug APK.
check_v6b_readonly.ps1 is an internal script behind the approved short entry and must not be run directly.
flutter build apk and any APK preparation flow are forbidden unless the user explicitly starts a phone-test APK release process.

Do not bump version.
Do not prepare APK.

## Tooling Reference

Full explanation of each script and the approved workflow:
  tooling\README.md

If Codex App shell stalls or is confused about scripts:
  docs\ai_handoff\codex_app_recovery_notes.md

## Forbidden

Do not delete:
- build/
- .dart_tool/
- Pub cache
- Gradle cache

Do not run:
- git clean
- git reset
- git config
- Start-Process
- flutter build apk
- dart format without -o none, unless the user explicitly asks to format a specific file
- tooling\validate_v6b.ps1 (deprecated, may format files and build APK)
- tooling\v6b_app.cmd / tooling\v6b_app.ps1 (experimental, not canonical)
- tooling\run_v6b_validation.cmd (legacy, routes to deprecated scripts)
