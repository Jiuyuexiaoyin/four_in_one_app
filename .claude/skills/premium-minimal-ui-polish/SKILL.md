---
name: premium-minimal-ui-polish
description: Guides Claude Code when performing premium minimal UI / visual polish on the four_in_one_app Flutter project. The named visual direction is "Dark Premium Productivity" — black/graphite foundation, restrained high-saturation accents, strong typography, high-end fitness/performance dashboard feeling. Use this skill ONLY for presentation/widget/theme/shared-UI work. Never for feature development, business logic, data models, persistence, semantics, dependencies, version, APK, or native config.
---

# Premium Minimal UI Polish — Project Skill

This skill governs all UI polish work on `four_in_one_app`. It is instruction-only. It must not be turned into scripts. It must not auto-run commands.

If a task does not match the rules below, stop and ask the user before making any change.

---

## 1. Visual Direction

The named visual direction for this project is **Dark Premium Productivity** (see section 2 for the anchor).

Target visual style:

- premium
- minimal
- calm
- clean
- quiet
- mature
- restrained
- big-tech product feeling
- generous whitespace
- clear information hierarchy
- dark premium foundation as the primary taste anchor (light mode must still be supported and look clean, but the design conversation is led from the dark side)

Forbidden visual direction:

- flashy, childish, mascots, cartoon illustrations
- saturated rainbow accents, neon used as decoration, gradients used as primary surface
- decorative borders, drop shadows used as decoration
- emoji used as load-bearing UI affordances (in-content emoji is fine where it already exists)
- generic Flutter demo style
- cute habit tracker style
- copying any reference app's signature look directly

Feature-parity references (inspiration only, never to clone — for product feature comparison):

- HabitDone — dense calm dark mode, restrained color blocks
- DayMark — iOS-clean list rows, year heatmap, low-saturation chips
- OffScreen — quiet metric panels, generous whitespace, honest empty states
- 番茄ToDo / Pomodoro ToDo — single-purpose focus hero (use the structure idea only; not the mascot or playful colors)

What to NOT copy from feature-parity references:

- 番茄ToDo's tomato mascot, illustration style, or playful color palette
- HabitDone's specific dark-mode-only feel; the app must still work in both modes
- DayMark's gradient backgrounds and decorative blue washes
- OffScreen's specific brand palette; only borrow the restraint, not the colors
- Any reference app's logo, mascot, or signature brand color

---

## 2. User Visual Taste Anchor — Dark Premium Productivity

The primary visual taste anchor selected by the user is **Dark Premium Productivity**, drawn from:

- **Equinox+** — premium black UI, strong typography, calm luxury feel, minimal but powerful layout
- **The Outsiders** — dark dashboard foundation, strong status/readiness hero, vivid accent used sparingly, fitness-data style metrics

Selected reference screenshots live at:

```
docs/references/ui_taste_board/selected/
```

(Contains curated Equinox+ and The Outsiders frames plus a README naming the selection rationale. Treat these as the visual-taste source of truth.)

### Style summary

- dark premium productivity app
- black / graphite foundation
- calm but powerful
- high-end fitness / performance dashboard feeling
- strong typography
- restrained high-saturation accents (electric green, hot pink, electric blue, deep purple — one at a time, used sparingly per surface)
- premium dark cards (graphite tone, subtle border, no decorative shadow stack)
- clear data hierarchy (one anchor number per surface; everything else recedes)
- real data only
- not childish
- not generic Flutter demo style
- not cute habit tracker style
- not copied from any reference app

### Useful visual principles from Equinox+

- premium black UI as the canvas; the surface is the page, not a nested box
- strong large typography for hero titles ("Realize Your Potential" scale)
- minimal luxury feeling — generous whitespace, sparse decoration
- restrained page structure — at most one primary action button per surface
- clean task / class card structure — full-bleed media or icon, large title, two short meta lines, two-button row (filled white + outlined dark)
- calm dark list and settings style — flat list rows, no card borders for inline lists
- strong onboarding / brand atmosphere — moody full-bleed imagery handled with restraint, then immediately back to clean type

### Useful visual principles from The Outsiders

- dark dashboard foundation with a single accent halo per surface (green for Today, purple for Sleep, blue for Progress)
- strong Today / status hero card — large status word ("Excellent" / "Moderate Readiness") above a long, calmly worded supporting paragraph
- readiness / progress feeling — one anchor metric ("73%", "0.83") as the visual lead, descriptor below, details further below
- vivid accent colors used sparingly — only one accent per surface, only on the lead metric/word and on small chevrons/badges
- data-forward metric cards — small uppercase label, big number, small status pill with checkmark beneath
- lightweight charts and activity strips — thin lines on a dark grid, no axis decoration noise, single accent per chart
- professional performance-tracking feeling — descriptive copy reads like an analyst, not a cheerleader

### What to NOT copy from the taste anchor

- Equinox+'s gym brand imagery, Equinox logo, or any specific class artwork
- The Outsiders' "Outsider" wordmark, mascot illustration, ranking laurels, or pricing card design
- Either app's specific brand accent value used as a single brand identity color (we pick our own restrained accent inside the existing accent-color system)
- Either app's subscription/upsell surfaces (we have no paywall)
- Photographic full-bleed hero imagery as a default — the app has no licensed photography and must not fabricate one
- Multi-color category donut charts (no faked categories)

---

## 3. How to translate references into four_in_one_app

The taste anchor maps to existing screens as follows. The mapping is a **principle translation**, not a layout clone. Every translation must preserve all existing widget keys, text where tested, and all business semantics (PlanRecord / Habit / Focus / Review).

### Today → premium status dashboard
- Lead the page with one calm hero metric strip (real data) and one short status sentence under it, inspired by "readiness / progress" framing.
- Use a single accent halo behind the hero number, not three accent uses at once.
- Reduce competing headers above the fold. The page header is the title; the hero supports it.
- Do not fabricate a "readiness" score. Use real counts (habit checkins / completed actions / focus minutes) and describe them honestly.

### Habits → training consistency system, not cute checklist
- Reframe the habit card as a training-consistency row: emoji or icon as a small identity badge, name + supporting line, today's progress as a numeric anchor right-aligned, 7-day strip below as the visual rhythm.
- Drop redundant decorative signaling (do not stack progress dots + linear bar + percent text on the same card).
- Calm down the accent use — at most one accent per card surface.

### Plan / Goals → structured mission board / training plan
- Hierarchy rows should read like a training plan: Goal as the heading, Project as a quiet sub-row, Subproject indented quietly, Task as a row with a status dot and right-aligned completion ratio.
- Year/month activity surfaces should match the Outsiders chart restraint: single accent, no decorative axis, no rainbow.
- Avoid stacking three progress visuals on a single card.

### Focus → premium focus session cockpit
- Keep `FocusTimerHero` as the page anchor; subordinate all sibling panels.
- Reduce the action row to one prominent primary CTA (开始/继续) and two compact secondary actions (暂停, 重置).
- The "本轮专注对象" panel and the "选择时长" panel should sit visually below the hero, not at equal weight.
- A future "calm breathing effect" on the timer ring is allowed in motion phase (see section 15), but the static version must already feel cockpit-grade.

### Review → performance summary dashboard
- Use the Outsiders "anchor metric + supporting text + status pill" pattern for each section panel (habits / plan / focus).
- Charts and activity strips stay lightweight; one accent per panel.
- Empty states stay honest. Never invent a trend line just because the panel feels empty.

### Settings / Theme Studio → calm premium control room
- Settings rows should read like a control room: section title, small label, value at the right, generous vertical breathing.
- Theme Studio's color picker is the only visually rich element on its surface; everything else around it stays quiet.
- "敬请期待" / future placeholder rows must stay quiet, not loud.

---

## 4. Hard Boundaries (Non-negotiable)

- Only UI / visual polish is allowed.
- Modify only one UI package per task.
- Before modifying code, output a written plan first; only modify after the user approves the plan.
- After modifying code, output: files changed, why each was changed, validation result, residual risks, and rollback advice.

You MUST NOT:

1. Continue new feature development.
2. Modify business logic.
3. Modify data models or schemas.
4. Modify PlanRecord schema or PlanRecord note / numeric / image / source semantics.
5. Modify Plan progress semantics or task-completion semantics.
6. Modify Habit -> Plan linking semantics.
7. Modify Habit record / skip / makeup / streak / proof semantics.
8. Modify Focus session, restore, or notification semantics.
9. Modify Review statistics semantics.
10. Create fake charts, fake trends, fake summaries, or fake activity data.
11. Add or remove dependencies.
12. Modify `pubspec.yaml` or `pubspec.lock`.
13. Modify `android/**` or `ios/**` native configuration.
14. Bump version in `pubspec.yaml` or anywhere else.
15. Prepare an APK or run `flutter build apk`.
16. Run `tooling\validate_v6b.ps1` (it is a forbidden historical script).
17. Run `flutter` or `dart` directly to validate (always use the fixed validation command in section 9).
18. Run `git clean`, `git reset --hard`, `git checkout --`, or modify `git config`.
19. Delete `build/`, `.dart_tool/`, or any cache directory.
20. Perform broad refactors across multiple packages in one task.
21. Modify multiple UI packages in one task.
22. Change real data sources just to make the UI look better.
23. Modify code without first providing a plan.

---

## 5. Allowed File Modification Scope

By default, you may modify files matching these paths only:

- `lib/features/*/presentation/**`
- `lib/features/*/presentation/pages/**`
- `lib/features/*/presentation/widgets/**`
- `lib/shared/widgets/**`
- `lib/shared/ui/**`
- `lib/shared/theme/**`
- `lib/theme/**`
- `lib/app/**` only when the change is strictly limited to `ThemeData`, navigation appearance, or `Scaffold` appearance
- `docs/ui/**`
- `docs/design/**`
- `.claude/skills/premium-minimal-ui-polish/SKILL.md` (this file)

Anything else is out of scope. If a file outside this scope appears to need a change, stop, explain why, and ask the user for approval before touching it.

---

## 6. Forbidden File Modification Scope

By default, do NOT modify:

- `pubspec.yaml`
- `pubspec.lock`
- `android/**`
- `ios/**`
- `lib/features/*/domain/**`
- `lib/features/*/application/**`
- `lib/features/*/data/**`
- `lib/features/goals/domain/models/**`
- `lib/features/goals/application/**`
- `lib/features/habits/domain/**`
- `lib/features/habits/application/**`
- `lib/features/focus/application/**`
- `lib/features/review/application/**`
- Any persistence / storage / repository / data layer file
- Any database / schema / migration file
- `tooling/validate_v6b.ps1`
- Any build output directory
- Any APK output directory
- Any version-related file
- Any `test/**` file (see section 7 for the only exception path)

---

## 7. Tests

By default, do NOT modify any test file.

If a UI polish change unavoidably affects a test (for example, a text label, key, or layout key changed by the polish), you MUST first output:

1. Why this UI polish change affects this specific test.
2. The exact test name and file path that needs updating.
3. Whether any business or semantic assertion would change (must answer "No"; if "Yes", abort the change).
4. Wait for the user's explicit approval before editing the test.

Preferred path: keep the existing widget keys and text strings stable so tests remain untouched. If a key/text must change for a real visual reason, treat it as the rare case above.

---

## 8. Required Pre-Change Plan

Before modifying any code, output the following:

1. UI package name for this task.
2. Goal of this task (one or two sentences, visual outcome, not implementation steps).
3. Expected files to modify (concrete paths).
4. Files you explicitly will NOT modify (reaffirm the boundary).
5. Whether business logic is involved (must answer "No").
6. Whether data models are involved (must answer "No").
7. Whether `pubspec.yaml` is involved (must answer "No").
8. Whether APK or version is involved (must answer "No").
9. Validation command (the exact fixed command from section 9).
10. Rollback plan (which files / commits revert if the user is not satisfied).

Wait for explicit user confirmation. Do not start editing until confirmed.

---

## 9. Fixed Validation Command

After each UI code change, the user runs (or you propose) the following exact fixed validation command. Do not substitute, do not shorten, do not chain other commands into it.

```
cmd.exe /d /s /c "set Path=D:\AI\Tools\Git\Git\cmd;D:\AI\Tools\Flutter\flutter\bin;D:\AI\Tools\Flutter\flutter\bin\cache\dart-sdk\bin;%Path%&& set FLUTTER_ROOT=D:\AI\Tools\Flutter\flutter&& set PUB_CACHE=D:\AI\Cache\Pub&& set FLUTTER_SUPPRESS_ANALYTICS=true&& set GIT_OPTIONAL_LOCKS=0&& call .\tooling\v6b.cmd"
```

Hard rules around validation:

- Do not call `flutter` directly.
- Do not call `dart` directly.
- Do not call `.\tooling\v6b.cmd` directly without the env-prefix above.
- Do not call `tooling\validate_v6b.ps1`.
- Do not parallelize validation calls.
- Do not skip validation after a UI code change.

After validation, you must report:

1. Whether validation passed (yes / no).
2. `analyze` result.
3. `tests` result.
4. If failed: the FAILED_STEP and full error excerpt.
5. Your diagnosis of the failure.
6. Whether you have rolled back, or recommend rollback.

---

## 10. Required Post-Package Output

After completing each UI package, output:

1. What was completed in this task (one short paragraph).
2. Which files were modified (concrete paths).
3. Why each file was modified (one short bullet per file).
4. Whether business logic was modified — explicit yes/no.
5. Whether data models were modified — explicit yes/no.
6. Whether `pubspec.yaml` was modified — explicit yes/no.
7. Whether dependencies were added — explicit yes/no.
8. Whether an APK was built — explicit yes/no.
9. Validation command result (analyze + tests).
10. Remaining risks and follow-ups (if any).
11. Suggested next UI package (one candidate, with a short reason).
12. How to roll back this UI change (commit hash to revert, or files to restore).

---

## 11. Design Token Discipline

When working on tokens, surfaces, chips, buttons, metric cards, headers, or empty states:

- Use the existing `AppThemeTokens` scale (spacing, radius, padding) wherever it already applies.
- If a value is needed that does not exist in the token system, prefer adding a single new token name to the token surface rather than inlining a magic number across pages.
- Never invent a parallel token system. There must remain a single source of truth.
- Keep `Brightness.light` and `Brightness.dark` both visually correct after any change; never assume one mode. The taste anchor is dark-led, but light must remain clean.
- Use `colorScheme.primary` as the accent restraint anchor. Do not paint multiple surface roles in primary at the same time on a single page. Translation rule from the taste anchor: **one accent per surface, not per page-wide explosion**.
- Avoid raw `Color` literals in widget files when a token exists.

---

## 12. Empty State Discipline

- Every empty state must be honest.
- Never invent placeholder counts, never fabricate "你已完成 0 次" trend visuals.
- A zero state is allowed to be visually quiet, not visually empty. A short line of guidance is enough.
- Never fall back to a different real data source just to fill a panel.
- Equinox+/Outsiders translation: an empty state can read like a calm coach line, not a sad "no data" badge.

---

## 13. Per-Page Visual Anchors

When polishing a page, treat the following as the page's visual anchor and polish it first; everything else aligns to it:

- Today: the top page header + the day status hero strip (Outsiders "readiness" framing).
- Habits: the habit card row pattern (training-consistency row).
- Plan / Goals: the Goal → Project → Subproject → Task hierarchy row (mission board row).
- Focus: the `FocusTimerHero` (timer + status + target line) as the cockpit.
- Review: the page header and the section panels (performance summary panels).
- Settings: the section header + `MySettingsRow` rhythm (control room row).

---

## 14. Reference Screenshot Use

Two reference roots:

- **Visual taste anchor** (load-bearing for this skill): `docs/references/ui_taste_board/selected/` — curated Equinox+ + The Outsiders frames. Treat as the visual direction source of truth.
- **Feature parity references**: `docs/references/app_content/{HabitDone, daymark, OffScreen, 番茄ToDo}/` — feature-completeness comparison only. They are not the visual anchor.

When citing a reference in a plan:

- Say what specific principle is borrowed (e.g., "Outsiders single-accent halo behind hero number," "Equinox+ two-button row pattern," "row spacing tightness").
- Do not say "make it look like X."
- Do not import any asset from any reference folder.
- Do not reproduce any reference logo, mascot, signature brand color, or wordmark.

---

## 15. Motion Language — Later Phase

Motion is **not** part of P1 Design Tokens. Motion is **not** part of the first static UI polish pass. Motion should only be implemented after the static UI system is stable and the user has explicitly approved a motion phase.

### Motion principles

- Motion must be subtle, premium, and restrained.
- No flashy, childish, game-like, or distracting animation.
- No new animation dependency unless explicitly approved.
- Prefer native Flutter animation primitives (`AnimatedContainer`, `AnimatedOpacity`, `TweenAnimationBuilder`, `AnimatedSwitcher`, `Hero`, `CurvedAnimation`, `ImplicitlyAnimatedWidget`) over external packages.
- Do not change business logic for animation.
- Do not change data semantics for animation.
- Do not modify persistence, storage, or scheduling to drive an animation.

### Motion direction (only when motion phase is approved)

Allowed and encouraged:

- fast but soft page transitions
- subtle card press feedback (light scale-down or color shift, not a bounce)
- smooth progress changes (animated linear progress, animated counter)
- quiet chart reveal (single-direction fade or width grow on first appearance)
- calm Focus timer breathing effect (low-amplitude opacity or scale loop on the ring while running)
- restrained tab / navigation transition (short cross-fade or slide, not parallax)

Strictly forbidden in motion:

- no confetti
- no particle effects
- no excessive bouncing
- no neon flashing
- no heavy 3D effects
- no looping attention-grabbing animation on idle surfaces
- no animation that obscures or delays real data

### When motion is allowed

Only after:

1. The static UI tokens (P1) are in place.
2. The shared visual primitives (P2) are in place.
3. All page-level polish phases (P3–P7) have landed and validated.
4. The user explicitly approves a "motion polish" package.

Until then, treat any motion change as out of scope and ask the user before adding it.

---

## 16. External Skill Fusion — Later Optional Phase

External Skills (community-published Claude Code skills, third-party agent prompt packs, MCP server bundles) are **not** part of the current UI polish setup.

### Hard rules

- Do not install external Skills during the current UI polish setup.
- External Skills may only be inspected later as references.
- Only instruction-level ideas may be extracted (text rules, checklists, prompt structure).
- Do not copy scripts, hooks, MCP servers, monitors, or executable files from any external Skill.
- Do not let external Skills override `four_in_one_app` safety boundaries (sections 4–7 of this skill take precedence).
- Do not add any external Skill that performs auto-validation, auto-commit, auto-push, or auto-APK behavior.

### Allowed later use (only after user approval)

External Skills can be used later only to improve:

- UI audit checklists (e.g., adopting a checklist item like "verify text scale 1.15 on 360dp").
- Design token rules (e.g., adopting a phrasing for token naming discipline).
- Visual QA (e.g., adopting a per-page screenshot/visual diff checklist).
- Motion QA (e.g., adopting a list of motion don'ts).

Any adoption must be:

1. Reduced to plain instruction text inside this `SKILL.md` (no imported scripts, no imported MCP).
2. Reviewed by the user before being added.
3. Subject to the same safety boundaries as the rest of this skill.

If a future external Skill recommends adding a dependency, modifying `pubspec.yaml`, touching native config, or running unfixed validation, that recommendation is **rejected by default** and must be flagged to the user with the exact text the external Skill suggested, before any action.

---

## 17. Workflow Summary

The repeated cycle for a single UI polish package is:

1. Confirm scope with user.
2. Output pre-change plan (section 8).
3. Wait for user approval.
4. Modify only the approved files (sections 5 and 6 boundaries).
5. Format only the files you changed (`dart format <paths>`).
6. Run the fixed validation command (section 9).
7. Output post-package report (section 10).
8. Stop. Wait for the next approved package.

Do not chain packages. Do not pre-stage future changes. Do not "while I'm here" any unrelated cleanup.

---

## 18. Project-Specific Reminders

- Version is `1.1.2+14`. Never bump it under this skill.
- Validation must pass at 172 tests as the current baseline; a UI polish change that breaks tests must be rolled back before reporting completion.
- `FocusPage` is intentionally `SingleChildScrollView + Column`, not `ListView`. Do not "optimize" it back to `ListView` — it was migrated to prevent `SliverList` lazy garbage collection of off-screen timer widgets while scrolling visibility checks ran. Preserve this structure.
- `ActivityStrip`, `MetricStrip`, `SoftSurface`, `MiniHeatmapCell`, `MySettingsSection`, `MySettingsRow`, and `ProductPageHeader` are the shared visual primitives. Prefer composing with them over creating new one-off `Container + BoxDecoration` blocks.
- The Theme Studio is feature-complete; visual tweaks there must not alter the picker behavior, input validation, or reset behavior.
- Digital wellbeing is research-only (V6G). No UI in this skill should imply real screen-time data exists.
- The visual taste anchor is **Dark Premium Productivity** (section 2). Light mode must remain clean, but the design conversation is led from the dark side.

---

End of skill.
