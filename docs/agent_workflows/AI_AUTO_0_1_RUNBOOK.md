# AI-AUTO-0.1 Runbook

## Purpose

AI-AUTO-0.1 provides verification-only automation scaffolding for `four_in_one_app`.
It does not implement AI agents, use the OpenAI API, create runner tokens, build APKs,
or auto-merge changes.

## What It Does

- Provides the GitHub Actions workflow `AI Verify`.
- Uses a fixed local Windows self-hosted runner.
- Supports targeted verification.
- Supports full verification.
- Uses the stable local verify wrapper for full verification:

```powershell
D:\AI\Tools\Codex\four_in_one_v6b_verify.cmd
```

## Repo And Branch

- GitHub repo: <https://github.com/Jiuyuexiaoyin/four_in_one_app>
- Branch: `p7-ui-foundation`

## Runner Information

- Runner name: `four-in-one-local`
- Runner label: `four-in-one`
- Runner path: `D:\actions-runner\four_in_one_app`
- Service name: `actions.runner.Jiuyuexiaoyin-four_in_one_app.four-in-one-local`

## Setup Fixes Applied

PowerShell execution policy:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
```

Git safe.directory entries:

```text
D:/AI/Projects/four_in_one_app
D:/AI/Tools/Flutter/flutter
```

## Restart Runner Service

Restart the runner service:

```powershell
Restart-Service "actions.runner.Jiuyuexiaoyin-four_in_one_app.four-in-one-local" -Force
```

Check runner service status:

```powershell
Get-Service "actions.runner.Jiuyuexiaoyin-four_in_one_app.four-in-one-local"
```

## Run Verification

1. Open GitHub Actions.
2. Select `AI Verify`.
3. Choose `Run workflow`.
4. Select mode:
   - `targeted`
   - `full`

Current confirmed status:

- `targeted` mode passed.
- `full` mode passed.

## Known Warning

The Node.js 20 actions deprecation warning from `actions/checkout@v4` is currently
non-blocking.

## Next Planned Phase: AI-AUTO-0.2

Planned additions:

- Add Planner / Implementer / Reviewer / Fixer / Reporter prompts.
- Add `codex exec` pipeline scripts.
- Do not auto-merge `main`.
- Limit fix loops to 2 rounds.
- Keep verifier as script/CI output, not model opinion.
