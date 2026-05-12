# V6B Plan Due Dates / Priority / Tags / Search Report

Status: completed and validated.

Current version: `1.1.2+14`

No version bump was made.
No phone-test APK was prepared.
No `flutter build apk` was run.

## Scope

V6B is limited to Plan project/action planning metadata and Plan discovery.

Implemented metadata is limited to:

- `ProjectItem.dueDate`
- `ProjectItem.priority`
- `ProjectItem.tags`
- `GoalTaskItem.dueDate`
- `GoalTaskItem.priority`
- `GoalTaskItem.tags`

No Goal metadata was added.
No Subproject metadata was added.
No PlanRecord schema or semantics were changed.
No progress or task completion semantics were changed.

## Files Changed For V6B

V6B implementation and hardening files:

- `lib/features/goals/domain/models/goal_item.dart`
- `lib/features/goals/application/goals_store.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- `test/goals_persistence_test.dart`
- `test/goals_flow_test.dart`
- `docs/plan_due_priority_tags_search_v6b_plan.md`
- `docs/plan_due_priority_tags_search_v6b_report.md`

Final documentation closeout is limited to docs. Do not modify `lib/`, `test/`, or `pubspec.yaml` during closeout.

## Project Metadata Schema

`ProjectItem` supports:

- `dueDate: String?`
- `priority: PlanPriority?`
- `tags: List<String>`

`dueDate` is a local date string in `YYYY-MM-DD`.

`priority` uses `PlanPriority.low`, `medium`, `high`, or `urgent`.

`tags` are free-text strings.

## Task Metadata Schema

`GoalTaskItem` supports:

- `dueDate: String?`
- `priority: PlanPriority?`
- `tags: List<String>`

The same due date, priority, and tag rules apply to tasks/actions.

## Storage And Migration

No new storage key was added.

The existing goals snapshot JSON stores the new optional fields on projects and tasks.

Old projects and tasks load with:

- `dueDate = null`
- `priority = null`
- `tags = []`

Malformed metadata is sanitized:

- malformed or non-calendar due dates load as `null`
- malformed priority loads as `null`
- malformed tags are skipped
- empty tags are removed
- duplicate tags are removed
- tags are capped to 16 characters each
- tags are capped to 8 per object

Due date validation rejects invalid calendar values such as `2026-13-40`, `2026-02-30`, and `2026-11-31`.

## Project Edit Behavior

Project edit includes planning metadata:

- due date picker
- clear due date action
- priority chips
- tag input and removable chips

Updating project planning metadata does not change project progress, child tasks, records, or source metadata.

## Task Edit Behavior

Task edit includes planning metadata:

- due date picker
- clear due date action
- priority chips
- tag input and removable chips

Updating task planning metadata does not toggle completion and does not alter Plan records.

## Search / Filter / Sort Behavior

The Plan page includes a read-only search/filter/sort surface.

Search covers:

- project title
- project description
- project tags
- task title
- task tags
- contextual path text

Filters include:

- all
- due today
- overdue
- high priority
- incomplete
- completed
- tag

Sort modes include:

- default hierarchy order
- due date
- priority

When search, filter, or non-default sort is active, results are shown as a flat contextual list. The canonical Plan hierarchy remains unchanged.

Due-date and priority sorting keep a stable hierarchy-order fallback when sort keys tie.

## Due Date Semantics

Due dates are local calendar dates stored as `YYYY-MM-DD`.

Task due today:

- `task.dueDate == today`
- task is not completed

Task overdue:

- `task.dueDate < today`
- task is not completed

Project due today:

- `project.dueDate == today`
- project task-derived progress is not complete

Project overdue:

- `project.dueDate < today`
- project task-derived progress is not complete

Completed tasks and completed projects are not counted as active overdue.

## Priority Semantics

Priority is optional.

Null priority means normal/no explicit priority.

High-priority filter includes:

- `high`
- `urgent`

Priority does not affect completion, progress, records, or review metrics.

## Tag Semantics

Tags are local object metadata on projects and tasks.

There is no global tag registry in V6B.

Tags are used for display, search, and filtering only.

Tags do not affect completion, progress, records, or generated habit-linked records.

## Today / Review Behavior

Today was not expanded as part of V6B final hardening.

Review remains unchanged.

No overdue, priority, or tag analytics were added to Review.

## Habit To Plan And Focus Safety

Habit -> Plan behavior remains unchanged:

- generated PlanRecords remain evidence/history
- generated PlanRecords do not complete Plan tasks
- duplicate prevention is unchanged
- generated records do not mutate due dates, priority, or tags

Focus binding behavior remains unchanged:

- focus target binding does not mutate Plan tasks
- focus completion does not auto-complete Plan tasks

## Validation

Final V6B validation was run manually by the user through the only approved read-only entry:

```powershell
.\tooling\v6b.cmd
```

Result:

- V6B read-only validation completed.
- Format checks passed.
- Focused persistence tests passed: `test/goals_persistence_test.dart` completed with 24 tests passed.
- Focused flow tests passed: `test/goals_flow_test.dart` completed with 6 tests passed.
- Targeted analyze passed: no issues found.
- Full analyze passed: no issues found.
- Full tests passed: 169 tests passed.

No APK step was run.
No `flutter build apk` was run.
No phone-test APK was prepared.
No version bump was made.

## Validation Rules

The only allowed V6B validation entry remains:

```powershell
.\tooling\v6b.cmd
```

Do not run `tooling\validate_v6b.ps1` directly. It is deprecated/forbidden for the current workflow because it may format files, write logs, and build an APK.

Do not run direct or experimental wrappers:

- `tooling\check_v6b_readonly.ps1`
- `tooling\v6b_app.cmd`
- `tooling\v6b_app.ps1`
- `tooling\run_v6b_validation.cmd`
- `tooling\run_validate_v6b_guarded.ps1`

## Cleanup Note

The `.claude` worktree and experimental/old validation wrappers were moved out of the main project directory.

Backup location:

```text
D:\AI\Backups\four_in_one_app_cleanup_20260511_155835
```

## Explicit Non-Changes

No version bump.

No phone-test APK prepared.

No `flutter build apk`.

No dependencies added.

No routing changes.

No native Android/iOS config changes.

No Habits, Focus, Review, or Theme Studio behavior changes.

No PlanRecord note/numeric/image/source behavior changes.

No Habit -> Plan semantic changes.

No cache or build directories were deleted.

## Next Step

V6B is sealed. Before starting the next feature package, confirm the package scope explicitly with the user.

Do not automatically bump version.
Do not prepare APK.
Do not run `flutter build apk`.
