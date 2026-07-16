# P8 Navigation and I18N Audit

## Scope Inspected

- `lib/app/router/app_router.dart`
- `lib/shared/widgets/app_shell.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`

## 1. Main Pages Currently Showing A Back Button

- Today: yes. `_TodayTopBar` renders a top-left chevron button with tooltip `返回` and calls `Navigator.of(context).maybePop()`.
- Habits: no back button on the bottom-tab route because `HabitsPage(showScaffold: false)` is wrapped by `AppShell` without an app bar.
- Plan: no top-left back button on the bottom-tab route.
- Focus: no top-left back button, but it uses `StitchExactHeader` with a left terminal icon.
- Review: secondary route, `AppShell(showBottomNavigation: false)` uses `AppBar`, so Flutter may show an automatic back affordance when the route can pop.
- Settings/My: currently routed through `AppShell` with bottom navigation still visible and no app bar/back button.

## 2. Main Pages With Top-Right Actions

- Today: top-right `_ReviewAvatar` opens `AppRoute.review`.
- Habits: top-right plus icon inside the Strive header opens create habit.
- Plan: top-right has plus icon for create goal and a settings icon that opens `'/settings'`.
- Focus: top-right person icon from `StitchExactHeader` has no callback, so it is visually actionable but disabled/no-op.
- Settings/My: top-right settings icon in its custom header has no callback.
- Review: secondary app bar has a settings icon that opens Settings.

## 3. Broken Or No-Op Buttons

- Focus top-right person icon: no `onTrailing`, therefore it does not open anything.
- Settings/My top-right settings icon: `StitchExactIconPill(icon: Icons.settings_outlined)` has no `onTap`.
- AppRouter settings route uses `currentIndex: 3` and bottom navigation, making Settings look like Focus instead of a secondary My/Settings page.
- Today top-left back button is not broken technically, but it is wrong for the home tab.

## 4. Review Reachability

- Today top-right `_ReviewAvatar` opens `AppRoute.review`.
- Settings/My `_ReviewAccessConsole` opens `AppRoute.review`.
- Review route is defined in `AppRouter`.

## 5. Settings/My Reachability

- Plan top-right settings icon opens `'/settings'`.
- Review secondary app bar action opens `AppRoute.settings`.
- AppShell secondary app bar action opens Settings.
- Focus top-right does not currently open Settings/My.
- Today top-right currently opens Review, not Settings/My.

## 6. Major English UI Labels Still Visible

- AppRouter titles: `Habits`, `Theme Studio`.
- AppShell secondary action tooltip: `Theme Studio`.
- Today: `今日 / TODAY`, `FOCUS SCORE`, `PEAK RHYTHM`, `MOMENTUM METRICS`, `COMPLETION`, `VELOCITY`, `STREAK`, `PRIORITY EXECUTE`, `FOCUS FLUX`, `OPTIMUM RANGE`, `THRESHOLD`, `ACTION PLAN`, `开始执行 / INITIATE`, minute suffix `m`, `days`.
- Habits: standalone app bar title `Habits`, `STRIVE`, `系统完整性 (SYSTEM INTEGRITY)`, `当前节奏 (CURRENT CADENCE)`, `完成 (COMPLETE)`, `每日节奏 (DAILY RHYTHM)`, `活跃协议 (ACTIVE PROTOCOLS)`.
- Plan: `STRATEGIC COMMAND`, `核心意图 // CORE INTENT`, `Discipline is the Bridge to Goals.`, `战略支柱 // STRATEGIC PILLARS`, English strategy paragraph, `INTENSITY`, `FOCUS`, `COMPLETE`, `REVIEW`, `ADD GOAL`, `里程碑日志 // MILESTONE LOG`, `EMPTY`.
- Focus: `OPTIMIZE`, `Flow Status`, fallback target `Deep Work`, `session progress`, `Current Peak`, `best day sessions`, `PAUSE`, `RESUME`, `START`, `focus score`, `minutes`, `sessions`, `history`, `weekly dist`, `Weekly Distribution`, `M/T/W/T/F/S/S`, `heatmap`, `Consistency Heatmap`, `weekly review`.
- Review: `audit log`, `Review is preserved and uses only real local records.`, `check-ins`, `actions`, `focus`.
- Settings/My: `STRATEGIC COMMAND`, `strategic command`, `Global Controls`, `Theme Studio`, `mode`, `hex`, `local`, `theme studio`, `Dark Mode Force / Primary Accent / Color Lab`, `dark mode force`, `primary accent`, `habits`, `actions`, `focus`, `storage`, `LOCAL`, `audit log`, `Review is preserved outside the 5-screen bottom navigation.`, `review access`, `OPEN`.

## 7. Recommended Unified Navigation Rule

- Bottom-tab pages are Today, Habits, Plan, and Focus.
- Bottom-tab pages must not show top-left back buttons.
- Top-right actions must be real actions:
  - Today: open Review (`复盘`) so Review remains reachable from the home tab.
  - Habits: create habit (`新建习惯`).
  - Plan: create goal (`新建目标`); settings can remain as a secondary icon only if it opens Settings/My and is labeled clearly.
  - Focus: select task if idle, otherwise open Settings/My; no decorative no-op icon.
- Review and Settings/My should be secondary routes without bottom navigation. They may show a back button and should use Chinese titles.
