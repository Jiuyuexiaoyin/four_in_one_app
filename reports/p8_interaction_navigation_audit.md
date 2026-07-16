# P8 Interaction and Navigation Audit

Date: 2026-07-12
Method: source, Store, route, and current widget-test inspection. Browser verification is recorded separately in the final system-QA report.

## Navigation rules

- Main tabs are `/today`, `/habits`, `/goals`, and `/focus`; they must use the bottom dock and must not show a back button.
- `/review` and `/settings` are secondary routes; they may show a back button and must return to their caller.
- Main-tab changes should replace the current main route. Secondary pages should be pushed normally.
- Every icon button needs a Chinese tooltip. A disabled control must state why it is unavailable. Decorative imagery must not be represented as a button.

## Interaction matrix

| Page | Visible control | Expected behavior | Actual route / Store method | Audit status | Defect / required fix | Existing coverage |
| --- | --- | --- | --- | --- | --- | --- |
| Today | 复盘 header action | Open Review | `pushNamed(AppRoute.review)` | Wired | Shared-header integration required | No visible-control route test |
| Today | 我的/设置 header action | Open My/Settings | Missing at baseline | Defect | Add real `/settings` action with Chinese tooltip | None |
| Today | Priority: Plan | Open Plan | `pushNamed(AppRoute.goals)` | Functional | Use replacement semantics for a main tab | Rendering only |
| Today | Priority: Habit | Check in selected habit | `HabitsStore.checkIn` | Functional | Add cross-page mutation test and success feedback | Partial Habits→Today test |
| Today | Priority: Focus | Open Focus | `pushNamed(AppRoute.focus)` | Functional | Use replacement semantics for a main tab | None |
| Today | Plan row | Open Plan | `pushNamed(AppRoute.goals)` | Functional | Use replacement semantics | None |
| Today | Habit row | Row opens Habits; round action checks in | `pushNamed(AppRoute.habits)` / `checkIn` | Functional | Main-route replacement and sync test | Partial |
| Today | Focus row | Open Focus | `pushNamed(AppRoute.focus)` | Functional | Main-route replacement | None |
| Habits | 新建习惯 | Open create dialog and create | dialog → `createHabit` | Functional | Dialog needs explicit `取消`; header needs shared sizing | `habits_flow_test.dart` |
| Habits | 打卡 | Add real record | `checkIn` | Functional | Add bounded success motion | Covered |
| Habits | 编辑 | Update identity/templates/link | `updateHabit` and template methods | Functional | No defect found | Covered |
| Habits | 提醒 | Configure reminder rules | `updateHabitReminderRules` | Functional | No defect found | Covered |
| Habits | 查看记录 | Open record sheet | record/detail flow | Functional when records exist | Disabled state must explain “暂无记录” | Covered |
| Habits | 详细统计 / 月节奏 | Open real statistics/activity views | Store-derived statistics | Functional | No placeholder statistics found | Covered |
| Habits | 生命周期 | Pause/archive/restore/delete-confirm | lifecycle Store methods | Functional | Inactive cards incorrectly label every disabled action “暂停” | Covered |
| Habits | 我的/设置 header action | Open My/Settings | Missing at baseline | Defect | Add real `/settings` action | None |
| Plan | 新建计划 | Create plan | `createGoal` then `updateGoalIdentity` | Functional | Move into shared header | Covered |
| Plan | 编辑计划 | Edit plan | `updateGoalIdentity` | Functional | No defect found | Covered |
| Plan | 添加行动 | Create action | `createTask`; creates a project first if none | Functional but misleading | Empty-project label must say “先建项目” | Covered baseline behavior |
| Plan | 完成行动 | Toggle completion | `toggleTask` | Functional | Add Today/Review/Focus synchronization test | Plan-only coverage |
| Plan | 计划详情 | Open bottom sheet | `_showPlanDetailSheet` | Functional | No defect found | Covered |
| Plan | 高级拆解 | Expand hierarchy | `ExpansionTile` | Functional | Keep collapsed and use bounded framework motion | Covered |
| Plan | 记录 | Note/numeric record flows | record Store methods | Functional | No defect found | Covered |
| Plan | 附件 | Add/replace/remove record attachment | attachment storage | Functional | No defect found | Covered |
| Plan | 我的/设置 | Open My/Settings | `pushNamed(AppRoute.settings)` | Functional | Move into shared header | No route-action test |
| Focus | 选择专注对象 | Open selector with incomplete Plan tasks | bottom sheet → `selectTarget` | Functional in body | Required in shared header; disabled state must explain active-round lock | Covered in body |
| Focus | 开始 | Start timer | `FocusStore.start` | Functional | Duplicate control sets at baseline | Covered |
| Focus | 暂停 | Pause timer | `FocusStore.pause` | Functional after critical sync fix | Disabled-state reason needed | Covered |
| Focus | 继续 | Resume timer | `FocusStore.start` | Functional | Add bounded state-label transition | Covered |
| Focus | 重置 | Reset timer | `FocusStore.reset` | Functional | Duplicate control sets at baseline | Covered |
| Focus | 我的/设置 | Open My/Settings | `pushNamed(AppRoute.settings)` | Functional | Shared header now supplies a Chinese tooltip | No route-action test |
| Review | Today entry | Open Review | `/review` | Functional | Add visible-control test | None |
| Review | Settings entry | Open Review | `/review` | Functional | Avoid Settings→Review→Settings loop from secondary action | None |
| Review | Back | Return to caller | implicit AppBar leading | Functional when pushed | Add Chinese-tooltip explicit back/fallback test | None |
| Review | Displayed values | Read Stores only | derived Review data | Functional with sync defects noted in data audit | Fix date ordering and focus completion race | Static seeded tests |
| Settings | Back | Return to caller | implicit AppBar leading | Functional when pushed | Add navigation test | None |
| Settings | Theme mode | Update app theme | `setThemeMode` | Store wired | Rendered theme was only partially responsive | Store/themeMode test only |
| Settings | Color controls | Update/reset colors | AppSettingsStore setters | Store wired | Dominant hardcoded surfaces reduce visible effect | Covered Store/UI selection |
| Settings | Review entry | Open Review | `pushNamed(AppRoute.review)` | Functional | Add return-path test | None |
| Settings | Local summary | Show local counts | reads all feature Stores | Live | “习惯与打卡” counts habits, not records; label needs precision | Covered partially |

## Proven defects and disposition

1. The four main headers were structurally inconsistent; Today and Habits lacked Settings, Focus lacked a header target selector, and the old Focus leading icon was a disabled decorative button.
2. AppShell top safe-area handling is inverted: main tabs receive no shared top inset while secondary content below an AppBar receives another SafeArea inset.
3. Today uses pushed main routes while the dock uses replacement, creating inconsistent back-stack semantics.
4. Settings contained a selected “主题工作室” icon pill with no callback. It was removed in this phase.
5. Focus showed two complete start/pause/reset command sets.
6. Create Habit lacked an explicit Cancel action.
7. Plan’s “添加行动” could open “新建项目” when no project existed.
8. Secondary back buttons are framework-generated and do not guarantee a Chinese tooltip.

## Test gap to close

Add one focused navigation test that checks all four main tabs for no back button, all eight required header actions/tooltips, Review and Settings entry, Focus target selector entry, and secondary-page return behavior. Existing smoke tests navigate programmatically and do not exercise these visible controls.
