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

## Full Visual Library Gate

- All UI tasks must know the full visual library exists.
- The full library index is `ai/reports/visual_library_full.md`.
- The task-specific image pack manifest is `ai/reports/codex_image_manifest.md`.
- Implementer sees task-specific selected images, not the entire library by default.
- Reviewer checks against the full visual brief and full library lessons.
- Do not attach all images blindly to every task unless explicitly requested.
- If the user explicitly requests all images, planner should first create a full visual audit, not a direct implementation task.

## AI-AUTO-1.0 Controlled Team Loop

AI-AUTO-1.0 is a controlled agent team loop scaffold, not a complete autonomous agent team. Linear jobs remain useful for visibility. The `team_loop` workflow mode is for bounded repair-loop orchestration:

implement -> verify -> review -> visual review -> fix -> verify again -> review again.

Rules:

- No auto-commit.
- No auto-merge.
- No APK build.
- Fixer loops are capped at 2.
- `enable_fixer=false` by default.
- `execute=false` by default.
- The verifier remains script/CI output, not model opinion.
- Implementation tasks require an exact allowed file list.
- `code_implementation`, `ui_implementation`, and `release` tasks must fail if `AllowedFileListPath` is missing or contains globs, directories, absolute paths, or parent traversal.
- App-source writes are allowed only when TaskType and exact allowlist permit them.
- UI implementation cannot be final without screenshot artifacts and visual review.
- User final visual approval remains required.

Task types:

- `probe`: reports only.
- `audit`: `docs/ui_redesign/*.md` and `ai/reports/*.md` only.
- `workflow`: AI scripts, prompts, workflow YAML, agent workflow docs, and task specs only.
- `docs`: docs only, excluding `docs/references/**`.
- `code_implementation`: exact allowlist required.
- `ui_implementation`: exact allowlist, visual references, screenshot artifact, verifier, and visual reviewer required.
- `release`: explicit user approval and exact release allowlist required.

The fixed `D:\AI` paths are valid only on the local Windows self-hosted runner. GitHub-hosted runners will not have these paths.

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
