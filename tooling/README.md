# tooling/ — V6B Validation Scripts

## Canonical Validation Command

```
.\tooling\v6b.cmd
```

Run this from the project root `D:\AI\Projects\four_in_one_app`.
This is the **only** approved V6B validation entry for Codex agents.

---

## What Each Script Does

### `v6b.cmd` — CANONICAL ENTRY (use this)

```cmd
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check_v6b_readonly.ps1"
```

A minimal CMD wrapper. Calls `check_v6b_readonly.ps1`. Safe to run anytime.

### `check_v6b_readonly.ps1` — REAL VALIDATION LOGIC (called by v6b.cmd)

The actual read-only validation script. It:

- Uses exact hard-coded tool paths (no environment variable lookups that can fail).
- Runs `dart format -o none --set-exit-if-changed` (check-only, never writes).
- Runs `flutter test --no-pub` for focused V6B test files.
- Runs `flutter analyze --no-pub`.
- Runs full `flutter test --no-pub`.
- Does **not** build an APK.
- Does **not** write any log files.
- Prints `FAILED_STEP: <name>` on the failing line so Codex can read it.

**Do not run this script directly.** Always invoke it through `v6b.cmd`.

### `validate_v6b.ps1` — DEPRECATED / FORBIDDEN FOR CURRENT WORKFLOW

**Do not run this script** during V6B development.

Why forbidden:
- Runs `dart format --set-exit-if-changed` in write mode (modifies files).
- Writes a log file to `tooling/v6b_validation_last.log`.
- Runs `flutter build apk --debug --no-pub` (builds a debug APK).
- Requires explicit user approval for a phone-test APK release before use.

### `v6b_app.cmd` / `v6b_app.ps1` — EXPERIMENTAL (not canonical)

Experimental wrappers that re-run `v6b.cmd` and capture output to
`tooling/v6b_app_last.log` via `Tee-Object`. Not the approved path.
May not stream output reliably inside Codex App. Do not use.

### `run_v6b_validation.cmd` / `run_validate_v6b_guarded.ps1` — LEGACY (do not use)

Old entry-point wrappers that may route to `validate_v6b.ps1`.
Not part of the current approved workflow.

---

## Forbidden Operations

Never run from Codex agents or automation:

- `tooling\validate_v6b.ps1`
- `tooling\check_v6b_readonly.ps1` (call it only via `v6b.cmd`)
- `tooling\v6b_app.cmd` / `tooling\v6b_app.ps1`
- `tooling\run_v6b_validation.cmd`
- `flutter build apk`
- `git clean`
- `git reset`
- `git config`
- `dart format` without `-o none` (unless user explicitly approves formatting)
- Deleting `build/`, `.dart_tool/`, Pub cache, Gradle cache

---

## How Codex Agents Should Behave

1. Edit code in `lib/` or `test/` as instructed.
2. Run `.\tooling\v6b.cmd` to validate.
3. Read the output. If a step shows `FAILED_STEP: <name>`, fix only the related code.
4. If the shell stalls or does not stream output, stop and tell the user. The user can run `.\tooling\v6b.cmd` manually and paste the `FAILED_STEP` line.
5. Never run long inline PowerShell command chains for validation.
6. Never bump version. Never prepare APK.
