# P8 Plan UX Simplify Audit

## Sources Read

- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/goals/application/goals_store.dart`
- `lib/features/goals/domain/models/goal_item.dart`
- `lib/shared/widgets/product/plan_goal_card.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- `reports/p8_plan_pixel_fix_report.md`

## 1. Current Visible Hierarchy

- The Plan tab renders one long `ListView` with:
  - Stitch-style command dashboard.
  - Core intent card.
  - Four strategic pillar cards.
  - Milestone log.
  - `执行路径 // EXECUTION PATH` section.
  - Search/filter/sort surface.
  - Execution overview metrics.
  - Add goal surface.
  - Goal list header.
  - Every goal card, each with every project, subproject, action, and records panel expanded inline.
- The page exposes the full internal model on the main page: `Goal -> Project -> Subproject -> GoalTaskItem -> PlanRecord`.

## 2. Current Buttons And Actions

- Top command bar:
  - Add goal.
  - Settings.
- Core intent:
  - Add goal.
- Add goal section:
  - Add goal.
- Goal card:
  - Edit goal.
  - Add project.
  - Open goal tree sheet.
- Project rows:
  - Edit project.
  - Open project detail/stats.
  - Add project record.
  - Add subproject.
  - Add task.
- Subproject rows:
  - Edit subproject.
  - Add task.
- Task rows:
  - Toggle completion.
  - Edit task.
  - Add task record.
- Search result rows:
  - Open project detail.
  - Edit project or edit task.
- Project record panels:
  - Open stats.
  - Attach/manage images for records.

## 3. Confusing Labels

- `执行路径 // EXECUTION PATH` is still mixed-language and sounds like an internal architecture section.
- `战略支柱`, `里程记录`, `P1/P2/P3/P4`, `强度`, `负载`, and `恢复` make the feature feel more like a diagnostic dashboard than a simple planning tool.
- Main cards mix goal/project/subproject/action vocabulary at the same depth.
- Some user-facing actions are implementation-oriented: `添加项目`, `添加子项目`, and `目标树结构` appear before the user has a clear next action.

## 4. Empty States

- The empty page currently says `还没有长期目标` and separately shows empty strategic pillar placeholders.
- The user goal asks for a simpler empty state: `还没有计划，先建立一个目标。` with one button `新建计划`.

## 5. Redundant Actions

- Add goal appears in multiple visible locations.
- Edit actions appear at goal, project, subproject, and task levels on the main surface.
- Project detail/stats is exposed both from project rows and record panels.
- Add record is shown inline inside every expanded project/task area.

## 6. Where The Page Exposes Too Much Internal Structure

- Every goal card expands all projects and subprojects by default.
- Every project shows direct tasks, subproject tasks, record panels, and multiple structural buttons inline.
- The main page asks users to understand the data hierarchy before answering the primary product questions:
  - What plan am I working on?
  - What is the next action?
  - What did I complete?
  - How do I add or edit a plan?

## 7. Real GoalsStore Features To Preserve

- Goals:
  - create goal
  - edit goal identity: title, icon, description, color
  - compute goal progress
  - migrated legacy goals
- Projects:
  - create project
  - edit project identity
  - planning metadata: due date, priority, tags
  - project detail/stats
- Subprojects:
  - create subproject
  - edit subproject title
  - subproject progress
- Tasks/actions:
  - create direct project task
  - create subproject task
  - edit task title/planning metadata
  - toggle completion
- Records:
  - create project note/numeric record
  - create task note/numeric record
  - record detail/statistics/history
  - image attachments for plan records
  - habit-linked records
- Search/filter/sort:
  - can be preserved as an advanced/search utility, but should not dominate the first screen.
