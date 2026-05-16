param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$tasksDir = "D:\AI\Projects\four_in_one_app\ai\tasks"
$promptsDir = "D:\AI\Projects\four_in_one_app\ai\prompts"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

$taskPath = Join-Path $tasksDir $TaskFile
$promptPath = Join-Path $promptsDir "planner.md"
$reportPath = Join-Path $reportsDir "planner_report.md"

if (-not (Test-Path -Path $taskPath)) {
  throw "Task file not found: $taskPath"
}
if (-not (Test-Path -Path $promptPath)) {
  throw "Planner prompt not found: $promptPath"
}

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue

Write-Host "AI_PLANNER_START"
Write-Host "Task file: $taskPath"
Write-Host "Prompt file: $promptPath"
Write-Host "Report path: $reportPath"

$taskText = Get-Content -Path $taskPath -Raw
$promptText = Get-Content -Path $promptPath -Raw

$report = @"
# Planner Report

Status: DRY_RUN

Task file: $taskPath
Prompt file: $promptPath

Codex CLI available: $([bool]$codexCommand)

## TODO

When AI-AUTO enables execution, run a `codex exec` planner command that combines
the planner prompt with the task file and writes this report.

## Prompt Preview

$promptText

## Task Preview

$taskText
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8

if ($null -eq $codexCommand) {
  Write-Host "codex command not found. Install/configure Codex CLI before enabling planner execution."
} else {
  Write-Host "codex command found: $($codexCommand.Source)"
  Write-Host "TODO codex exec command placeholder: codex exec -- <planner prompt + task file>"
}

Write-Host "AI_PLANNER_DRY_RUN_OK"
