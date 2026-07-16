# P8 Stitch UI Forensic Audit

Date: 2026-07-07

## Scope

This audit reviewed the previous `STITCH_UI_REBUILD_READY_FOR_REVIEW` work using:

- `git status --short`
- `git diff --stat`
- `git diff --name-only`
- targeted diffs for Today, Habits, Plan, Focus, Review, Settings, `AppShell`, `lib/app/theme`, and `lib/shared/widgets/visual_dna`
- `reports/stitch_to_flutter_mapping.md`
- `reports/p8_stitch_ui_rebuild_report.md`
- `rg "VisualDna|VisualDNA|visual_dna" lib/features lib/shared lib/app`

## Worktree State

The repo is dirty. Modified files include active routed page files, the app shell, theme files, several store/storage/domain files, and `pubspec.lock`. `lib/shared/widgets/visual_dna/` and `reports/` are untracked.

`git diff --stat` shows 16 tracked files changed with 718 insertions and 445 deletions. Because `lib/shared/widgets/visual_dna/` is untracked, `git diff -- lib/shared/widgets/visual_dna` returned no content even though `visual_dna_widgets.dart` exists.

## Findings

### 1. Did previous work modify active routed page files?

Yes. The previous work modified all six active page files requested for review:

- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`

However, the changes were uneven. Today received the largest routed change. Habits, Focus, Review, and Settings kept much of the previous layout and only inserted or swapped limited sections. Settings only imported Visual DNA for the page header, with the main settings sections still mostly old product widgets.

### 2. Are the new Visual DNA widgets imported and used?

Partially yes.

`rg` confirms active imports/usages in:

- Today: `VisualDnaPanel`, `VisualDnaPageHeader`, `VisualDnaProgressBar`, `VisualDnaMetricGrid`, `VisualDnaMiniBars`
- Habits: `_HabitsVisualDnaStats`, `VisualDnaPanel`, `VisualDnaPageHeader`, `VisualDnaProgressBar`, `VisualDnaMetricGrid`, `VisualDnaMiniBars`
- Goals/Plan: `VisualDnaPageHeader`, `VisualDnaPanel`, `VisualDnaProgressBar`, `VisualDnaMetricGrid`
- Focus: `VisualDnaPageHeader`, `VisualDnaPanel`, `VisualDnaMetricGrid`, `VisualDnaMiniBars`
- Review: `VisualDnaPageHeader`, `VisualDnaPanel`, `VisualDnaMetricGrid`
- Settings: `VisualDnaPageHeader` only

This means the widgets are wired into active routed pages, but they are not consistently dominant across the whole UI.

### 3. Did AppShell / bottom navigation change?

Yes. `AppShell` changed from a soft translucent navigation container to a darker blurred bottom navigation with black opacity, cyan border/glow, and a background grid/gradient overlay. The bottom routes remained Today, Habits, Plan, Focus, Review.

### 4. Did theme tokens change enough to affect the visible app?

Yes, but not enough by themselves to guarantee a visibly different routed experience everywhere.

Theme changes include:

- black/graphite dark tokens
- electric cyan accent
- purple secondary and acid-green tertiary
- smaller card radii
- lower-opacity borders
- darker default surface fallback
- removal of global transparent `ListTileTheme.tileColor`

These are real visible theme-level changes, but pages that still render old component structures can still look like the old app with darker colors.

### 5. Is there evidence Stitch MCP was successfully used?

The prior reports claim Stitch MCP access and identify project `projects/9831732537281731917`, but the repo did not contain independent raw MCP proof before this phase. This phase separately proved Stitch MCP access and wrote proof to `reports/stitch_mcp_access_proof.md`.

## Forensic Verdict

The previous rebuild was not fake, because it did modify active routed pages, theme files, and `AppShell`, and it did wire shared Visual DNA widgets into active pages.

It was also not a hard visual rebuild. Several screens kept their old page architecture, spacing, and product widgets, with new Visual DNA sections added as partial overlays. That can plausibly explain the user's manual observation that the app still looked almost identical to the old version.

Hard apply is justified.
