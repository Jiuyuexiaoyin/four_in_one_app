# Codex App Recovery Notes

Date: 2026-05-10
Project: four_in_one_app
Current stage: V6B Plan Due Dates / Priority / Tags / Search

---

## Why This Document Exists

Codex App became unreliable during V6B because:

- Multiple overlapping validation scripts confused agents (`validate_v6b.ps1`, `v6b.cmd`, `v6b_app.cmd`, `run_v6b_validation.cmd`).
- Old handoff docs (`validation_protocol.md`, `README_FOR_NEW_CODEX.md`) still referenced `validate_v6b.ps1`, which builds APKs and writes logs.
- Long inline PowerShell command chains sometimes hang or do not stream output inside Codex App.
- Path corruption incidents (spaces inserted into tool paths) caused silent failures.

---

## Correct Codex Workflow

**Codex edits code. Codex runs one safe command. Codex reads the result. Codex fixes failures.**

### Step 1: Edit Code

Make changes in `lib/` or `test/` as instructed. Do not touch `pubspec.yaml` version, `android/`, `ios/`, or any APK/build artifact.

### Step 2: Validate

Run exactly this one command from the project root:

```
.\tooling\v6b.cmd
```

That's it. No long PowerShell blocks. No environment variable setup. No direct Dart/Flutter commands.

### Step 3: Read the Result

The script prints `FAILED_STEP: <step-name>` when a step fails and exits immediately. Fix only the code related to the named step.

### Step 4: If the Shell Stalls

If Codex App's shell stalls or does not stream output:

1. **Stop.** Do not repeat the command.
2. Report to the user: "Shell did not produce output. Please run `.\tooling\v6b.cmd` manually."
3. The user runs `.\tooling\v6b.cmd` in their own terminal.
4. The user pastes the `FAILED_STEP` line into the Codex conversation.
5. Codex fixes the code based on that line.

---

## What `.\tooling\v6b.cmd` Does

`v6b.cmd` calls `tooling\check_v6b_readonly.ps1`, which:

1. Prints Dart and Flutter version.
2. Checks formatting of V6B files with `dart format -o none --set-exit-if-changed` (read-only, never writes).
3. Runs focused tests: `flutter test --no-pub test\goals_persistence_test.dart`
4. Runs focused tests: `flutter test --no-pub test\goals_flow_test.dart`
5. Runs targeted analyze: `flutter analyze --no-pub lib\features\goals ...`
6. Runs full analyze: `flutter analyze --no-pub`
7. Runs full tests: `flutter test --no-pub`

No APK build. No log files written. Safe to run at any time.

---

## What NOT To Do

| Forbidden | Reason |
|---|---|
| `tooling\validate_v6b.ps1` | Formats files, writes logs, builds APK — not safe for code-edit loop |
| `tooling\check_v6b_readonly.ps1` (direct) | Internal script; always call via `v6b.cmd` |
| `tooling\v6b_app.cmd` / `v6b_app.ps1` | Experimental; may not stream reliably |
| `flutter build apk` | APK prep only with explicit user approval |
| `git clean` / `git reset` / `git config` | Destructive or config-altering |
| Bumping `pubspec.yaml` version | Only for phone-test APK releases |
| Long inline PowerShell validation blocks | Unreliable in Codex App shell |
| `dart format` without `-o none` | May silently modify files |

---

## If New Codex Starts Fresh

Read in this order before touching code:

1. `AGENTS.md` — project rules and validation command
2. `docs/ai_handoff/README_FOR_NEW_CODEX.md` — feature context
3. `docs/ai_handoff/v6b_current_status.md` — what is done / what remains
4. `docs/ai_handoff/current_project_state.md` — file state summary
5. This file — recovery notes

Then report current state before changing anything.
