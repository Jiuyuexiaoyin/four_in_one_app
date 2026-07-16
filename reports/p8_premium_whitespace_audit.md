# P8 Premium Whitespace Audit

## Sources Reviewed

- Current manual screenshots:
  - `reports/manual_premium_spacing_review/01_today_current.png`
  - `reports/manual_premium_spacing_review/02_habits_current.png`
  - `reports/manual_premium_spacing_review/03_plan_current.png`
  - `reports/manual_premium_spacing_review/04_focus_current.png`
- Prior implementation reports:
  - `reports/p8_stitch_pixel_rewrite_report.md`
  - `reports/p8_plan_pixel_fix_report.md`
  - `reports/p8_stitch_export_ui_rebuild_report.md`
- Local Stitch export:
  - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/final_synthesis_2/screen.png`
  - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/scale_proportion_refinement/screen.png`
  - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/discipline_dashboard/screen.png`
  - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/final_synthesis_1/screen.png`
  - `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/performance_hub/screen.png`
- Settings and Review current manual screenshots were not present in `manual_premium_spacing_review`; older Flutter baseline screenshots were used only as secondary context.

## Cross-Screen Density Problems

1. The screens keep the dark Stitch direction, but the first viewport often contains too many equally strong modules.
2. Major section gaps are mostly 12-22px, so panels read as a continuous stack instead of a premium cadence.
3. Metric tiles are visually heavy because uppercase labels, large values, and dark boxed backgrounds repeat in tight grids.
4. Hero panels and secondary charts have similar card weight, which weakens hierarchy.
5. Bottom navigation visually compresses the last visible content. Several screens show content continuing underneath the dock.
6. Text hierarchy is aggressive in places where the copy is explanatory rather than decisive. This is most visible on Plan empty-state pillars and Settings controls.
7. Uppercase technical labels compete with body copy when too many labels appear in one viewport.

## Today

### Where It Feels Crowded

- The header, Focus Score, three metric tiles, Peak Rhythm panel, Momentum Metrics rings, Priority Execute, Focus Flux, and Action Plan all appear before the dock area.
- The first viewport shows too many dashboard layers before the user reaches the actual action list.
- Action Plan starts too close to the bottom nav and is visually clipped/compressed.

### Dense Cards

- The Focus Score metric grid is too heavy for a supporting summary.
- The Peak Rhythm panel has useful copy but competes with the primary Priority Execute card.
- Focus Flux appears immediately after Priority Execute, making the chart feel urgent even when data is empty.

### Spacing Issues

- Header to Focus Score is tight.
- Focus Score to Peak Rhythm and Peak Rhythm to Momentum Metrics need more separation.
- Action Plan needs more bottom safe area.

### Hierarchy Issues

- Focus Score is very large even when score is `0%`; it dominates without enough meaning.
- Momentum Metrics and Priority Execute both feel primary.

### Recommended Changes

- Keep Focus Score identity but reduce supporting metric tile weight.
- Make Priority Execute the single dominant command card.
- Increase section gaps before Momentum Metrics, Priority Execute, Focus Flux, and Action Plan.
- Push snapshots and logs lower with generous bottom padding.
- Soften or reduce labels on supporting metric groups.

## Habits

### Where It Feels Crowded

- STRIVE, System Integrity, Current Cadence, Daily Rhythm, Today Habits, and the first habit card all stack into one viewport.
- The Current Cadence card includes title, subtitle, metric grid, two large buttons, and progress in a compact block.
- The habit list begins while the bottom nav is already present.

### Dense Cards

- System Integrity is large and metric-heavy.
- Current Cadence is the most important card, but its internal controls are too close together.
- Daily Rhythm is a full panel even when it is mostly an empty chart.

### Spacing Issues

- System Integrity to Current Cadence is only a small gap.
- Current Cadence to Daily Rhythm is too tight.
- Today Habits header and habit row need more separation and bottom clearance.

### Hierarchy Issues

- System Integrity and Current Cadence both look like primary hero cards.
- Metric labels such as SYSTEM INTEGRITY, COGNITIVE LOAD, CURRENT CADENCE, DAILY RHYTHM, and ACTIVE PROTOCOLS compete.

### Recommended Changes

- Give Current Cadence more internal padding and action breathing room.
- Make System Integrity slightly calmer by reducing metric tile height and increasing internal rhythm.
- Treat Daily Rhythm as a quieter supporting module.
- Add a larger gap before the habit list.
- Increase habit row padding and inter-row spacing.

## Plan

### Where It Feels Crowded

- The current empty-state screen stacks Core Intent plus four similar empty strategic pillar cards.
- Repeated empty cards produce a wall-of-text effect.
- The fourth pillar is visibly compressed by the bottom dock.

### Dense Cards

- Core Intent copy is long and placed in a relatively compact card.
- Empty pillar cards repeat title, explanatory body, and add button four times.
- Strategic Pillars are full-weight cards even when no real GoalsStore data exists.

### Spacing Issues

- Core Intent headline to body card needs more room.
- Strategic Pillars section needs larger top and inter-card spacing.
- Bottom safe area is insufficient for the final visible pillar.

### Hierarchy Issues

- Four empty pillars feel equally important and urgent.
- The page headline is strong, but the following explanatory text is dense.

### Recommended Changes

- Keep the Stitch Plan structure, but reduce the repeated empty-state weight.
- Make empty pillar cards quieter with smaller copy and more whitespace.
- Increase section gaps and card run spacing.
- Keep goal/project/subproject/task actions intact below the first command area.
- Increase bottom padding above the dock.

## Focus

### Where It Feels Crowded

- Header, large timer, progress, peak card, controls, four metrics, weekly chart, heatmap, and target section all appear as a dense instrument panel.
- Metrics grid appears immediately under the timer hero and competes with the timer.
- Weekly Distribution and Heatmap are both heavy panels in the first scroll.

### Dense Cards

- Timer hero uses strong type and control grouping, which is correct, but needs more surrounding silence.
- Four metric tiles under the hero are dense and boxed.
- Weekly Distribution and Heatmap have large empty areas but still feel heavy because they are full cards.

### Spacing Issues

- Header to timer hero and timer hero to metrics need more breathing room.
- Chart/heatmap modules need larger gaps and slightly quieter internal padding.
- Bottom dock overlaps the start of the lower focus target area.

### Hierarchy Issues

- Timer should remain primary; weekly and heatmap panels should feel secondary.

### Recommended Changes

- Increase timer hero padding and timer-to-controls spacing.
- Reduce metric tile height and add larger gap after the hero.
- Lower chart/heatmap visual urgency by increasing spacing and reducing compact labels.
- Add stronger bottom safe area.

## Settings / My

### Where It Feels Crowded

- Current manual screenshot was not present; baseline and export context show the Settings page can become extremely dense because Theme Studio, color controls, data summary, review access, and future sections are stacked.
- The Theme Studio hero is visually strong, then Appearance and Global Controls repeat many similar controls.

### Dense Cards

- Appearance section has mode choices and color studio controls in a large text/control block.
- Global Controls repeats status pills, theme panel, accent strip, and local metrics.
- Data summary and Review access can feel like additional dashboards rather than quiet utilities.

### Spacing Issues

- Hero to control sections needs larger section rhythm.
- Mode choices and color controls need more internal padding.
- Bottom safe area should match nav pages when reached from bottom-nav surfaces.

### Hierarchy Issues

- Theme Studio should be the hero; data summary and future rows should be quieter utility content.

### Recommended Changes

- Increase page top and bottom padding.
- Increase hero-to-section and section-to-section gaps.
- Keep Theme Studio first and reduce repeated command-label pressure in supporting panels.
- Treat Review access and Data Summary as quieter utility rows.

## Review

### Where It Feels Crowded

- Review screenshot in `manual_premium_spacing_review` was not present. Existing code shows a header, status pills, hero metrics, habits section, plan section, focus section, and note with uniform 16px gaps.

### Dense Cards

- Review Overview, Habits, Plan, and Focus all use dense metric grids.
- Plan and Focus can show five metrics each, creating competing numeric blocks.

### Spacing Issues

- Section gaps are uniform and small for a recap surface.
- Bottom padding does not account for the floating dock when the route is reached from the shell.

### Hierarchy Issues

- The overview hero should be primary; individual sections should be calmer drill-down cards.

### Recommended Changes

- Increase gap after the header and between review sections.
- Increase bottom safe area.
- Reduce metric grid density where five metrics are shown.

## Bottom Navigation Compression

- Today, Habits, Plan, and Focus all show content under or very near the bottom dock.
- Current bottom padding values range from about 40px to 118px. The floating nav is 80px tall, so premium spacing needs at least 140-168px bottom padding on bottom-nav pages.
- Review and Settings should also include enough bottom clearance because they can be reached from the routed app flow.

## Page-By-Page Recommended Spacing Changes

- Today: top 28px, major section gap 28-34px, hero/command card padding 24px, chart/log gap 28px, bottom padding 160px.
- Habits: top 28px, stage card gaps 24-30px, current cadence padding 22-24px, habit list gap 28px, habit row bottom gap 14-16px, bottom padding 160px.
- Plan: top 24px, command-to-core gap 48px, core-to-pillars gap 30px, pillar run spacing 22-24px, bottom padding 168px.
- Focus: top 28px, header-to-hero gap 8px after header padding, timer hero padding 24px, hero-to-metrics gap 26px, chart gaps 24-28px, bottom padding 164px.
- Settings/My: top 28px, hero-to-controls gap 32px, section gap 28-32px, internal control panel padding 24px, bottom padding 144px.
- Review: top 28px, header-to-status gap 16px, overview-to-sections gap 26px, section gap 26px, bottom padding 144px.
