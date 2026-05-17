param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [switch]$Execute,
  [int]$MaxFixLoops = 2
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$scriptsDir = "D:\AI\Projects\four_in_one_app\ai\scripts"
$probeTaskFile = "probe_agent_report.md"

Set-Location -Path $repoPath

Write-Host "AI_PIPELINE_START"
Write-Host "Task file: $TaskFile"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE' } else { 'DRY_RUN' })"
Write-Host "Max fix loops: $MaxFixLoops"
Write-Host ""
Write-Host "Pipeline plan:"
Write-Host "1. Planner"
Write-Host "2. Implementer"
Write-Host "3. Targeted verify"
Write-Host "4. Reviewer"
Write-Host "5. Optional Fixer loop, max $MaxFixLoops rounds"
Write-Host "6. Reporter final report"
Write-Host ""
Write-Host "Rules:"
Write-Host "- no auto-commit"
Write-Host "- no auto-merge"
Write-Host "- no APK build in v0.2"
Write-Host "- verifier remains script/CI, not model opinion"
Write-Host ""

& (Join-Path $scriptsDir "show_status.ps1")

if (-not $Execute) {
  Write-Host "AI_PIPELINE_DRY_RUN_OK"
  Write-Host "Use -Execute later to enable staged agent execution. v0.2 still uses placeholders for codex exec."
  return
}

if ($TaskFile -ne $probeTaskFile) {
  throw "Real execute mode is only allowed for $probeTaskFile. Requested: $TaskFile"
}

& (Join-Path $scriptsDir "run_ai_planner.ps1") -TaskFile $TaskFile
& (Join-Path $scriptsDir "run_ai_implementer.ps1") -TaskFile $TaskFile -Execute

Write-Host "No Flutter verification is required for the safe probe task."
& (Join-Path $scriptsDir "run_ai_reviewer.ps1") -TaskFile $TaskFile -Execute
& (Join-Path $scriptsDir "run_ai_reporter.ps1") -TaskFile $TaskFile -Execute
Write-Host "AI_PIPELINE_EXECUTE_PROBE_OK"
