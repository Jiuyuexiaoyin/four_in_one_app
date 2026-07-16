# P8 Displayed Data Synchronization Audit

Date: 2026-07-12

## Rebuild architecture

`HabitsStore`, `GoalsStore`, `FocusStore`, and `AppSettingsStore` are `ChangeNotifier`s exposed through `InheritedNotifier` scopes. Today and Review call all three feature scopes in `build`, so Store notifications invalidate their derived metrics. `FourInOneApp` listens to `AppSettingsStore` with `AnimatedBuilder` and rebuilds `MaterialApp` without an app restart.

Habits and Goals notify before persistence. Focus originally notified an idle/completed UI before inserting history; that race is addressed in this phase. No persistence-schema or domain-model change is required.

## Display mapping

| Page / display | Store source | Exact calculation | Rebuild trigger | Empty behavior | Stale / hardcoded risk |
| --- | --- | --- | --- | --- | --- |
| Today habit ring/count | Habits | `completedCount / totalCount`, `totalCheckInsToday` | Habits notification | `0%`, `0/0` | Correct active-habit semantics |
| Today plan ring | Goals | completed tasks / all tasks | Goals notification | `0/0` | Global rather than today-filtered |
| Today focus minutes | Focus | sessions completed on `HabitsStore.currentDayKey`; per-session whole minutes | Focus notification | `0m` | Sessions under 60s display 0m |
| Today score | All three | 42% habit + 34% plan + 24% focus against selected duration | Any Store notification | 0 | Heuristic and selected-duration denominator are product assumptions |
| Today continuity ring | Habits | recent active days / 7 | Habits notification | 0/7 | Label says continuity, not strict consecutive streak |
| Today trend | Habits + Focus | seven-day counts added by index | Habits/Focus notification | zero series | Confirmed opposite-order defect; time-axis labels were fake |
| Today priority/status | Goals/Habits/Focus | first open task, else pending habit, else Focus | Any Store notification | Focus fallback | Baseline displayed fixed fake schedule times |
| Habits system integrity | Habits | current active totals and completion | Habits notification | zero state | Live |
| Habits current cadence | Habits | first pending active habit | Habits notification | no pending habit | Disabled hero action needs explanation |
| Habits daily rhythm | Habits | `recentActivityDays` totals | Habits notification | zero bars | Oldest→today data was labelled Monday→Sunday |
| Habit card state | Habits | current-day records, target, skip, lifecycle | Habits notification | no record / inactive | Inactive action label incorrect for archived habits |
| Habit statistics/heatmaps | Habits | record-derived statistics, attachments, numeric metrics | Habits notification | explicit empty copy | No placeholder values found |
| Plan overview | Goals | goals/tasks/records and completed ratio | Goals notification | zero metrics | “Today” wording summarizes all actions |
| Plan/Project/Subproject progress | Goals | `computeGoalProgress`, `computeProjectProgress`, `computeSubprojectProgress` | Goals notification | explicit no-action state | Live |
| Plan records/charts/heatmaps | Goals | real grouped/numeric records | Goals notification / sheet `AnimatedBuilder` | explicit empty copy | No placeholder values found |
| Focus status/progress | Focus | status, remaining, active duration | timer/command notification | idle full duration | Live |
| Focus weekly metrics | Focus | ISO-week session counts/minutes/day counts | Focus notification | zero values | Correct Monday→Sunday order |
| Focus score | Focus | weekly minutes / 300 minutes | Focus notification | 0 | Hardcoded 300-minute heuristic |
| Focus heatmap | Focus | last 28 days of completed sessions | Focus notification | zero cells | Real history |
| Focus target | Goals + Focus | incomplete tasks mapped to snapshots | either Store scope | explicit no-target | Selected idle snapshot can become stale after task completion/rename |
| Review habit metrics | Habits | active totals/current-day/recent activity | Habits notification | explicit empty text | Recent strip ordering was reversed; paused/archived history excluded |
| Review plan metrics | Goals | global counts and task completion ratio | Goals notification | explicit zero state | Live |
| Review focus metrics | Focus | total sessions/minutes and latest target | Focus notification | explicit empty state | Baseline completion race briefly exposed stale history |
| Settings theme values | Settings | theme mode and color values | Settings notification / root rebuild | defaults | Dominant fixed dark surfaces reduce visible effect |
| Settings local summary | All three | active habits, tasks, completed sessions | any Store notification | zero counts | Labels imply records but mostly count entities |

## Required chains

### Habit check-in

`HabitsStore.checkIn` creates a real record, notifies once, and therefore rebuilds Habits, Today, and Review immediately. Linked Plan-record writing is a second asynchronous Goals update. Required integrated test: perform the check-in once and inspect all three pages without reconstructing Stores.

### Habit create/edit/pause/archive

All mutations notify and active/paused/archived getters recalculate. Today correctly excludes inactive habits. Review currently also excludes their preserved historical activity; that semantic should remain explicit rather than being silently presented as all history.

### Plan action completion

`GoalsStore.toggleTask` notifies Plan, Today, Review, and Focus’s derived incomplete-target list. A previously selected idle Focus snapshot does not automatically clear or refresh at baseline; active/paused snapshots must remain preserved for session history.

### Focus completion

Baseline defect: delayed timer + Pause at/after target end discarded the round, and normal completion announced idle before history insertion. The application-layer fix now records elapsed Pause and inserts history before the completion notification; cleanup/persistence remain asynchronous.

### Theme changes

AppSettingsStore and `MaterialApp` rebuild correctly. Theme synchronization is visually partial because AppShell, Today, and the Stitch layer contain static colors. Shared dominant surfaces should read `Theme.of(context).colorScheme` while retaining current dark defaults.

## Confirmed date / hardcoded defects

- Habits `recentActivityDays`: oldest → today.
- Focus `recentDayCounts`: today → six days ago.
- Today added those lists index-for-index.
- Review labelled oldest-first Habit values as `今, 1, …, 6`.
- Habits labelled a rolling seven-day window with fixed weekdays.
- Today displayed fixed `09:00`, `11:30`, and `14:00` values unrelated to due dates/reminders.
- Resident pages have no explicit midnight invalidation; they refresh on navigation or the next Store notification.

## Schema gate

No confirmed issue requires a persistence-schema or domain-model change. The schema blocker verdict is not triggered.
