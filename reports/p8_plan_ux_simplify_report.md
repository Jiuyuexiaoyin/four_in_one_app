# P8 Plan UX Simplify Report

## 1. Old Plan UX problems
- The main Plan page exposed the full goal/project/subproject/task/record hierarchy at once.
- Goal cards mixed overview, edit, add project, project actions, subproject actions, task actions, records, and statistics in one surface.
- The old flow made every internal layer visible before the user knew the next step.
- Create/edit labels were goal-centric while the product tab is now Plan/计划, making the page harder to understand.
- Search and advanced hierarchy controls were visible too early for the primary workflow.

## 2. New Plan UX structure
- Main page now shows four simplified sections:
  1. Plan overview: real plan/action/completion/record counts and progress.
  2. Current focus plan: one selected plan, its description, progress, next action, and one primary next step.
  3. Next actions: unfinished actions flattened into a scannable list.
  4. All plans: compact plan cards that open detail.
- Plan detail opens in a bottom sheet and contains actions, records, and an advanced breakdown.
- Goal/project/subproject tree remains available, but it is collapsed behind `高级拆解`.
- Search/filter remains reachable through a collapsed `查找计划内容` section.

## 3. Files changed
Current phase changes:
- `lib/features/goals/presentation/pages/goals_page.dart`
- `test/goals_flow_test.dart`
- `test/goals_attachment_widget_test.dart`
- `test/app_smoke_test.dart`
- `reports/p8_plan_ux_simplify_audit.md`
- `reports/p8_plan_ux_simplify_plan.md`
- `reports/p8_plan_ux_simplify_report.md`

Scope note: the worktree already contained earlier uncommitted edits outside this phase. The required `git diff --name-only` still lists Today/Habits/Focus/Settings/Review/AppShell-related files from earlier work; those files were not edited for this Plan UX simplify phase.

## 4. Functions preserved
- Create plan through `GoalsStore.createGoal`.
- Edit plan identity through `GoalsStore.updateGoalIdentity`.
- Create project and subproject through existing dialog/store paths.
- Create direct and subproject actions through existing task dialogs/store paths.
- Toggle action completion through `GoalsStore.toggleTask`.
- Create project/task records through existing record dialogs/store paths.
- Record detail, statistics, source filters, and attachments remain reachable from plan detail/project detail.

## 5. Real GoalsStore bindings preserved
- The page still receives and reads the real `GoalsStore`.
- Overview counts use `goalsStore.goals`, `goalsStore.tasks`, and `goalsStore.records`.
- Progress uses existing `goalsStore.computeGoalProgress`, `computeProjectProgress`, and related task counts.
- Next actions are derived from real unfinished `GoalTaskItem` records.
- Plan detail pulls live goal/project/task/record state from `GoalsStore`.

## 6. Create/edit/action/record flows preserved
- `新建计划` opens a clean plan identity dialog with basic fields first.
- `添加行动` uses the current plan; if no project exists it creates the first project instead of exposing all hierarchy controls.
- `编辑` has one visible entry per current/compact plan surface.
- Plan cards open detail; detail shows actions, records, and the collapsed advanced breakdown.
- Advanced breakdown keeps project/subproject/task creation and edit controls reachable.

## 7. Final format result
- Command: `D:\ai\flutter\bin\dart.bat format .`
- Result: exit code 0.
- Note: formatter reported a Windows mapped-file overwrite warning for `lib\features\habits\presentation\pages\habits_page.dart`. Habits was outside this phase and was not manually changed.

## 8. Final analyze result
- Command: `D:\ai\flutter\bin\flutter.bat analyze`
- Result: pass, `No issues found!`

## 9. Final test result
- Command: `D:\ai\flutter\bin\flutter.bat test`
- Result: pass, `All tests passed!`

## 10. Chrome run result
- Command: `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321 --no-resident`
- Result: exit code 0.
- Output included: `Launching lib\main.dart on Chrome in debug mode...` and `Application finished.`

## 11. Manual screenshot instructions
1. Start the app on Chrome with `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321 --no-resident`.
2. Open the Plan tab.
3. Capture the default Plan page, the plan detail sheet, and the expanded `高级拆解` section.
4. Confirm the main page answers: current plan, next action, completed actions, and where to add/edit a plan.

## 12. Remaining risks
- The current git worktree is not clean because earlier phase edits remain uncommitted across multiple pages.
- `dart format .` still encounters a Windows mapped-file warning on the pre-existing Habits page file.
- Manual visual review is still required for exact premium feel and mobile spacing.

## Final verdict
PLAN_UX_SIMPLIFIED_READY_FOR_REVIEW
