# P8 After Hard Apply Screenshot Instructions

Automated after screenshots were attempted but blocked in this Codex shell.

Attempts:

- `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321 --no-resident`
- scoped `D:\ai\flutter\bin\flutter.bat run -d web-server --web-port=54321` capture job
- local headless Chrome route screenshots after waiting for `localhost:54321`

Observed result:

- The Chrome `--no-resident` run exited `0`, but did not leave a live app available for screenshot capture.
- The scoped web-server capture job did not make port `54321` reachable during the automated capture window.
- No after screenshots were saved.

Manual capture steps:

1. Run `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321` from `D:\ai\projects\four_in_one_app`.
2. Capture screenshots at mobile width, ideally 390 x 900.
3. Save these files in this folder:
   - `01_today.png`
   - `02_habits.png`
   - `03_create_habit_dialog.png`
   - `04_plan.png`
   - `05_focus.png`
   - `06_review.png`
   - `07_settings.png`
