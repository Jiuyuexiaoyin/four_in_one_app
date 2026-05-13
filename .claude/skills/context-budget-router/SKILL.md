---
name: context-budget-router
description: Manually invoked context budgeting workflow for four_in_one_app. Use before UI polish, UI audit, design token work, page polish, debugging, validation planning, or documentation tasks to reduce token usage. It selects the minimal files to read, avoids broad scans, routes to the correct local Skill, compresses context into a short task brief, and outputs the shortest safe next prompt.
disable-model-invocation: true
---

# Context Budget Router

> **Manual-only.** If the Claude Code harness does not honor the `disable-model-invocation: true` flag in the frontmatter, this Skill is still to be treated as manual-only. The agent must not auto-invoke this Skill. It runs only when the user explicitly types `/context-budget-router` (or otherwise explicitly invokes it by name). If the agent is uncertain whether this Skill applies, it must ask the user first; it must not run silently.

---

## Purpose

This Skill reduces token usage by preventing unnecessary broad reading and repeated long prompts.

It should be used before any large task to decide:

- which local Skill to use
- which files are actually needed
- which files should not be read
- whether code changes are allowed
- whether validation is needed
- what the shortest safe next prompt should be

The intent is not to read fewer files in absolute terms. The intent is to read the **right few files at the right time**.

---

## Hard Rules

- Manual invocation only.
- Do not modify files unless the user explicitly approves an implementation step.
- Do not read `docs/**` broadly.
- Do not read `lib/**` broadly.
- Do not read screenshots unless the task specifically requires a visual reference.
- Do not re-read long handoff documents if a short context brief is enough.
- Do not run validation unless code has changed.
- Do not build APK.
- Do not bump version.
- Do not add dependencies.
- Do not modify native config.
- Do not modify business logic or data models unless the user explicitly asks for that type of task.
- For UI tasks, route to `premium-minimal-ui-polish`.
- Do not let this Skill override safety boundaries declared in any other local Skill. The boundaries in `premium-minimal-ui-polish/SKILL.md` (sections 4–7 of that skill) take precedence whenever a UI task is routed.

---

## Task Categories

Classify every task into exactly one of the following categories. If the task is ambiguous, ask the user for clarification before reading many files.

1. UI taste / visual reference
2. UI audit
3. P1 Design Tokens
4. P2 Shared Components
5. Page polish
6. Motion planning
7. Validation / debugging
8. Documentation
9. Phone-test APK flow
10. Other

If the user's request straddles two categories, pick the one that most narrows the file-read footprint. Ask the user to confirm the category before continuing.

---

## Minimal File Selection Rules

### For UI planning tasks (categories 1, 2, 6)

Prefer reading only:

- `.claude/skills/context-budget-router/SKILL.md`
- `.claude/skills/premium-minimal-ui-polish/SKILL.md`
- `docs/ui/UI_CONTEXT_BRIEF.md` if it exists
- the specific file or folder mentioned by the user

### For P1 Design Tokens planning (category 3)

Prefer:

- `.claude/skills/premium-minimal-ui-polish/SKILL.md`
- `docs/ui/UI_CONTEXT_BRIEF.md` if it exists
- `lib/app/theme/app_theme_tokens.dart`
- `lib/shared/widgets/product/soft_surface.dart`
- `lib/shared/theme/app_text_styles.dart` only if it already exists
- `lib/shared/theme/app_dark_palette.dart` only if it already exists

### For P2 Shared Components planning (category 4)

Prefer:

- `.claude/skills/premium-minimal-ui-polish/SKILL.md`
- `docs/ui/UI_CONTEXT_BRIEF.md` if it exists
- `lib/shared/widgets/product/soft_surface.dart`
- The specific shared widget file targeted (e.g., `metric_strip.dart`, `activity_strip.dart`)
- Tokens introduced by P1 if already present

### For page polish (category 5)

Prefer:

- `.claude/skills/premium-minimal-ui-polish/SKILL.md`
- `docs/ui/UI_CONTEXT_BRIEF.md` if it exists
- **only the target page file** (e.g., one of: `today_page.dart`, `habits_page.dart`, `goals_page.dart`, `focus_page.dart`, `review_page.dart`, `settings_page.dart`)
- only the shared widgets directly used by that page

### For debugging (category 7)

Prefer:

- the error log or test output the user pasted
- the exact file named by the error
- `tooling/README.md` or `TESTING.md` only if validation command context is needed
- the specific test file that failed

### For documentation (category 8)

Prefer:

- the target document only
- `docs/ui/UI_CONTEXT_BRIEF.md` if project context is needed

### For phone-test APK flow (category 9)

Defer entirely until the user has explicitly approved a release step. Do not auto-prepare anything. Read no files; ask the user for the next manual instruction.

### For "Other" (category 10)

Ask the user what the task is before reading anything.

---

## Files Usually Not Needed

Do not read these unless the task explicitly requires them:

- all of `docs/` recursively
- all of `lib/` recursively
- all of `test/` recursively
- `android/**`
- `ios/**`
- `build/**`
- screenshot folders (`docs/references/app_content/**`, `docs/references/ui_taste_board/**`)
- old handoff documents (`docs/ai_handoff/**`) — read only the one specifically named
- long benchmark reports (`docs/final_benchmark_ui_feature_review_v6h.md`, etc.) — read only the section explicitly cited

If a glob would match more than ~5 files, treat that as a red flag and either narrow the glob or ask the user to identify the specific file.

---

## Routing Rules

If the task involves UI, visual polish, dark premium productivity, design tokens, components, cards, typography, spacing, charts, or motion:

> Route to: **`premium-minimal-ui-polish`**

If the task involves reducing token usage, choosing files, compressing prompts, or deciding next context:

> Use: **`context-budget-router`** (this Skill)

If the task involves business logic, data models, persistence, migrations, schemas, native config, version bumps, APK preparation, or anything outside the visual layer:

> Stop. Do **not** route to a UI Skill. Ask the user to confirm scope before proceeding.

If multiple Skills appear to apply:

> Default to the narrower one. UI work → `premium-minimal-ui-polish`. Context routing → `context-budget-router`. Never invoke both in the same turn without telling the user.

---

## Required Output Format

When invoked, output exactly the following items, in this order, and stop:

1. **Task category** — one of the 10 categories above.
2. **Recommended Skill to use next** — the exact Skill name.
3. **Minimal files to read** — concrete paths, capped at the smallest workable set.
4. **Files not needed** — paths or globs the agent should explicitly NOT open this turn.
5. **Whether code changes are allowed** — explicit yes / no, with the boundary (e.g., "only `lib/app/theme/**`").
6. **Whether validation is needed** — explicit yes / no; if yes, name the fixed validation command pointer (do not paste the command).
7. **Risk level** — low / medium / high, with one sentence of justification.
8. **Short context summary** — maximum 8 bullets, each under ~20 words.
9. **Shortest safe next prompt** — the exact short message the user should copy and send next. No additional preamble.
10. **Stop point** — one sentence stating what the agent must NOT do until the user approves the next step.

Do not add anything after item 10. Do not start performing the task in the same turn.

---

## Short Prompt Principle

Always replace long prompts with short prompts when possible.

**Instead of repeating all project bans**, say:

```
Use premium-minimal-ui-polish.
Task: Prepare P1 Design Tokens plan only.
Read minimal files only.
Do not modify files yet.
```

The local Skills already encode the bans. The short prompt only needs to:

- name the Skill,
- name the task,
- state read-only or modify intent,
- state validation expectation if any.

If the user's last prompt was long but the task is small, suggest the equivalent short version in the "shortest safe next prompt" output field.

---

## Context Brief Recommendation

If `docs/ui/UI_CONTEXT_BRIEF.md` does **not** exist, recommend creating it later, in a separate documentation task, after explicit user approval. Do not create it automatically.

Recommended contents of the brief (when the user later approves):

- current project status (version, last validated test count, last full-pass package completed)
- hard bans (no version bump, no APK, no native config, no dependency change, no business logic in UI tasks)
- current UI direction (Dark Premium Productivity)
- current UI workflow (audit → tokens → shared widgets → page polish → motion)
- validation command pointer (the fixed `cmd.exe /d /s /c "... call .\tooling\v6b.cmd"`)
- active Skills (`premium-minimal-ui-polish`, `context-budget-router`)

The brief must be short — under 60 lines. Its job is to replace the need for the agent to re-read long handoff docs at the start of every session.

---

## Final Rule

The goal is **not** to avoid reading files completely.
The goal is to read **the right few files at the right time**.

When in doubt, ask the user before reading. A clarifying question is cheaper than a wasted scan.

---

End of skill.
