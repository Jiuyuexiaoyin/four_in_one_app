# AI-AUTO-1.0 Controlled Agent Team Loop Scaffold

## What It Is

AI-AUTO-1.0 is a controlled scaffold for a bounded team loop:

implement -> verify -> review -> visual review -> fix -> verify again -> review again.

It is designed for the local Windows self-hosted runner used by `four_in_one_app`.

## What It Is Not

This is not a complete autonomous agent team. It must not be described as fully autonomous until it proves that verifier failures produce correct fix prompts, reviewer failures produce scoped fixes, visual reviewers can inspect screenshots, fixers modify only allowed files, verification reruns after fixes, artifacts preserve reports, and no source pollution occurs.

It does not auto-commit, auto-merge, build APKs, or bypass user approval.

## Runner Path Assumptions

The current runner uses fixed local Windows paths:

- `D:\AI\Projects\four_in_one_app`
- `D:\AI\Tools\Flutter`
- `D:\AI\Tools\Codex`

These paths are valid only on this self-hosted Windows runner. GitHub-hosted runners will not have these paths. If the project moves to a different runner, scripts must be parameterized or path-mapped.

## Task Types

- `probe`: may modify only `ai/reports/*.md`; no Flutter; no screenshot required.
- `audit`: may modify `docs/ui_redesign/*.md` and `ai/reports/*.md`; no app source changes; no Flutter; screenshot optional.
- `workflow`: may modify `ai/scripts/**`, `ai/prompts/**`, `.github/workflows/**`, `docs/agent_workflows/**`, and `ai/tasks/**`; no app source changes.
- `docs`: may modify `docs/**`, but not `docs/references/**`; no Flutter.
- `code_implementation`: may modify app source/tests only when exact allowed files are listed.
- `ui_implementation`: exact allowed files, visual references, verifier, screenshot artifact, and visual reviewer are required.
- `release`: requires explicit user approval and exact release allowlist.

## AllowedFileListPath Format

Implementation and release tasks require a plain text allowlist. Use one exact repository-relative file path per line with forward slashes only.

Valid:

```text
lib/features/habits/presentation/pages/habits_page.dart
test/habits_flow_test.dart
```

Invalid:

```text
lib/**
test/**
lib/features/habits/
D:\AI\Projects\four_in_one_app\lib\foo.dart
../pubspec.yaml
```

Blank lines and comment lines beginning with `#` are allowed. Wildcards, directory-only entries, absolute paths, and parent traversal are rejected.

## Safe Dry-Run Example

```powershell
.\ai\scripts\run_ai_team_loop.ps1 -TaskFile P7H_2A_habit_detail_audit.md -TaskType audit -UseImages -TaskPack habits -VerificationProfile none
```

## Execute Without Fixer Example

```powershell
.\ai\scripts\run_ai_team_loop.ps1 -TaskFile P7H_2A_habit_detail_audit.md -TaskType audit -Execute -UseImages -TaskPack habits -VerificationProfile audit
```

## Execute With Fixer Example

```powershell
.\ai\scripts\run_ai_team_loop.ps1 -TaskFile some_ui_task.md -TaskType ui_implementation -Execute -UseImages -TaskPack habits -VerificationProfile ui-smoke -EnableFixer -MaxFixLoops 2 -AllowedFileListPath ai\tasks\some_ui_task_allowed_files.txt
```

## Artifact Upload

The GitHub workflow uploads:

- `ai/reports/**`
- `ai/logs/**`
- `screenshots/**`

Missing artifact folders are ignored.

## Screenshot Gate

For `ui_implementation`, a screenshot artifact is required before visual review can PASS. Audit, probe, workflow, and docs tasks do not require screenshots.

## Current Limitations

- Visual screenshot gate is scaffold-only until screenshot capture is wired into a task.
- No APK build is performed.
- No auto-commit or auto-merge is performed.
- App-source write tasks require separate approval and an exact allowlist.
- User final visual approval remains required.
