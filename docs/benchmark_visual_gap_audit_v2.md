# Benchmark Visual Gap Audit V2

> Roadmap marker: `V5A Benchmark Visual Gap Audit`  
> Project stage: `1.0.1+11` phone-test repair baseline  
> Scope: audit only, no app code, no dependency, no version, no APK  
> Source direction: DayMark + HabitDone + OffScreen + 番茄ToDo, translated into one unified app

This document starts the `1.1 Benchmark Polish Roadmap`. The app is no longer a rough scaffold: Plan editing is visible, Today/Plan responsive issues were repaired, and core Habits/Plan/Focus/Review flows are feature-rich. The remaining problem is product polish: visual depth, richer charts/tables, stronger theme customization, and more benchmark-level Today/Plan surfaces.

## Evidence Inspected

Product and roadmap docs inspected:

- `AGENTS.md`
- `docs/product_vision.md`
- `docs/ui_direction.md`
- `docs/source_ui_reference.md`
- `docs/visual_gap_audit_v1.md`
- `docs/ui_reference_components.md`
- `docs/benchmark_parity_gate_v1.md`
- `docs/benchmark_parity_roadmap.md`
- `docs/feature_completion_checklist.md`
- `docs/references/app_report_v2.txt`

Reference screenshots inspected:

- DayMark: `docs/references/app_content/daymark`
- HabitDone: `docs/references/app_content/HabitDone`
- OffScreen: `docs/references/app_content/OffScreen`
- 番茄ToDo: `docs/references/app_content/番茄ToDo`

Current implementation inspected:

- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/shared/widgets/product/*.dart`

Priority definitions:

- `P0`: blocking benchmark trust or high-frequency phone usability.
- `P1`: major benchmark gap; should be in the 1.1 polish roadmap.
- `P2`: valuable polish or deeper feature, but not required before the next 1.1-quality test.

---

## 1. DayMark Gap Analysis

Current Plan is functionally deep: Goal / Project / Subproject / Task hierarchy exists; identity editing is visible; project/task records support notes, numeric logs, image proof, stats, current-month heatmap, habit-generated records, and source metadata. The remaining DayMark gap is visual/product surface depth: DayMark feels like a project object system with project-level records, tables, and charts; our app can still feel like a polished tree editor plus bottom sheets.

| Area | What DayMark Has | What Our App Currently Has | Missing Gap | Priority | Recommended Bounded Package |
| --- | --- | --- | --- | --- | --- |
| Project list | Compact project cards with icon, color identity, count badge, micro progress/history dots, and category chips. | Goal cards and tree rows with icon/color, visible edit actions, progress rail, project count/action count. | Project list still emphasizes hierarchy more than “project objects”; micro history dots and scan-friendly per-project cards are weaker. | P1 | `V5D Plan Project Detail + Records Table` plus `V5F UI Polish + Responsive Pass` |
| Project record/history | Central history tab with dated records, values, notes, photos, and compact rows. | Project/task record creation exists; project stats/history appears in sheets and rows; generated habit records show source metadata. | No dedicated project record table/list surface with sorting/grouping/filtering; history can feel hidden inside project actions/stats. | P1 | `V5D Project Records Table` |
| Project statistics | Calendar header, time filters, metrics, monthly sections, numeric summaries. | Project statistics bottom sheet: record count, active days, current-month records, photo count, numeric totals by unit, current-month heatmap. | Lacks segmented time filters, calendar header density, chart section, and stronger project identity header. | P1 | `V5D Project Detail + Stats Surface` |
| Project charts | Bar charts, metric graphs, yearly heatmap-like grid. | Current-month mini heatmap only; no bar/ring/line chart, no project annual heatmap. | Visual analytics are too small compared with DayMark chart pages. | P1 | `V5E Habit/Plan Visual Analytics Upgrade` |
| Project table | Date-based project table with values, labels, and per-record detail. | Record history rows exist but not as a table-like project detail surface. | Missing phone-readable record table with date/type/value/source/photo columns or row chips. | P1 | `V5D Plan Project Detail + Records Table` |
| Add/edit project | Edit project screen includes icon/color, group, reminders/settings, subproject settings, homepage display toggles. | Goal/project title/icon/color/description editing is visible and persists; subproject/task title editing visible. | Missing richer project settings surface: group, display options, record units, reminders, table/chart preferences. Do not overbuild yet. | P2 | `V5D` for project detail settings preview; deeper settings postponed |
| Record detail | Add record form handles date/time, numeric values, notes, images. | Create project/task note/numeric records and image proof foundation exist. | Existing record edit/detail is not yet a first-class DayMark-like screen; record review/modify/delete is not obvious. | P1 | `V5D Record Detail/Record Table Foundation` |
| Annual/project heatmap | Project chart page has annual heatmap grid. | Plan has current-month project activity only. | Project annual heatmap missing; should be read-only and derived from real records. | P1 | `V5E Project Annual Heatmap` |
| Habit-generated records | DayMark does not have this exact loop, but it has project records as evidence. | Habit daily completion creates sourced PlanRecord without task auto-completion. | Need clearer visual distinction: source chip should help, but generated records should not crowd manually created records. | P1 | `V5D` record table filter/source chip polish |

DayMark-specific conclusion:

- The next Plan improvement should not be another tree editor pass.
- The highest-value bounded package is a project detail bottom sheet or focused panel with record table, stats, source chips, and charts placeholders from real records.
- Full DayMark-like project charts and annual heatmap should follow after the table/detail surface stabilizes.

---

## 2. HabitDone Gap Analysis

Habits is the strongest feature area now: quick check-in, detailed records, notes, skip, makeup, proof images, camera, annual heatmap, streak, lifecycle, advanced reminders, per-habit color, and Habit → Plan linking exist. The remaining HabitDone gap is not basic capability; it is polish density: custom color system, multi-view statistics, visual habit hero, and personalization.

| Area | What HabitDone Has | What Our App Currently Has | Missing Gap | Priority | Recommended Bounded Package |
| --- | --- | --- | --- | --- | --- |
| Habit card identity | Bold personalized cards with icon, name, description, color, target, reminders, activity. | `HabitIdentityCard` with emoji, description, target, reminder summary, lifecycle/link chips, per-habit color, 7-day strip. | Functional and good, but less expressive; card could use stronger identity zones and preview hierarchy without becoming noisy. | P1 | `V5F UI Polish + Responsive Pass` |
| Check-in flow | One-tap plus rich detail flow. | One-tap remains fast; detailed check-in is draft/save; proof/note optional. | Mostly complete. Remaining gap is microcopy and visual delight, not semantics. | P2 | `V5F Habit flow polish` |
| Makeup flow | Calendar/stat view supports missed-day makeup. | Month view date operation and makeup for selected past localDate exist. | Needs a more visual date-specific calendar/table context so makeup feels integrated with analytics. | P1 | `V5E Habit Multi-view Calendar/Stats` |
| Habit statistics | Large hero metrics, total done, streak, milestones, year heatmap, duration/period panels. | Habit statistics sheet includes key metrics, recent 3-month activity, record history, distribution, annual heatmap, current/longest streak. | The data exists, but sheet may feel long and less heroic; missing milestone/duration visual framing and stronger segmentation. | P1 | `V5E Habit Statistics Visual Upgrade` |
| Heatmap views | Year/month/week/extreme modes and habit dashboard grids. | 7-day strip, current-month heatmap, recent 3-month activity, annual heatmap. | Missing multi-view toggle and all-habit dashboard style; annual heatmap exists but can be visually more HabitDone-like. | P1 | `V5E Multi-view Heatmap Upgrade` |
| Color/theme customization | Color wheel, habit theme color, heatmap background, shadow/display settings. | Global theme mode + 5 accent presets; per-habit low-saturation presets; per-project color identity. | Major user-called gap: no custom HEX/RGB/ARGB, no background/surface color, no preview studio, no heatmap palette controls. | P1-high | `V5B Theme Studio / Advanced Color System` |
| Personalization | Card display style, heatmap color/background, shadows, custom palettes. | Basic settings page plus per-habit color; My page has future sections. | Personalization is too shallow for a benchmark-level product. | P1 | `V5B Theme Studio`, later `V5F My polish` |
| Multi-view calendar/statistics | Dashboard-like overview with multiple heatmap cards and charts. | Per-habit sheet is rich but not a multi-view dashboard; Review remains global and calm. | Missing habit analytics mode switch and overview organization. | P1 | `V5E Habit/Plan Visual Analytics Upgrade` |
| Proof records | HabitDone direction supports rich proof/records. | Max 3 proof images per HabitRecord, gallery, camera, preview, replace/remove. | Strong enough for 1.1; no need for video/reorder/media dashboard. | P2 | Postpone unless real-device proof UX feedback appears |
| Advanced reminders | HabitDone-like reminders/settings. | Up to 3 reminder rules, weekday selection, enable/disable, lifecycle safety. | Mostly complete. Missing global reminder management/settings surface. | P2 | Later Settings/Reminder center |

HabitDone-specific conclusion:

- The clearest user-visible gap is color/customization, not record semantics.
- `V5B Theme Studio / Advanced Color System` should be first code package because it directly addresses the user’s palette/background/HEX/RGB/ARGB request.
- Habit statistics should be visually reorganized later, not expanded with new semantics.

---

## 3. OffScreen Gap Analysis

OffScreen contributes the visual tone: pastel backgrounds, large metrics, calm charts, soft panels, and premium spacing. Our app has shared surfaces and honest metrics, but still lacks OffScreen-level chart composition and atmospheric theming.

| Area | What OffScreen Has | What Our App Currently Has | Missing Gap | Priority | Recommended Bounded Package |
| --- | --- | --- | --- | --- | --- |
| Calm analytics | Large focused metrics, soft panels, clear daily/weekly data rhythm. | Review has large factual metrics and panels; Today has rhythm surface and module cards. | Metrics exist but visual grouping is still text/card-heavy compared with OffScreen. | P1 | `V5C Today Benchmark Home Upgrade`, `V5E Review Analytics` |
| Visual charts | Ring charts, bar charts, heatmap overlays, timeline charts. | Progress rails, MetricStrip, MiniHeatmapCell, ActivityStrip; no ring/bar chart system. | Missing chart vocabulary beyond heatmap/progress. | P1 | `V5E Visual Analytics Upgrade` |
| Card hierarchy | Strong hero panels with soft background and large whitespace. | SoftSurface and tokens exist; pages are improved but still stacked modules. | Need stronger screen-level hierarchy, fewer equal-weight cards. | P1 | `V5C` and `V5F` |
| Screen-time style data panels | Pickup count, screen time, usage distribution, first/last use. | Digital wellbeing is not implemented and should not be faked. | Missing by design. Should remain postponed until platform data exists. | P2 | Postpone Digital Wellbeing V2 |
| Premium spacing | Spacious, airy, not dense. | App uses tokens and responsive wraps; some sheets can still feel long/dense. | Need a polish pass for section rhythm, bottom sheet max height, and typography scale. | P1 | `V5F UI Polish + Responsive Pass` |
| Quiet dashboard feel | Visual data without enterprise-dashboard noise. | Today/Review are honest but can still read as module stack. | Need daily command center composition, not a list of summaries. | P1 | `V5C Today Benchmark Home Upgrade` |

OffScreen-specific conclusion:

- Do not add fake screen-time panels.
- Translate OffScreen into theme/background richness, soft chart components, and calmer hierarchy.
- Review analytics can grow only from real habit/plan/focus data.

---

## 4. 番茄ToDo Gap Analysis

Focus is reliable and now supports task/action binding, custom duration, restore, history, and notifications. The remaining gap is broader execution planning: modes, weekly overview, and task blocks. Because user explicitly said not to touch Focus logic in recent repair packs, Focus should stay stable unless scoped.

| Area | What 番茄ToDo Has | What Our App Currently Has | Missing Gap | Priority | Recommended Bounded Package |
| --- | --- | --- | --- | --- | --- |
| Timer modes | Pomodoro, countdown/count-up, strict/learning modes. | Custom countdown duration only; restore/history/notification stable. | Missing Pomodoro work/break mode, count-up, strict mode. | P2 | Postpone unless Focus becomes next priority |
| Weekly focus overview | Calendar/timeline grid of focus blocks. | Focus history is stored and Review shows aggregate metrics. | No weekly focus timeline view. | P1 | Later `Focus Weekly Overview V6` or `V5E Review Analytics` if read-only |
| Task execution clarity | Colorful task blocks with clear Start actions. | Focus can bind to Plan Task/Action; Plan tasks are not auto-completed. | Start-from-Plan action is not yet a strong execution loop; Today Focus entry is still summary/CTA. | P1 | `V5C Today Home Upgrade` and later Focus execution polish |
| Focus schedule/planner | Future countdown/planner and task calendar. | No focus schedule/planner. | Missing but not critical before visual/theming polish. | P2 | Postpone |
| Colorful structured UI | Task blocks are colorful but organized. | App intentionally restrained; FocusTimerHero exists. | Could use stronger state color and task context, but should not copy high-density colors. | P2 | `V5F Focus visual polish` |
| Notification/strict behavior | Strong execution constraints. | Completion notification path exists; no exact alarm/foreground strict mode. | Platform-heavy features remain postponed. | P2 | Postpone unless explicitly approved |

番茄ToDo-specific conclusion:

- Focus is not the first 1.1 polish target.
- The nearest useful Focus improvement is read-only weekly overview from existing sessions, but theme/Today/Plan gaps are more urgent.
- Do not destabilize Focus timer/notification logic during the 1.1 visual roadmap.

---

## 5. Theme / Color System Gap

The user specifically called out palette, background, UI color, HEX/RGB/ARGB, and richer customization as a major gap. Current implementation has:

- Global theme mode: system/light/dark.
- Global interface accent presets: 5 low-saturation colors.
- Per-habit `habitColorValue`.
- Goal/project identity color.
- No global background color editor.
- No surface/card color editor.
- No HEX/RGB/ARGB input.
- No color wheel.
- No live theme preview beyond swatches.
- No contrast guardrail UI.

### V5B Should Include

Recommended bounded scope: `V5B Theme Studio / Advanced Color System`.

Include:

- Global theme mode retained: system / light / dark.
- Global background color presets.
- Global UI accent color presets.
- Card/surface tint presets.
- Existing per-habit color remains, with clearer relationship to global accent.
- Existing per-project color remains, with shared color picker treatment.
- Custom HEX input, e.g. `#6FA982`.
- RGB input, e.g. `R 111 / G 169 / B 130`.
- ARGB input as advanced text input, e.g. `0xFF6FA982`, because Flutter stores ARGB ints.
- Preset color cards with Chinese labels and preview.
- Live theme preview panel showing: background, surface, button, chip, habit card, project card, heatmap cell.
- Dark/light readability preview.
- Safe contrast guardrails: show warning and prevent applying dangerously unreadable foreground/background combinations where feasible.
- No new dependency. Use native Flutter controls/text fields; postpone color wheel if it requires custom painter complexity or dependency.

### V5B Should Not Include

Postpone:

- Full color wheel if it expands scope too much.
- Gradient/background image customization.
- Theme marketplace.
- Cloud theme sync.
- Per-component full designer controls.
- Heatmap background/shadow/display style knobs.
- Font family marketplace.
- Animation style presets.
- Accessibility-grade automatic palette generator beyond simple guardrails.

### Color System Classification

| Feature | Current | V5B? | Postpone? | Notes |
| --- | --- | --- | --- | --- |
| Global background color | Missing | Yes | No | Major user-called gap. |
| Global UI accent color | 5 presets | Yes | No | Expand presets + custom input. |
| Card/surface color | Missing | Yes | No | Use safe tint presets, not arbitrary noisy surfaces by default. |
| Per-habit color | Present | Improve UI | No | Keep semantics unchanged. |
| Per-project color | Present | Improve UI | No | Share picker style with habit/project identity. |
| Custom HEX input | Missing | Yes | No | Simple text input, validate strictly. |
| RGB input | Missing | Yes | No | Useful for non-developer users. |
| ARGB input | Missing | Yes | No | Advanced option because stored ints are ARGB. |
| Color wheel / picker | Missing | Maybe not | Yes | Avoid dependency; can be V5B2 if custom painter is approved. |
| Preset color cards | Partial | Yes | No | Make visual and branded. |
| Theme preview | Missing | Yes | No | Critical for trust. |
| Dark/light readability | Partial | Yes | No | Preview and warnings. |
| Contrast guardrails | Missing | Yes | No | At least warn/block unsafe combos. |

---

## 6. Data Visualization Gap

Current data visuals:

- Habit 7-day ActivityStrip.
- Habit current-month heatmap.
- Habit recent 3-month activity.
- Habit annual heatmap.
- Habit stats sheet with streaks/distribution/record history.
- Plan project current-month heatmap.
- Plan project stats bottom sheet.
- Review MetricStrip and soft progress bars.
- FocusTimerHero progress.

Missing benchmark-level visuals:

| Visualization | Current State | Recommended Package | Priority | Postpone Notes |
| --- | --- | --- | --- | --- |
| Habit annual heatmap | Exists | `V5E` visual refinement only | P2 | Do not rebuild semantics. |
| Habit multi-view statistics | Partial | `V5E` | P1 | Add segmented views, reorganize stats sheet. |
| Project record table | Missing as first-class surface | `V5D` | P1 | Highest Plan data gap. |
| Project chart | Missing | `V5E` | P1 | Use custom lightweight bars/rings, no chart package initially. |
| Project annual heatmap | Missing | `V5E` | P1 | Derive from PlanRecord localDate. |
| Completion distribution | Habits partial, Plan/Review limited | `V5E` | P1 | Use real data only. |
| Bar/ring charts | Missing | `V5E` | P1 | Implement simple custom widgets or composed Flutter primitives. |
| Calendar table | Partial in Habits date operations | `V5D/V5E` | P1 | Plan table first, Habit calendar polish later. |
| Record history table | Partial rows | `V5D` | P1 | Plan record table and habit record table organization. |
| Review analytics | Basic real metrics | `V5E` or later | P1 | Avoid fake trends/digital wellbeing. |
| Screen-time charts | Not started | Postpone | P2 | Requires platform data/permissions. |
| Chart package | None | Postpone | P2 | User said do not add dependencies unless approved. |

Recommended split:

- `V5D`: tables and project detail surfaces.
- `V5E`: visual charts/heatmaps after tables clarify data structure.

---

## 7. Today Gap

Today improved in P0 repair: it now has a rhythm surface, habit summary, plan summary, focus summary, and real data chips. It still risks feeling like a stacked module overview instead of a benchmark-level daily command center.

### Why Today Still Feels Weaker

- It summarizes modules rather than giving a single “what should I do now” hierarchy.
- The first screen still has several equal-weight metric chips.
- Habit/Plan/Focus are adjacent, but the action relationship is not always obvious.
- It has factual data but not enough editorial priority: top habit, top plan action, current focus readiness.
- It avoids fake analytics correctly, but the result can feel less visually rich than OffScreen/HabitDone.

### What Today Should Show

Use real data only:

- Today readiness hero:
  - `今日达标 X/Y`
  - best/current habit streak
  - today Plan records
  - focus state or next executable action
- Habit lane:
  - pending habits first
  - `今日 X/Y`
  - reminder indicator
  - proof/note indicator only if lightweight
  - recent activity signal
- Plan lane:
  - active goals/projects/actions
  - today plan records
  - linked habit-generated records count
  - top incomplete action candidates, not fake due dates
- Focus lane:
  - selected/available Plan action
  - start focus CTA
  - current timer state
- Review lane:
  - small honest read-only prompt, not a full analytics block.

### What Should Be Removed or Compressed

- Compress repeated metric counts that appear both in hero and module cards.
- Avoid long helper copy on the first screen.
- Avoid showing every subsystem equally; Today should editorialize.
- Keep Review summary minimal on Today.

### Visual Hierarchy Needed

1. One hero surface: “today’s rhythm”.
2. One primary next-action surface: habit or plan/focus depending on real state.
3. Two secondary lanes: Habits and Plan.
4. Focus CTA as execution bridge.
5. Review only as quiet footer.

### Avoid Fake Dashboard

- Do not invent deadlines/trends.
- Do not show “missed” claims for dates without explicit tracking.
- Do not show screen-time data until platform integration exists.
- Do not add chart-heavy Today.

Recommended package: `V5C Today Benchmark Home Upgrade`.

---

## 8. Plan Gap

Plan is now semantically strong, but DayMark-level polish requires a shift from “hierarchy editing” to “project object management”.

### Why Plan Still Feels Weaker

- The UI still reads partly as a tree/list editor.
- Project history/statistics are available but not anchored as a project detail experience.
- Record table and charts are missing.
- Project identity exists but could be more dominant and less nested.
- Generated habit-linked records may be understood only if users enter the right history/stat surface.

### Recommended Direction

Project detail surface:

- Open from project row.
- Show project identity, description, progress, active actions, record count.
- Include clear buttons: `记录`, `统计`, `编辑项目`, `添加行动`.
- Use bottom sheet or focused panel, no new route for first package.

Records table:

- Date grouped rows.
- Type chip: note / numeric / habit source / image.
- Numeric value + unit.
- Source chip: `来自习惯：阅读`.
- Missing image safe indicator.
- Filters can be simple: all / manual / habit-generated / numeric / image.

Chart/stat section:

- Keep from real records.
- Current-month activity.
- Numeric totals by unit.
- Later project annual heatmap and bar chart.

Stronger project identity:

- Larger icon/color mark.
- Description shown in project detail.
- Edit control visible, not icon-only.

Phone layout:

- Less nested indentation in the main page.
- Move deeper record/stat density into project detail sheet.
- Keep tree phone-readable.

Recommended packages:

- `V5D Plan Project Detail + Records Table`.
- `V5E Project Visual Analytics Upgrade`.

---

## 9. Recommended 1.1 Package Order

### V5A Benchmark Visual Gap Audit

Goal:

- Produce this audit and align the 1.1 polish roadmap before coding.

Files likely touched:

- `docs/benchmark_visual_gap_audit_v2.md`

Must not change:

- App code, business logic, routing, dependencies, native config, version, APK.

Tests likely needed:

- None; doc-only.

### V5B Theme Studio / Advanced Color System

Goal:

- Add a richer but safe theme/color customization system: background, accent, surface/card tint, HEX/RGB/ARGB input, presets, preview, contrast guardrails.

Files likely touched:

- `lib/app/settings/domain/application/settings models/storage` if current settings model must expand.
- `lib/app/settings/application/app_settings_store.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_theme_tokens.dart`
- Existing habit/project color pickers if shared color picker is introduced.
- `test/app_settings_store_test.dart`
- `test/settings_theme_test.dart`
- Possibly `test/habits_flow_test.dart` / `test/goals_flow_test.dart` if picker UI changes.

Must not change:

- HabitRecord semantics.
- HabitRecordAttachment semantics.
- PlanRecord semantics.
- Plan progress semantics.
- Focus logic.
- Routing.
- Dependencies.
- Version.

Tests likely needed:

- Old settings load safely.
- Preset background/accent/surface persists.
- HEX input validates and persists.
- RGB input validates and persists.
- ARGB input validates and persists.
- Invalid colors fail safe.
- Dark/light preview readable.
- Habit/project existing color data unaffected.
- Theme persistence still passes.

### V5C Today Benchmark Home Upgrade

Goal:

- Make Today feel like a true daily command center, not stacked cards.

Files likely touched:

- `lib/features/today/presentation/pages/today_page.dart`
- Shared widgets only if a repeated surface emerges.
- `test/today_overview_test.dart`
- `test/app_smoke_test.dart`

Must not change:

- Today remains read-only.
- No fake data.
- No routing changes.
- No Habit/Plan/Focus semantics.
- No version bump.

Tests likely needed:

- Today renders at 360/393/412dp and text scale 1.15.
- Today shows real habit/plan/focus data.
- Today does not mutate records.
- Empty states remain honest.

### V5D Plan Project Detail + Records Table

Goal:

- Create a DayMark-like project detail bottom sheet/focused panel with project identity, record table, source chips, and compact stats.

Files likely touched:

- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/shared/widgets/product/plan_tree_row.dart`
- Possibly new shared record row/table widget.
- `test/goals_flow_test.dart`
- `test/goals_persistence_test.dart` only if no schema change should be asserted.

Must not change:

- Plan task completion semantics.
- Plan progress rollup.
- PlanRecord note/numeric semantics.
- Habit-generated record duplicate logic.
- Focus binding.
- Routing.
- Dependencies.
- Version.

Tests likely needed:

- Project detail opens.
- Record table groups by date.
- Source chip appears for generated habit records.
- Numeric totals remain grouped by unit.
- Task progress unchanged.
- Small phone bottom sheet does not overflow.

### V5E Habit/Plan Visual Analytics Upgrade

Goal:

- Add richer real-data visuals: project annual heatmap, simple bar/ring charts, improved habit multi-view stats, Review visual analytics.

Files likely touched:

- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/habits/domain/models/habit_statistics_summary.dart` only if derived fields are needed.
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- Shared visual widgets under `lib/shared/widgets/product`.
- `test/habit_statistics_test.dart`
- `test/goals_flow_test.dart`
- `test/review_overview_test.dart`

Must not change:

- No chart package unless separately approved.
- No fake trends.
- No fake screen-time data.
- No completion/progress semantic changes.
- No version bump.

Tests likely needed:

- Charts derive from real records only.
- Habit proof/skip/note do not affect completion/heatmap.
- Project annual heatmap uses PlanRecord localDate.
- Review zero states remain honest.
- Small phone rendering tests.

### V5F UI Polish + Responsive Pass

Goal:

- Consolidate spacing, sheet behavior, text wrapping, visual hierarchy, and source-app personality without new semantics.

Files likely touched:

- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- Shared product widgets.
- Responsive tests across major pages.

Must not change:

- Business logic.
- Store/model/schema.
- Routing.
- Dependencies.
- Version.

Tests likely needed:

- 360/393/412dp layout tests.
- Text scale 1.15 tests.
- Bottom sheets scroll safely.
- Existing flow tests still pass.

### V5G Benchmark Review for 1.1

Goal:

- Review the 1.1 visual/polish baseline honestly before any phone-test package.

Files likely touched:

- Possibly a doc-only review report.

Must not change:

- No code unless blockers are explicitly packaged.
- No version bump.
- No APK until approved.

Tests likely needed:

- `flutter analyze --no-pub`
- `flutter test --no-pub`
- `flutter build apk --debug --no-pub`
- Real phone checklist after user approval.

---

## 10. Final Recommendation

First code package after this audit should be:

```text
V5B Theme Studio / Advanced Color System
```

Reason:

- The user explicitly called out palette/background/UI color/HEX/RGB/ARGB as a major gap.
- Theme customization is a core product capability in `docs/ui_direction.md`, not optional polish.
- It improves all tabs at once without touching high-risk record/count semantics.
- It moves the app closer to HabitDone personalization and OffScreen premium tone.
- It can be bounded: settings model + theme tokens + preview + validation, no dependencies, no routing, no APK/version bump.

V5B should be followed by:

1. `V5C Today Benchmark Home Upgrade`
2. `V5D Plan Project Detail + Records Table`
3. `V5E Habit/Plan Visual Analytics Upgrade`
4. `V5F UI Polish + Responsive Pass`
5. `V5G Benchmark Review for 1.1`

Do not start V5C/V5D before V5B unless the user reprioritizes based on the next real-device feedback.
