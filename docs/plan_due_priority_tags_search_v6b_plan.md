# V6B Plan Due Dates / Priority / Tags / Search Implementation Plan

> Status: planning only. No app code, routing, dependency, native config, version, or APK change in this step.

## 0. References Read

- `AGENTS.md`
- `docs/product_vision.md`
- `docs/ui_direction.md`
- `docs/source_ui_reference.md`
- `docs/benchmark_visual_gap_audit_v2.md`
- `docs/benchmark_feature_completion_roadmap_v6.md`
- `docs/ui_reference_components.md`
- `docs/feature_completion_checklist.md`
- `docs/references/app_report_v2.txt`
- `docs/references/app_content/daymark`
- `docs/references/app_content/OffScreen`
- Current Plan models: `GoalItem`, `ProjectItem`, `SubprojectItem`, `GoalTaskItem`, `PlanRecord`
- Current Plan store/persistence: `GoalsStore`, `GoalsLocalStorage`
- Current Plan UI: project detail sheet, records table, focused goal tree
- Current Today/Review Plan summaries
- Current Habit -> Plan generated record implementation

## 1. Current Plan Baseline

The app already has a strong DayMark-inspired Plan foundation:

- Goal / Project / Subproject / Task hierarchy exists.
- Goal identity is editable: title, icon, color, description.
- Project identity is editable: title, icon, color, description.
- Subproject title is editable.
- Task/action title is editable.
- Task completion drives progress rollup.
- Project progress is derived from project tasks.
- Subproject progress is derived from subproject tasks.
- Goal progress is derived from tasks under all child projects.
- Plan records exist as dated records.
- Plan records support note records.
- Plan records support numeric records with units.
- Plan records support image proof attachments.
- Project detail sheet exists and includes identity, hierarchy counts, progress, activity, numeric totals, record breakdown, and records table.
- Records table supports note, numeric, image, and habit-generated source records.
- Habit -> Plan linking can create generated PlanRecords with source metadata.
- Generated habit-linked records show source chips such as `来自习惯`.
- Generated habit-linked records do not auto-complete tasks.
- Plan records do not affect task progress.
- Today shows Plan summary from goals/projects/subprojects/tasks and today Plan records.
- Review shows real Plan counts and task-derived progress only.

Important current constraints:

- `GoalItem`, `ProjectItem`, `SubprojectItem`, and `GoalTaskItem` do not currently store due dates, priority, or tags.
- `PlanRecord` already has source metadata: `sourceType`, `sourceId`, `sourceLocalDate`, `sourceKey`.
- Current project record filters are limited to record table filters: all / note / numeric / image / habit.
- There is no Plan-level search, filter, or sort across projects/tasks.

## 2. Benchmark Gap

Compared with DayMark, the current Plan module is structurally capable but still missing project/task management depth:

- Due dates: DayMark-like planning needs date pressure such as today, upcoming, and overdue.
- Priority: important projects/actions need a calm but visible way to rise above default hierarchy.
- Tags: projects/actions need lightweight grouping across the tree.
- Search: users need to find projects/actions by title, description, or tag without manually scanning the whole tree.
- Filters: users need quick views such as today, overdue, high priority, unfinished, completed, and tag-based subsets.
- Sorting: users need deadline and priority ordering when they switch from hierarchy browsing to execution planning.
- Overdue/upcoming states: current Plan has task completion, but no date-derived state.
- Today/upcoming Plan view: Today currently shows generic unfinished actions and record counts, not date-aware planning.
- Project/task management polish: metadata should make Plan feel more like owned project objects instead of only a tree editor.

Priority classification:

- P0: safe data model, migration, and progress semantics. Due/priority/tags must not corrupt existing task progress or records.
- P1: Project + Task dueDate/priority/tags, visible in edit UI and main Plan rows.
- P1: Plan-level search/filter/sort using real Project/Task metadata.
- P1: Calm overdue/today/upcoming visual states.
- P2: Goal-level tags.
- P2: Subproject dueDate/priority/tags.
- P2: Review overdue/upcoming analytics.
- P2: advanced saved searches, tag management center, recurring due dates, reminders.

Recommended bounded package:

- V6B should implement Project + Task metadata and Plan-level search/filter/sort.
- Goal/Subproject metadata should be postponed unless implementation proves tiny and safe.

## 3. Data Model Proposal

### 3.1 New Priority Model

Add a bounded enum:

```dart
enum PlanPriority {
  low,
  medium,
  high,
  urgent,
}
```

Recommended UI labels:

- `low`: 低
- `medium`: 中
- `high`: 高
- `urgent`: 紧急

Recommended storage:

- Store as stable string values: `low`, `medium`, `high`, `urgent`.
- Missing priority means no explicit priority / normal.
- Malformed priority loads as null.

Why nullable priority:

- Old objects should not suddenly display artificial priority.
- Default hierarchy remains calm.
- The UI can label null as `普通` only when needed.

### 3.2 Project Metadata

Add to `ProjectItem`:

```dart
final String? dueDate; // YYYY-MM-DD local date
final PlanPriority? priority;
final List<String> tags;
```

Rules:

- `dueDate` is a local date string in `YYYY-MM-DD`, not a UTC `DateTime`.
- `priority` is optional.
- `tags` is a sanitized free-text string list.
- No generated habit record should mutate these fields.
- Project metadata is object identity/planning metadata, not progress.

### 3.3 Task/Action Metadata

Add to `GoalTaskItem`:

```dart
final String? dueDate; // YYYY-MM-DD local date
final PlanPriority? priority;
final List<String> tags;
```

Rules:

- Same date, priority, and tag rules as `ProjectItem`.
- Completed task with past due date is not active overdue.
- Task due date does not affect completion or progress.

### 3.4 Postponed Model Fields

Do not add in first V6B unless a serious implementation reason appears:

- Goal dueDate
- Goal priority
- Goal tags
- Subproject dueDate
- Subproject priority
- Subproject tags
- Project/task status enum
- Recurrence
- Reminder fields
- Saved search objects
- Global tag registry

Reason:

- Project and Task are the two levels that best match current object detail and execution.
- Adding all hierarchy levels at once risks UI clutter, migration complexity, and unclear semantics.

### 3.5 Tags

Use free-text tags stored on each object:

```dart
final List<String> tags;
```

Sanitization rules:

- Trim whitespace.
- Drop empty tags.
- Deduplicate exact normalized text.
- Recommended object-level cap: 8 tags.
- Recommended tag length cap: 16 visible characters.
- Preserve Chinese, English, numbers, and common symbols.
- Do not introduce a separate global tag table in V6B.

Why free-text first:

- Avoids a tag-management feature package.
- Keeps schema small.
- Works for search/filter immediately.

### 3.6 Store API Direction

Add store methods such as:

- `updateProjectPlanningMetadata(projectId, dueDate, priority, tags)`
- `updateTaskPlanningMetadata(taskId, dueDate, priority, tags)`
- `searchPlanItems(query, filters, sortMode)`
- `isProjectOverdue(project, todayKey)`
- `isTaskOverdue(task, todayKey)`
- `isProjectDueToday(project, todayKey)`
- `isTaskDueToday(task, todayKey)`

These should be pure or store-level helpers where possible.

### 3.7 Storage Strategy

Use current goals snapshot storage. No new storage key is needed.

Expected JSON additions:

Project:

```json
{
  "dueDate": "2026-05-08",
  "priority": "high",
  "tags": ["健康", "本周"]
}
```

Task:

```json
{
  "dueDate": "2026-05-08",
  "priority": "urgent",
  "tags": ["写作"]
}
```

Schema version:

- If current pattern tolerates optional fields without bump, keep current schema version.
- If tests or current storage conventions require a snapshot schema bump, bump goals snapshot schema safely and preserve old loads.
- Do not create destructive migration.

## 4. UI Plan

### 4.1 Project Edit

Add a calm planning metadata section to the existing Project edit flow:

- 截止日期
- 优先级
- 标签

Controls:

- Due date picker using existing Flutter date picker pattern.
- Clear due date action: `清除日期`.
- Priority selector as compact segmented chips or a bottom-sheet choice:
  - 普通
  - 低
  - 中
  - 高
  - 紧急
- Tags input with small chips:
  - type a tag
  - add with button or keyboard action
  - remove chip with small close affordance

Copy direction:

- Keep it short and product-like.
- Avoid admin-heavy wording.
- Suggested section title: `计划属性`.

### 4.2 Task / Action Edit

Add the same metadata section to the existing Task edit flow:

- 截止日期
- 优先级
- 标签

Rules:

- Task title editing stays obvious.
- Task completion semantics stay unchanged.
- Metadata edit should not make quick task operations feel heavy.

### 4.3 Plan Main Page

Show metadata subtly:

- Project row:
  - due date chip only when set.
  - priority marker only when high/urgent or explicitly set.
  - show up to 2 tags, then `+N`.
  - overdue state uses restrained warm/error tone.
  - due today uses calm accent tone.
- Task row:
  - due date text/chip near context line.
  - priority dot/chip for high/urgent.
  - tags shown only if space allows.

Do not overload rows:

- Metadata should never compete with project/task title.
- Actions such as edit, record, detail remain readable.
- Long Chinese titles must ellipsize or wrap intentionally.

### 4.4 Project Detail

Add metadata to project detail snapshot:

- 截止日期
- 优先级
- 标签
- 状态: 今日 / 逾期 / 即将到期 only if derived from real due date.

Records table remains record-focused:

- Do not mix due/priority/tags into PlanRecord rows unless the record belongs to a task and context is already shown.

### 4.5 Search / Filter / Sort

Recommended location:

- Plan page level, above the main hierarchy, as a compact searchable planning surface.
- Use a collapsible or compact filter area so the default Plan page remains calm.

Search scope:

- Project title
- Project description
- Project tags
- Task title
- Task tags

Postpone search for:

- Goal tags, because Goal tags are postponed.
- Subproject tags, because Subproject tags are postponed.
- PlanRecord note contents, because that becomes record search and should be a separate package.

Filters:

- 全部
- 今天
- 逾期
- 高优先级
- 标签
- 未完成
- 已完成

Sort modes:

- 默认层级
- 截止日期
- 优先级

Hierarchy vs flat results:

- Default mode should keep the existing hierarchy.
- When search/filter/sort is active, show a flat `筛选结果` section for matching Projects and Tasks.
- Each result row should show its context path, for example:
  - `项目 · 健身计划`
  - `行动 · 健身计划 / 力量训练`
- Do not mutate or reorder the canonical hierarchy itself.

Why flat filtered results:

- It avoids confusing partial trees.
- It keeps the existing DayMark-like hierarchy intact.
- It makes search/filter easier to test and reason about.

### 4.6 Tag Picker / Tag Filter

Use derived tags from current Project/Task metadata:

- No global tag registry.
- Show recently used/current tags as chips.
- Selecting a tag filters matching Projects/Tasks.

### 4.7 Empty States

Examples:

- No search results: `没有找到匹配的项目或行动。`
- No overdue items: `没有逾期事项。`
- No due-today items: `今天没有设置截止事项。`
- No tags yet: `添加标签后，可以按主题筛选计划。`

Keep OffScreen-style restraint:

- No warning-heavy dashboard.
- No red overload.
- No fake productivity scoring.

## 5. Today / Review Behavior

### 5.1 Today

Preferred V6B behavior:

- Today can include a tiny read-only date-aware Plan cue if it is safe:
  - 今日到期行动 count
  - 逾期行动 count
  - next due action preview
- This should use existing Project/Task dueDate metadata only.
- It must not create new Today actions.
- It must not create records.
- It must not change task completion.
- It must not expand Today into a heavy dashboard.

Fallback:

- If Today layout risk is high, keep Today unchanged in V6B and let Plan page own search/filter first.

### 5.2 Review

Keep Review unchanged in V6B.

Postpone:

- overdue analytics
- tag analytics
- priority breakdown
- due-date completion trend

Reason:

- Review currently emphasizes factual metrics and task-derived progress.
- Date/priority/tag analytics need more product thought to avoid fake or noisy summaries.

## 6. Habit -> Plan Linking Behavior

Generated habit-linked PlanRecords:

- Do not affect Project dueDate.
- Do not affect Task dueDate.
- Do not inherit or add Project/Task tags.
- Do not alter Project/Task priority.
- Do not auto-complete linked Task.
- Do not affect task-derived progress.
- Keep existing source metadata and duplicate prevention unchanged.

If a generated record belongs to a linked Task:

- It can still appear in the project records table with source chip.
- It should not be treated as task completion.

If a linked Project/Task is missing:

- Existing fail-safe behavior remains.
- No due/priority/tag behavior should introduce crashes.

## 7. Semantics

### 7.1 Progress

Task progress remains completion-derived:

- Due date does not affect progress.
- Priority does not affect progress.
- Tags do not affect progress.
- Plan records do not affect progress.
- Habit-generated PlanRecords do not affect progress.

### 7.2 Overdue

Task overdue:

- `dueDate < today`
- task is not completed

Task not overdue:

- no dueDate
- dueDate is today or future
- task is completed

Project overdue:

- project has `dueDate < today`
- project progress is not complete

Project not overdue:

- no dueDate
- dueDate is today or future
- project progress is complete

### 7.3 Due Today

Due today:

- `dueDate == today`
- incomplete task or incomplete project

Completed tasks/projects with today due date:

- can show completed state if displayed.
- should not create urgent pressure.

### 7.4 Upcoming

Upcoming can be derived as:

- `today < dueDate <= today + 7 days`

V6B can use this internally for sorting/labels, but should avoid adding a large upcoming dashboard.

### 7.5 Dates

Use local date strings:

- `YYYY-MM-DD`
- same local-date style as habit records
- avoid UTC timezone surprises

### 7.6 Search

Search is read-only UI state:

- no storage
- no mutation
- no analytics side effects

### 7.7 Sorting

Sorting is read-only UI state:

- no mutation of stored hierarchy order.
- default hierarchy remains the canonical Plan structure.

## 8. Migration / Compatibility

Old data behavior:

- Old goals load unchanged.
- Old projects load with `dueDate = null`, `priority = null`, `tags = []`.
- Old subprojects load unchanged.
- Old tasks load with `dueDate = null`, `priority = null`, `tags = []`.
- Old PlanRecords load unchanged.
- Old PlanRecord source metadata remains unchanged.
- Old PlanRecord attachments remain unchanged.

Malformed data behavior:

- Malformed dueDate -> null.
- Malformed priority -> null.
- Malformed tags list -> [].
- Non-string tag entries are skipped.
- Empty tags are skipped.
- Duplicate tags are deduplicated.
- Invalid object metadata should not cause the whole snapshot to be lost if a safe skip/fallback is possible.

Persistence:

- New metadata persists after restart.
- Clearing dueDate persists as null.
- Clearing priority persists as null.
- Clearing tags persists as empty list.

No data loss:

- Do not delete goals, projects, subprojects, tasks, records, attachments, source metadata, image files, or habit links.

## 9. Tests

### 9.1 Persistence / Migration

- Old Plan data loads with null dueDate/priority/tags.
- Old Project data loads with `dueDate = null`, `priority = null`, `tags = []`.
- Old Task data loads with `dueDate = null`, `priority = null`, `tags = []`.
- Malformed dueDate falls back safely.
- Malformed priority falls back safely.
- Malformed tags are skipped/sanitized safely.
- Metadata persists after restart.

### 9.2 Project Metadata

- Create/edit Project dueDate.
- Clear Project dueDate.
- Create/edit Project priority.
- Clear Project priority.
- Create/edit Project tags.
- Remove Project tags.
- Project detail shows dueDate/priority/tags.
- Project row shows metadata without overflow.

### 9.3 Task Metadata

- Create/edit Task dueDate.
- Clear Task dueDate.
- Create/edit Task priority.
- Clear Task priority.
- Create/edit Task tags.
- Remove Task tags.
- Task row shows metadata without overflow.

### 9.4 Derived States

- Overdue task is calculated correctly.
- Completed overdue task is not shown as active overdue.
- Due-today task is calculated correctly.
- Project overdue state uses project dueDate and task-derived incomplete progress.
- Completed project with past dueDate is not active overdue.

### 9.5 Search / Filter / Sort

- Search by project title.
- Search by project description.
- Search by task title.
- Search by tag.
- Filter by today.
- Filter by overdue.
- Filter by high priority.
- Filter by unfinished.
- Filter by completed.
- Sort by due date.
- Sort by priority.
- Default hierarchy remains unchanged after search/filter/sort.
- Filtered results show context path.

### 9.6 Semantics / Regression

- Task progress unaffected by dueDate.
- Task progress unaffected by priority.
- Task progress unaffected by tags.
- Task progress unaffected by records.
- Habit-generated records unaffected.
- Habit-generated records do not alter tags/priority/dueDate.
- Habit-generated records do not auto-complete linked task.
- Today existing tests pass.
- Review existing tests pass.
- Habits tests pass.
- Focus tests pass.
- Theme Studio tests pass.

### 9.7 Responsive

- Plan page renders at 360dp width and text scale 1.15.
- Project edit metadata section renders at 360dp width and text scale 1.15.
- Task edit metadata section renders at 360dp width and text scale 1.15.
- Search/filter panel renders at 360dp width and text scale 1.15.
- Project detail metadata renders at 360dp width and text scale 1.15.

## 10. What Must Not Change

- Bottom navigation.
- Routing.
- Habits behavior.
- Habits record semantics.
- Habits proof/metric behavior.
- Focus behavior.
- Focus timer logic.
- Focus notification behavior.
- Review metrics logic.
- Plan task completion semantics.
- Plan task-derived progress rollup.
- PlanRecord note/numeric/image/source semantics.
- Habit -> Plan duplicate prevention.
- Habit -> Plan task safety.
- Theme Studio behavior.
- Dependencies.
- Native config.
- App version.
- Phone-test packaging.

## 11. Risk Analysis

### Scope Explosion

Risk:

- Due dates, priority, tags, search, filters, sorting, Today, and Review could become several packages.

Mitigation:

- V6B should only add Project + Task metadata and Plan-level search/filter/sort.
- Postpone Goal/Subproject metadata and Review analytics.

### Hierarchy vs Flat Filtered Results

Risk:

- Filtering a tree can confuse users if parent/child visibility changes unexpectedly.

Mitigation:

- Keep canonical hierarchy unchanged.
- Show flat `筛选结果` only when search/filter/sort is active.
- Include context path on every result.

### Date Localization

Risk:

- UTC `DateTime` storage can cause off-by-one due dates.

Mitigation:

- Store dueDate as local `YYYY-MM-DD` string.
- Compute overdue/today/upcoming using local day keys.

### Tag UI Clutter

Risk:

- Tags can make rows noisy.

Mitigation:

- Show at most 2 tags in rows.
- Move full tags to edit/detail surfaces.
- Use calm chips and wrapping.

### Priority Noise

Risk:

- Priority can turn the Plan page into a warning board.

Mitigation:

- Null/normal priority stays visually quiet.
- Only high/urgent receive stronger visual treatment.
- Avoid aggressive red unless overdue/urgent truly needs it.

### Today Over-expansion

Risk:

- Today could become a fake command dashboard.

Mitigation:

- Only add tiny due/overdue counts if layout remains calm.
- Keep Review unchanged.

### Migration Risk

Risk:

- Existing Plan JSON could fail if optional fields are parsed strictly.

Mitigation:

- Parse optional fields defensively.
- Fall back to null/empty list.
- Add migration tests.

### Small-screen Layout Risk

Risk:

- Date, priority, tags, and filters can overflow on 360dp phones.

Mitigation:

- Use `Wrap`, `Flexible`, `SingleChildScrollView`, and max tag counts.
- Add responsive tests.

## 12. Final Recommendation

Recommendation: **A. Task/Project dueDate + priority + tags + Plan search/filter in one bounded package.**

Bounded interpretation of A:

- Add dueDate / priority / tags to `ProjectItem`.
- Add dueDate / priority / tags to `GoalTaskItem`.
- Add Project edit UI for metadata.
- Add Task edit UI for metadata.
- Add subtle metadata display on Project and Task rows.
- Add metadata display in Project detail.
- Add Plan page-level search/filter/sort.
- Use flat filtered results when search/filter/sort is active.
- Keep the existing hierarchy as the default source of truth.
- Keep Today changes optional and tiny.
- Keep Review unchanged.
- Do not add Goal/Subproject metadata in first V6B.
- Do not add saved searches, recurring dates, reminder rules, or tag registry.

Fallback if implementation becomes too large:

- Switch to **B. Task/Project dueDate + priority first, tags/search later**.

Why A is acceptable:

- The schema is bounded to Project and Task.
- No PlanRecord semantics change is needed.
- No Habit/Focus/Review behavior needs to change.
- Search/filter/sort can remain UI-only and read-only.
- It directly addresses the DayMark gap without creating fake progress or noisy analytics.

