# P7 Agent Protocol

This document defines the future multi-agent workflow for P7 and later UI work. It is planning and verification scaffolding only; it does not authorize autonomous implementation, API usage, or merges.

## Roles

- Planner: defines the smallest safe scope, allowed files, forbidden files, acceptance criteria, and verification commands before implementation begins.
- Implementer: edits only the approved files and preserves existing behavior, keys, tests, persistence, and product semantics.
- Verifier: runs the approved scripts or CI jobs and records logs. The verifier is script/CI output, not model opinion.
- Reviewer: inspects diffs, screenshots, and logs, then outputs a clear PASS or FAIL.
- Fixer: addresses only the specific failing item reported by the verifier or reviewer.
- Reporter: summarizes changed files, verification evidence, risks, and next manual decisions.

## Hard Rules

- AI cannot claim success without verification logs.
- Verifier is script/CI, not model opinion.
- No domain/application/data changes unless explicitly allowed.
- No pubspec/native/tooling changes unless explicitly allowed.
- No build outputs, APKs, reference zips, or phone_test docs committed by default.
- Theme Studio/custom color must not be erased.
- UI work must be screenshot/reference driven, not color-only.
- Reviewer must output PASS/FAIL.
- Fix loops are limited to 2 rounds before escalation to the user.
- No auto-merge to main.

## Verification Modes

- targeted: runs analyze and focused route/UI tests through `ai/scripts/run_targeted_tests.ps1`.
- full: runs the stable local verification entry through `ai/scripts/run_verify.ps1`.

The current stable verification entry is:

```powershell
D:\AI\Tools\Codex\four_in_one_v6b_verify.cmd
```

## Visual Reference Gate

- UI tasks must pass through visual reference selection.
- The selection report is `ai/reports/visual_refs_selected.txt`.
- Reviewer must check visual reference usage.
- Without references, UI task cannot PASS.
- Theme Studio/custom color must remain visible.
- Current App UI screenshots are used to identify what to fix.
- Taste-board images are used to define desired visual language.
- Benchmark app images are inspiration, not literal cloning.

## Default Exclusions

Do not commit generated or local-only artifacts by default:

- build outputs
- APK files
- reference zip files
- temporary logs
- phone-test notes unless explicitly requested
- runner credentials or tokens

## Review Output

Reviewer output must include:

- PASS or FAIL
- verification command/log source
- changed-file scope
- forbidden-file check
- screenshot/reference comparison notes for UI work
- remaining risks
