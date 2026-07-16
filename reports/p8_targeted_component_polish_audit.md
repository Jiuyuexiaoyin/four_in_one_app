# P8 Targeted Component Polish Audit

Date: 2026-07-12

## Scope

This audit covers only the three requested legacy presentation areas. No Dart source was edited before this audit and the required Stitch inspection/generation gate.

## 1. Settings / My — 色卡灵感

Primary source: `lib/features/settings/presentation/pages/settings_page.dart`

Current widget path:

`SettingsPage → _SettingsContent → _AppearanceSection → MySettingsSection("外观") → MySettingsRow("颜色工作室") → _ThemeStudio → _PaletteBoards → _PaletteBoard × 5 → _PresetColorOption × 3`

The legacy weight comes from the outer settings panel, five always-expanded bordered palette boards, and fifteen individually bordered large swatches.

Bindings and callbacks:

- `AppSettingsScope.of(context)` supplies `AppSettingsStore`.
- `_ThemeStudioState._target` selects accent, background, or surface.
- Palette taps call `_applyColor`, which routes to `setAccentColor`, `setBackgroundColor`, or `setSurfaceColor`.
- Store setters update synchronously, call `notifyListeners()`, and then persist asynchronously, so the live theme changes without restart.
- Current-target reset routes to the matching individual reset method; reset-all calls `resetAllColors`.
- Advanced HEX/RGB/ARGB inputs already use a collapsed `ExpansionTile` and preserve the 0xCC alpha readability guard.
- Persistence remains in `app_settings_local_storage.dart` under the existing accent/background/surface keys.

Preset source:

- 自然: 松绿色, 鼠尾草绿, 暖米色
- 高级灰: 石墨灰, 雾灰色, 砂岩灰
- 柔和暖色: 陶土色, 柔和橙, 落日杏
- 冷静蓝绿: 雾蓝色, 深青色, 湖蓝灰
- 深色高级: 灰紫色, 夜青色, 墨蓝色

Current direct tests:

- `test/settings_theme_test.dart`
  - `Settings page can change accent color`
  - `Theme Studio accepts HEX, RGB, ARGB, and reset inputs`
  - `Theme Studio renders on common phone widths with larger text`
- `test/app_settings_store_test.dart` covers defaults, persistence, all-target restoration, reset-all, and invalid persisted colors.
- `test/app_system_sync_test.dart` covers live settings synchronization at the app level.

Narrow seam: retain `_ThemeStudioState`, all Store methods, target routing, parsing, persistence, and existing stable input/reset keys; replace only the palette presentation and reset emphasis.

## 2. Plan — 查找与筛选

Primary source: `lib/features/goals/presentation/pages/goals_page.dart`

Current widget path:

`GoalsPage → _PlanSearchDisclosure → _PlanTechCard → ExpansionTile("查找与筛选") → _PlanSearchSurface → SoftSurface → search field + all filter chips + optional tags + all sort chips + real results`

The current source is collapsed initially, but opening it reveals every filter and sort control at once inside multiple tonal/bordered layers.

Bindings and callbacks:

- `GoalsScope.of(context)` supplies the real `GoalsStore` through `InheritedNotifier` rebuilding.
- Search/filter/sort state is presentation-local; no query state lives in `GoalsStore`.
- Search matches real project/task title, project description, hierarchy context, and tags.
- Today/overdue delegate to Store helpers and exclude completed records.
- High priority includes both `high` and `urgent`.
- Completion uses task state or computed project progress.
- Tag matching is exact.
- Sorting preserves hierarchy order or sorts by due date/priority with null values last.
- Results are real projects/tasks and retain the existing edit/detail callbacks.

Current direct test:

- `test/goals_flow_test.dart`
  - `Plan search filters and sorting show flat contextual results`

Narrow seam: keep the real result model, matcher helpers, result rows, and page edit/detail callbacks; replace disclosure/control presentation with a compact committed toolbar plus a draft-only modal filter sheet.

## 3. Focus — 选择时长

Primary source: `lib/features/focus/presentation/pages/focus_page.dart`

Current widget path:

`FocusPage → _FocusDurationSelector → StitchExactPanel → heading/status row + wrapped ChoiceChip presets + custom ChoiceChip → _CustomDurationDialog`

Bindings and callbacks:

- Presets are `FocusStore.durationChoicesSeconds`: 5, 15, 25, and 45 minutes.
- Selected state uses `selectedDurationSeconds`; custom state uses `hasCustomSelectedDuration`.
- Idle taps call `selectDuration(seconds)`; controls are disabled while a round is active.
- Custom duration returns integer minutes and applies exactly one minutes-to-seconds conversion.
- Valid custom range is unchanged at 1–180 whole minutes.
- `selectDuration` updates selected, active, and remaining duration while idle, notifies listeners, and persists.
- Timer start/reset/completion continue to use the Store's active/selected duration fields.
- “下一轮” is presentation copy only; there is no distinct next-round queue or state.

Current direct tests:

- `test/focus_flow_test.dart`
  - minimal countdown lifecycle
  - custom duration validation/application
- `test/focus_store_test.dart`
  - preset/custom selection, running/paused protection, and reset semantics
- `test/focus_persistence_test.dart`
  - real session duration, notification timing, persistence, and restore behavior

Narrow seam: replace only `_FocusDurationSelector` option presentation and lightly restyle the existing dialog. Do not touch `FocusStore`, timer lifecycle, persistence, or session models.

## Runtime capture status

The requested resident Chrome process was started on port 54321 and responded with HTTP 200. The isolated Playwright client loaded Flutter's debug modules but the Chrome-device debug server did not dispatch the application entry point to a second browser client, leaving no `flutter-view`. A resident `web-server` fallback then failed to open its listener before the bounded timeout. No valid component “before” screenshots were fabricated; capture remains pending for the final runtime pass.

## Scope protection

No changes are needed in AppShell, main headers, Today, Habits, navigation, Stores, domain models, persistence schema, synchronization logic, version, or dependencies.
