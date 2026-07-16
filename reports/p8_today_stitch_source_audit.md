# P8 Today Stitch Source Audit

## Verdict

Exact Today reference found.

Primary source:
`.ai_reference\stitch\export_20260708\stitch_app\stitch_app\final_synthesis_2\code.html`

Visual screenshot:
`.ai_reference\stitch\export_20260708\stitch_app\stitch_app\final_synthesis_2\screen.png`

Supporting product brief:
`.ai_reference\stitch\export_20260708\程式码.txt`

Project intro:
`.ai_reference\stitch\export_20260708\项目简介.txt` is present but empty.

## Why This Is The Today Screen

`final_synthesis_2\code.html` declares:

```html
<title>Today - Premium Productivity</title>
```

The mobile app bar contains:

```html
<h1 class="text-headline-md font-headline-md font-bold text-on-surface">今日 / TODAY</h1>
```

The bottom navigation marks Today as active:

```html
<!-- Active Tab: 今天 (Today) -->
```

The screenshot at `final_synthesis_2\screen.png` visually matches these same sections.

## Supporting Brief

`.ai_reference\stitch\export_20260708\程式码.txt` defines Today as:

```md
### A. Today (今日中心) - Daily Command Center
*   **Key Features:** Daily Readiness score, Cognitive Load metrics, high-priority action queue, and peak performance windows.
*   **Visual Anchor:** Technical-editorial dashboard with real-time data visualization.
```

The same brief defines the design DNA:

```md
**Color Palette:** Deep Carbon backgrounds (`#131313`), Surface-dimmed containers, and high-energy accents (Cyan Core `#00E5FF`, Toxic Green, Critical Red).
**Typography:** Hanken Grotesque. High-contrast hierarchy, heavy use of caps for labels, and tactical mono-spaced data readouts.
**UI Density:** High information density handled through clean, precise spacing and micro-details.
```

## Today HTML/CSS Source Sections

### Theme Tokens

`final_synthesis_2\code.html` lines 15-61 define the Today palette:

```html
"primary-container": "#00e5ff",
"tertiary-container": "#6cec00",
"surface": "#131313",
"surface-container": "#201f1f",
"surface-container-low": "#1c1b1b",
"surface-container-high": "#2a2a2a",
"on-surface": "#e5e2e1",
"on-surface-variant": "#bac9cc"
```

Lines 63-77 define sharp radii and spacing:

```html
borderRadius: { "DEFAULT": "0.125rem", "lg": "0.25rem", "xl": "0.5rem", "full": "0.75rem" }
spacing: { "section-gap": "48px", "container-padding-mobile": "20px", "gutter": "16px" }
```

Lines 79-102 define typography:

```html
fontFamily: Hanken Grotesk, Inter, JetBrains Mono
fontSize: display 48/52, mobile display 36/40, headline 24/32, label caps 12/16
```

Lines 112-139 define the body background and chart grid:

```css
body { background-color: #131313; color: #e5e2e1; }
.glass-border { border: 1px solid rgba(255, 255, 255, 0.05); }
.chart-grid { background-size: 20% 25%; }
```

### Section Order

The exported Today structure is:

1. Top app bar, mobile only, with back chevron, `今日 / TODAY`, profile avatar.
2. Desktop side nav, not directly applicable inside the existing Flutter `AppShell`.
3. Main content canvas.
4. Focus Score hero.
5. Peak Rhythm insight card.
6. Momentum Metrics: Completion, Velocity, Streak.
7. Priority Execute card.
8. Focus Flux chart.
9. Action Plan timeline.
10. Bottom navigation, mobile only, with Today/Habits/Plan/Focus.

### Focus Score

`final_synthesis_2\code.html` lines 170-190:

```html
<span class="text-data-sm font-data-sm uppercase tracking-wider">Focus Score</span>
<h2 class="text-[80px] ...">88</h2>
<span class="text-headline-md ...">%</span>
<p class="text-data-sm ...">Oct 24, 2025</p>
...
<span class="text-label-caps ... text-tertiary-container uppercase">Peak Rhythm</span>
<p>今日认知能量充足，适合处理高难度逻辑任务。</p>
```

Flutter mapping must not hardcode `88`; it should derive the score from real habit, plan, and focus activity.

### Momentum Metrics

`final_synthesis_2\code.html` lines 196-237:

```html
<h3 ...>Momentum Metrics</h3>
...
<span ...>92%</span>
<div ...>COMPLETION</div>
<div ...>今日习惯</div>
...
<span ...>1.2x</span>
<div ...>VELOCITY</div>
<div ...>计划推进</div>
...
<div ...>STREAK</div>
<div ...>连续</div>
```

Flutter mapping:
- Completion: real `HabitsStore.completedCount / HabitsStore.totalCount`.
- Velocity: real completed plan actions over total actions from `GoalsStore.tasks`.
- Streak: real recent active days from habit activity.

### Priority Execute

`final_synthesis_2\code.html` lines 244-264:

```html
<span ...>Priority Execute</span>
<span ...>14:00</span>
<h3 ...>架构方案终审</h3>
<p ...>适合现在推进，完成后再进入专注 (Peak cognitive window identified. High focus expected.)</p>
<span ...>timer</span> 120m
<button ...>开始执行 / Initiate</button>
```

Flutter mapping:
- Title: first open `GoalTaskItem`, else first pending `HabitItem`, else focus-ready fallback.
- Duration chip: real selected focus duration from `FocusStore.selectedDurationSeconds`.
- Button: navigate to Plan for a plan action, check in a pending habit when the priority is a habit, otherwise navigate to Focus.

### Focus Flux

`final_synthesis_2\code.html` lines 270-292:

```html
<h3 ...>Focus Flux</h3>
<span ...>Optimum Range</span>
<div class="h-48 ... chart-grid ...">
<path ... d="M 0 80 L 15 65 ... L 100 70" stroke="#00e5ff">
<span>08:00</span><span>12:00</span><span>16:00</span><span>20:00</span>
<div ...>THRESHOLD</div>
```

Flutter mapping:
- Keep the section and visual line chart.
- Use real recent habit/focus counts to shape the chart instead of the static SVG path.

### Action Plan

`final_synthesis_2\code.html` lines 297-359:

```html
<h3 ...>Action Plan</h3>
09:00 Finalize Architecture Review
11:30 Anaerobic Threshold Run
14:00 Weekly Sync & Strategy
```

Flutter mapping:
- Preserve the three-row timeline structure.
- Populate rows from real open plan actions first, then pending habits, then focus fallback if there are no real items.
- Rows navigate to the corresponding real page or perform the real habit check-in action.

### Bottom Spacing And Navigation

`final_synthesis_2\code.html` line 140 applies:

```html
<body class="... pb-24 md:pb-0 overflow-x-hidden">
```

Flutter already wraps Today inside `AppShell`, so bottom navigation is supplied by existing app infrastructure. The Today page should keep sufficient bottom padding for the shell nav rather than duplicate a second nav.

## Current Flutter Today Gaps Found Before Editing

Current file:
`lib\features\today\presentation\pages\today_page.dart`

The current Today page already includes these exported labels:
- `Focus Score`
- `Peak Rhythm`
- `Momentum Metrics`
- `Priority Execute`
- `Focus Flux`
- `Action Plan`

But it continues past the exported Action Plan into extra non-exported bands:
- `_TodayHabitsBand`
- `_PlanSnapshot`
- `_FocusSnapshot`
- `StitchExactUtilityRow` for review

Those extra sections are not present in the exported Today reference and should be removed from the visible Today flow, while their real data bindings must be preserved inside the Stitch-derived sections where appropriate.
