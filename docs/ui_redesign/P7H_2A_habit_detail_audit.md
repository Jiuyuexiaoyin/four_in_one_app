# P7H-2A Habit Detail Rhythm Audit

## Audit Goal

This audit defines the P7H-2B redesign direction for Habit detail, month view, recent records, and statistics. The next implementation should move the page from a database-like record screen toward a calm rhythm visualization while preserving habit semantics, Theme Studio customization, existing test keys, persistence behavior, and current navigation entry points.

This is not a color-only, token-only, giant card-stack, or generic dark dashboard recommendation. The redesign should change hierarchy, density, rhythm, and interaction shape, with color supporting those structural changes rather than replacing them.

## Visual Reference Reports Used

The audit uses the required visual reference reports:

- `ai/reports/visual_refs_selected.txt`
- `ai/reports/codex_image_manifest.md`
- `ai/reports/visual_library_full.md`

Reference groups used:

- Current App UI group: `docs/references/current_app_ui/`, count 5, used for before-state density and stacked-card diagnosis.
- Desired UI Taste Board group: `docs/references/ui_taste_board/selected/`, selected image count: 12, used for The Outsiders rhythm/data visuals and Equinox+ full-screen/editorial composition.
- Functional Benchmark Apps group: `docs/references/app_content/`, count 21, used for habit/calendar workflow rhythm and compact interaction density.
- Full visual library count: 38.

Selected TaskPack: `global`.

Selected images cited from `ai/reports/codex_image_manifest.md`:

- `docs/references/current_app_ui/01_today_??.jpg`
- `docs/references/ui_taste_board/selected/The Outsiders iOS 0.png`
- `docs/references/ui_taste_board/selected/The Outsiders iOS 10.png`
- `docs/references/ui_taste_board/selected/The Outsiders iOS 14.png`
- `docs/references/ui_taste_board/selected/The Outsiders iOS 17.png`
- `docs/references/ui_taste_board/selected/The Outsiders iOS 31.png`
- `docs/references/ui_taste_board/selected/The Outsiders iOS 45.png`
- `docs/references/ui_taste_board/selected/Equinox+ iOS 0.png`
- `docs/references/ui_taste_board/selected/Equinox+ iOS 12.png`
- `docs/references/ui_taste_board/selected/Equinox+ iOS 28.png`
- `docs/references/ui_taste_board/selected/Equinox+ iOS 32.png`
- `docs/references/ui_taste_board/selected/Equinox+ iOS 48.png`

Visual lessons applied:

- The Outsiders references: use wave/path/dot rhythm, quiet charting, large status statements, sparse metrics, and data marks that feel like a living pattern instead of a table.
- Equinox+ references: use a full-screen stage, strong headline hierarchy, generous vertical pacing, restrained controls, and confident empty space.
- Functional benchmark references: keep habit completion fast, keep calendar meaning visible, and avoid hiding the action path behind decorative presentation.

## Why The Current Habit Detail Feels Database-Like

The Habit detail/month/statistics surface feels database-like when it treats every unit of data as a separate record with equal visual weight. A month grid becomes a table when each day is boxed similarly, every record row is fully expanded, and summary widgets are stacked as independent cards rather than composed into one readable habit rhythm.

The likely weak pattern is not just color or card styling. It is structural:

- The month view reads as a calendar ledger: repeated cells, dates, completion marks, and borders are more prominent than the habit's momentum.
- Recent records read like an audit log: each completion/miss/note appears as a row to inspect instead of a supporting trail.
- Distribution and year activity compete with the month grid for attention, so the page feels like multiple reports stitched together.
- Metrics are probably too literal and dense: counts, labels, legends, and section headers explain the database instead of revealing the behavior pattern.
- Cards create isolated containers for data that should feel connected: month, streak, completion texture, and recent activity all describe the same habit rhythm.

P7H-2B should therefore redesign composition and interaction first. Swapping tokens, changing colors, or adding larger rounded cards would preserve the database feeling.

## Habit Semantics And Tests That Must Remain

P7H-2B must preserve the underlying habit behavior exactly:

- Completion state by date must remain unchanged.
- Missed, skipped, partial, target-count, and note semantics must remain unchanged where they already exist.
- Streak, monthly completion, yearly activity, completion distribution, and recent record calculations must keep their current data sources and logic.
- Existing date navigation and selected-month behavior must remain functionally equivalent.
- Existing edit/delete/settings/detail entry points must remain reachable.
- Existing test keys must be preserved. New widgets may add keys, but current keys used by `habits_flow_test.dart`, smoke tests, and Theme Studio tests must not be renamed or removed.
- Persistence behavior, ordering, filtering, localization, and timezone/date-boundary behavior must not change.
- Theme Studio/custom color behavior must remain active and visible.

The audit does not recommend domain, application, data, persistence, or test rewrites. P7H-2B should be presentation-layer work only unless a narrowly scoped UI adapter is already local to the habit detail view.

## Month Grid As Rhythm Visualization

The month grid should become the central visual object on the page, closer to a rhythm surface than a spreadsheet.

Recommended structure:

- Place the habit name, current streak or monthly progress, and primary completion action in a top stage. This stage should establish the habit color and the current month mood.
- Convert the calendar grid into a calm field of rhythm marks: dots, pulses, short bars, rings, or connected marks. Date numbers should be secondary, not the dominant object.
- Let completed days form a visible path or cadence. Consecutive completions can connect subtly; gaps can breathe instead of shouting failure.
- Use scale, opacity, fill, or glow to communicate completion strength. Do not rely only on color because Theme Studio colors vary.
- Keep tap targets large enough even if the visible mark is small. The visual mark can be minimal while the hit area remains accessible.
- Keep selected day state clear through shape, outline, elevation, or halo tied to the habit accent.
- Use the current month as the main rhythm and move adjacent-month days into low-contrast peripheral marks, if they remain visible at all.
- Use weekday labels as quiet anchors, not table headers.

The goal is that a user can glance at the month and feel cadence: consistent, broken, restarting, building, or quiet. It should not require reading each cell as a record.

## Recent Records As Minimal Or Collapsed

Recent records should support the rhythm view instead of taking over the page.

Recommended structure:

- Collapse records by default into a compact "Recent" strip or short stack showing the last 3 meaningful events.
- Use small date chips or micro rows with icons/marks: completed, missed, skipped, note. Avoid full ledger rows unless expanded.
- Provide a clear "View all records" or expand affordance for users who need audit detail.
- Keep destructive or edit actions available in the expanded state, not on every collapsed row.
- If notes exist, show a one-line preview only when meaningful; otherwise keep records as quiet metadata.
- Tie record marks to the same visual language as the month grid so the record list feels like a zoomed-in excerpt of the rhythm, not a separate database table.

Collapsed recent records should answer "what just happened?" Full records should remain available for behavior parity and tests.

## Calmer Completion Distribution And Year Activity

Completion distribution and year activity should become secondary evidence, not another dashboard.

Recommended structure:

- Replace heavy cards and verbose legends with compact visual summaries: a thin distribution band, soft histogram, yearly sparkline, or grouped dot field.
- Put labels after the visual, not before it, so the pattern leads.
- Use only the most useful numbers: completion rate, longest streak, current streak, and total completions when they help the habit story.
- Fold deeper statistics behind a "Stats" or "Year" section that starts collapsed or visually quieter below the main month rhythm.
- Use consistent rhythm marks across month and year. A yearly activity grid can be lower opacity and smaller, acting as texture rather than a second primary calendar.
- Avoid red/green judgment-heavy styling. Misses and low activity should read as calm gaps or muted marks unless the app already has semantic warning behavior to preserve.

The page should feel like one habit story with supporting data, not multiple analytics cards.

## Theme Studio And Habit Color Requirements

Theme Studio and custom habit color must drive real surfaces, selected states, and rhythm marks. A fixed hardcoded palette must not swallow user customization.

P7H-2B requirements:

- Theme background color should affect the full page atmosphere, including the stage area behind the header and rhythm grid.
- Theme card/surface color should affect any panels that remain, but the design should reduce unnecessary card count.
- Theme accent color and habit color should influence the primary rhythm marks, selected day halo, completion action, highlighted borders, and active controls.
- The habit color should be visible as a local identity layer for the page, even when global Theme Studio colors are customized.
- Use derived opacity, blending, or tonal variants from Theme Studio values rather than hardcoded dark dashboard colors.
- Maintain contrast for text, icons, selected states, and disabled states across custom themes.
- Do not solve the redesign by only swapping color tokens. Theme Studio must be expressed through composition: stage glow, rhythm marks, selected states, progress emphasis, and CTA treatment.

## P7H-2B Scope

P7H-2B should be allowed to edit only presentation files directly responsible for Habit detail, month visualization, records display, and local habit statistics UI. It should not edit domain, application, data, persistence, native platform files, tooling, `pubspec.yaml`, or tests unless a later task explicitly expands scope.

Allowed P7H-2B edit intent:

- Habit detail page layout and local widgets.
- Month grid rendering/painter/layout code.
- Recent records presentation and collapsed/expanded UI state.
- Completion distribution and year activity presentation widgets.
- Local theming helpers inside the habit UI layer, if needed to map Theme Studio and habit color into visual states.
- Golden/screenshot-only support code only if explicitly included in the next implementation task.

Not allowed for P7H-2B:

- Habit calculation semantics.
- Repository/data model changes.
- Persistence migrations.
- Test key renames.
- Version bump.
- APK preparation.
- Flutter build APK.
- Replacing the page with generic cards or a fixed visual palette.

## P7H-2B Design Direction

Recommended hierarchy:

1. Top stage: back/settings actions, habit title, current rhythm statement, primary completion action, and one or two high-signal metrics.
2. Month rhythm: the main visual object, using marks/path/dots instead of boxed table cells.
3. Recent strip: collapsed by default, showing the latest habit events with a path-consistent visual language.
4. Calm statistics: distribution/year activity as quiet supporting texture, with expand affordances for deeper inspection.

Interaction requirements:

- The completion action must stay fast and discoverable.
- Month/day selection must still expose per-day detail where the current product supports it.
- Expanded records must still allow the current edit/delete/detail behavior.
- The page must remain scrollable and stable on small devices.
- Empty states must use the same rhythm language: a quiet inactive field and a clear first-action prompt, not a large explanatory card.

## Tests to Run for P7H-2B

P7H-2B tests to run after implementation:

- `habits_flow_test.dart`
- `app_smoke_test.dart`
- `settings_theme_test.dart`
- `today_overview_test.dart` if Today entry points are affected
- full V6B verification wrapper:
  `D:\AI\Tools\Codex\four_in_one_v6b_verify.cmd`

The next implementation report should include the command output or explicit reason any expected test was not run. Do not run `flutter build apk` unless a user explicitly starts a phone-test APK release process.

## Screenshot Acceptance Checklist

P7H-2B screenshots should pass this checklist:

- Habit detail first viewport has a clear visual stage, not a stack of same-weight cards.
- Month view reads as rhythm/cadence before it reads as a table.
- Completed, missed, skipped, selected, today, and future/unavailable days are distinguishable without relying on color alone.
- Habit color is visible in the rhythm marks and selected state.
- Theme Studio background, card/surface, and accent choices visibly affect the page.
- Recent records are minimal or collapsed by default, with full records still reachable.
- Completion distribution and year activity are calmer than the month rhythm and do not dominate the page.
- Existing entry points remain visible: back/navigation, edit/settings where applicable, completion action, record access, and month navigation.
- Text does not overlap or overflow on small screens.
- The page does not become a generic dark dashboard, giant rounded card stack, token-only refresh, or color-only repaint.
- Light/dark/custom Theme Studio combinations maintain readable contrast.
- Existing automated tests relying on habit behavior and test keys still pass.

## Risks For P7H-2B

- Over-minimizing records could hide edit/delete workflows. Keep a clear expanded state.
- A custom painter or animated rhythm field could accidentally break tap targets. Preserve large semantic hit areas.
- Theme-derived color blending can reduce contrast in custom themes. Test with extreme Theme Studio values.
- Removing labels too aggressively can hurt accessibility. Keep semantic labels and screen-reader descriptions even when the visual UI is sparse.
- Calendar/date changes are high risk. Keep data selection and month navigation logic unchanged.

## Intentional Non-Recommendations

- Do not redesign by only changing colors, gradients, or tokens.
- Do not make a bigger stack of rounded cards.
- Do not clone The Outsiders or Equinox+ branding, assets, pricing UI, workout semantics, or exact layouts.
- Do not replace habit semantics with fitness readiness semantics.
- Do not hide functional entry points for the sake of a poster-like screen.
- Do not change app version, prepare APKs, or modify validation tooling.
