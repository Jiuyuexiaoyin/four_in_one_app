# Files To Read After Reset

Read these before changing code:

- `AGENTS.md`
- `docs/ai_handoff/README_FOR_NEW_CODEX.md`
- `docs/ai_handoff/current_project_state.md`
- `docs/ai_handoff/v6a_completion_summary.md`
- `docs/ai_handoff/v6b_current_status.md`
- `docs/ai_handoff/validation_protocol.md`
- `docs/product_vision.md`
- `docs/ui_direction.md`
- `docs/source_ui_reference.md`
- `docs/benchmark_visual_gap_audit_v2.md`
- `docs/benchmark_feature_completion_roadmap_v6.md`
- `docs/habit_structured_checkin_v6a_plan.md`
- `docs/plan_due_priority_tags_search_v6b_plan.md`
- `docs/feature_completion_checklist.md`
- `docs/versioning.md`

## Benchmark References Required

New Codex must read the four benchmark app local screenshot references:

1. HabitDone: `docs/references/app_content/HabitDone`
2. DayMark: `docs/references/app_content/daymark`
3. OffScreen: `docs/references/app_content/OffScreen`
4. 番茄ToDo: `docs/references/app_content/番茄ToDo`
5. Overall report: `docs/references/app_report_v2.txt`

These screenshots are product UI / feature benchmark references and must not be ignored.

For every later UI / feature package, state:

- which reference app traits were inherited;
- what was intentionally not copied;
- how the final app stays unified.

## Current V6B Code Files To Inspect

- `lib/features/goals/domain/models/goal_item.dart`
- `lib/features/goals/application/goals_store.dart`
- `lib/features/goals/data/goals_local_storage.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- `test/goals_persistence_test.dart`
- `test/goals_flow_test.dart`

## Current V6A Code Files To Keep In Mind

- `lib/features/habits/domain/models/habit_check_in_template.dart`
- `lib/features/habits/domain/models/habit_record_metric.dart`
- `lib/features/habits/data/habits_local_storage.dart`
- `lib/features/habits/application/habits_store.dart`
- `lib/features/habits/domain/models/habit_statistics_summary.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`

