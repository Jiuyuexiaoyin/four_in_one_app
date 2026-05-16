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
$promptPath = Join-Path $promptsDir "fixer.md"
$reviewerReportPath = Join-Path $reportsDir "reviewer_report.md"
$reportPath = Join-Path $reportsDir "fixer_report.md"

if (-not (Test-Path -Path $taskPath)) {
  throw "Task file not found: $taskPath"
}
if (-not (Test-Path -Path $promptPath)) {
  throw "Fixer prompt not found: $promptPath"
}
if (-not (Test-Path -Path $reviewerReportPath)) {
  throw "Reviewer report is required before fixer can run: $reviewerReportPath"
}

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
$codexExecCommand = "codex exec --sandbox workspace-write -- `"$promptPath`" `"$taskPath`" `"$reviewerReportPath`""

Write-Host "AI_FIXER_START"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE' } else { 'DRY_RUN' })"
Write-Host "Task file: $taskPath"
Write-Host "Prompt file: $promptPath"
Write-Host "Reviewer report: $reviewerReportPath"
Write-Host "Report path: $reportPath"

if ($null -eq $codexCommand) {
  Write-Host "codex command not found. Dry-run only."
} else {
  Write-Host "codex command found: $($codexCommand.Source)"
  Write-Host "Exact codex exec command that would run:"
  Write-Host $codexExecCommand
}

if (-not $Execute) {
  Set-Content -Path $reportPath -Value "# Fixer Report`n`nStatus: DRY_RUN`n`nWould run: $codexExecCommand`n" -Encoding UTF8
  Write-Host "AI_FIXER_DRY_RUN_OK"
  return
}

if ($null -eq $codexCommand) {
  throw "Cannot execute fixer because codex command was not found."
}

Write-Host "AI_FIXER_EXECUTE_PLACEHOLDER"
Write-Host "Execution is intentionally not wired in v0.2 beyond command preview."
Set-Content -Path $reportPath -Value "# Fixer Report`n`nStatus: EXECUTE_PLACEHOLDER`n`nCommand preview: $codexExecCommand`n" -Encoding UTF8
