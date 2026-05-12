# Feature Completion Checklist

This checklist is a guardrail for product completeness. Do not treat an MVP scaffold, placeholder, field-only implementation, or minimal technical proof as true V1 completion.

Status values:

- `done`: implemented, usable, persisted where needed, and reflected in the relevant UI.
- `partial`: present but incomplete, minimal, field-only, or not yet fully productized.
- `not started`: no meaningful product implementation yet.

## V6 Full-Pass Closure

Status: `done`. V6A through V6H are complete for the current full-pass scope and have passed validation through the only approved entry:

```powershell
.\tooling\v6b.cmd
```

Confirmed validation results:

- V6B read-only validation completed.
- focused goals tests passed.
- targeted analyze passed.
- full analyze passed.
- full tests passed: 172 tests.

Version remains `1.1.2+14`.

No version bump, phone-test APK preparation, `flutter build apk`, `pubspec.yaml` / dependency change, or Android/iOS native change was made.

V6C-V6H completion summary:

- V6C: read-only Plan timeline, project activity charts, and year heatmap from existing PlanRecord data.
- V6D: Focus weekly overview on FocusPage.
- V6E: Review focus activity strip.
- V6F: Settings data summary from existing app stores.
- V6G: digital wellbeing research completed as docs-only.
- V6H: final benchmark review updated.

Semantic guardrails confirmed:

- PlanRecord schema and semantics untouched.
- PlanRecord note/numeric/image/source semantics untouched.
- Plan progress semantics untouched.
- task completion semantics untouched.
- Habit -> Plan linking semantics untouched.

Human review focus before any future release step:

- `FocusPage` migration from `ListView` to `SingleChildScrollView` + `Column`.
- `goals_page.dart` read-only V6C timeline/chart/year activity display.
- `goals_store` / `goal_item` derived statistics helpers.
- `tooling\validate_v6b.ps1` remains a forbidden historical script.

Do not automatically enter APK, bump version, or start a new development package. Confirm the next scope with the user first.

## App Personalization / Theme Studio

| Item | Status | Notes |
| --- | --- | --- |
| Global UI accent color | done | The existing `界面强调色` behavior is preserved and now accepts preset, HEX, RGB, and ARGB custom colors stored as nullable ARGB ints. |
| Global background color | done | Users can choose a global page background color; null falls back to the current theme token and custom colors are softly blended for light/dark readability. |
| Global card/surface color | done | Users can choose a global card/surface color for panels and bottom sheets; null falls back to the current theme token and malformed values are ignored safely. |
| Theme Studio preview/reset | done | Settings includes a `颜色工作室` with live preview, dependency-free saturation/brightness picker, hue slider, grouped palette boards, collapsed advanced HEX/RGB/ARGB input, per-target reset, global reset, and invalid-input/readability guardrails. |
| Advanced theme system | partial | Wallpaper images, gradient editor, color wheel, custom fonts, per-page themes, theme marketplace, and export/import remain postponed. |

## Product UI / Responsive Polish

| Item | Status | Notes |
| --- | --- | --- |
| Full UI polish pass | done | Shared metric cards, product headers, settings rows, Habit cards, Plan image-proof copy, and main page smoke coverage were tightened for calmer hierarchy and better small-phone resilience without changing business logic. |
| Benchmark visual system reset | done | V5H reduced chip/border noise, softened card weight, strengthened primary/secondary hierarchy, refined Today/Habit/Plan/Focus/Settings surfaces, and preserved existing behavior/data semantics. |
| Responsive layout guardrails | done | Today, Plan project detail, Habit statistics/annual heatmap, Theme Studio, and main feature pages have 360dp/text-scale coverage; 393dp and 412dp coverage remains in focused Today/Plan/Theme tests. |

## HabitDone-Inspired Habits V1

| Item | Status | Notes |
| --- | --- | --- |
| Lightweight habit list | done | Habits page lists habits as habit cards. |
| Emoji/icon | done | Habit identity includes emoji/icon. |
| Description | done | Habit identity includes description. |
| Target count per day | done | Completion is computed from target count. |
| Multiple daily check-ins | done | Same habit can be checked in multiple times per day. |
| Record-based check-ins | done | `HabitRecord` stores check-in records. |
| Check-in notes | done | Detailed habit records can include an optional note while one-tap check-in remains available. |
| Skip / no-check record | done | Habits can store a skip record for a local date; skip does not count toward completion. |
| Makeup check-in | done | Makeup records apply to the selected local date and count toward that date's target. |
| Recent 7-day activity | done | Habit cards show a lightweight count-aware 7-day activity strip. |
| Month/heatmap-like activity view | done | Current-month, per-habit recent 3-month, and current-year annual heatmap views exist; multi-habit yearly dashboards are postponed. |
| Per-habit statistics | done | Each habit has a lightweight statistics bottom sheet with completion days, current/longest streak, effective check-ins, skip/makeup counts, proof count, tracked-day completion rate, visual completion distribution bars, recent 3-month activity, annual activity with clearer legend/month labels, and date-grouped record history from real records. |
| Reminders field | done | Habits support up to 3 reminder rules with time, weekday selection, and enable/disable state; legacy `reminderTime` migrates to one all-week rule. |
| Reminders local notification | done | Enabled reminder rules schedule daily or weekly local notifications; paused, archived, and soft-deleted habits cancel reminder IDs. Snooze, exact alarms, boot rescheduling, and missed-check-in logic are postponed. |
| Theme/accent-aware styling | done | Habit cards use current global accent/background/surface tokens while preserving per-habit color identity. |
| Per-habit color identity | done | Each habit can optionally choose a low-saturation `习惯颜色`; null follows the global `界面强调色`. Habit cards, activity strips, month heatmap, and statistics accents derive from the habit color without changing record semantics. |
| Edit habit identity/settings | done | Existing habits can edit emoji, name, description, target count, and reminder field without resetting records. |
| Photo proof | done | Habit record history supports up to 3 proof images per record, gallery selection, camera capture, preview, replace, remove, and safe missing-file states; video, crop/compression, reorder, and media dashboard are postponed. |
| Habit-to-Plan link | done | A habit can link to one Plan Project or Task; reaching the daily target creates one sourced Plan note record for that habit/date without completing Plan tasks. |
| Streak / continuous days | done | Current and longest streak are derived from effective check-in days using the habit target count; paused local-date intervals are neutral and do not add completed days. |
| Streak protection | partial | Pause-aware streak protection is implemented with persisted pause intervals; skip protection, tokens, rewards, and streak recovery items are postponed. |
| Archive/delete | partial | Habits support pause, archive/restore, and soft delete while preserving records/proof; hard delete and deleted-habit data management remain postponed. |
| Today habit summary | done | Today shows completed habits, total habits, total check-ins, and short previews. |
| Review habit summary | done | Review shows today's target-reached habits, total check-ins including makeup, completion rate, and recent record-based activity; skip records are not counted as check-ins. |

## DayMark-Inspired Goals V1

| Item | Status | Notes |
| --- | --- | --- |
| Long-term goal | done | Goal now represents a long-term outcome with persisted `createdAt`. |
| Project under goal | done | Projects can be created and shown under goals in the in-page hierarchy. |
| Goal/project identity | done | Goals and projects support editable icon/emoji, color identity, title, and description; advanced grouping/settings are postponed. |
| Subproject or nested layer | done | One lightweight Subproject/Section layer exists under projects. |
| Task/action under project/subproject | done | Tasks/actions can be created and shown under projects. |
| Project/action due dates | done | V6B adds persisted local-date due dates to Plan Projects and Tasks/Actions, with due-today and overdue helpers that do not change completion, progress, records, or Review semantics. Validated through `.\tooling\v6b.cmd`. |
| Project/action priority | done | V6B adds optional persisted `low` / `medium` / `high` / `urgent` priority to Plan Projects and Tasks/Actions for display, filtering, and sorting only; null remains normal/no explicit priority. |
| Project/action tags | done | V6B adds sanitized free-text tags to Plan Projects and Tasks/Actions, capped and deduplicated without introducing a global tag registry. |
| Plan search/filter/sort | done | V6B adds a read-only Plan search/filter/sort surface with flat contextual results when active; the canonical hierarchy remains unchanged. Final V6 full-pass validation passed focused goals tests, targeted analyze, full analyze, and 172 full tests through `.\tooling\v6b.cmd`. |
| Task is directly completable unit | done | Tasks are the only directly completable unit in the Goals UI. |
| Parent-child progress rollup | done | Project and goal progress are derived from child tasks and shown in the hierarchy UI. |
| Hierarchy/tree-like UI | done | In-page Goal -> Project -> Subproject -> Task hierarchy is visible and usable. |
| Goal detail view | done | A focused structure bottom sheet shows goal, projects, subprojects, tasks, and rollup progress. |
| Project/action records | partial | `PlanRecord` supports note, numeric, and one-image proof attachments under projects and tasks; V5D adds a project detail surface with a phone-readable records table, source chips, image indicators, and UI-only filters. Richer record types are postponed. |
| Habit-generated Plan records | done | Linked habit daily completions create traceable `PlanRecord` notes with habit source metadata and duplicate prevention; task completion/progress remains task-derived. |
| Date-based project history | partial | Project sections and the project detail sheet show local-date grouped record history/table rows for notes, numeric logs, image proof, action context, and habit-generated records; V6C adds a read-only recent activity timeline from existing PlanRecord data. A full standalone history page is postponed. |
| Project statistics foundation | partial | Project detail shows project identity, parent goal context, task-derived progress, subproject/action/completed counts, habit-generated record count, record count, active days, current-month records, photo count, record composition bars, current-month heatmap, V6C read-only year activity / month chart surfaces, and scan-friendly numeric totals grouped by unit; external chart packages and deeper analytics are postponed. |
| Today goal/project summary | done | Today shows read-only planning metrics and previews from goals, projects, subprojects, and actions. |
| Review goal progress summary | done | Review shows hierarchy counts and action progress derived from task completion. |

## Focus Inspired By 番茄ToDo

| Item | Status | Notes |
| --- | --- | --- |
| Countdown | done | Focus timer supports countdown. |
| Custom duration | done | Fixed and custom durations are supported. |
| Restore after app kill | done | Active focus session state is persisted and restored. |
| Local notification | done | Focus active/completion notifications exist. |
| Dynamic Android notification small countdown | done | Android chronometer countdown fields are used. |
| Focus history | done | Completed focus sessions are recorded locally. |
| Focus weekly overview | done | V6D adds a read-only weekly ActivityStrip and MetricStrip on FocusPage using existing focus session history. |
| Pomodoro mode | not started | No work/break cycle mode yet. |
| Count-up timer | not started | Countdown only. |
| Strict mode | not started | No strict focus mode. |
| White noise | not started | No audio/white noise features. |
| Interruption tracking | not started | No interruption tracking. |
| Binding to task/goal/habit | partial | Focus sessions can bind to a Plan Task/Action snapshot; direct goal/habit binding is postponed. |

## OffScreen-Inspired Digital Wellbeing

| Item | Status | Notes |
| --- | --- | --- |
| Screen time | not started | No screen time data integration. |
| Pickup count | not started | No pickup count tracking. |
| App usage ranking | not started | No app usage ranking. |
| Bedtime/sleep phone use | not started | No bedtime phone-use tracking. |
| App limits | not started | No app limits. |
| Focus restrictions | not started | No app blocking/restriction behavior. |
| Digital wellbeing report | not started | No digital wellbeing analytics/report yet. |
| Digital wellbeing research | done | V6G completed docs-only research. No phone usage data, native permission, dependency, or product implementation was added. |
