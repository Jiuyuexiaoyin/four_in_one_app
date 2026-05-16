# P7H-2 Habit Detail Rhythm View Redesign

## Goal

Redesign the Habit Detail view into a rhythm-first, modern, minimal page that shows
habit progress, recent cadence, and month rhythm without changing habit semantics.

## Allowed Files

- `lib/features/habits/presentation/pages/habits_page.dart`
- `lib/app/theme/app_theme.dart` only if a tiny visual token adjustment is explicitly needed
- `lib/app/theme/app_theme_tokens.dart` only if a tiny visual token adjustment is explicitly needed

## Forbidden Files

- `lib/features/habits/domain/**`
- `lib/features/habits/application/**`
- `lib/features/habits/data/**`
- `lib/features/goals/**`
- `lib/features/focus/**`
- `lib/features/review/**`
- `lib/features/today/**`
- `test/**` unless an intentional IA change is separately approved
- `pubspec.yaml`
- `android/**`
- `ios/**`
- `tooling/**`

## Tests To Run

- `flutter analyze --no-pub`
- `flutter test --no-pub test/app_smoke_test.dart`
- `flutter test --no-pub test/settings_theme_test.dart`
- `flutter test --no-pub test/today_overview_test.dart`
- `flutter test --no-pub test/habits_flow_test.dart`

## Theme Studio Requirements

- Habit color affects rhythm dots, selected days, hero glow, and key highlights.
- App accent affects global CTA and shell selection.
- Do not hardcode a fixed black/gold/blue palette that erases custom colors.
- Respect background/card/accent colors from the active theme path.

## Visual Goals

- Replace dense database-like detail surfaces with a calm rhythm view.
- Use path/wave/dots for progress and cadence.
- Keep text hierarchy quiet and readable.
- Show month rhythm without table-like heaviness.
- Keep key actions visible and tappable.

## Non-Goals

- Do not change check-in semantics.
- Do not change skip/makeup semantics.
- Do not change reminders semantics.
- Do not change proof image semantics.
- Do not add storage, schema, dependencies, or native permissions.
- Do not build APK.

## Acceptance Checklist

- Existing habit detail flows still pass tests.
- Existing keys remain mounted and tappable.
- No domain/application/data changes.
- No pubspec/native/tooling changes.
- No overflow at 360dp width and text scale 1.15.
- The page looks rhythm-first, not like a raw record table.
- Verification logs are attached before claiming success.
