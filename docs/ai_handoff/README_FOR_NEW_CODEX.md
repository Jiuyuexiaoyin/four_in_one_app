# README FOR NEW CODEX

Project path: `D:\AI\Projects\four_in_one_app`

Current app version: `1.1.2+14`

Current stage: `V6B Plan Due Dates / Priority / Tags / Search` is in progress.

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

## What Is Currently In Progress

V6B adds DayMark-like planning metadata and read-only discovery:

- `ProjectItem.dueDate`
- `ProjectItem.priority`
- `ProjectItem.tags`
- `GoalTaskItem.dueDate`
- `GoalTaskItem.priority`
- `GoalTaskItem.tags`
- Plan page search/filter/sort surface
- Flat filtered results when search/filter/sort is active
- Default hierarchy view unchanged

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

```powershell
Set-Location "D:\AI\Projects\four_in_one_app"
.\tooling\validate_v6b.ps1
```

If running commands manually, run one command at a time and inspect it before execution.

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
11. Continue V6B only.

