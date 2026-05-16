param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [switch]$Execute
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$tasksDir = "D:\AI\Projects\four_in_one_app\ai\tasks"
$promptsDir = "D:\AI\Projects\four_in_one_app\ai\prompts"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

$taskPath = Join-Path $tasksDir $TaskFile
$promptPath = Join-Path $promptsDir "reviewer.md"
$reportPath = Join-Path $reportsDir "reviewer_report.md"

if (-not (Test-Path -Path $taskPath)) {
  throw "Task file not found: $taskPath"
}
if (-not (Test-Path -Path $promptPath)) {
  throw "Reviewer prompt not found: $promptPath"
}

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
$nameOnly = git diff --name-only
$stat = git diff --stat
$codexExecCommand = "codex exec --sandbox read-only -- `"$promptPath`" `"$taskPath`""

Write-Host "AI_REVIEWER_START"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE' } else { 'DRY_RUN' })"
Write-Host "Task file: $taskPath"
Write-Host "Prompt file: $promptPath"
Write-Host "Report path: $reportPath"
Write-Host "Changed files:"
$nameOnly
Write-Host "Diff stat:"
$stat

if ($null -eq $codexCommand) {
  Write-Host "codex command not found. Dry-run only."
} else {
  Write-Host "codex command found: $($codexCommand.Source)"
  Write-Host "Exact codex exec command that would run:"
  Write-Host $codexExecCommand
}

if (-not $Execute) {
  $report = @"
# Reviewer Report

Status: DRY_RUN

Task file: $taskPath
Prompt file: $promptPath

## Changed Files

$($nameOnly -join "`n")

## Diff Stat

$($stat -join "`n")

Would run: $codexExecCommand
"@
  Set-Content -Path $reportPath -Value $report -Encoding UTF8
  Write-Host "AI_REVIEWER_DRY_RUN_OK"
  return
}

if ($null -eq $codexCommand) {
  throw "Cannot execute reviewer because codex command was not found."
}

Write-Host "AI_REVIEWER_EXECUTE_PLACEHOLDER"
Write-Host "Execution is intentionally not wired in v0.2 beyond command preview."
Set-Content -Path $reportPath -Value "# Reviewer Report`n`nStatus: EXECUTE_PLACEHOLDER`n`nCommand preview: $codexExecCommand`n" -Encoding UTF8
