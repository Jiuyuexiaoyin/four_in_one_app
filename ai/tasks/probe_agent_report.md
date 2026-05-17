# Probe Agent Report

## Goal

Verify that AI Task execute=true can safely run the multi-agent pipeline without touching app code.

## Allowed files

Only these files may be created or modified:

- ai/reports/probe_agent_report.md
- ai/reports/planner_report.md
- ai/reports/implementer_report.md
- ai/reports/reviewer_report.md
- ai/reports/final_report.md

## Forbidden files

Do not modify:

- lib/**
- test/**
- pubspec.yaml
- android/**
- ios/**
- docs/references/**
- build/**
- *.apk

## Expected Planner behavior

- Read this task.
- Produce a short plan.
- Do not propose app source changes.

## Expected Implementer behavior

- Create ai/reports/probe_agent_report.md.
- Write:
  - task name
  - current timestamp
  - runner user if available
  - statement that no app source code was changed
  - statement that this is a safe pipeline probe
- Do not modify app source, tests, pubspec, native files, or build outputs.

## Expected Reviewer behavior

- Inspect git diff --name-only.
- PASS only if changed files are limited to ai/reports/*.md.
- FAIL if any app source/test/pubspec/native/build/reference files changed.

## Verification

No Flutter verification is required for this probe.

Required safety check:

```powershell
git diff --name-only
```

The output must not include:

- lib/
- test/
- pubspec.yaml
- android/
- ios/
- docs/references/
- build/

## Acceptance

The probe is accepted when:

- ai/reports/probe_agent_report.md exists
- planner / implementer / reviewer / reporter reports may exist
- no app source code changed
- no tests changed
- no pubspec changed
- no APK/build output was created
- no commit was made by the agent
