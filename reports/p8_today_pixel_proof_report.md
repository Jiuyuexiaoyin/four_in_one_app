# P8 Today Pixel Proof Report

## 1. Exact Stitch Today Source Files Used

- `.ai_reference\stitch\export_20260708\项目简介.txt`
  - Present but empty.
- `.ai_reference\stitch\export_20260708\程式码.txt`
  - Used for Today role and design DNA: Daily Command Center, deep carbon background, cyan/toxic-green accents, caps labels, dense technical dashboard.
- `.ai_reference\stitch\export_20260708\stitch_app\stitch_app\final_synthesis_2\code.html`
  - Exact Today screen source.
  - Title: `Today - Premium Productivity`
  - Heading: `今日 / TODAY`
  - Sections: Focus Score, Peak Rhythm, Momentum Metrics, Priority Execute, Focus Flux, Action Plan, mobile bottom nav.
- `.ai_reference\stitch\export_20260708\stitch_app\stitch_app\final_synthesis_2\screen.png`
  - Visual source for proportions, card order, dark palette, chart, and timeline.

Audit report:

- `reports\p8_today_stitch_source_audit.md`

Plan report:

- `reports\p8_today_pixel_rewrite_plan.md`

## 2. Old Today Issues Found

The previous Today implementation still contained extra non-Stitch sections after the exported Action Plan:

- `_TodayHabitsBand`
- `_PlanSnapshot`
- `_FocusSnapshot`
- visible `今日回看` utility row

Those sections made the page continue beyond the exported Today reference and kept it closer to the prior generic cross-feature overview than to the Stitch screen.

## 3. Files Changed

Implementation:

- `lib\features\today\presentation\pages\today_page.dart`

Today-facing tests updated for the new structure:

- `test\app_smoke_test.dart`
- `test\habits_flow_test.dart`
- `test\today_overview_test.dart`

Reports:

- `reports\p8_today_stitch_source_audit.md`
- `reports\p8_today_pixel_rewrite_plan.md`
- `reports\p8_today_pixel_proof_report.md`

Important working-tree note:

- The repo already had many dirty files before this batch.
- The user-requested broad command `D:\ai\flutter\bin\dart.bat format .` also formatted some already-dirty non-Today files, including `focus_page.dart` and `goals_page.dart`. No non-Today app page was manually rewritten in this batch.

## 4. Sections Removed

Removed from Today visible flow:

- old habit snapshot panel
- old goal snapshot panel
- old focus snapshot panel
- old review utility row
- dependency on the broad `StitchExact` widget set from Today

Confirmed rejected labels are not present in `lib\features\today` or `lib\shared` for the requested search:

- `今天，先推进`
- `Peak Rhythm`
- `Strategic Command`
- `Flow Status`
- `System Control`
- `StitchClone`
- `stitch_clone`

Note: the new page uses the Stitch label as uppercase `PEAK RHYTHM`, matching the screenshot rendering.

## 5. Sections Implemented

Today now follows the exported Stitch section order:

1. `今日 / TODAY` top bar
2. `FOCUS SCORE`
3. `PEAK RHYTHM`
4. `MOMENTUM METRICS`
5. `PRIORITY EXECUTE`
6. `FOCUS FLUX`
7. `ACTION PLAN`
8. bottom padding for existing `AppShell` nav

The page is now local Today-specific code, not a light recolor of the prior panel stack.

## 6. Real Data Bindings Preserved

- Habits: `HabitsStore.habits`, `completedCount`, `totalCount`, `totalCheckInsToday`, `isCompletedToday`, `todayCheckInCount`, `recentActivityDays`.
- Goals: `GoalsScope.of(context).tasks`, open/completed task counts, first open task as priority when available.
- Focus: `FocusStore.sessions`, `selectedDurationSeconds`, `formattedRemaining`, `status`, `recentDayCounts`, `currentTarget`.

Mappings:

- Focus score = weighted real habit completion, plan progress, and today's focus minutes.
- Completion ring = real habit completion.
- Velocity ring = real completed actions over total actions.
- Streak ring = real recent habit-active days.
- Priority Execute = first real open plan action, else first real pending habit, else focus fallback.
- Focus Flux = recent real habit/focus activity counts.
- Action Plan = real open actions and pending habits, with focus fallback if no items exist.

## 7. Real Actions Preserved

- Plan priority and plan rows navigate to `AppRoute.goals`.
- Pending habit priority can call `HabitsStore.checkIn(habit.id)`.
- Habit rows navigate to `AppRoute.habits`; row action can check in the habit.
- Focus fallback navigates to `AppRoute.focus`.
- Top-right review access navigates to `AppRoute.review`.

## 8. Final Format Result

Command run:

```powershell
D:\ai\flutter\bin\dart.bat format .
```

Result:

- Exit code: `0`
- Reported 7 changed files.
- Also reported Windows overwrite warning for `lib\features\today\presentation\pages\today_page.dart`:
  - `请求的操作无法在使用用户映射区域打开的文件上执行。 (error code 1224)`

Follow-up targeted format on Today produced the same overwrite warning. Analyze and tests still pass.

## 9. Final Analyze Result

Command run:

```powershell
D:\ai\flutter\bin\flutter.bat analyze
```

Result:

- Exit code: `0`
- `No issues found!`

## 10. Final Test Result

Command run:

```powershell
D:\ai\flutter\bin\flutter.bat test
```

Result:

- Exit code: `0`
- `All tests passed!`

Focused Today test was also run:

```powershell
D:\ai\flutter\bin\flutter.bat test test\today_overview_test.dart --reporter expanded
```

Result:

- Exit code: `0`
- `All tests passed!`

## 11. Chrome Run Result

Port check:

- `54321 available`

Command run:

```powershell
D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321 --no-resident
```

Result:

- Exit code: `0`
- Output included:
  - `This application is not configured to build on the web.`
  - `Launching lib\main.dart on Chrome in debug mode...`
  - `Waiting for connection from debug service on Chrome...`
  - `Application finished.`

## 12. Manual Screenshot Instruction

Open the app on the Today tab and capture the first scroll view from the top through the Action Plan. Compare against:

`.ai_reference\stitch\export_20260708\stitch_app\stitch_app\final_synthesis_2\screen.png`

Manual review should check:

- section order matches the Stitch screen
- dark carbon background and cyan/green/purple accents match closely
- Focus Score hero is large and top-weighted
- Momentum Metrics are three circular blocks
- Priority Execute uses the large dark card and cyan pill button
- Focus Flux chart is grid-backed with cyan line
- Action Plan is the final visible content section before bottom spacing

TODAY_PIXEL_PROOF_READY_FOR_MANUAL_REVIEW
