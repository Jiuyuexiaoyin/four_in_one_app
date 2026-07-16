# P8 Navigation and I18N Fix Plan

## 1. Header Rules To Apply

- Today, Habits, Plan, and Focus remain the only bottom-tab pages.
- Main-tab pages must not display a top-left back button.
- Main-tab top-right controls must be intentional, clickable, and described in Chinese tooltips.
- Review and Settings/My become secondary pages with Chinese titles and no bottom navigation.
- Keep the current visual direction and layout density; only adjust labels, callbacks, and small header behavior.

## 2. Page-Specific Header Behavior

- Today:
  - Title becomes `今天`.
  - Remove top-left `maybePop` back button.
  - Keep top-right action to open `AppRoute.review`, tooltip `复盘`.

- Habits:
  - Route/app bar title becomes `习惯`.
  - Keep top-right plus icon in the Habits header as create habit.
  - Standalone scaffold title becomes `习惯`.

- Plan:
  - Title remains `计划`.
  - Keep plus icon as the primary top-right action: create goal.
  - Keep settings as a secondary, clearly clickable Settings/My action using `AppRoute.settings` rather than a string literal route.

- Focus:
  - Header title becomes `专注`.
  - Remove the no-op person icon behavior by wiring top-right to Settings/My.
  - No top-left back button.
  - Existing target picker, timer start/pause/reset, and duration controls remain unchanged.

- Review:
  - Secondary page title `复盘`.
  - Back behavior may remain via secondary AppBar.
  - Settings/My remains reachable from the secondary app bar.

- Settings/My:
  - Secondary page title `我的`.
  - No bottom navigation.
  - Review remains reachable from the existing review access panel.

## 3. Chinese Copy Replacements

- Today:
  - `FOCUS SCORE` -> `今日评分`
  - `PEAK RHYTHM` -> `高效节奏`
  - `MOMENTUM METRICS` -> `推进指标`
  - `COMPLETION` -> `完成度`
  - `VELOCITY` -> `推进率`
  - `STREAK` -> `连续性`
  - `PRIORITY EXECUTE` -> `优先行动`
  - `FOCUS FLUX` -> `专注趋势`
  - `OPTIMUM RANGE` -> `适宜区间`
  - `THRESHOLD` -> `阈值`
  - `ACTION PLAN` -> `行动计划`
  - `开始执行 / INITIATE` -> `开始执行`

- Habits:
  - `STRIVE` -> `习惯`
  - `系统完整性 (SYSTEM INTEGRITY)` -> `系统完整性`
  - `当前节奏 (CURRENT CADENCE)` -> `当前节奏`
  - `完成 (COMPLETE)` -> `完成`
  - `每日节奏 (DAILY RHYTHM)` -> `每日节奏`
  - `活跃协议 (ACTIVE PROTOCOLS)` -> `活跃习惯`

- Plan:
  - `STRATEGIC COMMAND` -> `计划中心`
  - `核心意图 // CORE INTENT` -> `核心目标`
  - `战略支柱 // STRATEGIC PILLARS` -> `关键支柱`
  - `里程碑日志 // MILESTONE LOG` -> `里程记录`
  - English strategy sentence/paragraph -> concise Chinese copy.
  - `INTENSITY`, `FOCUS`, `COMPLETE`, `REVIEW`, `ADD GOAL`, `EMPTY` -> Chinese equivalents.

- Focus:
  - `OPTIMIZE` -> `专注`
  - `Flow Status` -> `专注状态`
  - `session progress` -> `本轮进度`
  - `Current Peak` -> `本周峰值`
  - `best day sessions` -> `单日最高轮次`
  - `PAUSE`/`RESUME`/`START` -> `暂停`/`继续`/`开始`
  - Metrics and chart labels -> Chinese.

- Review and Settings/My:
  - Translate audit/settings/studio/storage/action labels into Chinese.
  - Preserve real functionality and test keys.

## 4. Files To Modify

- `lib/app/router/app_router.dart`
- `lib/shared/widgets/app_shell.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/features/goals/presentation/pages/goals_page.dart`
- `lib/features/focus/presentation/pages/focus_page.dart`
- `lib/features/review/presentation/pages/review_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- Tests only if existing assertions must be updated for corrected Chinese copy/navigation.

## 5. What Must Not Change

- Store logic, data models, storage, and existing create/check-in/edit/reminder/stat/statistics flows.
- Goals/projects/tasks behavior.
- Focus timer start/pause/reset behavior.
- Settings/theme/color studio behavior.
- Review data aggregation.
