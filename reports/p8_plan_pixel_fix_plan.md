# P8 Plan Pixel Fix Plan

## Scope

Modify only:

- `lib/features/goals/presentation/pages/goals_page.dart`

Create reports only:

- `reports/p8_plan_stitch_reference_audit.md`
- `reports/p8_plan_pixel_fix_plan.md`
- `reports/p8_plan_pixel_fix_report.md`

No Today, Habits, Focus, Settings, Review, AppShell, Codex config, or starter-kit edits.

## Old Plan Sections To Remove Or Replace

- Replace the generic `_PlanStrategicDashboard` top composition.
- Remove the generic command-header presentation of `STRATEGIC COMMAND`.
- Replace the generic `core intent` panel with the exported label, large headline, and technical body card.
- Replace generic `目标支柱` timeline cards with export-shaped strategic pillar cards.
- Replace the generic `里程碑日志` panel with transparent milestone log rows.
- Keep lower functional surfaces:
  - `_PlanSearchSurface`
  - `_PlanOverviewSurface`
  - `_AddGoalSection`
  - `_GoalsListHeader`
  - `_GoalHierarchyCard` and child hierarchy/action widgets

## New Stitch Plan Sections To Implement

- Plan-specific black grid background behind the page.
- Mobile header row:
  - cyan `STRATEGIC COMMAND`
  - settings icon at right, no AppShell modification required.
- Core Intent:
  - label `核心意图 // CORE INTENT`
  - large `Discipline is the Bridge to Goals.` headline with `Bridge` cyan.
  - dark technical card with the export body copy.
  - two real-data chips: `INTENSITY` and `FOCUS`.
- Strategic Pillars:
  - section label `战略支柱 // STRATEGIC PILLARS`
  - up to four real goal cards mapped to the export card archetypes:
    - P1 linear progress card.
    - P2 circular readiness card.
    - P3 allocation/ratio rows.
    - P4 bar matrix card.
  - If fewer goals exist, show real empty placeholders that invite creating goals, not fake pillars.
- Milestone Log:
  - section label `里程碑日志 // MILESTONE LOG`, `VIEW ALL_`.
  - rows from real plan records first, then real tasks as fallback.
  - status chips derived from actual task/record state.

## Real GoalsStore Bindings

- Focus percent: completed tasks / total tasks.
- Intensity: derived from real goals/actions/overdue state.
- P1 progress: real goal progress for first goal.
- P2 readiness: real goal progress for second goal or global progress when absent.
- P3 allocation rows: real counts and ratios for goals/projects/subprojects/tasks, no fake finance data.
- P4 matrix bars: real task distribution across the first four goals or task completion distribution.
- Milestones: `GoalsStore.records` and `GoalsStore.tasks`.
- Lower hierarchy: existing `GoalsStore` create/edit/toggle/record calls remain untouched.

## Real Actions Preserved

- Create goal remains available from the top Plan header/core section and existing add section.
- Existing project/subproject/task creation remains in the goal hierarchy cards and sheets.
- Existing edit goal/project/task actions remain unchanged.
- Existing task completion and plan record creation remain unchanged.
- Existing project detail/stat sheets remain unchanged.

## What Must Not Be Faked

- Do not use exported `68%`, `80/100`, `42%`, `38%`, `20%`, or 2023 milestone dates unless those values come from the local store.
- Do not create static milestone rows.
- Do not replace the GoalsStore hierarchy with placeholder data.

## Verification

- Run the requested Plan proof commands.
- Run format, analyze, test, and Chrome run.
- If validation fails, fix only `goals_page.dart` unless a strictly necessary support-file change is discovered.
