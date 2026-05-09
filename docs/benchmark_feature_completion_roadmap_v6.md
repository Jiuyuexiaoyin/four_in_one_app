# Benchmark Feature Completion Roadmap V6

> Roadmap marker: `V6 Benchmark Feature Completion Roadmap`  
> Current app stage: `1.1.2+14` phone-test baseline after Theme Studio real color picker repair  
> Scope: roadmap only, no app code, no dependencies, no version bump, no APK  
> Product direction: controlled completion of benchmark-level functions before the next phone-test cycle

This document defines the next controlled feature-completion roadmap after the `1.1.x` visual polish and Theme Studio repair cycle. The app is now functional and materially richer than an MVP. The remaining work should not become a chaotic "add everything" phase. Each package below is bounded, has explicit schema-risk notes, and preserves the hard semantic rules that have already been repaired.

## Evidence Inspected

Project direction and audit docs:

- `AGENTS.md`
- `docs/product_vision.md`
- `docs/ui_direction.md`
- `docs/source_ui_reference.md`
- `docs/benchmark_visual_gap_audit_v2.md`
- `docs/ui_reference_components.md`
- `docs/feature_completion_checklist.md`
- `docs/references/app_report_v2.txt`

Reference app folders:

- `docs/references/app_content/HabitDone`
- `docs/references/app_content/daymark`
- `docs/references/app_content/OffScreen`
- `docs/references/app_content/番茄ToDo`

Current implementation inspected:

- Habits: `HabitItem`, `HabitRecord`, `HabitRecordAttachment`, `HabitStatisticsSummary`, `HabitsStore`, attachment storage, reminder service, `habits_page.dart`
- Plan: `GoalItem`, `ProjectItem`, `SubprojectItem`, `GoalTaskItem`, `PlanRecord`, `PlanRecordAttachment`, `GoalsStore`, `goals_page.dart`
- Focus: `FocusStore`, active session/session models, notification service, `focus_page.dart`
- Today: `today_page.dart`
- Review: `review_page.dart`
- Settings / Theme Studio: `AppSettingsStore`, `app_theme.dart`, `app_theme_tokens.dart`, `settings_page.dart`
- Shared product widgets: `SoftSurface`, `MetricStrip`, `MetricTile`, `ProgressRail`, `ActivityStrip`, `MiniHeatmapCell`, `HabitIdentityCard`, `PlanGoalCard`, `PlanTreeRow`, `FocusTimerHero`, `MySettingsSection`
- Current tests: 18 Dart test files covering settings, smoke, focus, goals, habits, reminders, habit-plan linking, attachments, statistics, review, and Today

Priority definitions:

- `P0`: a trust, data-safety, or high-frequency usability blocker before any phone-test package.
- `P1`: benchmark-level feature gap that should be completed in the next controlled roadmap.
- `P2`: valuable deeper feature, but safe to postpone until the foundation is stronger.

---

## 1. Current Completed Baseline

The app has crossed the "real 1.0+" threshold. The baseline is no longer a scaffold; it is a local-first productivity system with real habit tracking, plan records, focus sessions, review metrics, customization, and cross-feature linking.

### App Personalization / Theme Studio

Current state:

- Global theme mode supports system, light, and dark.
- Global UI accent color is persisted as nullable ARGB int.
- Global background color is persisted as nullable ARGB int.
- Global card/surface color is persisted as nullable ARGB int.
- Old settings load safely and malformed colors fall back.
- Theme Studio now includes a dependency-free visual color picker:
  - saturation/brightness square
  - hue slider
  - current color preview
  - grouped palette boards
  - live preview
  - collapsed `高级输入` for HEX, RGB, and ARGB
  - reset controls
  - low-alpha and readability guardrails
- Per-habit color and per-project color remain distinct from global theme colors.

Key files:

- `lib/app/settings/application/app_settings_store.dart`
- `lib/app/settings/data/app_settings_local_storage.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_theme_tokens.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `test/app_settings_store_test.dart`
- `test/settings_theme_test.dart`

### HabitDone-Inspired Habits

Current state:

- Lightweight habit cards with emoji/icon, name, description, target count, reminder summary, lifecycle state, per-habit color, progress, and recent activity.
- One-tap quick check-in remains primary.
- Detailed check-in uses draft/save semantics and does not create a record until saved.
- `HabitRecord` supports `checkIn`, `makeup`, and `skip`.
- Notes are optional metadata on records.
- Makeup targets selected past `localDate`; it counts on the selected date, not `createdAt`.
- Skip is blocked when a date already has effective check-in/makeup and does not count as completion.
- Proof images support up to 3 images per record, gallery selection, camera capture, preview, replace, remove, and missing-file safe states.
- 7-day activity, current-month heatmap, recent 3-month activity, and current-year annual heatmap exist.
- Per-habit statistics include completion days, active days, tracked days, skipped days, proof days, proof image count, current/longest streak, pause-protected days, completion distribution, and record history.
- Streaks are derived from effective check-ins only; pause intervals are neutral and do not add completed days.
- Lifecycle supports active, paused, archived, and soft-deleted habits.
- Advanced reminder rules support up to 3 rules per habit, weekday selection, enable/disable, lifecycle cancellation, startup resync, and legacy `reminderTime` migration.
- Habit can link to a Plan Project or Task; daily target completion creates one sourced PlanRecord without auto-completing Plan tasks.

Key files:

- `lib/features/habits/domain/models/habit_item.dart`
- `lib/features/habits/domain/models/habit_record.dart`
- `lib/features/habits/domain/models/habit_record_attachment.dart`
- `lib/features/habits/domain/models/habit_statistics_summary.dart`
- `lib/features/habits/application/habits_store.dart`
- `lib/features/habits/application/habit_plan_record_writer.dart`
- `lib/features/habits/data/habit_record_attachment_storage.dart`
- `lib/features/habits/data/habit_reminder_notification_service.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `test/habit_statistics_test.dart`
- `test/habits_flow_test.dart`
- `test/habits_persistence_test.dart`
- `test/habits_reminder_notifications_test.dart`
- `test/habit_plan_linking_test.dart`
- `test/habit_record_attachment_storage_test.dart`

### DayMark-Inspired Plan

Current state:

- Goal / Project / Subproject / Task hierarchy exists.
- Goal and Project identity are editable: title, icon, color, description.
- Subproject and Task titles are editable.
- Task/action is the only directly completable unit.
- Goal and Project progress roll up from child task completion only.
- PlanRecord supports note and numeric record types.
- PlanRecord supports localDate, projectId, optional subprojectId, optional taskId, numeric value/unit, and source metadata.
- PlanRecord source metadata supports generated records from linked habits:
  - `sourceType`
  - `sourceId`
  - `sourceLocalDate`
  - `sourceKey`
- Project detail surface exists with identity, progress, record stats, numeric totals by unit, current-month activity, record composition, filters, and phone-readable records table.
- Generated habit-linked records show source chips such as `来自习惯`.
- Plan proof attachments exist for Plan records; current Plan behavior is still one-image proof per record.
- Records do not affect task progress.

Key files:

- `lib/features/goals/domain/models/goal_item.dart`
- `lib/features/goals/application/goals_store.dart`
- `lib/features/goals/data/goals_local_storage.dart`
- `lib/features/goals/data/plan_record_attachment_storage.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/shared/widgets/product/plan_goal_card.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- `test/goals_flow_test.dart`
- `test/goals_persistence_test.dart`
- `test/goals_attachment_widget_test.dart`
- `test/plan_record_attachment_storage_test.dart`

### Focus Inspired By 番茄ToDo

Current state:

- Large timer hero exists.
- Countdown timer supports custom duration.
- Active focus session persists and restores after app kill.
- Completion history is stored.
- Focus notification path exists.
- Focus can bind to a Plan Task/Action snapshot.
- Focus target snapshot is preserved in history.
- Focus does not auto-complete Plan tasks.
- Start / pause / reset clarity exists.

Key files:

- `lib/features/focus/application/focus_store.dart`
- `lib/features/focus/data/focus_local_storage.dart`
- `lib/features/focus/data/focus_notification_service.dart`
- `lib/features/focus/domain/models/focus_active_session.dart`
- `lib/features/focus/domain/models/focus_session_item.dart`
- `lib/features/focus/domain/models/focus_target_snapshot.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `test/focus_store_test.dart`
- `test/focus_flow_test.dart`
- `test/focus_persistence_test.dart`

### OffScreen-Inspired Review / Data Surfaces

Current state:

- Review uses real metrics only.
- Review shows habit check-ins/completion, plan hierarchy progress, and focus session data.
- Review avoids fake digital wellbeing data.
- Today uses real habit/plan/focus data as a daily command center.
- Shared product widgets support calm data panels, metric strips, progress rails, heatmap cells, and soft surfaces.

Key files:

- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/shared/widgets/product/*.dart`
- `test/review_overview_test.dart`
- `test/today_overview_test.dart`
- `test/app_smoke_test.dart`

### Responsive Polish

Current state:

- Main pages and major sheets have been repeatedly repaired for small phone widths.
- Tests include small-width coverage for key pages/sheets.
- Recent validation baseline after Theme Studio repair passed analyze/test/build before the `1.1.2+14` phone-test build.

---

## 2. Remaining HabitDone Gaps

Habits is the most mature feature area. The remaining HabitDone gaps are not basic tracking gaps; they are structured check-in depth, richer record types, habit organization, and deeper analytics from real data.

### Gap H1: Habit Sub-records / Measurable Check-in Templates

What HabitDone-like benchmark direction suggests:

- Habit tracking can be more than a binary count.
- Some habits need measurable check-in details: pages read, minutes studied, kilometers run, cups of water, mood, difficulty, checklist items, or custom fields.
- A habit should remain quick, but detailed records should support structured evidence.

What our app has:

- `HabitRecord` supports type, localDate, createdAt, and optional note.
- Multiple check-ins, makeup, skip, proof images, and per-habit target counts exist.
- Notes are free-form only.

What is missing:

- No per-habit check-in template.
- No numeric habit fields.
- No units for habit records.
- No structured sub-record values under a HabitRecord.
- No metric-specific analytics.

Priority:

- `P1-high`

Risk:

- High risk of making quick check-in heavy.
- High schema risk.
- High analytics semantics risk if numeric values are confused with completion counts.

Schema impact:

- Likely required.
- Recommended new model:
  - `HabitCheckInTemplateField`
  - `HabitRecordMetricValue`
- Avoid replacing existing `HabitRecord` fields; extend with optional structured values or add a separate model/list stored alongside records.

Recommended package:

- `V6A Habit Structured Check-in Templates + Numeric Units`

Core rule:

- Completion count remains `checkIn + makeup`; numeric values are evidence/analytics, not automatic completion unless explicitly and carefully scoped later.

### Gap H2: Numeric Check-in Fields and Units

What benchmark has:

- HabitDone-style tracking can feel more meaningful when a record can say "30 min", "10 pages", "2 km", not just "done".

What our app has:

- Plan records support numeric value + unit.
- Habit records do not.

What is missing:

- Habit record numeric value/unit.
- Multi-field numeric templates for habits.
- Unit presets per habit.
- Aggregates by unit.

Priority:

- `P1-high`

Risk:

- Unit mixing risk.
- Ambiguous completion logic risk.
- Migration risk if stored directly on `HabitRecord`.

Schema impact:

- Likely required.
- Prefer reusable value rows over a single numeric field because future templates may need multiple values.

Recommended package:

- `V6A Habit Structured Check-in Templates + Numeric Units`

### Gap H3: Grouped Habit Records

What benchmark has:

- Record/history views often group by day, activity type, proof, and detail values.

What our app has:

- Date-grouped habit record list exists.
- Type chips and proof indicators exist.

What is missing:

- Grouping by structured field/template.
- Filter chips such as all / check-in / makeup / skip / proof / numeric.
- Calendar-table view for record inspection.

Priority:

- `P1`

Risk:

- UI density and small-screen crowding.

Schema impact:

- No schema impact if built only from existing records.
- Schema impact if it depends on V6A metric fields.

Recommended package:

- `V6B Habit Metric Analytics + Calendar Table`

### Gap H4: Habit Categories / Groups

What benchmark has:

- Habit lists often support categories, groups, or sections so many habits do not become a long flat list.

What our app has:

- Active, paused, archived, and deleted lifecycle segmentation.
- No user-defined habit category/group.

What is missing:

- Habit group/category model.
- Filter by group.
- Grouped habit dashboard.
- Optional category color/icon.

Priority:

- `P1`

Risk:

- Adds management complexity.
- Can clutter the main habit list.
- Needs careful empty-state and edit UI.

Schema impact:

- Likely required.
- Options:
  - Add `categoryId` / `groupId` to `HabitItem`.
  - Add `HabitGroup` storage list.
  - Simple first step: `categoryLabel` string on HabitItem, but this is weaker long-term.

Recommended package:

- `V6C Habit Groups + List Organization`

### Gap H5: Richer Habit Statistics From Structured Metrics

What benchmark has:

- More meaningful statistics when a habit has measurable values:
  - total minutes/pages/km
  - weekly/monthly totals
  - average value per active day
  - distribution by record type
  - calendar/table drill-down

What our app has:

- Completion days, active days, tracked days, skip/proof days, proof image count, streaks, current-month/recent/annual heatmaps, completion distribution, and history.

What is missing:

- Numeric/unit totals for habits.
- Chart-like visual bars based on habit metric fields.
- Metric trend from real values.
- Calendar table with value columns.

Priority:

- `P1`

Risk:

- Fake trend risk if the app implies meaning without enough data.
- Unit mixing risk.

Schema impact:

- Depends on V6A.

Recommended package:

- `V6B Habit Metric Analytics + Calendar Table`

### Gap H6: Habit Calendar/Table Views

What benchmark has:

- More complete calendar/table views for habit history and analytics.

What our app has:

- Current month date operations, recent 3-month activity, annual heatmap, date-grouped record list.

What is missing:

- Dedicated table-like per-habit record view.
- Month/year view toggle or calendar/table mode switch.
- Filters by record type and proof/note.

Priority:

- `P1`

Risk:

- Bottom sheet could become too long.
- New route would be a routing decision; avoid until explicitly approved.

Schema impact:

- None if derived from existing records.

Recommended package:

- `V6B Habit Metric Analytics + Calendar Table`

### Gap H7: Remaining Habit Customization

What benchmark has:

- Rich habit visual identity, heatmap palette controls, card display style, possibly icon libraries.

What our app has:

- Global Theme Studio.
- Per-habit low-saturation color.
- Emoji/custom emoji.

What is missing:

- Custom HEX/RGB/ARGB for per-habit color.
- More visual habit color picker reuse.
- Optional habit category icon/color.
- Heatmap palette customization beyond deriving from habit color.

Priority:

- `P2`

Risk:

- Can make UI too customization-heavy.
- Could confuse global accent vs habit identity again.

Schema impact:

- Per-habit custom color already has `habitColorValue`; no schema impact for better picker UI.
- Heatmap palette customization would require schema if separate from habit color.

Recommended package:

- Postpone until after V6A/V6B, or fold only picker reuse into `V6C` if the UI is tiny and safe.

### Gap H8: Habit Hard Delete / Data Management

What benchmark direction suggests:

- Lifecycle should eventually support deletion/data cleanup safely.

What our app has:

- Soft delete preserves records/proof.
- Hard delete postponed.

What is missing:

- Deleted-habits management UI.
- Restore from deleted state.
- Final hard delete with attachment cleanup.
- Data export/backup before destructive delete.

Priority:

- `P1` for data management before hard delete.
- `P2` for hard delete itself.

Risk:

- Data loss and orphan file risk.

Schema impact:

- No schema impact for deleted-habit management.
- Backup/export may add file format decisions but not app schema.

Recommended package:

- `V6H Data Management + Backup/Export Foundation`

---

## 3. Remaining DayMark Gaps

Plan is functionally strong but still has deeper DayMark gaps around project record detail, charts, project lifecycle, richer action metadata, and data management.

### Gap D1: Editable Plan Record Detail

What DayMark has:

- Records feel like first-class project history objects that can be inspected and edited.

What our app has:

- PlanRecord creation for note/numeric records.
- One-image proof attachment replacement/removal.
- Project record table and filters.

What is missing:

- Clear record detail/edit surface.
- Edit localDate, note, numeric value, unit, and attachment after creation.
- Delete individual PlanRecord safely.
- Audit/source clarity for generated habit records.

Priority:

- `P1`

Risk:

- Editing generated habit records can break traceability if not handled carefully.
- Deleting generated records may allow duplicates to be recreated unless sourceKey rules are defined.

Schema impact:

- No schema impact for editing existing fields.
- May need `updatedAt` if audit trail is desired; postpone unless necessary.

Recommended package:

- `V6D Plan Record Detail Editing + Source Safety`

Core rule:

- Editing/deleting records must not change task progress.

### Gap D2: Plan Multi-image / Camera Proof Parity

What DayMark direction suggests:

- Project/action evidence should support richer proof, similar to Habits proof.

What our app has:

- PlanRecordAttachment supports one attachment per record behavior.
- Habit proof supports max 3, gallery, camera, preview, replace, remove.

What is missing:

- Max 3 Plan proof images per PlanRecord.
- Camera capture for Plan proof.
- Thumbnail grid/preview parity.
- Missing-file safe multi-image UI for Plan records.

Priority:

- `P1`

Risk:

- Native camera/photo permission was already handled for habits; no new native config should be needed, but real-device parity must be tested.
- Storage growth and orphan file risk.

Schema impact:

- Probably no schema impact if allowing multiple `PlanRecordAttachment` rows per recordId, mirroring habits.

Recommended package:

- `V6D Plan Record Detail Editing + Multi-image Proof Parity`

### Gap D3: Project Annual Heatmap

What DayMark has:

- Project-level annual heatmap/chart direction.

What our app has:

- Current-month project activity.
- Habit annual heatmap.

What is missing:

- Current-year project heatmap from PlanRecord localDate.
- Project activity legend and month labels.
- Read-only long-range project visibility.

Priority:

- `P1`

Risk:

- 365-cell grid small-phone readability.
- Performance with many records.

Schema impact:

- None; derive from PlanRecord localDate.

Recommended package:

- `V6E Plan Project Annual Heatmap + Chart Upgrade`

### Gap D4: Project Chart Suite

What DayMark has:

- Project statistics and charts beyond counts.

What our app has:

- Metric panels, record composition bars, numeric totals, current-month heatmap.

What is missing:

- Record trend by week/month.
- Numeric total trend by unit.
- Action completion trend.
- Project distribution chart from real records.

Priority:

- `P1`

Risk:

- Fake trend risk.
- No chart dependency allowed unless approved.

Schema impact:

- None if derived.

Recommended package:

- `V6E Plan Project Annual Heatmap + Chart Upgrade`

### Gap D5: Goal-Level Analytics

What DayMark direction suggests:

- Goals can be viewed as long-term containers with their own progress/activity.

What our app has:

- Goal progress derived from child tasks.
- Focused goal tree view.

What is missing:

- Goal-level record/activity rollup from projects.
- Goal-level current-month/year activity.
- Goal-level active days and record totals.

Priority:

- `P2`

Risk:

- Could confuse project records with task progress.

Schema impact:

- None if derived from project records.

Recommended package:

- Later `V6E2 Goal Analytics Rollup`, after Project analytics is stable.

### Gap D6: Project Lifecycle

What DayMark direction suggests:

- Projects and goals need archive/delete/restore rules as the data grows.

What our app has:

- Habit lifecycle exists.
- Plan does not have lifecycle states.

What is missing:

- Project archive.
- Goal archive.
- Safe soft delete.
- Data management surface.

Priority:

- `P1`

Risk:

- Plan hierarchy integrity risk.
- Missing target behavior with habit links and focus snapshots.
- Data loss risk if delete is hard.

Schema impact:

- Likely required:
  - status fields for Goal/Project/Subproject/Task, or at least Goal/Project.
  - archivedAt/deletedAt timestamps.

Recommended package:

- `V6H Data Management + Plan Lifecycle Foundation`

### Gap D7: Action Metadata

What DayMark and task/planning apps often have:

- Due date, priority, tags, scheduled date, repeat rules, or milestones.

What our app has:

- Task title, completion flag, createdAt, project/subproject parent.
- Focus target binding snapshot.

What is missing:

- Due/scheduled dates.
- Priority.
- Tags.
- Task notes/details.
- Repeat action templates.

Priority:

- `P2`

Risk:

- Can turn Plan into a full task manager and overload Today.

Schema impact:

- Required if implemented.

Recommended package:

- Postpone until after records/analytics/data management.

---

## 4. Remaining OffScreen Gaps

OffScreen is the strongest benchmark for calm analytics, digital wellbeing, and premium data surfaces. The current app has OffScreen-inspired visual rhythm but not true digital wellbeing integration.

### Gap O1: Real Digital Wellbeing Data

What OffScreen has:

- Screen time.
- Pickup count.
- App usage ranking.
- Morning/night phone behavior.
- App limits and usage restrictions.

What our app has:

- No screen-time integration.
- Review only uses real internal app data: habits, plan, focus.

What is missing:

- Platform screen time permissions.
- App usage data import/collection.
- Pickup count.
- App usage ranking.
- App limits.
- Bedtime phone behavior.

Priority:

- `P2` for now.

Risk:

- Very high platform/native risk.
- iOS requires Screen Time / Family Controls / Device Activity style capabilities and Apple review constraints.
- Android requires sensitive usage access and possibly vendor-specific behavior.
- Must not fake.

Schema impact:

- Required if implemented.

Recommended package:

- Postpone to a separate `V7 Digital Wellbeing Foundation` after the core four-in-one loop is stable.

### Gap O2: Weekly / Monthly Real Review Reports

What OffScreen has:

- Calm long-range reports and visual rhythms.

What our app has:

- Review page with factual current/today and recent metrics.

What is missing:

- Weekly report.
- Monthly report.
- Date range selector.
- Habit/Plan/Focus time-series from real app data.
- Export/share report.

Priority:

- `P1`

Risk:

- Fake insight risk if copy implies causality.
- UI density risk.

Schema impact:

- None if reports are derived on demand.
- Persisted report snapshots are optional and should be postponed.

Recommended package:

- `V6G Review Weekly/Monthly Real Analytics Report`

### Gap O3: Calm Chart Vocabulary

What OffScreen has:

- Ring charts, bar charts, usage timelines, sparse metric panels.

What our app has:

- Progress rails, metric tiles, heatmaps, distribution bars.

What is missing:

- A small internal chart vocabulary for:
  - weekly bars
  - segmented rings
  - daily timeline strips
  - unit trend bars

Priority:

- `P1`

Risk:

- No chart package unless explicitly approved.
- Can become noisy if overused.

Schema impact:

- None.

Recommended package:

- `V6G Review Weekly/Monthly Real Analytics Report`, sharing widgets with `V6E`.

### Gap O4: Privacy / Data Controls

What OffScreen-like products must do well:

- Explain sensitive permissions.
- Let users manage data.
- Provide export/delete paths.

What our app has:

- Local-first data.
- Soft delete for habits.
- No full backup/export/import/data management center.

What is missing:

- Data export.
- Local backup file.
- Restore/import.
- Deleted habit management.
- Final deletion guardrails.

Priority:

- `P1`

Risk:

- Data loss if done late or casually.

Schema impact:

- No schema impact if exporting current storage snapshots.

Recommended package:

- `V6H Data Management + Backup/Export Foundation`

---

## 5. Remaining 番茄ToDo Gaps

Focus is stable and should be protected. The next Focus work should add execution capability only after habit/plan completion features are stabilized.

### Gap F1: Pomodoro Work/Break Cycles

What 番茄ToDo has:

- Pomodoro cycles and work/break modes.

What our app has:

- Custom countdown duration only.

What is missing:

- Work duration.
- Short break duration.
- Long break duration.
- Cycle count.
- Auto/confirm next phase behavior.

Priority:

- `P1`

Risk:

- Timer and notification logic risk.
- App-kill restore complexity increases.

Schema impact:

- Likely required for active session mode and history mode.

Recommended package:

- `V6F Focus Pomodoro Modes + Weekly Focus Overview`

### Gap F2: Count-up Timer

What benchmark has:

- Count-up / stopwatch-style focus.

What our app has:

- Countdown only.

What is missing:

- Count-up focus mode.
- History label for count-up sessions.
- Notification copy for count-up.

Priority:

- `P2`

Risk:

- Lower risk than Pomodoro but still touches timer logic.

Schema impact:

- Likely required to store focus mode.

Recommended package:

- Fold into `V6F` only if Pomodoro scope remains safe; otherwise postpone.

### Gap F3: Weekly Focus Overview

What benchmark has:

- Weekly focus calendar/overview.

What our app has:

- Focus sessions and Review aggregate metrics.

What is missing:

- Weekly focus bars by day.
- Target distribution.
- Recent sessions grouped by date/target.

Priority:

- `P1`

Risk:

- Low if read-only.

Schema impact:

- None.

Recommended package:

- `V6F Focus Pomodoro Modes + Weekly Focus Overview`

### Gap F4: Strict Mode / Interruption Tracking / White Noise

What benchmark has:

- Strict focus modes, interruption tracking, white noise.

What our app has:

- No strict mode, interruption log, or audio.

What is missing:

- Strict exit rules.
- Interruption records.
- White noise/audio player.

Priority:

- `P2`

Risk:

- Strict mode can be hostile if wrong.
- Audio may need new dependencies/platform concerns.
- Interruption tracking needs clear semantics.

Schema impact:

- Required for interruption records.

Recommended package:

- Postpone.

### Gap F5: Focus Schedule / Planner

What benchmark has:

- Planned focus blocks or schedule-like execution.

What our app has:

- Today and Plan can show focus entry; Focus target binding exists.

What is missing:

- Scheduled focus blocks.
- Today focus plan.
- Link focus plan to Plan tasks without auto-completion.

Priority:

- `P2`

Risk:

- Could overlap with task due-date/scheduling work.

Schema impact:

- Required if persisted.

Recommended package:

- Postpone until Plan action metadata is defined.

---

## 6. Remaining Theme / Customization Gaps

The P0 Theme Studio issue is fixed, so V6 should not immediately spend another large package on colors unless real-device feedback specifically asks for it. Remaining customization gaps are now lower priority than structured habit data and Plan record completion.

### Current Theme Studio Done

- Visual picker.
- Hue slider.
- Palette boards.
- Live preview.
- Background/surface/accent targets.
- Collapsed advanced HEX/RGB/ARGB input.
- Theme persistence.
- Readability guardrails.

### Remaining Customization Gaps

| Gap | Priority | Schema Impact | Recommendation |
| --- | --- | --- | --- |
| Save named theme presets | P2 | Possibly yes | Postpone until users ask to switch between multiple saved themes. |
| Separate light/dark custom palettes | P2 | Yes | Postpone; current colors are blended for readability. |
| Per-habit visual picker reuse | P2 | No | Can be a small polish task later. |
| Per-project visual picker reuse | P2 | No | Can be paired with Plan identity polish. |
| Wallpaper/background image | P2 | Yes/files | Postpone. |
| Gradient editor | P2 | Yes | Postpone. |
| Custom fonts | P2 | Yes/assets | Postpone; no dependencies/assets now. |
| Export/import themes | P2 | Format decision | Postpone until data backup/export exists. |

Recommended package:

- No V6 package unless real-device feedback makes customization P0 again.

---

## 7. Cross-Feature Completion Gaps

### Gap X1: Backup / Export / Import

Why needed:

- The app now stores meaningful personal data: habits, proof images, plan records, focus sessions, theme settings.
- Hard delete and deeper schema changes become safer only after backup/export exists.

Current state:

- Local storage exists.
- No user-facing backup/export/import.

Missing:

- Export structured JSON snapshot.
- Export app-managed images or include references safely.
- Restore/import strategy.
- Conflict handling.
- Data management UI.

Priority:

- `P1`

Risk:

- Data-loss risk if implemented casually.
- File permission/platform differences.

Schema impact:

- No app data schema change required, but export format must be versioned.

Recommended package:

- `V6H Data Management + Backup/Export Foundation`

### Gap X2: Search and Filtering

Why needed:

- Records are now numerous: habit records, Plan records, generated records, attachments.

Current state:

- Some Plan record filters exist.
- No global search.

Missing:

- Search records by note/title/source.
- Filter by date range/type/source.
- Maybe per-feature only first.

Priority:

- `P2`

Schema impact:

- None.

Recommended package:

- Postpone until record detail/table work is complete.

### Gap X3: Permission Center

Why needed:

- Notifications, camera, photo library, and future digital wellbeing permissions need clear user trust surfaces.

Current state:

- Settings has theme/personalization; permissions are not a full management center.

Missing:

- Notification permission explanation/status.
- Camera/photo permission guidance.
- Future digital wellbeing permission placeholders.

Priority:

- `P2`

Schema impact:

- None.

Recommended package:

- Later My/Settings polish package, not V6 first.

### Gap X4: iOS Build / Distribution Strategy

Why needed:

- User has iPhones and asked for Apple install package before.

Current state:

- Windows can build Android APK.
- iOS IPA/TestFlight requires macOS/Xcode/Apple Developer workflow.

Missing:

- iOS signing/distribution plan.
- Device UDID/TestFlight strategy.

Priority:

- `P1` operationally, not app-code.

Schema impact:

- None.

Recommended package:

- Separate deployment planning doc when user is ready; do not mix with feature coding.

---

## 8. Recommended V6 Package Order

The recommended order prioritizes data-model foundations before analytics, then Plan record parity, then Focus and Review. This avoids building charts on fields that do not exist yet.

### V6A Habit Structured Check-in Templates + Numeric Units

Goal:

- Add measurable habit records without making quick check-in heavy.
- Support optional per-habit detailed check-in templates.
- Support numeric values and units for habit records.

Likely files touched:

- `lib/features/habits/domain/models/habit_item.dart`
- `lib/features/habits/domain/models/habit_record.dart`
- possible new model file under `lib/features/habits/domain/models/`
- `lib/features/habits/application/habits_store.dart`
- `lib/features/habits/data/habits_local_storage.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `test/habits_persistence_test.dart`
- `test/habits_flow_test.dart`
- `test/habit_statistics_test.dart`

Likely schema impact:

- Yes.
- Preferred shape:
  - Add `checkInTemplateFields` to `HabitItem`, or a separate non-global persisted template model.
  - Add optional structured values to records through a separate list/model instead of overloading `HabitRecord.note`.

Must not change:

- Quick one-tap check-in remains fast.
- Completion count remains effective `checkIn + makeup` unless the user explicitly approves numeric-target semantics later.
- Skip/proof/note do not count as completion.
- Reminder/lifecycle/streak/habit-plan link semantics unchanged.

Tests needed:

- Old habits/records load safely.
- Habit with no template behaves exactly as before.
- Create habit with numeric field template.
- Detailed check-in saves numeric value/unit.
- Makeup saves numeric value on selected localDate.
- Numeric value does not affect completion count by default.
- Heatmap/streak unchanged.
- Invalid numeric/unit data falls back safely.
- Existing habit proof/reminder/lifecycle/linking tests pass.

Recommendation:

- This should be the first V6 code package.

### V6B Habit Metric Analytics + Calendar Table

Goal:

- Use V6A structured values to make Habit analytics richer and more HabitDone-like.
- Add calendar/table detail for habit records.

Likely files touched:

- `lib/features/habits/domain/models/habit_statistics_summary.dart`
- `lib/features/habits/application/habits_store.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- shared analytics widgets if needed
- `test/habit_statistics_test.dart`
- `test/habits_flow_test.dart`

Likely schema impact:

- None if V6A already created the necessary model.

Must not change:

- Completion semantics.
- Streak semantics.
- Annual heatmap intensity.
- Proof semantics.

Tests needed:

- Metric totals group by unit.
- Unit values do not mix.
- Calendar table groups records by date.
- Filters by type/proof/note/metric work if implemented.
- Missing/malformed metric values fail safe.
- Small-phone rendering tests.

### V6C Habit Groups + List Organization

Goal:

- Add user-defined habit groups/categories so many habits remain manageable.

Likely files touched:

- `lib/features/habits/domain/models/habit_item.dart`
- possible new `habit_group.dart`
- `lib/features/habits/application/habits_store.dart`
- `lib/features/habits/data/habits_local_storage.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/today/presentation/pages/today_page.dart` only if Today grouping display is safe
- `test/habits_persistence_test.dart`
- `test/habits_flow_test.dart`
- `test/today_overview_test.dart`

Likely schema impact:

- Yes.
- Prefer one optional group per habit for first package.

Must not change:

- Active/paused/archived/deleted lifecycle semantics.
- Today active-only obligation count.
- Reminder scheduling.

Tests needed:

- Old habits load ungrouped.
- Create/edit/clear habit group.
- Grouped list renders without overflow.
- Lifecycle sections still work.
- Today counts unchanged.

### V6D Plan Record Detail Editing + Multi-image Proof Parity

Goal:

- Make Plan records first-class DayMark-style project evidence.
- Add record detail/edit/delete rules.
- Bring Plan proof behavior closer to Habit proof with max 3 images and camera/gallery.

Likely files touched:

- `lib/features/goals/domain/models/goal_item.dart` only if updatedAt/source safety requires it
- `lib/features/goals/application/goals_store.dart`
- `lib/features/goals/data/goals_local_storage.dart`
- `lib/features/goals/data/plan_record_attachment_storage.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `test/goals_flow_test.dart`
- `test/goals_persistence_test.dart`
- `test/goals_attachment_widget_test.dart`
- `test/plan_record_attachment_storage_test.dart`

Likely schema impact:

- Maybe.
- Multi-image can likely reuse existing `PlanRecordAttachment` rows per recordId.
- Record editing can use existing fields.
- Add `updatedAt` only if strongly justified.

Must not change:

- Task completion semantics.
- Plan progress rollup.
- Habit-generated record duplicate prevention.
- Focus binding.

Tests needed:

- Edit note record.
- Edit numeric value/unit.
- Edit localDate if scoped.
- Delete manual record safely.
- Generated habit records remain traceable.
- Generated records are not auto-recreated unexpectedly after deletion unless explicitly defined.
- Add second/third Plan image proof.
- Fourth Plan image blocked.
- Camera/gallery fake storage tests.
- Records still do not affect task progress.

### V6E Plan Project Annual Heatmap + Chart Upgrade

Goal:

- Make Project analytics closer to DayMark using existing PlanRecord data.

Likely files touched:

- `lib/features/goals/domain/models/goal_item.dart` only for derived summary if needed
- `lib/features/goals/application/goals_store.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- shared analytics widgets
- `test/goals_flow_test.dart`

Likely schema impact:

- None.

Must not change:

- No fake analytics.
- No chart dependency unless separately approved.
- Records still do not affect task progress.

Tests needed:

- Project annual heatmap derives from PlanRecord localDate.
- Source/generated records count as records only.
- Numeric charts group by unit.
- Current-month logic still works.
- Small-phone rendering tests.

### V6F Focus Pomodoro Modes + Weekly Focus Overview

Goal:

- Move Focus closer to 番茄ToDo without destabilizing the current timer.
- Add Pomodoro work/break modes and a read-only weekly overview if safe.

Likely files touched:

- `lib/features/focus/domain/models/focus_active_session.dart`
- `lib/features/focus/domain/models/focus_session_item.dart`
- `lib/features/focus/application/focus_store.dart`
- `lib/features/focus/data/focus_local_storage.dart`
- `lib/features/focus/data/focus_notification_service.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart` only if read-only focus overview is shared
- `test/focus_store_test.dart`
- `test/focus_flow_test.dart`
- `test/focus_persistence_test.dart`

Likely schema impact:

- Yes for focus mode/session phase if Pomodoro is implemented.

Must not change:

- Focus task binding must not mutate Plan tasks.
- Existing countdown mode must remain unchanged.
- Notification IDs must remain separated from habit reminders.

Tests needed:

- Existing countdown tests still pass.
- Pomodoro phase persists/restores.
- Break phase does not create fake focus minutes unless clearly defined.
- Completion history labels mode correctly.
- Weekly overview derives from completed sessions only.

### V6G Review Weekly/Monthly Real Analytics Report

Goal:

- Add OffScreen-like weekly/monthly reporting from real app data only.

Likely files touched:

- `lib/features/review/presentation/pages/review_page.dart`
- possibly derived summary helpers
- shared chart widgets
- `test/review_overview_test.dart`
- `test/app_smoke_test.dart`

Likely schema impact:

- None if reports are derived on demand.

Must not change:

- No fake digital wellbeing data.
- No fake trends.
- No generated habit-linked PlanRecord overcount in Plan progress.

Tests needed:

- Weekly report uses real habit/plan/focus data.
- Monthly report uses real habit/plan/focus data.
- Empty states are honest.
- Generated PlanRecords count as records only.
- Small-phone layout safe.

### V6H Data Management + Backup/Export Foundation

Goal:

- Add safe data management before hard delete, import/export, or deeper lifecycle actions.

Likely files touched:

- Storage snapshot classes for settings, habits, goals, focus.
- Settings/My page.
- Attachment storage helpers.
- Tests for export/import helpers.

Likely schema impact:

- No core schema impact required, but export format should be versioned.

Must not change:

- Existing data load paths.
- Existing record semantics.
- No destructive hard delete without explicit user confirmation.

Tests needed:

- Export includes settings/habits/records/attachments metadata/goals/focus.
- Export does not store image bytes in SharedPreferences.
- Import malformed data fails safe.
- Restore does not duplicate IDs incorrectly.
- Deleted/archived data is represented safely.

### V6I Benchmark Feature Completion Review

Goal:

- Review the V6 feature-completion baseline before preparing the next phone-test APK.

Likely files touched:

- Optional review doc only.

Must not change:

- No version bump until package preparation is explicitly approved.
- No APK until review passes.

Validation:

- `flutter analyze --no-pub`
- `flutter test --no-pub`
- `flutter build apk --debug --no-pub`
- Real-device checklist after user approval.

---

## 9. What Should Be Postponed Beyond V6

Postpone these unless the user explicitly reprioritizes:

- Full digital wellbeing / screen-time integration.
- App blocking / strict phone restrictions.
- Social supervision, groups, leaderboards, self-study room.
- Cloud sync.
- Theme marketplace.
- Wallpaper/gradient/theme export.
- White noise/audio.
- Focus strict mode.
- Habit streak tokens/rewards/badges.
- Full annual multi-habit dashboard.
- Hard delete without backup/export.
- iOS IPA/TestFlight build work on Windows. iOS distribution requires macOS/Xcode/Apple Developer workflow.

---

## 10. Non-Negotiable Semantic Guardrails

These rules must stay intact through every V6 package:

- Habit quick check-in must remain one-tap and low friction.
- Detailed habit record must remain draft/save based.
- `checkIn + makeup` are the only effective habit completion record types.
- `skip` does not count as completion.
- `proof` does not count as completion.
- `note` does not count as completion.
- Makeup counts on selected `localDate`, not `createdAt`.
- Habit heatmaps/streaks use real records only.
- Pause intervals are neutral for streak and do not add completed days.
- Habit lifecycle states must not pollute Today obligations.
- Habit reminder rules must not touch Focus notification IDs.
- Habit proof images and Plan proof images must not store bytes/base64 in SharedPreferences.
- Plan records do not affect task progress.
- Plan progress remains task-derived.
- Habit-generated PlanRecords must not auto-complete tasks.
- Focus task binding must not mutate Plan tasks.
- Review must not invent digital wellbeing data or fake analytics.
- Theme Studio must remain global theme customization, separate from per-habit/per-project identity colors.
- Version bumps happen only when preparing a new phone-test build.

---

## 11. Recommended First Code Package

Recommended first package after this roadmap:

```text
V6A Habit Structured Check-in Templates + Numeric Units
```

Why this should go first:

- The user specifically asked to complete benchmark-level functions, not another visual-only pass.
- HabitDone remaining gaps now center on richer record meaning: sub-records, measurable fields, units, and calendar/table analytics.
- Plan already has numeric records, but Habits does not; this asymmetry is now one of the clearest product gaps.
- Metric analytics cannot be done honestly until metric data exists.
- This is schema-sensitive, so it must be planned and implemented before downstream charts/tables.

Recommended V6 sequence:

1. `V6A Habit Structured Check-in Templates + Numeric Units`
2. `V6B Habit Metric Analytics + Calendar Table`
3. `V6C Habit Groups + List Organization`
4. `V6D Plan Record Detail Editing + Multi-image Proof Parity`
5. `V6E Plan Project Annual Heatmap + Chart Upgrade`
6. `V6F Focus Pomodoro Modes + Weekly Focus Overview`
7. `V6G Review Weekly/Monthly Real Analytics Report`
8. `V6H Data Management + Backup/Export Foundation`
9. `V6I Benchmark Feature Completion Review`

If the next real-device feedback is primarily about Plan rather than Habits, swap V6A/V6D order. Otherwise, start with V6A.

---

## 12. Next Step Prompt Recommendation

The next safe user prompt should be:

```text
V6A Habit Structured Check-in Templates + Numeric Units is approved.
Do not code yet.
Create an implementation plan only.
```

The V6A plan should decide:

- whether structured values live inside `HabitRecord` JSON or a separate `HabitRecordMetricValue` list;
- whether a habit template supports one numeric field first or multiple fields immediately;
- whether target completion remains count-based only in V6A;
- how old records migrate;
- how detailed check-in UI stays lightweight;
- what analytics are postponed to V6B.

