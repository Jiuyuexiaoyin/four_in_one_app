# V6B Current Status

Package: `V6B Plan Due Dates / Priority / Tags / Search`

Status: in progress.

Current version: `1.1.2+14`

Do not bump version.
Do not prepare APK.

## V6B Goal

Make Plan closer to DayMark by adding real project/action management depth:

- due dates;
- priority;
- tags;
- search;
- filters;
- sorting.

## Approved Scope

Only these schema additions are approved:

- `ProjectItem.dueDate`
- `ProjectItem.priority`
- `ProjectItem.tags`
- `GoalTaskItem.dueDate`
- `GoalTaskItem.priority`
- `GoalTaskItem.tags`

Plan page changes:

- read-only search;
- filters;
- sorting;
- default hierarchy unchanged;
- active filtered/search view can be flat and contextual.

Explicitly not in V6B:

- no Goal metadata;
- no Subproject metadata;
- no tag center;
- no saved searches;
- no recursive date inheritance;
- no Review expansion;
- no PlanRecord schema change.

## Files Currently Appearing Modified For V6B

Observed recently modified V6B files:

- `lib/features/goals/domain/models/goal_item.dart`
- `lib/features/goals/application/goals_store.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- `test/goals_persistence_test.dart`
- `test/goals_flow_test.dart`
- `docs/plan_due_priority_tags_search_v6b_plan.md`

`lib/features/goals/data/goals_local_storage.dart` was checked during formatting but does not appear to contain V6B logic changes.

## Parts Already Implemented

### Data Model

`PlanPriority` enum exists with:

- `low`
- `medium`
- `high`
- `urgent`

`ProjectItem` has:

- `String? dueDate`
- `PlanPriority? priority`
- `List<String> tags`

`GoalTaskItem` has:

- `String? dueDate`
- `PlanPriority? priority`
- `List<String> tags`

Defensive parsing exists:

- malformed dueDate -> null;
- malformed priority -> null;
- malformed tags skipped/sanitized;
- tags trimmed;
- empty tags removed;
- duplicate tags removed;
- tag length capped;
- tag count capped.

### Store APIs

Implemented or appearing implemented:

- `updateProjectPlanningMeta`
- `updateTaskPlanningMeta`
- `isProjectDueToday`
- `isTaskDueToday`
- `isProjectOverdue`
- `isTaskOverdue`

Metadata updates should not alter task completion, records, or progress rollup.

### UI

Implemented or appearing implemented:

- Project edit includes planning metadata.
- Task edit includes planning metadata.
- Plan page includes `_PlanSearchSurface`.
- Search/filter/sort surface has keys such as:
  - `plan-search-field`
  - `plan-filter-today`
  - `plan-filter-overdue`
  - `plan-filter-highPriority`
  - `plan-sort-dueDate`
  - `plan-sort-priority`
- Flat filtered result rows use keys like:
  - `plan-filtered-result-project-<id>`
  - `plan-filtered-result-task-<id>`
- `PlanTreeRow` supports task metadata display.
- Project detail appears to show planning metadata.

### Tests

Implemented or appearing implemented:

- old Plan data metadata defaults;
- malformed dueDate/priority/tags safe;
- project/task metadata persistence;
- completed state unchanged;
- task/project progress unaffected;
- overdue helpers;
- widget tests for visible metadata editing;
- widget tests for search/filter/sort flat contextual results.

## Parts Remaining Unfinished

V6B needs final hardening and validation.

Likely next work:

1. Run focused V6B validation using `tooling/validate_v6b.ps1`.
2. If `goals_flow_test` fails, inspect the failing widget interaction and patch only V6B files.
3. Run targeted analyze.
4. Run full analyze/test/build only after focused checks pass.
5. Update `docs/feature_completion_checklist.md` only after validation passes.

## Known Validation Status

Known from manual local PowerShell:

```powershell
Set-Location 'D:\AI\Projects\four_in_one_app'
& 'D:\AI\Tools\Flutter\flutter\bin\flutter.bat' test --no-pub 'test\goals_persistence_test.dart'
```

Result:

```text
00:01 +24: All tests passed!
```

`goals_flow_test` status is not confirmed from the current Codex session because command execution was interrupted during shell reliability issues.

No full V6B validation result is available yet.

## Known Command / Shell Issues

During V6B validation, previous Codex command construction became unreliable:

- one malformed format command concatenated two file paths;
- long env blocks should not be pasted manually;
- `Start-Process` should not be used;
- direct command calls should be preferred;
- commands should be run one at a time;
- if no output appears for too long, stop and report exact command.

Use `tooling/validate_v6b.ps1` after reinstall/reset.

## Exact Next Steps

1. Read the handoff docs.
2. Report current state to the user before code changes.
3. Run:

```powershell
Set-Location "D:\AI\Projects\four_in_one_app"
.\tooling\validate_v6b.ps1
```

4. If the script fails, fix only the reported V6B issue.
5. Do not bump version.
6. Do not prepare APK.
7. After validation passes, update `docs/feature_completion_checklist.md`.

