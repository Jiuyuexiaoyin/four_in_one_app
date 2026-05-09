# Habit Structured Check-in Templates + Numeric Units V6A Plan

> Package marker: `V6A Habit Structured Check-in Templates + Numeric Units`  
> Scope: implementation plan only  
> Current baseline: `1.1.2+14` after Theme Studio real visual color picker repair  
> Hard constraints: no app code changes in this planning step, no dependency changes, no routing changes, no version bump, no APK

This plan defines a controlled implementation path for structured habit check-in templates and numeric units. The goal is to let a habit record real measurable details such as `深蹲 30 个`, `阅读 30 分钟`, or `跑步 3 公里`, while keeping the existing one-tap habit flow fast and preserving all repaired record/count semantics.

## Evidence Inspected

Product and roadmap docs:

- `AGENTS.md`
- `docs/product_vision.md`
- `docs/ui_direction.md`
- `docs/source_ui_reference.md`
- `docs/benchmark_visual_gap_audit_v2.md`
- `docs/benchmark_feature_completion_roadmap_v6.md`
- `docs/ui_reference_components.md`
- `docs/feature_completion_checklist.md`
- `docs/references/app_report_v2.txt`

Reference app folders:

- `docs/references/app_content/HabitDone`
- `docs/references/app_content/daymark`
- `docs/references/app_content/OffScreen`

Current implementation inspected:

- `lib/features/habits/domain/models/habit_item.dart`
- `lib/features/habits/domain/models/habit_record.dart`
- `lib/features/habits/domain/models/habit_record_attachment.dart`
- `lib/features/habits/domain/models/habit_statistics_summary.dart`
- `lib/features/habits/application/habits_store.dart`
- `lib/features/habits/data/habits_local_storage.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/domain/models/goal_item.dart`
- `lib/features/goals/application/goals_store.dart`
- current habit-related tests under `test/`

## 1. Current Habits Record Baseline

Habits is already a mature HabitDone-inspired tracker. The current baseline includes:

- Quick one-tap check-in through `HabitsStore.checkIn`.
- Detailed record sheet with draft/save semantics; opening the sheet does not create a record.
- Record types: `checkIn`, `makeup`, `skip`.
- Optional note on `HabitRecord`.
- Makeup records use the selected `localDate`, not `createdAt`.
- Skip records do not count as completion and are blocked for dates that already have effective check-in/makeup.
- Multi-image proof through `HabitRecordAttachment`, up to 3 images per `HabitRecord`.
- Gallery selection, camera capture, preview, replace, remove, and missing-file safe states.
- 7-day activity, current-month heatmap, recent 3-month activity, annual heatmap.
- Current streak and longest streak derived from real effective records.
- Pause-aware streak protection through `HabitPauseInterval`; paused days are neutral and do not add streak length.
- Habit lifecycle: active, paused, archived, soft-deleted.
- Advanced reminders: up to 3 reminder rules per habit, weekdays, enable/disable, lifecycle cancel/reschedule.
- Per-habit color identity and global Theme Studio compatibility.
- Habit -> Plan linking: reaching daily target creates one sourced PlanRecord, without auto-completing Plan tasks.

Current semantic anchors:

- Effective completion = `checkIn + makeup`.
- `skip`, `note`, and `proof` do not count as completion.
- Heatmap intensity = `checkIn + makeup` only.
- Streak = completed localDate days where effective count >= `targetCountPerDay`.
- Today uses active habits only.
- Plan progress remains task-derived only.

## 2. Benchmark Gap

HabitDone-like habit tracking is now deep in record semantics, proof, reminders, lifecycle, streaks, and visual analytics. The remaining gap is structured measurable habit detail.

What benchmark direction suggests:

- Some habits are not only "done"; they have measurable sub-items.
- Fitness examples need multiple fields: `深蹲 30 个`, `俯卧撑 20 个`, `跑步 3 公里`.
- Reading/study examples need units: `阅读 30 分钟`, `笔记 1 篇`.
- Users should be able to reuse these sub-items instead of typing them every time.
- Statistics should summarize real numeric values over time.

What our app has:

- Free-form notes.
- Numeric PlanRecord for Plan, with `numericValue + unit`.
- Habit records do not have numeric values or reusable templates.

What is missing:

- Structured measurable sub-records.
- Per-habit reusable check-in templates.
- Habit numeric values and units.
- Grouped habit record table with metric values.
- Per-template totals and recent metric summaries.

Priority:

- `P1-high`, because this is the clearest remaining HabitDone-level functional gap after color, proof, reminders, lifecycle, and analytics.

## 3. Data Model Proposal

### Recommended Model Shape

Use two new persisted models separate from `HabitItem` and `HabitRecord`:

```dart
class HabitCheckInTemplate {
  final String id;
  final String habitId;
  final String title;
  final String unit;
  final double? defaultValue;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

class HabitRecordMetric {
  final String id;
  final String recordId;
  final String habitId;
  final String? templateId;
  final String titleSnapshot;
  final String unitSnapshot;
  final double numericValue;
  final DateTime createdAt;
}
```

Recommended storage integration:

- Add `templates` and `metrics` lists to `HabitsSnapshot`.
- Add two storage keys following the current storage pattern:
  - `habits.checkin.templates.local.json`
  - `habits.record.metrics.local.json`
- Keep `HabitItem` schema unchanged in V6A if possible.
- Keep `HabitRecord` schema unchanged in V6A if possible.

Why separate storage is preferred:

- It preserves old `HabitRecord` compatibility.
- It avoids turning `HabitItem` into a large nested template blob.
- It lets metrics be skipped safely when malformed.
- It lets attachments and records remain independent.
- It keeps completion logic centered on `HabitRecord.type`, not numeric values.
- It mirrors the existing storage pattern: habits, records, attachments already live in separate persisted lists.

### HabitCheckInTemplate Rules

Fields:

- `id`: generated stable id, for example `habit-template-1`.
- `habitId`: owning habit id.
- `title`: normalized non-empty label, for example `深蹲`, `阅读`, `跑步`.
- `unit`: normalized non-empty unit, for example `个`, `分钟`, `公里`, `页`.
- `defaultValue`: optional finite value, used only as a helper in the detailed record UI.
- `sortOrder`: integer for user-defined order.
- `isArchived`: soft archive; archived templates are hidden from new detailed check-ins but remain available for history.
- `createdAt`: UTC timestamp.
- `updatedAt`: UTC timestamp after edit/archive.

Recommended bounds:

- Maximum 6 active templates per habit in V6A.
- Title length: normalize and cap in UI; store non-empty text.
- Unit length: normalize and cap in UI; store non-empty text.
- `defaultValue`: optional, finite, non-negative. Do not auto-create metric records from it without user save.

Template archive/delete behavior:

- Implement archive, not hard delete, in V6A.
- Archived templates do not appear as active input rows.
- Historical `HabitRecordMetric` rows remain readable through snapshots.
- A later data-management package can define hard deletion if needed.

### HabitRecordMetric Rules

Fields:

- `id`: generated stable id, for example `habit-metric-1`.
- `recordId`: the saved `HabitRecord` id.
- `habitId`: denormalized for efficient filtering and safety.
- `templateId`: optional; can be null for malformed/missing legacy-like cases or future one-off metric support.
- `titleSnapshot`: the template title at the time of saving.
- `unitSnapshot`: the template unit at the time of saving.
- `numericValue`: finite numeric value.
- `createdAt`: UTC timestamp.

Snapshot fields are required because:

- Template titles and units may be edited later.
- Archived templates should not make old records unreadable.
- Missing templates should not break record history.

Recommended numeric policy:

- Save only finite values.
- Reject `NaN`, infinity, and empty input.
- Prefer positive values for V6A saved metrics. If users need explicit `0`, this should be considered later with clearer semantics.
- Do not mix units in statistics; group by exact `titleSnapshot + unitSnapshot` or by template id with snapshot fallback.

### Questions Answered

Should templates live inside `HabitItem` or separate storage?

- Recommendation: separate storage. This keeps `HabitItem` focused on identity, lifecycle, reminders, color, and Plan link.

Should metric values be embedded in `HabitRecord` or separate storage?

- Recommendation: separate storage. This keeps old records compatible and prevents accidental count/heatmap/streak coupling.

How to preserve old HabitRecord compatibility?

- Do not change `HabitRecord` in V6A. Old records simply have no associated metrics.

How to handle renamed templates while keeping old records readable?

- Store `titleSnapshot` and `unitSnapshot` on each `HabitRecordMetric`.

How to handle deleted/archived templates?

- Archive templates in V6A. Historical metric rows stay readable. Hard delete is postponed.

How to avoid breaking note/skip/makeup/proof semantics?

- Metrics are optional child evidence rows attached only to saved `checkIn` or `makeup` records. Skip cannot save positive metric values. Proof remains attachment metadata.

## 4. UI Plan

### A. Habit Create/Edit

Add a compact section named:

- `打卡项目`
- Secondary copy: `用于详细打卡，例如 深蹲/个、阅读/分钟。`

User can:

- Add a template with title and unit.
- Optionally set a default value.
- Edit template title/unit/default value.
- Archive template.
- Reorder templates if simple; otherwise use sort order by creation and postpone manual reorder.

Recommended first UI:

- A quiet list of existing active templates.
- `添加项目` text button.
- Template edit bottom sheet with fields:
  - `项目名称`
  - `单位`
  - `默认值（可选）`
- Archived templates hidden by default with optional small `已停用项目` section only if implementation remains simple.

Keep create/edit lightweight:

- Do not force every habit to configure templates.
- Empty template state should say: `不需要精细记录时，可以保持为空。`
- Quick check-in remains primary and unchanged.

### B. Detailed Check-in Sheet

Add metric input rows only when the habit has active templates.

Detailed sheet should still show:

- selected localDate
- record type (`打卡` or `补打`; `跳过` remains separate/non-completion)
- existing records for selected date
- note input
- proof image section
- save/cancel

Metric section:

- Heading: `记录项目`
- Row examples:
  - `深蹲` [number field] `个`
  - `阅读` [number field] `分钟`
- Empty values are ignored.
- Invalid values show friendly inline copy and block save or skip that metric, with a clear chosen implementation rule.

Recommended save behavior:

- If the user saves detailed `checkIn` or `makeup`, create the `HabitRecord`.
- Save metric rows with valid positive numeric values as `HabitRecordMetric`.
- If no metric values are entered, save the record normally.
- If the selected type is skip, hide metric inputs or disable them with copy: `跳过不会记录项目数值。`

Default value behavior:

- Default value can prefill the field in detailed check-in if the UI clearly shows it.
- To reduce accidental metrics, an alternative is to show default value as a quick-fill chip. The safer V6A recommendation is quick-fill chip first.

### C. Habit Card

Do not clutter the habit card in V6A.

Recommended behavior:

- Keep `打卡` as the strongest action.
- Keep `记录 / 统计 / 月视图 / 更多` secondary.
- Do not show all metric templates on the card.
- Optional if very lightweight: show a single quiet line after today's effective count, such as `今日记录 2 项`, derived from today's metrics.

If card density increases or small-screen layout becomes crowded:

- Do not add metric summary to the card in V6A.
- Put metric visibility in detailed sheet and statistics sheet only.

### D. Habit Statistics

Add basic metric summary to the existing per-habit statistics sheet.

Recommended sections:

- `项目汇总`
  - total per template/unit
  - example: `深蹲 180 个`, `跑步 9 公里`
- `最近项目记录`
  - newest metric rows grouped by date
  - include record type context: `打卡` / `补打`
- Optional tiny bar rows using existing `AnalyticsBarList` style if no chart dependency is needed.

Do not add:

- fake trends
- streaks based on metric values
- unit-mixed totals
- heavy dashboard route
- chart package

## 5. Counting Semantics

These rules are non-negotiable for V6A:

- Quick check-in still creates a normal `checkIn` record.
- Detailed check-in with metrics creates one `checkIn` or `makeup` record plus optional `HabitRecordMetric` rows.
- Metric values do not create completion by themselves.
- Metric values do not change today's effective count.
- Metric values do not change heatmap intensity.
- Metric values do not change streak.
- Metric values do not change skip semantics.
- Metric values do not change proof semantics.
- `skip` records cannot contain completion metrics in V6A.
- `proof`, `note`, and `metric` remain metadata/evidence unless paired with a real `checkIn` or `makeup` record.
- Makeup metrics count on the selected `localDate` because the parent makeup record uses selected `localDate`.
- Future dates remain non-recordable under existing date rules.

Important distinction:

- `targetCountPerDay` still means how many effective check-in/makeup records are needed for a completed day.
- Numeric templates mean what the user did inside a detailed record.
- V6A should not introduce numeric target completion semantics such as "30 minutes means complete" unless separately approved later.

## 6. Relationship With Plan

V6A should not change the Habit -> Plan linking contract unless a tiny, clearly safe addition is approved during implementation.

Current contract:

- A linked habit creates one generated PlanRecord when the habit reaches daily target.
- Duplicate prevention uses `sourceKey`.
- The generated record is evidence/history.
- It does not auto-complete Plan tasks.
- It does not affect Plan progress.

Recommended V6A behavior:

- Keep generated PlanRecord behavior unchanged in the first implementation.
- Do not create Plan numeric records automatically from habit metrics.
- Do not copy habit metric values into Plan numeric totals.
- Do not alter Plan task progress.

Optional later enhancement:

- A future V6A2/V6B package can add a short metric summary to the generated PlanRecord note, such as:
  - `来自习惯：阅读 · 2026-04-30 已达标 · 阅读 30 分钟，笔记 1 篇`
- This should be postponed unless implementation can do it without changing duplicate behavior, Plan numeric semantics, or generated record traceability.

Why not auto-create Plan numeric records in V6A:

- It would mix Habit metric analytics with Plan numeric logs too early.
- It could make Project statistics appear inflated or confusing.
- It risks changing Plan behavior, which is explicitly out of scope for this planning package.

## 7. Statistics Rules

V6A should add real, conservative metric statistics only.

Recommended derived summaries:

- Per-template total:
  - group by active template id when available
  - display snapshot title/unit for historical rows
  - if template is missing, use `titleSnapshot + unitSnapshot`
- Per-unit total:
  - only where title/unit grouping is clear
  - never mix units
- Recent metric values:
  - grouped by parent record `localDate`
  - newest first
  - show parent record type (`打卡` / `补打`)
- Metric record count:
  - number of metric rows
  - number of parent records with at least one metric

Avoid in V6A:

- Fake averages.
- Trend arrows.
- Percent improvements.
- Numeric streaks.
- "Missed amount" calculations.
- Unit conversion.
- Cross-habit metric aggregation.

Allowed if clearly labeled:

- `平均每次` can be considered only if it is a direct total divided by metric-entry count, but recommendation is to postpone averages to V6B to avoid overexplaining.

Empty states:

- If no templates: `这个习惯还没有设置记录项目。`
- If templates exist but no metrics: `详细打卡后，这里会显示项目数值。`

## 8. Migration / Compatibility

Required migration behavior:

- Old habits load with no templates.
- Old records load with no metrics.
- Old attachments remain unaffected.
- Old reminder rules remain unaffected.
- Old lifecycle/pause data remains unaffected.
- Old Habit -> Plan links remain unaffected.

Storage load rules:

- Missing template storage key => empty templates.
- Missing metric storage key => empty metrics.
- Malformed template list => skip malformed entries and set `shouldPersistAfterLoad`.
- Malformed metric list => skip malformed entries and set `shouldPersistAfterLoad`.
- Template with missing habitId or missing owning habit => skip safely.
- Metric with missing recordId/habitId/title/unit/value => skip safely.
- Metric with missing parent record => ignore in UI/stats.
- Metric with missing template but valid snapshots => display through snapshots.

Persistence rules:

- Do not store metric bytes, image bytes, or base64.
- Store only template and metric JSON metadata.
- Keep UTC timestamps in JSON.
- Keep localDate semantics on parent `HabitRecord`.

Safe rewrite:

- If malformed templates/metrics are skipped at load, the next save can rewrite clean lists if the existing storage pattern supports it.

## 9. Tests

Required model/storage tests:

- Old habits load without templates.
- Old records load without metrics.
- Missing templates storage key loads as empty.
- Missing metrics storage key loads as empty.
- Malformed templates are skipped safely.
- Malformed metrics are skipped safely.
- Metrics for missing records are ignored in stats/UI.
- Missing template still displays `titleSnapshot` and `unitSnapshot`.

Required template tests:

- Create habit with templates.
- Add template title/unit/default value.
- Edit template title/unit.
- Archive template.
- Archived template is hidden from new detailed check-in inputs.
- Archived template historical metrics remain visible.
- Max active templates per habit is enforced.

Required record tests:

- Detailed check-in saves metric values.
- Makeup saves metric values on selected `localDate`.
- Quick check-in remains unchanged and creates no metrics.
- Detailed check-in with no metric values still saves normal record.
- Skip does not save completion metrics.
- Invalid metric value is rejected or ignored according to implementation rule.
- Renamed template preserves old record snapshot.

Required semantics tests:

- Metric values do not affect today count.
- Metric values do not affect heatmap intensity.
- Metric values do not affect current/longest streak.
- Metric values do not affect proof counts.
- Metric values do not affect skip semantics.
- Makeup metric appears on selected localDate through parent record.

Required statistics tests:

- Habit stats group totals by template/unit.
- Unit totals never mix units.
- Recent metric table groups by date.
- Old records without metrics remain safe.
- Metrics from other habits do not leak.

Required cross-feature tests:

- Habit -> Plan linking remains safe.
- Reaching target still creates at most one generated PlanRecord.
- Metrics do not create Plan numeric records in V6A.
- Generated PlanRecord does not auto-complete linked task.
- Plan progress remains task-derived.
- Existing Habits / Plan / Focus / Review / Theme tests pass.

Responsive tests:

- Detailed check-in sheet with 4-6 templates renders at 360dp width and text scale 1.15.
- Habit statistics sheet with metric summary renders at 360dp width and text scale 1.15.

## 10. What Must Not Change

V6A must not change:

- bottom navigation
- routing
- Plan task/progress semantics
- Focus timer behavior
- Focus notification behavior
- Review metrics logic
- habit reminder rules
- habit lifecycle semantics
- pause-aware streak semantics
- annual heatmap intensity semantics
- proof image behavior
- Theme Studio behavior
- Habit -> Plan duplicate prevention
- PlanRecord numeric semantics
- dependencies
- native config
- app version
- phone-test packaging

V6A must not:

- make quick check-in slower or heavier
- require templates for every habit
- auto-convert metric totals into completion
- create fake analytics
- mix units
- add chart dependencies
- add a new route
- add Plan numeric records automatically

## 11. Risk Analysis

Schema complexity:

- Adding both templates and metrics creates new persisted structures. Keeping them separate from `HabitItem` and `HabitRecord` reduces migration risk.

Detailed record sheet becoming too heavy:

- A habit with many templates can crowd the sheet. Cap active templates at 6 and use compact numeric rows.

Quick check-in becoming slower:

- Quick check-in must not show metric inputs or require additional taps. Structured values belong only to detailed check-in.

Target count vs metric values confusion:

- Users may think `阅读 30 分钟` should satisfy target automatically. V6A should explain that numeric projects are record details; completion remains count-based.

Unit mixing:

- `分钟`, `小时`, `页`, and `篇` cannot be summed together. Group by exact unit and avoid conversion in V6A.

Template rename/delete history:

- Snapshot fields solve rename history. Archive solves deletion safety.

Habit -> Plan source record duplication:

- Do not change sourceKey or generated PlanRecord semantics in V6A. Metrics should not trigger additional Plan records.

Stats becoming noisy:

- Keep V6A stats to totals and recent metric table. Deeper charts belong in V6B.

Malformed data:

- Add strict parser rules and skip bad templates/metrics safely.

Storage growth:

- Metrics are small JSON rows, but frequent detailed records may grow storage. Avoid storing derived stats; calculate on demand.

## 12. Final Recommendation

Recommended route:

```text
A. Implement templates + metrics in one bounded package
```

Reasoning:

- The user need is explicitly about reusable sub-items and numeric values together.
- Templates without metric values would not solve the main problem.
- One-off numeric fields without templates would not feel HabitDone-like or reusable.
- The schema can remain bounded if templates and metrics are stored separately from existing `HabitItem` and `HabitRecord`.
- Quick check-in can remain completely unchanged.

Recommended implementation package name:

```text
V6A Habit Structured Check-in Templates + Numeric Units
```

Recommended V6A implementation boundaries:

- Add `HabitCheckInTemplate`.
- Add `HabitRecordMetric`.
- Add template/metric storage lists to `HabitsSnapshot`.
- Add template management to habit create/edit.
- Add metric input rows to detailed check-in and makeup flows only.
- Add conservative metric totals/recent values to habit stats.
- Keep quick check-in unchanged.
- Keep completion, heatmap, streak, proof, skip, Plan, Focus, Review, Theme Studio semantics unchanged.

Postponed beyond V6A:

- Habit metric charts.
- Habit calendar/table mode with filters.
- Numeric-target completion semantics.
- Unit conversion.
- Cross-habit metric aggregation.
- Auto-generated Plan numeric records.
- Template hard delete.
- Habit groups/categories.

