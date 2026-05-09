# Benchmark Parity Gate V1

This gate defines what must be true before the next phone test build. The next test APK should not be prepared merely because another small improvement landed. It should be prepared only after the core experiences feel close to the benchmark apps in product quality, while still forming one unified app.

## Source References

The gate is based on:

- `docs/references/app_report_v2.txt`
- `docs/references/app_content/HabitDone`
- `docs/references/app_content/daymark`
- `docs/references/app_content/番茄ToDo`
- `docs/references/app_content/OffScreen`
- `docs/product_vision.md`
- `docs/ui_direction.md`
- `docs/source_ui_reference.md`
- `docs/visual_gap_audit_v1.md`
- `docs/ui_reference_components.md`
- `docs/feature_completion_checklist.md`

## Benchmark Parity Definition

For V1, "close to or better than source apps" does not mean copying screenshots or matching every advanced feature. It means the current app must pass these concrete standards:

- A new user can understand each main tab's role within 10 seconds: 今日 for daily center, 计划 for structure, 专注 for execution, 复盘 for feedback, 我的 for personalization.
- Habits must feel like repeatable daily tracking, not todo completion.
- Plan must feel like goal/project/subproject/action planning, not a plain nested list.
- Focus must feel like an execution surface with a strong timer center, not only a functional countdown.
- Review must feel like a calm data surface based on real records, not text summaries or fake analytics.
- Core flows must be low-friction on a real phone: create/edit/check in habits, set reminders, view activity, create/edit plan hierarchy, start/pause/reset focus, review progress.
- Visual quality must use shared spacing, radius, typography, tone, and accent rules so the app feels like one product.
- No major screen may show debug artifacts, overflow, unreadable labels, unclear selected states, or controls that appear functional but are fake.
- All required gates below must be validated by automated tests where practical and by a real-phone checklist before any version bump.

## HabitDone Parity Gate

Required before next phone test:

- Habit cards feel like lightweight habit tracking cards, not todo rows.
- Habit card identity is visible: emoji/icon, name, optional description, target count, reminder state, and activity cue.
- Emoji/icon quick selection exists and custom emoji input still works.
- Habit creation and editing support name, description, emoji/icon, target count per day, and reminder time.
- Multiple daily check-ins work and the same habit can exceed the target count.
- 今日 X / Y is visually obvious and easy to scan on the habit card and Today previews.
- Recent 7-day activity is count-aware and visually clear for 0 / 1 / 2 / 3+ check-ins.
- Monthly heatmap is readable on phone, does not overflow, and has clear 0 / 1 / 2 / 3+ intensity.
- Reminder picker is usable without raw HH:mm typing.
- Real daily local reminder notification is scheduled, updated, and canceled from habit reminder changes.
- Permission denial never breaks habit create/edit/check-in.
- Edit habit identity/settings preserves existing HabitRecord history.
- Habit styling is theme/accent-aware without becoming noisy or card-heavy.
- The create/edit/check-in/reminder flow feels smooth and low-friction on real phone.
- Today habit summary remains read-only and expresses habit tracking: target-reached habits, total check-ins, short previews.
- Review habit summary remains read-only and expresses real habit records.

Postponed beyond this gate:

- Photo proof.
- Skip/makeup.
- Notes.
- Streak protection.
- Archive/delete.
- Full yearly heatmap.
- Advanced reminder rules, snooze, exact alarms, and boot rescheduling.

## DayMark Parity Gate

Required before next phone test:

- Plan contains Goal / Project / Subproject / Task hierarchy.
- Goal represents long-term outcome, Project represents workstream, Subproject represents nested structure, Task/Action is the directly completable unit.
- Project/goal visual identity is clear enough that Plan does not read as a generic engineering tree.
- Parent-child progress rollup is visible and derived from task completion.
- Project, Subproject, and Task title editing works without changing ids, parent ids, createdAt, or completion state.
- Empty subproject has a clear inline 添加行动 affordance and feels useful, not dead.
- Focused goal tree / structure view shows goal, projects, subprojects, tasks, and rollup progress.
- Plan creation flows remain compact: add goal, add project, add subproject, add action.
- Today expresses planning progress using planning language, not checklist completion.
- Review expresses planning progress with factual hierarchy metrics and task-derived progress.
- Plan stays readable on phone through indentation, structure labels, progress text, and restrained surfaces.

Postponed beyond this gate:

- Due dates.
- Priorities.
- Tags.
- Filters/search.
- Milestones.
- Archive/delete.
- Full project history/statistics page.
- Infinite nesting.
- Plan reminders.

## 番茄ToDo Parity Gate

Required before next phone test:

- Focus page has a large visual timer center that is unmistakably the main object.
- Custom duration works and persists as designed.
- Countdown restores after app kill/relaunch.
- Paused and running sessions restore correctly.
- If a running session elapsed while killed, exactly one completed session is recorded using intended target end time.
- Completed focus history is stored and reflected in Review.
- Completion notification is scheduled and does not depend on the app being open.
- Start / Pause / Continue / Reset hierarchy is visually clear.
- Notification copy is truthful about Android limitations.
- Android small system chronometer countdown remains dynamic where supported.
- A task/plan binding design decision is documented and ready for implementation.
- At least one V1 execution improvement beyond plain countdown is implemented or explicitly justified as deferred with a stronger timer center and reliable history.

Can postpone to V2:

- True Android foreground service.
- Exact alarm permissions.
- Boot rescheduling.
- Strict mode.
- White noise.
- Count-up timer.
- Full pomodoro work/break system if the V1 execution improvement is chosen differently.
- Interruption tracking.
- Deep weekly focus overview.

Android notification honesty:

- Flutter local notifications can show an Android chronometer/countdown in the system time area, but normal notification body text is static unless actively updated or implemented natively.
- V1 must not pretend a static body is live.
- Larger/main countdown notification behavior may require a native bridge or foreground-service style complexity and should be separately planned before implementation.

## OffScreen Parity Gate

### Review/Data Parity Required Before Next Phone Test

- Review uses large key metrics for available real data.
- Review uses calm data panels instead of plain text blocks.
- Review shows habit activity summary from HabitRecord data.
- Review shows plan progress summary from Goal / Project / Subproject / Task data.
- Review shows focus completion summary from stored focus sessions.
- Review clearly handles zero-data states without fake 0% failure.
- Review remains fully read-only.
- Today and Review share a calm metric language and do not become dense dashboards.
- No fake analytics, fake trends, fake charts, or unavailable digital wellbeing data are shown.

### Digital Wellbeing V2 Scope

Not required for the next phone test:

- Screen time.
- Pickup count.
- App usage ranking.
- App limits.
- Sleep/bedtime phone use.
- Focus restrictions.
- Digital wellbeing permissions.
- Platform-specific screen behavior integrations.

Digital wellbeing must not be marked done until real platform data and permission flows exist.

## Unified App Rule

The app must not become four separate apps stitched together. It must use one shared product loop:

- 今日 is the daily center: what matters today, what is waiting, what needs attention.
- 计划 is the structure layer: goals, projects, subprojects, actions, and progress.
- 专注 is the execution layer: a reliable timer that should later bind to actions.
- 复盘 is the feedback layer: real records, calm metrics, and honest reflection.
- 我的 is the personalization/settings layer: appearance, reminders, privacy, backup/export, version.

Unification rules:

- Use common visual tokens for spacing, radius, border tone, typography, surface tone, and accent behavior.
- Use consistent Chinese product language: habits are 打卡/今日 X / Y, plan is 目标/项目/子项目/行动/推进, focus is 专注/时长/完成, review is 回看/进展/记录.
- Use Today as the cross-feature entry point without turning it into a full dashboard.
- Use Review as the cross-feature feedback layer without fake analytics.
- Keep feature depth in feature pages, not in Today.
- Keep interactions compact and phone-first.
- Prefer soft, low-saturation surfaces over heavy cards, heavy shadows, dense charts, or admin dashboard layouts.

## No Phone Test Gate

No version bump and no phone-test APK until:

- All items marked required before next phone test in this document are complete.
- The five packages in `docs/benchmark_parity_roadmap.md` are implemented or explicitly re-scoped with approval.
- `flutter analyze --no-pub` passes.
- `flutter test --no-pub` passes.
- `flutter build apk --debug --no-pub` passes.
- A real-phone smoke checklist confirms Habits, Plan, Focus, Review, Today, and My core flows.
- The user explicitly approves preparing the next phone test build.

