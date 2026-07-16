# P8 Plan Pixel Fix Report

## 1. Exact Stitch Plan Reference Files Used

- `.ai_reference/stitch/export_20260708/项目简介.txt`
- `.ai_reference/stitch/export_20260708/程式码.txt`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/discipline_dashboard/code.html`
- `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/discipline_dashboard/screen.png`

The exported Plan screen is the `discipline_dashboard` screen.

## 2. Old Plan Issues Found

- The previous Plan route was still closer to the rejected generic dashboard than to the exported Stitch Plan composition.
- The visual hierarchy did not follow the exported sequence: command header, core intent, strategic pillars, milestone log.
- The page did not closely model the exported black grid background, low-radius dark cards, thin gray borders, compact uppercase labels, yellow highlight, cyan status accents, and transparent milestone rows.
- The exported labels `STRATEGIC COMMAND`, `核心意图 // CORE INTENT`, `Discipline is the Bridge to Goals.`, `战略支柱 // STRATEGIC PILLARS`, and `里程碑日志 // MILESTONE LOG` are real Stitch Plan labels, so they were retained in the exported structure rather than removed.

## 3. Files Changed

Intentionally changed in this Plan-only phase:

- `lib/features/goals/presentation/pages/goals_page.dart`
- `reports/p8_plan_stitch_reference_audit.md`
- `reports/p8_plan_pixel_fix_plan.md`
- `reports/p8_plan_pixel_fix_report.md`

The worktree already contains unrelated dirty files from prior phases. They were not intentionally changed for this Plan-only fix.

## 4. Old Sections Removed

- Removed the rejected generic top dashboard structure from the Plan route.
- Removed the old Plan hero/card composition as the first visible route structure.
- Did not keep title-case generic sections such as `Strategic Pillars` or `Milestone Log`; the page now uses the exported bilingual uppercase labels.

## 5. New Sections Implemented

- Export-style black grid page background via the existing Stitch exact background component.
- Compact top command bar matching the exported Plan screen.
- `核心意图 // CORE INTENT` section with the exported headline and metric chips.
- `战略支柱 // STRATEGIC PILLARS` four-card dashboard:
  - real project/task completion progress
  - real readiness ratio
  - real goal/project/task allocation rows
  - real task/record matrix bars
- `里程碑日志 // MILESTONE LOG` using real goals, projects, tasks, and records where available.
- Existing full functional hierarchy remains below the exported dashboard: search, overview, create goal, goal/project/subproject/task cards, records, and attachments.

## 6. Real GoalsStore Bindings Preserved

- Goal count, project count, subproject count, task count, completed task count, and record count are derived from `GoalsStore`.
- Strategic pillar progress uses real project task completion, task completion, and record data.
- Milestone rows use real recent records and upcoming tasks, with empty states when no real data exists.
- Empty dashboard cards explicitly state that real `GoalsStore` data is required rather than using fake metrics.
- Existing create/edit actions remain wired through the existing dialogs and store calls:
  - create/edit goal
  - create/edit project
  - create/edit subproject
  - create/edit task
  - toggle task completion
  - create project/task records
  - plan record attachment flow

## 7. Final Analyze Result

Command:

`D:\ai\flutter\bin\flutter.bat analyze`

Result:

`No issues found!`

## 8. Final Test Result

Command:

`D:\ai\flutter\bin\flutter.bat test`

Result:

`All tests passed!`

## 9. Chrome Run Result

Command:

`D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321 --no-resident`

Result:

- Failed because port `54321` was already occupied.
- Flutter also printed the existing project warning: `This application is not configured to build on the web.`

Retry command:

`D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54322 --no-resident`

Result:

- Exit code `0`
- Chrome launched in debug mode.
- Output ended with `Application finished.`

Format note:

- `D:\ai\flutter\bin\dart.bat format .` scanned 81 files and only attempted to change `goals_page.dart`.
- Windows reported error `1224` when Dart tried to overwrite the active Plan file directly.
- The Plan file was formatted through a temporary local copy workaround, and analyzer/tests passed afterward.

## 10. Manual Screenshot Instruction

1. Run `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54322`.
2. Open the app in the launched Chrome window.
3. Navigate to the Plan tab.
4. Capture a mobile-sized viewport screenshot, preferably `390 x 844`.
5. Compare it against `.ai_reference/stitch/export_20260708/stitch_app/stitch_app/discipline_dashboard/screen.png`.

Final verdict:

PLAN_PIXEL_FIX_READY_FOR_MANUAL_REVIEW
