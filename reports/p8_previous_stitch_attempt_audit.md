# P8 Previous Stitch Attempt Audit

Date: 2026-07-07

## Commands Run

- `git status --short`
- `git diff --stat`
- `git diff --name-only`
- `rg "VisualDna|VisualDNA|Stitch|Neon|Cyber|Command" lib reports`

## Worktree Summary

The working tree is dirty. Modified tracked files include:

- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_theme_tokens.dart`
- `lib/shared/widgets/app_shell.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- several store/storage/model files outside pure presentation
- `pubspec.lock`

Untracked paths include:

- `lib/shared/widgets/visual_dna/`
- `reports/`
- `.playwright-mcp/`

`git diff --stat` currently reports 21 tracked files changed with 1283 insertions and 652 deletions.

## Existing Report Findings

Previously written reports already acknowledge these facts:

- `reports/stitch_to_flutter_mapping.md` says the original bottom navigation was Today, Habits, Plan, Focus, Review, while Settings was reached separately.
- `reports/p8_stitch_ui_rebuild_report.md` says Stitch HTML fetch was blocked by the local network sandbox and implementation used project metadata, screen metadata, screenshot references, and design-system data.
- `reports/p8_stitch_ui_forensic_audit.md` says active routed page files were modified, but several screens kept old page architecture and only added Visual DNA sections.
- `reports/p8_stitch_ui_hard_apply_report.md` ends with `BLOCKED_BY_RUNTIME` and states that extra direct edits to Today, Goals, and AppShell failed.
- `reports/stitch_mcp_access_proof.md` proves project identity and screen references, but also says raw generated HTML and node-level layout JSON were not returned inline.

## Active Route Inspection

### 1. Did the previous task actually change active routed page files?

Yes. The active routed page files are modified in the working tree:

- Today: `lib/features/today/presentation/pages/today_page.dart`
- Habits: `lib/features/habits/presentation/pages/habits_page.dart`
- Plan: `lib/features/goals/presentation/pages/goals_page.dart`
- Focus: `lib/features/focus/presentation/pages/focus_page.dart`
- Review: `lib/features/review/presentation/pages/review_page.dart`
- Settings/My: `lib/features/settings/presentation/pages/settings_page.dart`

However, this was not a clean route-level replacement. Today still includes the older `_TodayRhythmCanvas` structure. Habits still presents `_HabitsRhythmStage`, `_HabitsListHeader`, and list-first habit rows before the later Visual DNA stats/matrix blocks. Settings still has the existing settings stack, with a Theme Studio hero inserted but not promoted to a bottom tab.

### 2. Are new visual components actually imported and used by those pages?

Partially yes.

`rg` confirms `VisualDna` usage in Today, Habits, Goals, Focus, Review, Settings, shared product panels, and `lib/shared/widgets/visual_dna/visual_dna_widgets.dart`.

The usage is real, but it is not uniformly dominant. The previous attempt added a Visual DNA layer around existing workflows; it did not fully replace every active page layout.

### 3. Is the bottom navigation still using Review instead of My/Settings?

Yes.

`lib/shared/widgets/app_shell.dart` still defines the bottom routes as:

- Today
- Habits
- Goals/Plan
- Focus
- Review

`lib/app/router/app_router.dart` still routes `/review` with `currentIndex: 4`. `/settings` is routed with `showBottomNavigation: false` and `currentIndex: 0`.

This directly contradicts the requested Stitch 5-core model of Today / Habits / Plan / Focus / My.

### 4. Is there hard evidence that Stitch screen contents were used?

There is hard evidence that Stitch MCP project metadata, design-system tokens, target screen names, target screen IDs, dimensions, screenshot file references, and HTML file references were used.

There is not hard evidence that actual Stitch screen layout/content/code was read. The existing reports state that raw HTML and node-level layout JSON were not returned inline. The previous implementation therefore appears to be a generic dark/cyan Visual DNA interpretation rather than a faithful extraction from actual screen contents.

### 5. Which previous changes should be kept, and which should be overwritten?

Keep:

- `lib/shared/widgets/visual_dna/visual_dna_widgets.dart` as reusable building blocks.
- Theme token movement toward black/graphite/cyan/purple/green.
- Functional fixes that made analyze/tests pass, especially non-visual store/storage/model fixes, unless separately reviewed.
- Visual hardening of shared product surfaces where it does not remove real functionality.

Overwrite or replace:

- AppShell bottom navigation: replace Review with My/Settings as the fifth core tab.
- Today route composition: remove or demote old rhythm-canvas presentation and make the dense dashboard the primary route.
- Habits route composition: stop list-first visual structure; put Habit Command/stats/matrix hierarchy first while preserving real habit cards/actions.
- Settings route: make My/Settings an active bottom-nav page, not a hidden app-bar destination.
- Any report language claiming a faithful hard Stitch apply without actual screen code/layout extraction.

## Audit Verdict

The previous attempt changed active routed files and used Visual DNA widgets, so it was not entirely unused. It did not satisfy the current product requirement because the active nav model stayed wrong, the routed pages retained major old layout structures, and there is no proof that raw Stitch screen content was extracted.
