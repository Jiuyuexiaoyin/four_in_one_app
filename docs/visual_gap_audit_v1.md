# Visual Gap Audit V1

This audit uses the local source-app screenshots as the primary visual reference. Product docs are supporting context only.

## Source Evidence Inspected

DayMark reference folder:

- `docs/references/app_content/daymark`
- Screenshots inspected:
- `微信图片_20260425154305_41_33.png`: project list.
- `微信图片_20260425154305_42_33.png`: history record list.
- `微信图片_20260425154305_43_33.png`: project statistics.
- `微信图片_20260425154305_44_33.png`: project charts and yearly heatmap.
- `微信图片_20260425154305_45_33.png`: add check-in record.
- `微信图片_20260425154305_46_33.png`: add/edit project settings.

HabitDone reference folder:

- `docs/references/app_content/HabitDone`
- Screenshots inspected:
- `微信图片_20260425154726_55_33.png`: habit theme color picker.
- `微信图片_20260425154726_56_33.png`: create habit form.
- `微信图片_20260425154726_57_33.png`: makeup check-in calendar/stat view.
- `微信图片_20260425154726_58_33.png`: habit statistics detail.
- `微信图片_20260425154726_59_33.png`: personalization settings.
- `微信图片_20260425154726_60_33.png`: multi-view habit dashboard.
- `微信图片_20260425154727_61_33.png`: habit statistics hero.

OffScreen reference folder:

- `docs/references/app_content/OffScreen`
- Screenshots inspected:
- `微信图片_20260425154507_47_33.png`: statistics charts.
- `微信图片_20260425154507_48_33.png`: focus-by-tag overview.
- `微信图片_20260425154507_49_33.png`: timeline and chart usage view.
- `微信图片_20260425154507_50_33.png`: pomodoro/focus timer hero.
- `微信图片_20260425154507_51_33.png`: multi-dimensional screen-time metrics.

Tomato ToDo reference folder:

- `docs/references/app_content/番茄ToDo`
- Screenshots inspected:
- `微信图片_20260425154615_52_33.png`: future countdown list.
- `微信图片_20260425154615_53_33.png`: task-driven focus blocks.
- `微信图片_20260425154615_54_33.png`: weekly focus overview timeline.

## Source UI Trait Extraction

### DayMark

Concrete traits observed:

- Project list uses clear project/goal cards with icon identity, color identity, count badges, and micro progress dots.
- History view separates each record into compact rows with colored labels, values, timestamps, and optional photo proof.
- Statistics view uses a calendar header, segmented time filters, summary metrics, and restrained charts.
- Chart view includes bar charts and a yearly heatmap-like grid, but still keeps the surface clean and mobile-first.
- Add/edit project settings include icon/color, group, reminder, subproject toggles, and nested project settings.
- Visual identity is tied to each project, not just global theme color.

Direction for this app:

- `计划` should look like structured goal/project planning, not an engineering tree dump.
- Goal/project cards need stronger identity and progress hierarchy.
- Progress rollup should be scan-friendly.
- History/statistics can be added later only when real data exists.

### HabitDone

Concrete traits observed:

- Habit creation is compact but identity-rich: icon, name, description, theme color, target count, goal toggle, notification, start/end.
- Habit detail/stat views use large achievement metrics, visual milestones, and heatmap grids.
- Heatmaps are a core visual language: daily/month/year activity appears as small grids with clear intensity.
- Habit cards feel lightweight and personalized, not like todo rows.
- Personalization offers theme color, heatmap color/background, shadows, and display style.
- The UI uses bold top copy, dark/light surfaces, and highly visible habit identity.

Direction for this app:

- Habits should visually read as daily tracking: emoji, name, description, `今日 X / Y`, activity strip, reminder state.
- Monthly heatmap must be readable and not overflow.
- Habit cards should gain more identity while staying light.
- Customization is a core product thread, but deep customization should not arrive before the basic surfaces are stable.

### OffScreen

Concrete traits observed:

- Soft pastel background cards frame the phone UI and make data feel approachable.
- Key metrics are large and centered, often supported by circular charts, bars, timelines, or calm metric cards.
- Focus page has a strong central timer object rather than a normal text timer.
- Data pages are visual but not dense; panels feel calm, rounded, and high whitespace.
- Screen behavior metrics use icon cards and big numbers, not text-heavy explanations.

Direction for this app:

- `今日`, `复盘`, and `专注` need larger key metrics and calmer visual surfaces.
- Review should not stay as plain text panels.
- Focus timer should feel like the visual center.
- Do not show screen-time charts until the app has real digital wellbeing data.

### 番茄ToDo

Concrete traits observed:

- Task/focus blocks are colorful and action-oriented.
- Each task row has a clear `开始` action and a visible countdown/remaining-day relationship.
- Focus is tied to concrete tasks, not only a standalone timer.
- Weekly focus overview uses a calendar/timeline block layout.
- The UI is more colorful and execution-heavy than this app should be, but its action clarity is important.

Direction for this app:

- Focus should eventually bind to tasks/actions from `计划`.
- Plan actions should later be executable, not only completable.
- Weekly focus overview should be postponed until focus history and task binding are mature.
- Do not copy the high color density directly; translate it into restrained, accent-aware action surfaces.

## Current Page Gap Audit

### 今日

| Item | Audit |
| --- | --- |
| Current visual problem | Improved after V3A, but still risks reading as a vertical module stack rather than a true daily command center. |
| Source guide | HabitDone for daily habit rhythm; OffScreen for large metrics and calm surfaces. |
| Missing | Stronger visual bridge between habit progress, plan action progress, and focus readiness. Limited soft data visual language. |
| Change first | Refine TodayHero and DailyMetricStrip so the first screen has obvious daily rhythm without becoming a dashboard. |
| Do not copy literally | Do not copy OffScreen screen-time charts or HabitDone full habit dashboard onto Today. |
| Priority | P1 |

### 计划

| Item | Audit |
| --- | --- |
| Current visual problem | Data model is DayMark-like, but UI still has some engineering tree/list feel. Goal cards need more project identity and progress affordance. |
| Source guide | DayMark for project/goal cards, identity, progress dots/badges, hierarchy; OffScreen for restraint. |
| Missing | Per-goal/project color/icon identity, clearer progress badges, more polished tree affordance, later history/stat directions. |
| Change first | PlanGoalCard and PlanTreeView polish: identity rail, progress badge, quieter nested surfaces, clearer empty project/subproject cues. |
| Do not copy literally | Do not copy DayMark exact card layout, full statistics pages, or dense project settings yet. |
| Priority | P1 |

### 习惯 Route

| Item | Audit |
| --- | --- |
| Current visual problem | Habit feature is functionally richer, but phone feedback shows month heatmap overflow/English artifact and unclear intensity. Habit cards can still look too generic. |
| Source guide | HabitDone. |
| Missing | Stronger habit identity cards, clearer heatmap intensity, native-feeling reminder picker, richer but still lightweight check-in rhythm. |
| Change first | Fix month heatmap bug/overflow and improve HabitIdentityCard + HabitMiniHeatmap visual clarity. |
| Do not copy literally | Do not add full yearly heatmap, proof/photo, skip/makeup, or deep personalization in the same package. |
| Priority | P0 |

### 专注

| Item | Audit |
| --- | --- |
| Current visual problem | Timer is reliable, but still more like a functional timer page than a strong execution center. Notification small countdown works, but the in-app visual center can be stronger. |
| Source guide | OffScreen for timer hero; 番茄ToDo for task-driven execution. |
| Missing | FocusTimerHero with strong central timer object, task/action binding later, clearer completion/review link. |
| Change first | Refine visual hierarchy only: central timer hero, calmer duration/control area, no timer logic change. |
| Do not copy literally | Do not add foreground service, strict mode, task binding, white noise, or colorful Tomato ToDo density yet. |
| Priority | P1 |

### 复盘

| Item | Audit |
| --- | --- |
| Current visual problem | Review is honest and read-only, but still text-heavy. It lacks OffScreen-like data panels and visual hierarchy. |
| Source guide | OffScreen. |
| Missing | Larger key metrics, soft chart-like panels from real data, habit heatmap summary, focus history visual summary. |
| Change first | ReviewMetricPanel polish using real existing data only. |
| Do not copy literally | Do not add fake charts, screen-time panels, or digital wellbeing visuals before real data exists. |
| Priority | P1 |

### 我的

| Item | Audit |
| --- | --- |
| Current visual problem | Settings is clearer after accent selector fix, but still mostly a list of sections. It does not yet express HabitDone-like customization depth. |
| Source guide | HabitDone personalization plus OffScreen restraint. |
| Missing | More confident appearance section, clearer distinction between accent color and future style/background customization, future backup/privacy/version hierarchy. |
| Change first | Keep functional appearance controls but make placeholder rows more honest and visually quiet. |
| Do not copy literally | Do not add all HabitDone customization knobs or marketplace-like themes yet. |
| Priority | P2 |

## Honest Rough-MVP Findings

The current app has improved, but the remaining roughness is real:

- Some surfaces still feel like generic Flutter cards.
- Today can still read as stacked feature modules.
- Plan can still read as an engineering tree/list rather than a designed planning surface.
- Review still risks feeling like a text-heavy dashboard.
- Focus is reliable but not yet visually iconic.
- Habit heatmap/readability issues are the most concrete phone-test visual bug.

## Prioritized Next 3 Implementation Packages

### Package A: Habits Month Heatmap Bug + Habit Visual Polish

Scope:

- Fix month heatmap bottom overflow / strange English artifact.
- Improve heatmap intensity clarity for 0 / 1 / 2 / 3+ check-ins.
- Make Habit cards closer to HabitDone: stronger emoji identity, clearer `今日 X / Y`, reminder state, activity strip.
- Keep behavior unchanged unless directly needed to fix the visual bug.

Must not change:

- Routing, schema, persistence keys, reminder scheduling logic, Focus, Goals, Review, version.
- No proof/photo, notes, skip/makeup, streak, archive/delete, or full yearly heatmap.

Phone acceptance criteria:

- No Flutter overflow or stray English/debug text appears in month heatmap.
- 0 / 1 / 2 / 3+ check-in days are visibly different on phone.
- Habit card reads as habit tracking, not todo completion.
- Reminder state remains visible and not crowded.
- Existing check-in/edit/reminder behavior still works.

### Package B: Today + Plan Source UI Alignment

Scope:

- Today closer to HabitDone + OffScreen: daily center, larger key metrics, calm soft surfaces, short habit/plan previews.
- Plan closer to DayMark + OffScreen: goal/project identity, progress badges, clearer tree affordance, quiet hierarchy surfaces.
- Avoid generic card stack feeling.

Must not change:

- Routing, store/model/schema, persistence, Focus logic, reminder notification logic, version.
- No new Plan edit/delete/archive, due dates, priorities, tags, filters, milestones, or search.

Phone acceptance criteria:

- Today first screen clearly communicates daily rhythm.
- Today does not gain new mutating controls.
- Plan card visually reads as goal/project structure, not checklist.
- Project/subproject empty cues feel useful and actionable.
- App remains low-saturation and not dashboard-heavy.

### Package C: Focus + Review Source UI Alignment

Scope:

- Focus closer to 番茄ToDo + OffScreen: stronger timer hero and calmer execution hierarchy.
- Review closer to OffScreen: larger factual metrics, soft data panels, stronger visual hierarchy.
- Use existing real data only.

Must not change:

- Timer/notification/restore/history logic, routing, schemas, dependencies, version.
- No fake analytics, charts package, digital wellbeing implementation, task binding, pomodoro mode, strict mode, white noise.

Phone acceptance criteria:

- Focus timer feels like the visual center.
- Duration choices and controls remain understandable and unchanged.
- Review no longer feels like plain text blocks.
- Review shows stronger hierarchy without fake trends.
- Existing Focus restore/history behavior still works.

## Priority Summary

- P0: Habit month heatmap bug and intensity/readability.
- P1: Today source alignment, Plan source alignment, Focus timer hero, Review data-panel hierarchy.
- P2: My page deeper personalization expression, future digital wellbeing, full yearly heatmap, project history/statistics, task-bound focus, advanced reminders.

## Guardrails For Implementation

- Every future UI package must name the source folder/screenshots inspected before coding.
- Source screenshots are references for traits, not templates to clone.
- Use current app tokens first; add new shared components only when a repeated pattern is stable.
- Keep the five-tab IA intact: 今日 / 计划 / 专注 / 复盘 / 我的.
- Do not mix source identities into separate visual islands; unify them through spacing, typography, accent usage, and calm hierarchy.
