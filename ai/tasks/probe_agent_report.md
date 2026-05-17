# Probe Agent Report

## Goal

Verify that AI Task `execute=true` can call the agent pipeline safely.

## Allowed Files

- `ai/reports/probe_agent_report.md`
- `ai/reports/implementer_report.md`
- `ai/reports/reviewer_report.md`
- `ai/reports/final_report.md`

## Forbidden Files

- `lib/**`
- `test/**`
- `pubspec.yaml`
- `android/**`
- `ios/**`
- `docs/references/**`
- `build/**`

## Expected Implementer Behavior

- Create `ai/reports/probe_agent_report.md`.
- Write timestamp, runner user, task name, and statement that no app code was changed.

## Expected Reviewer Behavior

- Verify no app source/test/pubspec files changed.
- Output PASS if only `ai/reports` files changed.

## Verification

- No Flutter required.
- `git diff --name-only` must not include:
  - `lib/`
  - `test/`
  - `pubspec.yaml`
  - `android/`
  - `ios/`

## Acceptance

- `ai/reports/probe_agent_report.md` exists.
- `ai/reports/implementer_report.md` exists if implementer ran.
- `ai/reports/reviewer_report.md` exists if reviewer ran.
- No app source changes.
