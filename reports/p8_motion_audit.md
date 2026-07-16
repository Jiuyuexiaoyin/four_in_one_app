# P8 Motion and Feedback Audit

Date: 2026-07-12

## Motion tokens

- Fast: 160 ms
- Standard: 240 ms
- Emphasis: 360 ms
- Default curve: `Curves.easeOutCubic`

These durations stay inside the requested ranges and are short enough for `pumpAndSettle`.

## Baseline audit

| Interaction | Baseline | Required treatment |
| --- | --- | --- |
| Habit check-in | Count, button label, and status change abruptly | Fast `AnimatedSwitcher`/surface feedback keyed to real state |
| Metric values | Most shared metrics replace text abruptly | Fast `AnimatedSwitcher`; preserve existing value keys |
| Progress rails | Width jumps | Standard `TweenAnimationBuilder<double>` |
| Bottom-nav selection | New selected icon/rail appears abruptly | Standard bounded opacity/scale transition |
| Focus start/pause | Labels and selected state jump; controls duplicated | One command surface with fast status/label transition |
| Plan advanced breakdown | Framework `ExpansionTile` animation | Preserve; no custom continuous motion |
| Dialog/sheet appearance | Framework route/sheet motion | Preserve |
| Settings swatches | 140 ms `AnimatedContainer` | Move to 160 ms token |
| Habit preset transitions | 120 ms | Move to 160 ms token |

## Guardrails

- No periodic decorative animation.
- No delayed input handling.
- Timer digits must not use `AnimatedSwitcher` on every second, because an active timer would keep settling work alive.
- Animations must be driven by real Store state and retain semantic/value keys used by tests.
- Sheets, dialogs, checkboxes, chips, and ExpansionTiles already have adequate framework feedback.

## Feedback defects

- Focus baseline duplicates start/pause/reset, weakening hierarchy and disabled-state clarity.
- Disabled Focus controls do not explain which timer state makes them unavailable.
- Archived/paused Habit cards use a misleading disabled “暂停” label.
- The Settings “主题工作室” icon looked pressable but had no callback; it was removed.
