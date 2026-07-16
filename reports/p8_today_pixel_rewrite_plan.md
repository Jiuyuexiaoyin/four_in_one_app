# P8 Today Pixel Rewrite Plan

## Scope

Rewrite only:

- `lib\features\today\presentation\pages\today_page.dart`

Tests may be updated only where they assert removed Today structure:

- `test\today_overview_test.dart`
- `test\app_smoke_test.dart`
- `test\habits_flow_test.dart`

No changes to HabitsPage, GoalsPage, FocusPage, SettingsPage, ReviewPage, AppShell, stores, models, storage, versioning, or APK flow.

## 1. Old Today Sections To Remove

Remove the visible sections that are not in the exported Stitch Today screen:

- `_TodayHabitsBand`
- `_PlanSnapshot`
- `_FocusSnapshot`
- `StitchExactUtilityRow` / visible `今日回看` utility row
- old post-Action-Plan snapshot stack
- dependency on the broad `lib\shared\widgets\stitch_exact\stitch_exact.dart` component set from the Today page

Do not keep the old rejected structures:

- `今天，先推进一件事`
- `Strategic Command`
- `Flow Status`
- `System Control`
- generic previous snapshot bands after the Action Plan

## 2. Exact Stitch Today Sections To Implement

Implement the exported section order from:

`.ai_reference\stitch\export_20260708\stitch_app\stitch_app\final_synthesis_2\code.html`

Sections:

1. Mobile-style top bar inside the Today scroll canvas:
   - back chevron
   - `今日 / TODAY`
   - compact round profile/review/settings action
2. Focus Score hero:
   - `FOCUS SCORE`
   - large numeric score with `%`
   - current local date in exported compact date style
3. Peak Rhythm insight card:
   - toxic-green left rail/dot
   - `PEAK RHYTHM`
   - real-data rhythm sentence
4. Momentum Metrics:
   - three circular metric blocks
   - `COMPLETION` / `今日习惯`
   - `VELOCITY` / `计划推进`
   - `STREAK` / `连续`
5. Priority Execute card:
   - `PRIORITY EXECUTE`
   - time chip
   - priority title
   - subtitle
   - duration chip
   - `开始执行 / INITIATE` button
6. Focus Flux:
   - `FOCUS FLUX`
   - `OPTIMUM RANGE`
   - grid-backed line chart
   - `08:00`, `12:00`, `16:00`, `20:00`, `THRESHOLD`
7. Action Plan:
   - three timeline rows when real data is available
   - cadence bars and round action buttons
8. Bottom spacing:
   - preserve enough bottom padding for the existing Flutter `AppShell` bottom navigation
   - do not duplicate AppShell navigation inside Today

## 3. Real Data Bindings

### Habit Completion

Use:

- `HabitsStore.habits`
- `HabitsStore.completedCount`
- `HabitsStore.totalCount`
- `HabitsStore.isCompletedToday`
- `HabitsStore.todayCheckInCount`

Binding:

- Completion ring progress = `completedCount / totalCount`
- Completion center = real completed percentage
- Pending habits in Action Plan = active habits not completed today

### Total Check-ins

Use:

- `HabitsStore.totalCheckInsToday`

Binding:

- Included in the Focus Score composition and Peak Rhythm sentence.
- Preserved in tests via Today metric semantics, not as an old standalone habit panel.

### Plan / Action Count

Use:

- `GoalsStore.tasks`
- `GoalTaskItem.isCompleted`

Binding:

- Velocity ring progress = completed actions / total actions.
- Priority Execute title uses the first open plan action when available.
- Action Plan rows prioritize real open actions before pending habits.

### Focus Minutes

Use:

- `FocusStore.sessions`
- `FocusSessionItem.completedAt`
- `FocusSessionItem.durationSeconds`
- `FocusStore.selectedDurationSeconds`
- `FocusStore.formattedRemaining`
- `FocusStore.status`

Binding:

- Focus Score composition includes today's completed focus minutes against selected duration.
- Priority duration chip uses selected focus duration.
- Focus Flux line includes recent focus session counts.
- Empty Action Plan fallback navigates to Focus and shows the current focus state.

### Pending Habit / Action

Use:

- first open `GoalTaskItem` as top priority
- first pending `HabitItem` when no open plan action exists

Binding:

- Priority Execute title/subtitle/action come from the selected real priority.
- Action Plan rows include up to three real rows from open actions and pending habits.

## 4. Real Actions

Preserve:

- Navigate to habits: Action Plan habit rows / habit action buttons use `AppRoute.habits` or real check-in where appropriate.
- Navigate to plan: plan-action rows and Priority Execute for plan items use `AppRoute.goals`.
- Navigate to focus: empty/focus fallback and focus-oriented action use `AppRoute.focus`.
- Access review if currently required: top-right review/action icon uses `AppRoute.review`; no separate exported-nonmatching review band.
- Settings access remains available through the compact profile/settings icon if needed by current shell behavior.
- Habit check-in remains real through `HabitsStore.checkIn(habit.id)` for pending habit action buttons.

## 5. What Must Not Be Faked

Do not hardcode:

- Focus score
- habit completion
- total check-ins
- plan/action progress
- focus minutes
- pending habit/action names
- Action Plan real rows when store data exists

Allowed visual fallbacks:

- Empty-state copy when no real actions/habits exist.
- Generated row times (`09:00`, `11:30`, `14:00`) only as visual slots, matching the Stitch timeline format; they are labels, not claimed schedule data.
- Static axis labels in Focus Flux because the export uses visual time anchors.

## 6. Exact Files To Modify

Primary implementation:

- `lib\features\today\presentation\pages\today_page.dart`

Reports:

- `reports\p8_today_stitch_source_audit.md`
- `reports\p8_today_pixel_rewrite_plan.md`
- `reports\p8_today_pixel_proof_report.md`

Tests, only if required by changed Today structure:

- `test\today_overview_test.dart`
- `test\app_smoke_test.dart`
- `test\habits_flow_test.dart`
