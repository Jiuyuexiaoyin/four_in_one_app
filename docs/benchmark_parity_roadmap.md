# Benchmark Parity Roadmap

This roadmap lists the required implementation packages before the next phone test. It replaces the earlier pattern of shipping small incremental test APKs. The next test build should happen only after Benchmark Parity V1 gates are complete enough to make the app feel like a unified four-in-one product.

## Package A: Habits Benchmark Repair V2

Source references:

- `docs/references/app_content/HabitDone`
- `docs/references/app_content/OffScreen`
- `docs/references/app_report_v2.txt`

Scope:

- Make habit cards feel decisively like HabitDone-style habit tracking.
- Strengthen emoji/name/description/target/reminder/activity hierarchy.
- Make 今日 X / Y and 打卡 action visually immediate.
- Improve reminder picker path and permission-denied messaging if still unclear on device.
- Validate real daily reminder scheduling on Android device.
- Improve monthly heatmap readability and phone fit.
- Preserve existing multiple check-ins, records, edit flow, reminders, Today summary, and Review summary.

Files likely to change:

- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/habits/application/habits_store.dart` only if reminder interaction safety requires it.
- `lib/features/habits/data/habit_reminder_notification_service.dart` only for confirmed reminder scheduling/copy defects.
- `test/habits_flow_test.dart`
- `test/habits_reminder_notifications_test.dart`
- `docs/feature_completion_checklist.md`

Acceptance criteria:

- On phone, habit cards read as repeatable habit tracking, not todo rows.
- User can create a habit with defaults in under 20 seconds.
- User can choose preset emoji or type custom emoji.
- User can set and clear reminder from the card/edit flow without raw typing.
- Reminder scheduling, updating, canceling, and permission denial are tested.
- Monthly heatmap has no overflow and 0 / 1 / 2 / 3+ levels are visually distinct.
- Existing HabitRecord history is preserved after edits.

Must not change:

- Routing.
- HabitItem schema.
- HabitRecord schema.
- Goals behavior.
- Focus timer/notification behavior.
- Review behavior except required copy/test alignment.
- Dependencies.
- Version.
- Photo proof, notes, skip/makeup, streak, archive/delete, yearly heatmap.

## Package B: Plan Benchmark Repair V2

Source references:

- `docs/references/app_content/daymark`
- `docs/references/app_content/OffScreen`
- `docs/references/app_report_v2.txt`

Scope:

- Make Plan feel like DayMark-style planning rather than an engineering tree.
- Strengthen goal/project visual identity using existing accent/theme tokens.
- Improve PlanGoalCard and PlanTreeView hierarchy, progress labels, and focused structure view.
- Keep project/subproject/task edit flows usable and compact.
- Make empty project/subproject cues clearly actionable.
- Prepare design for later task-bound focus without implementing it here unless explicitly approved.

Files likely to change:

- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/goals/application/goals_store.dart` only if title-edit safety needs minor store support.
- `test/goals_flow_test.dart`
- `test/today_overview_test.dart` only if visible copy changes.
- `docs/feature_completion_checklist.md`

Acceptance criteria:

- On phone, each goal reads as a planning object, not a checklist item.
- Project/action/subproject hierarchy is readable without feeling dense.
- Project, subproject, and task edit works and preserves progress.
- Empty subproject clearly invites adding an action.
- Focused structure view feels like a usable goal tree view, not a read-only debug panel.
- Parent progress remains derived from task completion.

Must not change:

- Routing.
- Goal / Project / Subproject / Task schema unless explicitly approved.
- Habits behavior.
- Focus behavior.
- Review behavior except visible wording required by Plan expression.
- Dependencies.
- Version.
- Due dates, priorities, tags, filters/search, milestones, reminders, archive/delete, full statistics/history page.

## Package C: Focus Benchmark Repair V2

Source references:

- `docs/references/app_content/番茄ToDo`
- `docs/references/app_content/OffScreen`
- `docs/references/app_report_v2.txt`

Scope:

- Make Focus feel like the execution layer, not only a timer.
- Strengthen FocusTimerHero with a large central timer, clear state, and clear control priority.
- Keep current restore/history/notification behavior reliable.
- Decide and document the minimum V1 task/plan binding path.
- Add one bounded execution improvement only if it is clearly required for parity, such as task selection for a focus round or a simple pomodoro work/break mode.
- Be honest about Android notification limitations.

Files likely to change:

- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/focus/application/focus_store.dart` only if a required bounded execution improvement needs state.
- `lib/features/focus/data/focus_local_storage.dart` only if state persistence must be extended and approved.
- `test/focus_flow_test.dart`
- `docs/feature_completion_checklist.md`

Acceptance criteria:

- On phone, timer is the unmistakable visual center.
- Start, pause, continue, and reset hierarchy is clear.
- Custom duration, restore after kill, elapsed-while-killed completion, and history still pass tests.
- Completion notification behavior remains intact.
- Any V1 execution improvement is bounded, tested, and does not introduce platform-heavy complexity.
- If larger notification countdown is postponed, the limitation and future path are documented.

Must not change:

- Routing.
- Habits behavior.
- Plan behavior except future binding interfaces if explicitly approved.
- Review behavior except read-only use of existing focus data.
- Dependencies unless separately approved.
- Version.
- Foreground service, exact alarms, boot receiver, notification actions, strict mode, white noise, deep analytics, digital wellbeing.

## Package D: Review Data Visual V2

Source references:

- `docs/references/app_content/OffScreen`
- `docs/references/app_content/HabitDone`
- `docs/references/app_content/daymark`
- `docs/references/app_report_v2.txt`

Scope:

- Make Review feel like a calm data feedback page using existing real data.
- Add stronger large metrics for habits, plan, and focus.
- Use soft data panels and simple real-data visuals without chart packages.
- Represent habit activity, plan action progress, and focus completion history honestly.
- Improve zero-data states so they are calm and not misleading.
- Keep Review fully read-only.

Files likely to change:

- `lib/features/review/presentation/pages/review_page.dart`
- `test/review_overview_test.dart`
- `docs/feature_completion_checklist.md`

Acceptance criteria:

- On phone, Review no longer feels like plain text blocks.
- Habit summary uses real check-ins and activity.
- Plan summary uses real hierarchy counts and completed actions.
- Focus summary uses real completed session history.
- No fake charts, fake trends, or digital wellbeing data appear.
- Zero-data states do not show forced failure-like 0% progress.

Must not change:

- Routing.
- Store/model/schema.
- Persistence.
- Habits, Plan, or Focus behavior.
- Dependencies.
- Version.
- Charts package, fake analytics, screen-time panels, digital wellbeing implementation.

## Package E: Unified UI Component System V2

Source references:

- `docs/references/app_content/HabitDone`
- `docs/references/app_content/daymark`
- `docs/references/app_content/番茄ToDo`
- `docs/references/app_content/OffScreen`
- `docs/ui_reference_components.md`

Scope:

- Consolidate repeated source-inspired UI patterns into app-native components after Packages A-D stabilize.
- Normalize TodayHero, DailyMetricStrip, HabitIdentityCard, HabitMiniHeatmap, HabitMonthHeatmap, PlanGoalCard, PlanTreeView, FocusTimerHero, ReviewMetricPanel, and MySettingsSection where useful.
- Keep the five tabs visually unified through shared tokens, copy rhythm, and accent treatment.
- Reduce generic Flutter card-stack feeling.
- Improve phone fit, touch targets, and dark/light consistency.

Files likely to change:

- `lib/app/theme/app_theme_tokens.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- Optional shared widgets under `lib/shared/widgets/` if a pattern is repeated and stable.
- Existing widget tests only where selectors/copy change.

Acceptance criteria:

- On phone, the app feels like one product across 今日 / 计划 / 专注 / 复盘 / 我的.
- Components share spacing, radius, border tone, typography, and accent behavior.
- HabitDone, DayMark, Tomato ToDo, and OffScreen traits are visible but not copied literally.
- No page becomes card-heavy, noisy, or dashboard-like.
- Current interactions remain intact.

Must not change:

- Routing.
- Business logic.
- Store/model/schema.
- Persistence.
- Dependencies unless separately approved.
- Version.
- New feature scope beyond UI system consolidation.

## Required Validation Before Next Phone Test

Before version bump:

- Complete Packages A-E or explicitly mark any item as postponed with approval.
- Run `flutter analyze --no-pub`.
- Run `flutter test --no-pub`.
- Run `flutter build apk --debug --no-pub`.
- Perform real-phone validation for Habits, Plan, Focus, Review, Today, My, and persistence.
- Confirm no debug overflow, unreadable labels, broken selected states, or fake functionality.
- Confirm notification behavior for habit reminder and focus completion on a real Android device.
- Only then update version and package the next phone-test APK.

## No Phone Test Rule

No version bump and no phone-test APK until all Benchmark Parity V1 gates marked required before test are complete and validated. Normal development work should continue without version changes.

