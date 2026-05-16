# P7H Habit UI Redesign Plan

Status: audit and planning only. No implementation in this document.

Context:
- P7IA-1 changed bottom navigation to: Today / Habits / Plan / Focus / Review.
- Settings / Mine / Theme Studio now belongs behind the top-right gear.
- Habits is now a first-class bottom tab, so it needs its own visual rhythm instead of feeling like a dense utility screen.

## 1. Current Habits UI Problems

The current Habits page is functionally rich but visually overloaded:

- The top of the page starts with a generic product header, an add section, a statistics header, then a stack of habit cards. It reads as an admin list rather than a daily ritual surface.
- Each `HabitIdentityCard` carries too much at once: emoji, description, today count, progress, reminder, plan link, lifecycle state, action cluster, recent activity strip, record button, stats button, month view button.
- The page has too many small controls at the same hierarchy level. `打卡`, `编辑`, lifecycle, `记录`, `统计`, and `月视图` all compete visually.
- The recent activity strip is useful but too small to establish a strong visual rhythm.
- The month view is still calendar/table-like. It has weekday headers, square cells, and a fixed grid feeling rather than a calm activity rhythm.
- Recent records and statistics sheets expose detailed record rows by default. They feel closer to database logs than a habit reflection experience.
- Record cards carry note/type/metric/attachment details in a dense way. They should be available, but not the default first impression.
- Current habit custom colors are present, but they mostly behave as card accents. They do not create atmosphere, rhythm, or identity.
- The page lacks a strong first screen. A screenshot does not immediately communicate "this is my habit rhythm today."

## 2. New Habits IA

### Habits Tab Home

Purpose: daily habit execution and rhythm overview.

Structure:
- Full-width habit stage at the top, not a boxed dashboard.
- Calm headline such as `今天的习惯节奏`.
- One primary action area for the next incomplete habit.
- Compact rhythm rail showing today's active habits as dots/waves/short rows.
- Active habit list below, but each row should be lighter than current cards.
- Paused and archived habits remain accessible but collapsed by default.

Primary actions:
- Check in next incomplete habit.
- Open habit detail.
- Add habit.

Do not make this page a second Today page. Today summarizes all domains; Habits focuses on execution and habit rhythm.

### Habit Detail

Purpose: one habit's identity, streak/rhythm, and meaningful actions.

Structure:
- Habit hero with emoji/name/color, current day state, and primary check-in action.
- A large rhythm object: path, wave, or dot trail for recent days.
- Month rhythm view as a visual panel, not a raw calendar table.
- Short insights: completion rate, active days, missed/rest days.
- Secondary actions: edit, reminder, lifecycle, linked plan.

Detail should be reached from a habit row/card. It can be a route or bottom sheet depending on implementation risk, but it should feel dedicated rather than a modal full of logs.

### Check-In / Record Sheet

Purpose: quick confirmation first, detailed record second.

Structure:
- Top: habit identity and selected date.
- Primary actions: check-in, makeup, skip.
- Optional details are progressive disclosure:
  - note
  - numeric metrics
  - image proof
  - date selector
- The default sheet should be short and calm. Advanced fields should not dominate first view.

Must preserve current record semantics:
- `HabitRecordType.checkIn`
- `HabitRecordType.makeup`
- `HabitRecordType.skip`
- notes / metrics / attachments
- explicit save/cancel behavior

### Records History

Purpose: review history without looking like database output.

Structure:
- Default history view groups records by week/month with compact summary rows.
- Recent records show as timeline beads or quiet rows.
- Detailed record cards open on demand.
- Image proof thumbnails can remain, but should not make every row feel heavy.
- Search/filter can be future work, not required for first redesign pass.

## 3. Visual Direction

Target attributes:
- modern
- minimal
- calm
- premium
- rhythm-based
- fewer cards
- more graphical data

Specific direction:
- Replace dense stacked cards with rhythm rows and visual stage panels.
- Prefer large quiet composition plus small precise controls.
- Use typography hierarchy sparingly: one strong title, one supporting line, clear action text.
- Use dots, paths, waves, rails, and compact sparklines for habit continuity.
- Reduce visible borders. Use depth, spacing, translucency, and accent glows instead.
- Keep interaction clear, but avoid dashboard overload.

## 4. What To Borrow From The Outsiders

Borrow:
- Full-screen composition that feels like a visual system, not a form page.
- A dominant abstract object: rhythm path, wave, orbit, or dot field.
- Calm data graphics with enough breathing room.
- Large but clean editorial placement.
- The feeling of motion and progress without adding animation complexity.

Adapt for Habits:
- Each habit can own a mini rhythm path.
- Habit color can tint the path and dots.
- The tab home can show all active habits as a small rhythm constellation.
- Detail view can use one bigger rhythm object for the selected habit.

Do not borrow:
- Heavy cinematic decoration that hides functionality.
- Fixed black/gold/blue palettes that override Theme Studio.
- Visual spectacle that makes check-in harder.

## 5. What To Remove

Remove or demote from default first view:
- Huge raw record lists by default.
- Table-like month grids as the primary monthly expression.
- Dense dashboard stat blocks.
- Database-looking record cards.
- Equal-weight action clusters on every card.
- Repeated metadata that does not help immediate action.

Keep available through progressive disclosure:
- Edit habit.
- Reminder.
- Lifecycle pause/archive/delete.
- Month detail.
- Full records.
- Numeric metrics.
- Image proof.
- Plan link status.

## 6. Theme Studio Integration

Theme Studio must remain a product feature, not a casualty of redesign.

Habit color should affect:
- habit rhythm dots
- selected day marks
- habit hero glow
- active habit row highlight
- progress path / wave
- check-in confirmation accent

App accent should affect:
- global CTA
- selected bottom nav
- page-level highlight borders
- Settings/Mine gear affordance
- global action focus states

Rules:
- No hardcoded muddy gold/blue as the final look.
- Use app background/card colors for actual surfaces.
- Use habit color for per-habit identity.
- Use app accent for navigation and global hierarchy.
- If a habit follows interface accent, that should visibly merge with Theme Studio accent.

## 7. Implementation Phases

### P7H-1 Habits Tab Home

Goal:
- Make Habits tab home immediately look like a habit rhythm surface.

Likely changes:
- Redesign top section of `HabitsPage`.
- Introduce private presentation widgets inside `habits_page.dart` or small shared presentation widgets if repeated.
- Replace heavy first-screen card stack with:
  - habit rhythm stage
  - next action module
  - compact active habit rows
  - collapsed paused/archived sections

Do not change:
- `HabitsStore`
- `HabitItem`
- `HabitRecord`
- check-in behavior

### P7H-2 Habit Detail + Month Rhythm View

Goal:
- Replace raw month grid emphasis with a cleaner rhythm-first detail experience.

Likely changes:
- Add habit detail surface or sheet.
- Rework `_MonthlyActivityDialog` into a rhythm panel.
- Keep existing month cell keys where tests depend on them, or update tests only for intentional UI structure changes.
- Preserve date selection behavior from month view to record sheet.

Do not change:
- activity count calculation
- target count semantics
- makeup/skip interpretation

### P7H-3 Records History + Check-In Panel

Goal:
- Make check-in quick and make history readable without database-card density.

Likely changes:
- Simplify `_HabitRecordSheet` first view.
- Move advanced fields behind expansion/progressive disclosure.
- Rework `_HabitStatisticsRecordRow` and record groups into quiet timeline rows.
- Keep explicit save behavior and all existing record inputs.

Do not change:
- record type semantics
- note/numeric/image attachment semantics
- attachment storage behavior

### P7H-4 Theme Studio + Font Scale Integration

Goal:
- Ensure redesigned Habits works with custom colors, common phone widths, and larger Chinese text.

Likely changes:
- Audit habit color contrast against app theme surfaces.
- Add responsive sizing for rhythm objects and action rows.
- Make large text mode reduce density rather than overflow.
- Confirm selected bottom nav, CTA, and habit highlights all use Theme Studio paths.

## 8. Files Likely Touched

Likely presentation files:
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/shared/widgets/product/habit_identity_card.dart`
- `lib/shared/widgets/product/activity_strip.dart`
- `lib/shared/widgets/product/mini_heatmap_cell.dart`
- `lib/shared/widgets/product/soft_surface.dart`
- `lib/app/theme/app_theme_tokens.dart`

Possible tests:
- `test/habits_flow_test.dart`
- `test/app_smoke_test.dart`
- `test/today_overview_test.dart`
- `test/settings_theme_test.dart` only if Theme Studio visual integration changes affect settings expectations

Files that should not be touched for this UI pass:
- `lib/features/habits/application/**`
- `lib/features/habits/domain/**`
- `lib/features/habits/data/**`
- `pubspec.yaml`
- `android/**`
- `ios/**`
- `tooling/**`

## 9. Tests Likely Affected

High-sensitivity tests:
- `habits_flow_test.dart`
  - Depends on keys for check-in, edit, reminder, lifecycle, month view, record sheet, record save/cancel.
  - Month view currently asserts `habit-month-cell-*` keys and level labels.
  - Record sheet tests assert explicit save/cancel behavior and record type semantics.
- `app_smoke_test.dart`
  - Depends on route compatibility and bottom navigation.
- `today_overview_test.dart`
  - Depends on Today-to-Habits entry and summary semantics.

Testing strategy:
- Preserve existing keys whenever the same behavior remains.
- For intentional IA changes, update tests to new visible labels or reachable controls.
- Add screenshot-oriented widget assertions only for stable structure, not fragile visual details.
- Do not loosen tests around record semantics.

## 10. Screenshot Acceptance Checklist

Habits tab home should pass these visual checks:
- First screen clearly reads as a first-class Habits tab, not a generic list.
- There is one dominant habit rhythm visual object or stage.
- The next habit action is obvious within one second.
- Active habit rows are compact and calm.
- There are fewer visible buttons per habit on the first screen.
- Paused/archived habits do not compete with active habits.
- Theme Studio accent is visible in global CTA/nav highlights.
- Habit-specific color is visible in rhythm dots/path/selected days.
- The page does not look like stacked database cards.
- The page works at 360dp width and larger Chinese text without overflow.

Habit detail should pass:
- One habit identity feels distinct.
- Recent rhythm is more prominent than raw logs.
- Month view no longer feels like a spreadsheet.
- Record history is available but not visually dominant by default.

Check-in / record sheet should pass:
- Quick check-in is fast and visually clear.
- Detailed fields are available but quieter.
- Save/cancel behavior remains explicit.
- Image/numeric/note fields remain discoverable.

## Summary Recommendation

Start with P7H-1 only:
- Redesign Habits tab home first.
- Keep all data and semantics unchanged.
- Preserve current keys as much as possible.
- Do not touch records/history/month sheet until the home screenshot direction is accepted.

This avoids repeating color-only redesign and creates visible IA proof before deeper record/detail work.
