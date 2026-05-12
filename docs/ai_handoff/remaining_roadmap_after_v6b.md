# Remaining Roadmap After V6B

V6 full-pass closure status: V6B has passed validation through `.\tooling\v6b.cmd`, and V6C through V6H have been completed for the current full-pass scope.

Confirmed validation result:

- V6B read-only validation completed.
- focused goals tests passed.
- targeted analyze passed.
- full analyze passed.
- full tests passed: 172 tests.

Version remains `1.1.2+14`. No version bump, phone-test APK preparation, `flutter build apk`, `pubspec.yaml` / dependency change, or Android/iOS native change was made.

Semantic guardrails confirmed: PlanRecord schema/semantics, PlanRecord note/numeric/image/source semantics, Plan progress semantics, task completion semantics, and Habit -> Plan linking semantics remain unchanged.

This file is now historical roadmap context plus future-scope guidance. Do not automatically start APK work, bump version, or begin a new package from this document. Confirm the next scope with the user first.

## V6C Plan Timeline / Project Charts / Year Heatmap

Goal:

- strengthen DayMark-like project history and analytics;
- add timeline or calendar-like project activity;
- add chart-like visuals without new dependencies if possible;
- consider project year heatmap only if real data semantics are clear.

Constraints:

- no fake analytics;
- Plan task progress remains task-derived;
- records remain evidence/history only.

Current full-pass result:

- completed as a read-only MVP using existing PlanRecord-derived data;
- implemented without PlanRecord schema/semantic changes;
- recommended human review focus: `goals_page.dart` display and `goals_store` / `goal_item` derived helpers.

## V6D Focus Pomodoro Modes / Rest Cycles / Count-up / Weekly Overview

Goal:

- improve 番茄ToDo-like focus depth;
- consider rest cycles, count-up mode, focus modes, weekly overview.

Constraints:

- do not break existing Focus timer restore;
- do not break notification behavior;
- do not auto-complete Plan tasks.

Current full-pass result:

- Focus weekly overview was implemented.
- Pomodoro/rest cycles/count-up remain future work unless explicitly scoped.
- recommended human review focus: `FocusPage` migration from `ListView` to `SingleChildScrollView` + `Column`.

## V6E Review Cross-feature Trends

Goal:

- add careful cross-feature trends after data foundations are stable;
- keep OffScreen restraint;
- avoid fake digital wellbeing data.

Possible real metrics:

- habit completion over time;
- plan action completion;
- focus session history;
- linked habit-generated PlanRecords as records only.

Current full-pass result:

- Review focus activity strip was implemented from real focus session data.
- broader cross-feature trends remain future work unless explicitly scoped.

## V6F Data Management / Backup / Export / Cleanup

Goal:

- export/backup local data;
- safe cleanup of orphaned media;
- user-visible data management.

Constraints:

- no destructive cleanup without explicit confirmation;
- do not delete proof images unless safe and approved.

Current full-pass result:

- Settings data summary was implemented as read-only counts from existing app stores.
- backup/export/cleanup remains future work and must be separately approved.

## V6G OffScreen-like Digital Wellbeing Research / Optional Module

Goal:

- research whether a real optional digital wellbeing module is feasible.

Constraints:

- no fake phone usage data;
- platform permissions and data availability must be researched first;
- do not add native permissions without approval.

Current full-pass result:

- V6G completed as docs-only research.
- no native permission, dependency, or digital wellbeing product implementation was added.

## V6H Final Benchmark UI / Feature Review

Goal:

- review the app against HabitDone, DayMark, OffScreen, and 番茄ToDo;
- decide whether the next phone-test APK is ready.

V6H review docs are updated, but they do not approve a phone-test APK by themselves.

A new phone-test APK still requires explicit user approval, a separate version-bump decision, and a separate release process.
