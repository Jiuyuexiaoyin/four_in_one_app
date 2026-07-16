# P8 Premium Spacing Rules

These rules keep the current dark Stitch UI direction while reducing tension and density. Values are practical Flutter constants and should be implemented without changing business logic.

## Global Constants

Use these values as the premium density baseline:

```dart
abstract final class StitchExactPremiumSpacing {
  static const pageX = 22.0;
  static const pageTop = 28.0;
  static const pageBottom = 160.0;
  static const pageBottomSecondary = 144.0;
  static const section = 30.0;
  static const sectionTight = 24.0;
  static const card = 18.0;
  static const cardLarge = 24.0;
  static const cardGap = 16.0;
  static const cardGapRelaxed = 22.0;
  static const titleGap = 10.0;
  static const subtitleGap = 8.0;
  static const metricGap = 14.0;
  static const metricRunGap = 14.0;
  static const silent = 36.0;
}
```

## Page Horizontal Padding

- Mobile page padding: `22px`.
- Wider constrained content remains max-width limited by the existing StitchExact page conventions.
- Do not reduce page padding below `20px` on dark Stitch screens.

## Top Spacing

- Bottom-nav pages should start at `28px` from safe content top.
- Plan may use `24px` because the grid background has strong visual gravity.
- Headers should reserve `24-28px` below themselves before the first large module.

## Section Spacing

- Major sections: `30px`.
- Tight related sections: `24px`.
- Avoid placing two full panels with only `12px` between them unless they are part of the same component.

## Card Internal Padding

- Primary hero or command card: `24px`.
- Normal full-width cards: `20-22px`.
- Small utility cards: `16-18px`.
- Dense empty-state cards should use at least `20px` padding and softer text weight, not compressed body copy.

## Card Gap

- Repeated card list gap: `16px` minimum.
- Premium dashboard card run spacing: `22-24px`.
- Habit rows and plan hierarchy rows should use `14-16px` vertical gaps.

## Title / Subtitle Rhythm

- Label to title: `8-10px`.
- Title to subtitle: `8-10px`.
- Subtitle to controls or metrics: `16-20px`.
- Avoid putting uppercase labels directly above large numbers without a small silent gap.

## Metric Grid Spacing

- Tile spacing and run spacing: `14px`.
- Supporting metric min height: `74-78px`.
- Dashboard metric min height: `82-90px`.
- Avoid more than four heavy metrics in a single viewport unless the metrics are the primary purpose of that screen.
- When five or more real metrics are needed, place them lower on the page or use a quieter row/utility treatment.

## Bottom Safe Area

- Bottom-nav pages: at least `160px` bottom padding.
- Non-bottom-nav Settings/Review pages: at least `144px` bottom padding.
- If a page uses a floating dock, final visible content should never start underneath the dock.

## Max Visual Density Per Screen

- First viewport should contain one primary hero/command card.
- First viewport may contain one secondary metrics group.
- Charts, logs, and secondary snapshots should start lower unless they are the page's main job.
- Avoid four or more heavy full-width cards before the user scrolls.

## Content That Should Move Lower

- Today: Focus Flux, Action Plan, habit/plan/focus snapshots.
- Habits: Daily Rhythm and habit list after Current Cadence.
- Plan: repeated empty strategic pillars and functional execution path.
- Focus: Weekly Distribution, Heatmap, target selector, duration selector.
- Settings: data summary, review access, reminder/about utility sections.
- Review: detailed Habits/Plan/Focus metric panels after the overview hero.

## Labels To Reduce Or Soften

- Repeated uppercase technical labels in supporting panels.
- Empty-state pillar labels.
- Secondary metric labels that appear next to already clear values.
- Labels that repeat route identity, such as multiple command labels on one page.

## Page-Specific Rules

### Today

- Keep Focus Score identity, but do not let it be the only dominant element when score is empty.
- Keep Priority Execute as the dominant action card.
- Use larger gaps around Peak Rhythm, Momentum Metrics, Priority Execute, Focus Flux, and Action Plan.
- Use quieter supporting metrics and more bottom clearance.

### Habits

- STRIVE header remains direct and high-contrast.
- Current Cadence receives premium internal padding and action breathing room.
- Daily Rhythm becomes a quiet supporting module.
- Habit/check-in area gets more vertical space than metadata cards.

### Plan

- Preserve Strategic Command, Core Intent, Strategic Pillars, and Milestone Log.
- Use more gap before and after Core Intent.
- Empty pillars should be quieter and more breathable.
- Keep all create/edit goal/project/subproject/task actions intact.

### Focus

- Timer hero stays primary.
- Increase whitespace around timer and controls.
- Metrics become supporting.
- Weekly Distribution and Heatmap sit lower and use calmer spacing.

### Settings / My

- Theme Studio remains the primary hero.
- Appearance, Color Lab, data summary, and Review access get larger section spacing.
- Utility sections should not compete with Theme Studio.

### Review

- Review overview hero is primary.
- Habits, Plan, and Focus panels are detail sections with larger section gaps.
- Preserve real-record-only behavior.
