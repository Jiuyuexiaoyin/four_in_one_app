# P8 Habits Stitch Source Audit

## Verdict

Exact Habits reference found.

Primary source:

- `.ai_reference\stitch\export_20260708\stitch_app\stitch_app\scale_proportion_refinement\code.html`

Visual screenshot:

- `.ai_reference\stitch\export_20260708\stitch_app\stitch_app\scale_proportion_refinement\screen.png`

Supporting product brief:

- `.ai_reference\stitch\export_20260708\程式码.txt`

Project intro:

- `.ai_reference\stitch\export_20260708\项目简介.txt` is present but empty.

## Why This Is The Habits Screen

`scale_proportion_refinement\code.html` declares:

```html
<title>Strive - Habits</title>
```

The mobile header contains:

```html
<h1 class="font-display-lg-mobile text-display-lg-mobile uppercase tracking-tight">STRIVE</h1>
```

The navigation marks Habits as active:

```html
<a class="... text-primary-fixed-dim ...">习惯</a>
```

The mobile bottom nav marks Habits active:

```html
<span class="material-symbols-outlined text-[20px] icon-fill">rebase_edit</span>
<span class="font-label-caps text-[9px] uppercase font-bold tracking-wider">习惯</span>
```

## Supporting Brief

`.ai_reference\stitch\export_20260708\程式码.txt` defines Habits as:

```md
### B. Habits (习惯节奏) - Cadence Control
*   **Role:** Managing the recurring rhythms of life and training.
*   **Key Features:** Cadence timelines, streak instrumentation, and ritual tracking.
*   **Visual Anchor:** Instrument-like grid layouts and rhythmic status indicators (LED-style dots).
```

The same brief defines the design DNA:

```md
**Color Palette:** Deep Carbon backgrounds (`#131313`), Surface-dimmed containers, and high-energy accents (Cyan Core `#00E5FF`, Toxic Green, Critical Red).
**Typography:** Hanken Grotesque. High-contrast hierarchy, heavy use of caps for labels, and tactical mono-spaced data readouts.
**UI Density:** High information density handled through clean, precise spacing and micro-details.
```

## Theme, Typography, And Spacing

`scale_proportion_refinement\code.html` lines 17-62 define the Habits palette:

```html
"background": "#131313",
"surface-container": "#201f1f",
"surface-container-lowest": "#0e0e0e",
"surface-container-highest": "#353534",
"primary-fixed-dim": "#00daf3",
"primary-container": "#00e5ff",
"tertiary-container": "#6cec00",
"on-surface": "#e5e2e1",
"on-surface-variant": "#bac9cc"
```

Lines 64-78 define compact radii and spacing:

```html
borderRadius: DEFAULT 0.125rem, lg 0.25rem, xl 0.5rem, full 0.75rem
spacing: page padding mobile 20px, gutter 16px, stack-md 12px, section-gap 48px
```

Lines 81-101 define fonts:

```html
Hanken Grotesk for display/headlines/data-lg
Inter for body
JetBrains Mono for labels/data-sm
display mobile: 28px/32px, label caps: 11px/16px, body: 14px/20px
```

## Exact Screen Sections

### Header

`scale_proportion_refinement\code.html` lines 158-165:

```html
<span class="material-symbols-outlined text-primary-fixed-dim text-xl" ...>bolt</span>
<h1 class="font-display-lg-mobile text-display-lg-mobile uppercase tracking-tight">STRIVE</h1>
<div class="h-8 w-8 rounded-xl overflow-hidden border border-white/10">
```

Flutter mapping:

- Keep `STRIVE`.
- Use an add-control/profile-equivalent in the right slot to preserve create habit.

### System Integrity

`scale_proportion_refinement\code.html` lines 169-220:

```html
<h2 ...>系统完整性 (SYSTEM INTEGRITY)</h2>
<p ...>每日准备就绪</p>
<div ...>78%</div>
<span ...>认知负荷 (Cognitive Load)</span>
<span ...>最佳</span>
```

Metric blocks:

```html
恢复 82/100
压力 14.2
睡眠 7h12m
```

Flutter mapping:

- Completion percentage must use real `HabitsStore.completedCount / totalCount`.
- `恢复` maps to completed habits.
- `压力` maps to remaining habits.
- `睡眠` visual slot maps to today check-ins because no sleep store exists.

### Current Cadence

`scale_proportion_refinement\code.html` lines 221-249:

```html
<h3 ...>当前节奏 (CURRENT CADENCE)</h3>
<h4 ...>深度工作区块 I</h4>
<p ...>严格专注于高杠杆架构任务。零干扰。</p>
目标 90m
已用时 42m
<button ...>完成 (COMPLETE)</button>
```

Flutter mapping:

- Use next pending real habit as current cadence.
- `目标` maps to habit target count per day.
- `已用时` maps to today check-in count for that habit.
- `完成 (COMPLETE)` performs real `HabitsStore.checkIn`.

### Daily Rhythm

`scale_proportion_refinement\code.html` lines 251-294:

```html
<h3 ...>每日节奏 (DAILY RHYTHM)</h3>
<span ...>82%</span>
```

The chart uses seven bars labeled:

```html
一 二 三 四 五 六 日
```

Flutter mapping:

- Use real weekly habit check-in totals from `HabitsStore.recentActivityDays`.
- Keep a bar chart with Friday/active-day emphasis where possible.

### Active Protocols

`scale_proportion_refinement\code.html` lines 296-386:

```html
<h3 ...>活跃协议 (ACTIVE PROTOCOLS)</h3>
```

Protocol card structure:

```html
icon tile
habit title
subtitle/target
large streak number
连续
seven small rhythm dots labeled 一 二 三 四 五 六 日
```

Example visible text:

```html
补水协议
每日 3L 目标
晨间运动
Zone 2 有氧
深度阅读
30 页
```

Flutter mapping:

- Render real active habits first, then archived/paused sections if needed.
- Use real habit name, description/target, today count, target count, reminder summary, lifecycle state, and recent activity.
- Preserve controls for check-in, reminder, edit, lifecycle, records, monthly rhythm, and statistics.

### Mobile Bottom Navigation

`scale_proportion_refinement\code.html` lines 389-407 defines bottom nav.

Flutter already supplies navigation through `AppShell`, so the Habits page should keep bottom padding and not duplicate a second nav.

## Current Flutter Habits Gaps Found Before Editing

Current file:

- `lib\features\habits\presentation\pages\habits_page.dart`

It already contains some Stitch labels:

- `STRIVE`
- `系统完整性 (SYSTEM INTEGRITY)`
- `当前节奏 (CURRENT CADENCE)`
- `每日节奏 (DAILY RHYTHM)`

But it continues into extra non-exported visible sections:

- `_HabitsListHeader`
- `_HabitsStitchExactStats`
- `_HabitsActivityMatrix`
- `_HabitInsightPreview`
- `_RecentRecordPreview`

And current habit rows are generic dense control cards rather than the exported `ACTIVE PROTOCOLS` structure. Those rows need to be structurally reshaped while keeping their real controls and keys.
