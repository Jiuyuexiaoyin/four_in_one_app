# P7H-2A Habit Detail Rhythm Audit

## Goal

Analyze current Habit detail / month view / records / statistics UI and produce a redesign audit for a modern, minimal, rhythm-based interface inspired by The Outsiders and Equinox+.

This is audit-only. Do not modify app code.

## Required Visual Context

- `docs/ui_redesign/P7_VISUAL_BRIEF.md`
- `docs/references/REFERENCE_MANIFEST.md`
- `ai/reports/visual_library_full.md`
- `ai/reports/codex_image_manifest.md`
- `ai/reports/visual_refs_selected.txt`

## Hard Output Requirements

The generated audit document MUST include this exact heading:

```markdown
## Visual Reference Reports Used
```

This section must explicitly cite:

- `ai/reports/visual_refs_selected.txt`
- `ai/reports/codex_image_manifest.md`
- `ai/reports/visual_library_full.md`

It must also mention:

- Current App UI group
- Desired UI Taste Board group
- Functional Benchmark Apps group
- selected image count: 12
- full visual library count: 38

The generated audit document MUST also include this exact heading:

```markdown
## Tests to Run for P7H-2B
```

Under that heading, it must include the exact phrase:

```text
tests to run
```

And include this concrete checklist:

- `habits_flow_test.dart`
- `app_smoke_test.dart`
- `settings_theme_test.dart`
- `today_overview_test.dart` if Today entry points are affected
- full V6B verification wrapper:
  `D:\AI\Tools\Codex\four_in_one_v6b_verify.cmd`

The generated audit must still include:

- Theme Studio requirements
- P7H-2B scope
- screenshot acceptance checklist
- no color-only/token-only/card-stack direction

## Allowed Files

- `docs/ui_redesign/P7H_2A_habit_detail_audit.md`
- `ai/reports/planner_report.md`
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
- `*.apk`

## Audit Must Answer

1. Why current habit detail/month view feels database-like.
2. What must remain for habit semantics and tests.
3. How month grid should become rhythm visualization.
4. How recent records should become minimal/collapsed.
5. How completion distribution/year activity should become calmer.
6. How Theme Studio and habit color should drive the page.
7. Which reference images were used.
8. What P7H-2B should be allowed to edit.
9. What tests P7H-2B must run.
10. Screenshot acceptance checklist.

## Safety Execution Requirements

- Real codex execute may be allowed for this task only if task_file is exactly:
  `P7H_2A_habit_detail_audit.md`
- The only non-report output allowed is:
  `docs/ui_redesign/P7H_2A_habit_detail_audit.md`
- Before and after execution, run:
  `git diff --name-only`
- If any changed file starts with:
  - `lib/`
  - `test/`
  - `android/`
  - `ios/`
  - `docs/references/`
  - `build/`
  or equals `pubspec.yaml`, fail immediately with `FORBIDDEN_CHANGE_DETECTED`.
- Do not commit.
- Do not build.
- Do not run Flutter.

## Reviewer Requirements

- PASS only if changed files are limited to allowed files.
- FAIL if audit does not cite visual references.
- FAIL if audit is generic.
- FAIL if it suggests color-only/token-only/card-stack changes.
- FAIL if it ignores Theme Studio.
