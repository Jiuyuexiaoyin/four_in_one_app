# P8 Premium UI Consistency Audit

Date: 2026-07-12

## Target rhythm

- Horizontal page padding: 20–24 px (shared target 22 px)
- Top content spacing: 20–28 px (shared target 28 px after SafeArea)
- Major section gap: 24–32 px (shared target 30 px)
- Related card gap: 12–16 px
- Card padding: 18–24 px
- Label/title gap: 6–10 px
- Title/description gap: 8–12 px
- Bottom clearance above main dock: 112–136 px (target 128 px)
- Secondary page bottom clearance: about 56 px because no dock is present

## Page audit

| Page | Finding | Required improvement |
| --- | --- | --- |
| Today | 20 px horizontal is acceptable; top inset is page-local; major gaps reach 38–50 px; fixed schedule labels imply fake precision | Use shared SafeArea/header, normalize major gaps near 30 px, derive labels from real due/reminder state |
| Habits | Shared 22/28 padding is close; header differs; hero keeps a disabled action when no pending habit; inactive action label is misleading | Shared header, explicit empty explanation, lifecycle-accurate state copy |
| Plan | Top is 24 px and many major gaps are only 18 px; custom header is wider/heavier than other tabs | Shared 28 px header rhythm and 24–30 px major spacing |
| Focus | Shared 22/28 padding; analytics dominate before setup; timer commands appear twice | Put target/duration/one command surface before analytics; keep weekly/heatmap lower |
| Review | 26 px section gaps are within range; secondary bottom padding is excessive | Keep sections; reduce no-dock bottom space; translate remaining English status labels |
| Settings | Repeats a large hero, Theme Studio, theme console, and accent strip; 4:5 hero grows excessively on wide web | Constrain content/hero width, remove no-op controls, reduce repeated theme weight |

## Cross-page findings

- Header title alignment, icon size, action size, radius, spacing, and tooltip behavior are inconsistent across all four main pages.
- AppShell SafeArea is inverted for main versus secondary pages.
- Only Today constrains its content width; other pages can stretch excessively on desktop Chrome.
- Shared main bottom padding was 160 px, above the requested range, while Today used 118 px.
- Header/icon targets ranged from 34 to 40 px; the shared header target is 44–48 px.
- Plan’s custom progress geometry uses a fixed width and should use available constraints.
- Review still contains `recap`, `REAL`, and `EMPTY`; Settings exposes raw `system/light/dark` values and a fake “版本 01”.

## Preserved direction

The accepted carbon-dark UI, cyan/green/purple accent family, compact technical typography, real Store-backed panels, and advanced-detail disclosure model remain the visual foundation. The recommended work is hierarchy, spacing, feedback, and consistency—not a new redesign.
