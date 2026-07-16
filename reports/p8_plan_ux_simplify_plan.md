# P8 Plan UX Simplify Plan

## 1. New Main Plan Page Structure

Use a simpler, product-facing main surface:

1. Plan overview
   - Total plans from `goalsStore.goals.length`.
   - Active actions from unfinished `goalsStore.tasks`.
   - Completed actions from completed `goalsStore.tasks`.
   - Progress percentage from completed/total actions.

2. Current focus plan
   - Pick the first incomplete goal with work, otherwise the newest goal.
   - Show title, description/fallback, progress, next unfinished action, and concise metadata.
   - Primary action:
     - If it has a next action: `继续推进`, opening the plan detail sheet.
     - If it has no action: `添加行动`, creating an action in the first project or creating a project first if none exists.
   - Secondary actions: `编辑`, `详情`.

3. Next actions
   - Show unfinished tasks/actions across all plans.
   - Each row shows action title, parent plan/project context, due/priority metadata, and completion control.
   - Tap/edit entry opens the existing task edit flow.
   - Completion still uses `goalsStore.toggleTask`.

4. All plans
   - Compact cards only.
   - Each card shows title, description/fallback, progress, due/priority when available from child projects/tasks, and action count.
   - Tap opens plan detail.
   - One edit entry per card.

## 2. Secondary Detail Sheet/Page

Create a goal-level detail sheet from the main page:

- Header: plan title, description, progress.
- Actions section:
  - direct and subproject tasks flattened into a readable list.
  - complete/edit/add record remain available.
  - add action remains available.
- Records section:
  - show project record summaries and existing project statistics entry points.
- Advanced breakdown:
  - the full Goal / Project / Subproject tree stays reachable behind a collapsed section.
  - use existing `PlanTreeRow`, `_FocusedProjectBlock`, `_FocusedSubprojectBlock`, `_ProjectRecordsPanel`, and project stats/attachment flows.

## 3. Simplified Edit/Create Interactions

- New plan:
  - one clear `新建计划` button.
  - use the existing identity dialog so title/icon/description/color remain supported.
  - create with `goalsStore.createGoal`, then apply identity fields through `updateGoalIdentity`.
- Add action:
  - if the focus plan has at least one project, create a direct task under the first project.
  - if it has no projects, prompt for a project first via the existing project creation flow.
  - detail sheet also exposes add action per project through the advanced section.
- Edit plan:
  - one visible `编辑` entry on focus/card surfaces.
  - uses existing `updateGoalIdentity`.
- Plan detail:
  - opens from focus plan and compact all-plan cards.
  - records and attachments remain reachable through the existing project detail/statistics flows.

## 4. What Will Be Removed From The Main Page

- Always-expanded project/subproject/action tree inside every goal card.
- Multiple visible create/edit buttons per hierarchy level on the main card.
- Dashboard-like `战略支柱` and milestone-first composition as the main experience.
- Inline project records panel on the main page.

## 5. What Will Be Preserved

- `GoalsStore` model and storage schema.
- Existing create/edit/toggle/record/attachment methods.
- Existing project detail/statistics sheet.
- Existing record dialogs and attachment sheet.
- Search/filter/sort surface as a secondary utility below the simplified main sections or reachable after the main experience.

## 6. Exact Files To Modify

- `lib/features/goals/presentation/pages/goals_page.dart`
- `test/goals_flow_test.dart` if needed for the new detail-first interaction path.
- `test/goals_attachment_widget_test.dart` only if record panels move behind detail and tests must open detail first.

No Store, model, storage, Today, Habits, Focus, Settings, Review, or AppShell changes are planned.
