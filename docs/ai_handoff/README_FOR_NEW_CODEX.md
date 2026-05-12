# README FOR NEW CODEX

Project path: `D:\AI\Projects\four_in_one_app`

Current app version: `1.1.2+14`

Current stage: V6 full-pass completed and validated.

V6A `Habit Structured Check-in Templates + Numeric Units` is completed and validated.

## First Rule

Before changing code, read the handoff docs and report the current state back to the user.

Do not bump version.
Do not prepare APK.
Do not add dependencies.
Do not change routing.
Do not change business semantics.

## Benchmark References Must Be Read

The four benchmark apps are local product and UI references. They are not optional.

1. HabitDone: `docs/references/app_content/HabitDone`
2. DayMark: `docs/references/app_content/daymark`
3. OffScreen: `docs/references/app_content/OffScreen`
4. 番茄ToDo: `docs/references/app_content/番茄ToDo`
5. Overall report: `docs/references/app_report_v2.txt`

These screenshots and reports are the product UI / feature benchmark basis. Do not ignore them.

For every later UI or feature package, explicitly state:

- which reference app traits were inherited;
- which traits were intentionally not copied;
- how the app remains unified instead of becoming a noisy benchmark clone.

## What Has Already Been Completed

- Theme Studio has a real dependency-free visual color picker.
- Habits have deep HabitDone-like tracking.
- V6A structured habit templates and numeric metrics are implemented.
- Plan has project detail, records table, statistics, note/numeric/image/habit-source records.
- Habit -> Plan linking creates evidence/history records without completing tasks.
- Focus has task/action binding and target snapshot history.
- Review uses real, factual metrics.
- Responsive polish has been repeatedly tested around 360dp / 393dp / 412dp and text scale 1.15.
- V6B Plan due dates, priority, tags, and read-only search/filter/sort are complete and validated.
- V6C Plan timeline, project charts, and year heatmap are implemented as read-only PlanRecord-derived displays.
- V6D Focus weekly overview is implemented.
- V6E Review focus activity strip is implemented.
- V6F Settings data summary is implemented.
- V6G Digital wellbeing research is completed as docs-only.
- V6H final benchmark review docs are updated.

## Latest Completed Package

V6 full-pass closure is complete:

- V6A completed.
- V6B Plan Due Dates / Priority / Tags / Search / Filter / Sort completed and validated.
- V6C Plan Timeline / Project Charts / Year Heatmap read-only MVP implemented.
- V6D Focus Weekly Overview implemented.
- V6E Review Focus Activity Strip implemented.
- V6F Settings Data Summary implemented.
- V6G Digital Wellbeing Research completed as docs-only.
- V6H Final Benchmark Review docs updated.

Validation was run manually by the user through the only approved read-only entry:

```powershell
.\tooling\v6b.cmd
```

Confirmed result:

- V6B read-only validation completed
- focused goals tests passed
- targeted analyze passed
- full analyze passed
- full tests passed: 172 tests

Version remains `1.1.2+14`.

No version bump was made.
No phone-test APK was prepared.
No `flutter build apk` was run.
No `pubspec.yaml` or dependency change was made.
No Android/iOS native change was made.

Semantic guardrails confirmed:

- PlanRecord schema and semantics remain untouched.
- PlanRecord note/numeric/image/source semantics remain untouched.
- Plan progress semantics remain untouched.
- task completion semantics remain untouched.
- Habit -> Plan linking semantics remain untouched.

Human review focus before any future release step:

- `lib/features/focus/presentation/pages/focus_page.dart`: `ListView` to `SingleChildScrollView` + `Column` migration.
- `lib/features/goals/presentation/pages/goals_page.dart`: V6C read-only Plan timeline/chart/year heatmap display.
- `lib/features/goals/application/goals_store.dart` and `lib/features/goals/domain/models/goal_item.dart`: derived statistics helpers.
- `tooling\validate_v6b.ps1`: forbidden historical script, not a direct validation entry.

The `.claude` worktree and experimental/old validation wrappers were moved out of the main project directory.

Backup location:

```text
D:\AI\Backups\four_in_one_app_cleanup_20260511_155835
```

Before starting the next feature package, confirm the package scope explicitly with the user. Do not automatically bump version or prepare APK.

## Must Not Be Changed

- Bottom navigation.
- Routing.
- Habits behavior.
- Focus timer/notification behavior.
- Review metrics logic.
- Plan task completion semantics.
- Plan progress rollup.
- PlanRecord note/numeric/image/source semantics.
- Habit -> Plan duplicate prevention.
- Theme Studio behavior.
- Dependencies.
- Native Android/iOS config.
- App version, unless explicitly preparing a phone-test APK.
- APK packaging, unless explicitly approved.

## Command Reliability Warning

Previous Codex shell command construction became unreliable during V6B validation.

Observed issues:

- path strings were accidentally concatenated;
- long PowerShell environment blocks became difficult to audit;
- `Start-Process` hit environment/path problems;
- commands were sometimes changed from the exact user-provided form;
- a Flutter SDK wrapper corruption incident previously made `dart.bat` / `flutter.bat` hang.

Use script-based validation instead of manually typing long commands.

Preferred validation entry point:

```
.\tooling\v6b.cmd
```

This is the **only** approved V6B validation command. It calls `check_v6b_readonly.ps1`
which is safe: no formatting writes, no log files, no APK build.

Do **not** run `tooling\validate_v6b.ps1` — it formats files and builds APK.

Do **not** run experimental or legacy wrappers such as `tooling\v6b_app.cmd`,
`tooling\v6b_app.ps1`, `tooling\run_v6b_validation.cmd`, or
`tooling\run_validate_v6b_guarded.ps1`.

If the shell stalls, stop and report. Do not repeat the command.

## How New Codex Should Resume

1. Read this file.
2. Read `docs/ai_handoff/current_project_state.md`.
3. Read `docs/ai_handoff/v6a_completion_summary.md`.
4. Read `docs/ai_handoff/v6b_current_status.md`.
5. Read `docs/ai_handoff/validation_protocol.md`.
6. Read `docs/benchmark_feature_completion_roadmap_v6.md`.
7. Read `docs/plan_due_priority_tags_search_v6b_plan.md`.
8. Read `docs/feature_completion_checklist.md`.
9. Read the four benchmark app reference folders and report.
10. Report current state before changing code.
11. Confirm the next feature-package scope with the user before editing.
