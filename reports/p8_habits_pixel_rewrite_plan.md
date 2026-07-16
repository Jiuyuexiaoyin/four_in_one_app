# P8 Habits Pixel Rewrite Plan

## Scope

Modify only:

- `lib\features\habits\presentation\pages\habits_page.dart`

Reports:

- `reports\p8_habits_stitch_source_audit.md`
- `reports\p8_habits_pixel_rewrite_plan.md`
- `reports\p8_habits_pixel_proof_report.md`

No changes to:

- `lib\features\today\presentation\pages\today_page.dart`
- Goals, Focus, Settings, Review pages
- AppShell
- stores, models, storage, version, APK flow

## Old Habits Sections To Remove From Visible Flow

Remove or stop rendering these non-exported page-level sections:

- `_HabitsListHeader`
- `_HabitsStitchExactStats`
- `_HabitsActivityMatrix`
- `_HabitInsightPreview`
- `_RecentRecordPreview`

Do not remove the supporting record/statistics dialogs and sheets:

- `_HabitRecordSheet`
- `_HabitStatisticsSheet`
- `_HabitRecordAttachmentSheet`
- monthly activity dialog
- reminder picker
- lifecycle sheet
- habit form dialog

## New Stitch Habits Sections To Implement

Reference:

- `.ai_reference\stitch\export_20260708\stitch_app\stitch_app\scale_proportion_refinement\code.html`

Visible page order:

1. Header:
   - cyan bolt
   - `STRIVE`
   - right-side create habit control
2. `系统完整性 (SYSTEM INTEGRITY)` card:
   - `每日准备就绪`
   - large real readiness percent
   - cognitive-load progress rail
   - three metric blocks
3. `当前节奏 (CURRENT CADENCE)` card:
   - cyan pulse dot
   - current pending habit title
   - description
   - target count and completed-today count
   - `完成 (COMPLETE)` action
   - add habit secondary action if needed
4. `每日节奏 (DAILY RHYTHM)` card:
   - real weekly rhythm percent
   - seven bars labeled `一 二 三 四 五 六 日`
5. `活跃协议 (ACTIVE PROTOCOLS)` section:
   - protocol-style cards for real habits
   - icon tile
   - title and subtitle
   - real streak/today metric
   - seven rhythm dots
   - preserved action row for check-in, reminder, edit, lifecycle, records, month rhythm, statistics
6. Bottom spacing:
   - enough padding for existing `AppShell` bottom nav
   - do not duplicate bottom navigation inside Habits

## Real HabitsStore Data Bindings

Use:

- `HabitsScope.of(context)`
- `HabitsStore.habits`
- `HabitsStore.pausedHabits`
- `HabitsStore.archivedHabits`
- `HabitsStore.completedCount`
- `HabitsStore.totalCount`
- `HabitsStore.remainingCount`
- `HabitsStore.totalCheckInsToday`
- `HabitsStore.todayCheckInCount(habit)`
- `HabitsStore.isCompletedToday(habit)`
- `HabitsStore.isSkippedToday(habit)`
- `HabitsStore.recentActivityDays(habit)`
- `HabitsStore.currentMonthActivity(habit)`
- `HabitsStore.recordsForHabit`
- `HabitsStore.templatesForHabit`
- existing reminder, lifecycle, record, attachment, and statistics APIs

Data mappings:

- System Integrity percent = real completed active habits / active habit count.
- Recovery metric = real completed active habits.
- Strain metric = real remaining active habits.
- Sleep visual slot = real total check-ins today, documented as a local mapping because no sleep source exists.
- Current Cadence = first active habit not completed today.
- Daily Rhythm = real recent weekly check-in totals.
- Protocol streak slot = real recent active days or today count/target where appropriate.

## Real Actions Preserved

Preserve:

- Create habit: `_showCreateHabitDialog`
- Edit habit: `_showEditHabitDialog`
- Check-in: `HabitsStore.checkIn`
- Reminder settings: `_showReminderPicker`
- Lifecycle controls: `_showHabitLifecycleSheet`
- Record details: `_showHabitRecordSheet`
- Statistics: `_showHabitStatisticsSheet`
- Monthly activity: `_showMonthlyActivityDialog`
- Plan link selection through lifecycle sheet
- Attachment proof flow inside record sheets

Do not delete tests.

## Exact Files To Modify

Implementation:

- `lib\features\habits\presentation\pages\habits_page.dart`

Reports:

- `reports\p8_habits_stitch_source_audit.md`
- `reports\p8_habits_pixel_rewrite_plan.md`
- `reports\p8_habits_pixel_proof_report.md`

Tests only if the Habits page structure requires expectation updates. Prefer preserving existing keys and visible text to avoid broad test churn.
