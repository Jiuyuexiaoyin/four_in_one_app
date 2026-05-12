# V6B Current Status

Package: `V6B Plan Due Dates / Priority / Tags / Search`

Status: completed and validated.

Current version: `1.1.2+14`

Do not bump version.
Do not prepare APK.
Do not run `flutter build apk`.

## Completion Summary

V6B is sealed. It adds DayMark-like planning metadata and read-only discovery to Plan while keeping the existing hierarchy and business semantics unchanged.

Implemented scope:

- `ProjectItem.dueDate`
- `ProjectItem.priority`
- `ProjectItem.tags`
- `GoalTaskItem.dueDate`
- `GoalTaskItem.priority`
- `GoalTaskItem.tags`
- Plan page search/filter/sort surface
- flat contextual results when search/filter/sort is active
- default hierarchy view unchanged

Explicitly not changed:

- no Goal metadata
- no Subproject metadata
- no tag center
- no saved searches
- no recursive date inheritance
- no Review expansion
- no PlanRecord schema change
- no Plan progress semantics change
- no task completion semantics change
- no Habit, Focus, Review, or Theme Studio behavior change

## Validation

Validation was run manually by the user through the only approved V6B entry:

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

## Validation Rules Going Forward

The only allowed V6B validation entry remains:

```powershell
.\tooling\v6b.cmd
```

Do not run these directly:

- `tooling\validate_v6b.ps1`
- `tooling\check_v6b_readonly.ps1`
- `tooling\v6b_app.cmd`
- `tooling\v6b_app.ps1`
- `tooling\run_v6b_validation.cmd`
- `tooling\run_validate_v6b_guarded.ps1`

`validate_v6b.ps1` is forbidden for the current workflow because it may format files, write logs, and build an APK.

## Cleanup Note

The `.claude` worktree and experimental/old validation wrappers were moved out of the main project directory.

Backup location:

```text
D:\AI\Backups\four_in_one_app_cleanup_20260511_155835
```

## Final V6B Files

V6B implementation and test coverage are in:

- `lib/features/goals/domain/models/goal_item.dart`
- `lib/features/goals/application/goals_store.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- `test/goals_persistence_test.dart`
- `test/goals_flow_test.dart`

Do not modify `lib/`, `test/`, or `pubspec.yaml` during final documentation closeout.

## Next Step

V6B is complete. Before starting the next feature package, confirm the new package scope explicitly with the user.

Do not automatically bump version.
Do not prepare APK.
Do not run `flutter build apk`.
