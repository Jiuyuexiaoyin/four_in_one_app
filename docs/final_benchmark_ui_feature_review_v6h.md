# V6H Final Benchmark UI / Feature Review

Status: V6 full-pass docs closure.

Project: `four_in_one_app`

Current version: `1.1.2+14`

Current baseline:

- V6A is completed.
- V6B Plan Due Dates / Priority / Tags / Search is completed and validated.
- V6C Plan Timeline / Project Charts / Year Heatmap is completed and validated.
- V6D Focus Weekly Overview is completed and validated.
- V6E Review Focus Activity Strip is completed and validated.
- V6F Settings Data Summary Section is completed and validated.
- V6G Digital Wellbeing Research is completed as docs-only.
- V6H Final Benchmark Review (this document) is updated.
- Validation entry: `.\tooling\v6b.cmd`.
- V6B read-only validation completed.
- focused goals tests passed.
- targeted analyze passed.
- full analyze passed.
- full tests passed: 172 tests.
- No version bump was made.
- No APK was prepared.
- `flutter build apk` was not run.
- No `pubspec.yaml` / dependency change was made.
- No Android/iOS native change was made.

This review does not approve a release build and does not start a new code package.

Confirmed semantic non-changes:

- PlanRecord schema and semantics untouched.
- PlanRecord note/numeric/image/source semantics untouched.
- Plan progress semantics untouched.
- task completion semantics untouched.
- Habit -> Plan linking semantics untouched.

## Non-Negotiable Guardrails

Do not bump version.

Do not prepare APK.

Do not run `flutter build apk`.

Do not modify business code without an explicitly approved next package.

Do not modify PlanRecord schema or semantics without explicit approval.

Do not modify Habit -> Plan semantics.

Do not change Plan progress semantics.

Do not change task completion semantics.

Do not invent Review or digital wellbeing metrics that are not backed by real stored data.

## Current Completed Capability Summary

### V6A

V6A is treated as complete by the current handoff state. It established richer Habit structure and metrics while preserving the habit completion rule: effective completion remains based on real check-in/makeup behavior rather than proof, notes, or fake analytics.

### V6B

V6B is complete and sealed.

Implemented Plan metadata:

- `ProjectItem.dueDate`
- `ProjectItem.priority`
- `ProjectItem.tags`
- `GoalTaskItem.dueDate`
- `GoalTaskItem.priority`
- `GoalTaskItem.tags`

Implemented Plan discovery:

- read-only search
- filters
- sorting
- flat contextual results when search/filter/sort is active
- default hierarchy unchanged

Explicit V6B non-changes:

- no Goal metadata
- no Subproject metadata
- no PlanRecord schema change
- no Plan progress semantics change
- no task completion semantics change
- no Habit, Focus, Review, or Theme Studio behavior change

### Habits

Status: strong foundation, partly complete at benchmark depth.

Done:

- lightweight habit cards
- emoji/icon/name/description identity
- target count per day
- multiple daily check-ins
- detailed records with notes
- skip and makeup records
- proof images with gallery/camera flow
- reminders
- lifecycle states
- per-habit color identity
- recent activity, current-month heatmap, recent 3-month activity, annual heatmap
- streaks with pause-aware protection
- Habit -> Plan linking that creates sourced PlanRecords without completing Plan tasks
- Today and Review habit summaries from real data

Remaining:

- richer habit organization and grouping
- deeper calendar/table inspection if needed
- hard delete/data management only after backup/export foundations
- optional advanced customization is lower priority

### Plan

Status: strong DayMark-like hierarchy with V6C read-only record/history analytics MVP complete.

Done:

- Goal -> Project -> Subproject -> Task hierarchy
- editable Goal/Project identity
- editable Subproject/Task title
- task/action as the only directly completable unit
- progress rollup from child task completion only
- PlanRecords for note/numeric records
- one-image proof attachment behavior for Plan records
- project detail sheet with record table, filters, stats, numeric totals, and current-month activity
- V6C read-only project timeline, month chart, and year activity display from real PlanRecord data
- habit-generated PlanRecords with source metadata and duplicate prevention
- V6B due dates, priority, tags, search, filters, and sorting

Remaining:

- deeper standalone project history surface if needed
- richer project chart/detail inspection if explicitly scoped
- PlanRecord detail/edit/delete surface
- Plan multi-image proof parity with Habits
- advanced Plan analytics must remain record-derived, not progress-derived

### Focus

Status: reliable base loop with weekly overview, not yet full Tomato ToDo depth.

Done:

- countdown timer
- custom duration
- active session persistence/restore
- local notification path
- completion history
- Plan Task/Action target snapshot binding
- Focus does not auto-complete Plan tasks
- V6D weekly focus overview (ActivityStrip + MetricStrip on FocusPage, showing per-day session counts and week totals)
- FocusPage migrated from ListView to SingleChildScrollView+Column to prevent SliverList lazy garbage collection of off-screen timer widgets

Remaining:

- Pomodoro work/break cycles
- rest cycles
- count-up mode
- strict mode, interruption tracking, and white noise are intentionally postponed unless explicitly approved

### Review

Status: honest real-data summary with cross-feature activity strips.

Done:

- habit metrics from real habit records
- Plan hierarchy/progress metrics from real task completion
- Focus metrics from real focus sessions
- calm data surfaces
- no fake digital wellbeing metrics
- V6E focus recent 7-day activity strip (ActivityStrip on ReviewPage with `review-focus-recent-strip` key)

Remaining:

- careful weekly/monthly cross-feature trends
- generated habit-linked PlanRecords must remain records only, not progress
- digital wellbeing remains research-first and cannot be faked (see V6G report)

### Theme / Settings

Status: core Theme Studio is complete; data summary section added.

Done:

- visual color picker without new dependency
- hue slider and saturation/brightness picker
- palette boards
- live preview
- background/surface/accent customization
- HEX/RGB/ARGB advanced input
- reset and readability guardrails
- per-habit and per-project identity colors remain separate from global theme
- V6F data summary section: replaces "备份与导出" placeholder with real read-only counts of habits, actions, and focus sessions from all three stores

Remaining:

- actual backup/export functionality (file sharing, versioned format)
- named theme presets
- separate light/dark custom palettes
- wallpaper, gradient, fonts, theme import/export
- these are intentionally postponed unless real-device feedback makes them urgent

### Today

Status: functional daily command center.

Done:

- read-only Today summaries for habits, Plan, and Focus
- real data only
- calm, high-frequency surface

Remaining:

- any deeper Today scheduling or due-date expansion should be scoped separately
- Today must not become a dense dashboard

## Benchmark Alignment Matrix

| Reference | Status | Current Alignment | Remaining / Out Of Scope |
| --- | --- | --- | --- |
| HabitDone | partial | Habits has identity, target counts, multiple check-ins, notes, skip, makeup, proof images, reminders, lifecycle, heatmaps, streaks, and Habit -> Plan linking. | Habit groups, richer organization, and deeper calendar/table workflows remain. Social/gamified mechanics are intentionally out of scope. |
| DayMark | partial | Plan has goal/project/subproject/task hierarchy, project identity, task-derived progress, PlanRecords, project detail, records table, numeric totals, image proof, V6B metadata/search/filter/sort, and V6C read-only timeline/chart/year activity display. | Deeper standalone history, PlanRecord detail editing, multi-image proof parity, Goal/Subproject metadata, and saved searches remain out of current scope. |
| OffScreen | partial | UI tone is restrained; Today/Review use real metrics; Review avoids fake analytics; Theme and shared surfaces support calm data presentation. | Real digital wellbeing data is not implemented. Screen time, pickup count, app ranking, limits, and focus restrictions are not started and must remain research-first. |
| Tomato ToDo | partial | Focus has large timer direction, custom countdown, persistence/restore, notifications, history, Plan action binding, and V6D weekly overview. | Pomodoro cycles, rest cycles, count-up, strict mode, interruption tracking, and white noise are not started. Strict/white-noise behaviors are intentionally postponed. |

## Checklist State

Done highlights:

- Theme Studio visual picker and global theme targets
- Product UI responsive polish
- Habit daily tracking and proof/history foundation
- DayMark-like Plan hierarchy
- Habit-generated Plan records
- Focus countdown, restore, notifications, history, and task binding
- Review and Today real-data summaries
- V6B Plan due dates, priority, tags, search/filter/sort
- V6C Plan project year heatmap and timeline from real PlanRecord data
- V6D Focus weekly overview: per-day ActivityStrip + MetricStrip week totals on FocusPage
- V6E Review focus activity strip: recent 7-day ActivityStrip on ReviewPage
- V6F Settings data summary: real habit / action / focus session counts replacing placeholder section
- V6G Digital wellbeing research completed (docs-only; no implementation)

Partial highlights:

- Advanced theme system
- Habit streak protection and archive/delete lifecycle depth
- Plan records and project history/statistics depth
- Focus binding beyond Plan Task/Action

Not started highlights:

- Pomodoro mode
- Count-up timer
- Focus strict mode, white noise, interruption tracking
- OffScreen-like digital wellbeing data (researched; deferred; see V6G report)
- App usage limits/restrictions
- Backup/export file sharing

## Next Feature Package Candidates

Historical note: this candidate list was used during V6 planning. V6C through V6H are now completed for the current full-pass scope. Treat the details below as future-scope background, not as authorization to start new work.

### V6C Plan Timeline / Project Charts / Year Heatmap

Function goal:

- Strengthen DayMark-like project history and analytics with real PlanRecord-derived visuals.
- Add timeline or calendar-like project activity.
- Add chart-like visuals without new dependencies if possible.
- Consider a project year heatmap only if the data semantics stay clear.

Modules involved:

- Plan page
- Project detail sheet
- GoalsStore derived stats
- shared analytics/heatmap widgets if reuse is possible

Risk level: medium.

Schema/native/API change:

- Schema: no, if derived from existing PlanRecord fields.
- Native: no.
- API/dependency: no new dependency recommended.

Testing needed: yes.

Test focus:

- timeline/heatmap derives only from PlanRecord `localDate`
- generated habit-linked PlanRecords count as records only
- numeric totals remain grouped by unit
- current-month stats remain unchanged
- small-phone layout does not overflow

Possible semantic impact:

- Low if kept read-only.
- Main risk is accidentally implying records affect task progress. They must not.

### V6D Focus Pomodoro Modes / Rest Cycles / Count-up / Weekly Overview

Function goal:

- Improve Tomato ToDo-like Focus depth with work/rest cycles, count-up mode, focus modes, and weekly overview.

Modules involved:

- Focus store
- Focus active/session models
- Focus local storage
- Focus notification service
- Focus page
- possibly Review if weekly overview is reused there

Risk level: high.

Schema/native/API change:

- Schema: likely yes for focus mode, phase, or cycle state.
- Native: probably no if existing notification path is enough, but notification behavior risk is high.
- API/dependency: no new dependency recommended.

Testing needed: yes, extensive.

Test focus:

- existing countdown behavior remains unchanged
- active session restore works across mode/phase
- notification behavior remains reliable
- break phases do not create fake focus minutes unless explicitly defined
- Focus target binding never mutates Plan tasks

Possible semantic impact:

- Medium to high because timer/session semantics change.
- Must not auto-complete Plan tasks.

### V6E Review Cross-feature Trends

Function goal:

- Add careful weekly/monthly cross-feature trends after data foundations are stable.
- Keep OffScreen restraint and avoid fake digital wellbeing data.

Modules involved:

- Review page
- read-only derived summaries from Habits, Plan, and Focus
- shared metric/chart widgets

Risk level: medium.

Schema/native/API change:

- Schema: no if reports are derived.
- Native: no.
- API/dependency: no dependency recommended.

Testing needed: yes.

Test focus:

- trends are based only on real stored habit records, task completions, PlanRecords, and focus sessions
- generated habit-linked PlanRecords count as records only
- empty states are honest
- no screen-time or app-usage claims without real data

Possible semantic impact:

- Medium if metrics are miscounted.
- Must not change Habits, Focus, PlanRecord, or progress semantics.

### V6F Data Management / Backup / Export / Cleanup

Function goal:

- Add export/backup foundation.
- Provide safe cleanup of orphaned media only when explicit and safe.
- Create user-visible data management without destructive defaults.

Modules involved:

- Settings/My page
- app settings storage
- habits storage and attachment metadata
- goals storage and Plan attachment metadata
- focus storage
- export/import helpers if approved

Risk level: high.

Schema/native/API change:

- Schema: no core app schema change required, but export format should be versioned.
- Native: possibly yes if file picker/share/export permissions are introduced.
- API/dependency: possible if export/share packages are required; avoid until explicitly approved.

Testing needed: yes, extensive.

Test focus:

- export includes expected data safely
- image bytes are not stored in SharedPreferences
- malformed import fails safe if import is included
- cleanup never deletes proof images without explicit confirmation
- IDs and attachment references remain consistent

Possible semantic impact:

- High data-safety risk.
- No destructive cleanup should happen without explicit user confirmation.

### V6G OffScreen-like Digital Wellbeing Research / Optional Module

Function goal:

- Research whether a real optional digital wellbeing module is feasible.
- Understand platform permissions and data availability before any implementation.

Modules involved:

- docs/research first
- later possibly Settings, Review, Today, Android native config, and permissions if approved

Risk level: high for implementation, low for research-only docs.

Schema/native/API change:

- Schema: none for research-only.
- Native: likely yes if implemented.
- API/dependency: likely yes if implemented.

Testing needed:

- No for research-only docs.
- Yes if implementation is approved.

Test focus if later implemented:

- permission states
- honest unavailable-data states
- privacy and opt-in behavior
- no fake phone usage data

Possible semantic impact:

- High if implemented.
- It must not invent screen time, pickup count, app ranking, app limits, or focus restrictions.

## Recommended Next Step

V6 full-pass can move to documentation closure and scope-confirmation mode. Do not automatically start a new code package from this document.

Before any future implementation, confirm the new scope with the user and restate:

- whether the work is docs-only or code-changing;
- whether it touches Plan, Habits, Focus, Review, Theme, Settings, native config, dependencies, versioning, or APK flow;
- what validation command is allowed;
- whether a phone-test APK and version bump are explicitly approved.

Human review focus before any future release step:

- `FocusPage` migration from `ListView` to `SingleChildScrollView` + `Column`;
- `goals_page.dart` V6C read-only Plan timeline/chart/year activity display;
- `goals_store` / `goal_item` derived statistics helpers;
- `tooling\validate_v6b.ps1` remains a disabled historical script and must not be run directly.

## Final Release Note

V6H does not make the app ready for a new phone-test APK by itself.

A phone-test APK requires explicit user approval, version bump approval, and a separate release process.

Until then:

- keep version at `1.1.2+14`
- do not prepare APK
- do not run `flutter build apk`
- do not change release metadata
