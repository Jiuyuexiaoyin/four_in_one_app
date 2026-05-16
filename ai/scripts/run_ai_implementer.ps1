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
$promptPath = Join-Path $promptsDir "implementer.md"
$reportPath = Join-Path $reportsDir "implementer_report.md"

if (-not (Test-Path -Path $taskPath)) {
  throw "Task file not found: $taskPath"
}
if (-not (Test-Path -Path $promptPath)) {
  throw "Implementer prompt not found: $promptPath"
}

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
$codexExecCommand = "codex exec --sandbox workspace-write -- `"$promptPath`" `"$taskPath`""

Write-Host "AI_IMPLEMENTER_START"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE' } else { 'DRY_RUN' })"
Write-Host "Task file: $taskPath"
Write-Host "Prompt file: $promptPath"
Write-Host "Report path: $reportPath"

if ($null -eq $codexCommand) {
  Write-Host "codex command not found. Dry-run only."
} else {
  Write-Host "codex command found: $($codexCommand.Source)"
  Write-Host "Exact codex exec command that would run:"
  Write-Host $codexExecCommand
}

if (-not $Execute) {
  Set-Content -Path $reportPath -Value "# Implementer Report`n`nStatus: DRY_RUN`n`nWould run: $codexExecCommand`n" -Encoding UTF8
  Write-Host "AI_IMPLEMENTER_DRY_RUN_OK"
  return
}

if ($null -eq $codexCommand) {
  throw "Cannot execute implementer because codex command was not found."
}

Write-Host "AI_IMPLEMENTER_EXECUTE_PLACEHOLDER"
Write-Host "Execution is intentionally not wired in v0.2 beyond command preview."
Set-Content -Path $reportPath -Value "# Implementer Report`n`nStatus: EXECUTE_PLACEHOLDER`n`nCommand preview: $codexExecCommand`n" -Encoding UTF8
