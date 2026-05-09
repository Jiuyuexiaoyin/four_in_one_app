# V6A Completion Summary

Package: `V6A Habit Structured Check-in Templates + Numeric Units`

Status: completed and validated.

Version: no bump. `pubspec.yaml` remains `1.1.2+14`.

## Modified Files

Known V6A project files:

- `lib/features/habits/domain/models/habit_check_in_template.dart`
- `lib/features/habits/domain/models/habit_record_metric.dart`
- `lib/features/habits/data/habits_local_storage.dart`
- `lib/features/habits/application/habits_store.dart`
- `lib/features/habits/domain/models/habit_statistics_summary.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `test/habits_persistence_test.dart`
- `test/habits_flow_test.dart`
- `test/habit_statistics_test.dart`
- `test/habit_plan_linking_test.dart` if metric summary / linking expectations were touched.
- `docs/feature_completion_checklist.md` after validation.

## HabitCheckInTemplate Schema

Model: `HabitCheckInTemplate`

Fields:

- `id: String`
- `habitId: String`
- `title: String`
- `unit: String`
- `defaultValue: double?`
- `sortOrder: int`
- `isArchived: bool`
- `createdAt: DateTime`
- `updatedAt: DateTime?`

Behavior:

- Belongs to one habit.
- Active templates appear in detailed check-in.
- Archived templates are hidden from new detailed records.
- Historical metric records remain readable after template rename/archive.
- Malformed templates are skipped safely.
- Old habits load with no templates.

## HabitRecordMetric Schema

Model: `HabitRecordMetric`

Fields:

- `id: String`
- `recordId: String`
- `habitId: String`
- `templateId: String?`
- `titleSnapshot: String`
- `unitSnapshot: String`
- `numericValue: double`
- `createdAt: DateTime`

Behavior:

- Belongs to a `HabitRecord`.
- `titleSnapshot` and `unitSnapshot` preserve history when templates are renamed or archived.
- `templateId` may be null or refer to a missing/archived template.
- Malformed metric values are skipped safely.
- Old records load with no metrics.

## Storage Keys

V6A added separate safe storage keys:

- `habits.checkin.templates.local.json`
- `habits.record.metrics.local.json`

Existing habit storage remains:

- `habits.items.local.json`
- `habits.records.local.json`
- `habits.record.attachments.local.json`

## UI Behavior

- Habit edit has a compact `打卡项目` section.
- Users can add reusable metric templates with title, unit, and optional default value.
- Detailed check-in shows metric input rows from active templates.
- Empty metric fields are ignored.
- Invalid numeric input is safe and does not crash.
- Quick one-tap `打卡` remains unchanged.
- Skip does not save positive completion metrics.
- Makeup metrics use the selected localDate.
- Note behavior is preserved.
- Proof image behavior is preserved.

## Statistics Behavior

- Habit statistics include structured metric summaries.
- `项目合计` groups totals by item title/unit.
- Recent metric records are shown from real records.
- Units are grouped exactly.
- Units are not mixed.
- No fake analytics were added.

## Habit -> Plan Behavior

- Linked habits still create only one generated PlanRecord when the daily target is reached.
- Generated records do not auto-complete Plan tasks.
- Plan progress remains task-derived.
- Metric summary may be included in generated PlanRecord note only if implemented safely by the current code.
- No Plan numeric records are created automatically by habit metrics.

## Semantics Confirmation

Metrics do not affect:

- Today X/Y except through checkIn/makeup records.
- Heatmap intensity except through checkIn/makeup records.
- Streak except through checkIn/makeup records.
- Proof/image behavior.
- Reminder rules.
- Lifecycle behavior.

## Validation Result

After Flutter SDK wrapper repair, V6A validation passed.

Known validation items reached:

- `habits_persistence_test`
- `habits_flow_test`
- `habit_statistics_test`
- targeted habits analyze
- full analyze
- full test
- debug build

No version bump was made.

No phone-test APK was prepared for V6A.

