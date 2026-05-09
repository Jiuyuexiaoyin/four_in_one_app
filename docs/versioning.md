# Versioning Rules

- Only upgrade the app version when preparing a new on-device test APK.
- Do not upgrade the version for ordinary development iterations, UI changes, or logic changes.
- The phone test version sequence starts at `0.1.0+1`.
- `0.1.0+1`: first phone test build.
- `0.2.0+2`: second phone test build.
- `0.3.0+3`: Focus notification countdown + custom duration phone test build.
- `0.4.0+4`: Theme customization + Focus notification copy fix phone test build.
- `0.5.0+5`: Settings accent selector fix + HabitDone Habits V1 + DayMark Goals V1 phone test build.
- `0.6.0+6`: Five-tab IA + UI Product Feel V2A + Today/Plan source UI alignment phone test build.
- `0.7.0+7`: Habits/Today/Plan/Focus/Review source UI alignment phone test build.
- `0.8.0+8`: Benchmark Repair + Unified UI Component System prepared state.
- `0.9.0+9`: Deep Plan/Habits benchmark feature parity phone test build.
- `1.0.0+10`: Deep HabitDone + DayMark + Habit→Plan loop phone test build.
- `1.0.1+11`: P0 UX repair phone-test build: Plan edit discoverability, Today daily center refinement, and multi-device responsive layout repair.
- `1.1.0+12`: Benchmark Polish phone-test build: Theme Studio, Today command center, Plan project detail/records table, Habit/Plan analytics visual upgrade, and responsive UI polish.
- `1.1.1+13`: V5H Benchmark Visual System Reset phone-test build: global visual rhythm reset, Today/Habits/Plan visual polish, Theme Studio polish, and responsive UI refinement.
- `1.1.2+14`: Theme Studio real visual color picker repair phone-test build: visual color picker, hue slider, grouped palette boards, collapsed advanced HEX/RGB/ARGB input, and live preview refinement.
- Future phone test builds continue as `1.2.0+15`, `1.3.0+16`, etc.
