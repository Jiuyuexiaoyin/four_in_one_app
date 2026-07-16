# P8 Before Hard Apply Screenshot Instructions

Automated before screenshots were attempted but blocked in this Codex shell.

Attempts:

- `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321` in a scoped PowerShell capture job
- route screenshots through local Chrome after waiting for `localhost:54321`
- foreground `D:\ai\flutter\bin\flutter.bat run -d chrome --web-port=54321`

Observed result:

- Port `54321` did not become reachable during the automated capture window.
- The foreground Flutter command timed out without useful output in this shell.
- No before screenshots were saved.

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
