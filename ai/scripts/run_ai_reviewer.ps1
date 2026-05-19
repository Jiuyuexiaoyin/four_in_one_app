param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [switch]$Execute,
  [switch]$UseImages
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$tasksDir = "D:\AI\Projects\four_in_one_app\ai\tasks"
$promptsDir = "D:\AI\Projects\four_in_one_app\ai\prompts"
$probeTaskFile = "probe_agent_report.md"
$imageManifestPath = Join-Path $reportsDir "codex_image_manifest.md"

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

function Test-IsAllowedProbeReport {
  param([string]$Path)
  return $Path -match '^ai/reports/[^/]+\.md$'
}

function Assert-NoForbiddenChanges {
  param([string[]]$ChangedFiles)

  foreach ($file in $ChangedFiles) {
    if (
      $file.StartsWith("lib/") -or
      $file.StartsWith("test/") -or
      $file.StartsWith("android/") -or
      $file.StartsWith("ios/") -or
      $file.StartsWith("docs/references/") -or
      $file -eq "pubspec.yaml"
    ) {
      Write-Host "FORBIDDEN_CHANGE_DETECTED"
      Write-Host $file
      throw "Forbidden change detected: $file"
    }
  }
}

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
$nameOnly = @(git diff --name-only)
$stat = @(git diff --stat)
$codexExecCommand = "codex exec --sandbox read-only -- `"$promptPath`" `"$taskPath`""

Write-Host "AI_REVIEWER_START"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE' } else { 'DRY_RUN' })"
Write-Host "Task file: $taskPath"
Write-Host "Prompt file: $promptPath"
Write-Host "Report path: $reportPath"
Write-Host "Use images: $UseImages"
Write-Host "Changed files:"
$nameOnly
Write-Host "Diff stat:"
$stat

if ($UseImages) {
  if (Test-Path -Path $imageManifestPath) {
    $manifestLines = Get-Content -Path $imageManifestPath
    $selectedCountLine = $manifestLines | Where-Object { $_ -match "Selected image count:" } | Select-Object -First 1
    Write-Host "Image manifest: $imageManifestPath"
    Write-Host $selectedCountLine
  } else {
    Write-Host "Image manifest requested but missing: $imageManifestPath"
  }
}

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

Image manifest:
$(if ($UseImages -and (Test-Path -Path $imageManifestPath)) { Get-Content -Path $imageManifestPath -Raw } else { "Not used." })
"@
  Set-Content -Path $reportPath -Value $report -Encoding UTF8
  Write-Host "AI_REVIEWER_DRY_RUN_OK"
  return
}

if ($TaskFile -ne $probeTaskFile) {
  throw "Real execute mode is only allowed for $probeTaskFile. Requested: $TaskFile"
}

Assert-NoForbiddenChanges -ChangedFiles $nameOnly

$nonReportChanges = @($nameOnly | Where-Object { -not (Test-IsAllowedProbeReport -Path $_) })
$status = if ($nonReportChanges.Count -eq 0) { "PASS" } else { "FAIL" }

$report = @"
# Reviewer Report

REVIEW STATUS: $status

Task file: $TaskFile

## Changed Files

$($nameOnly | ForEach-Object { "- $_" } | Out-String)

## Blocking Issues

$(if ($status -eq "PASS") { "None." } else { "Non-report changes detected:`n$($nonReportChanges | ForEach-Object { "- $_" } | Out-String)" })

## Non-Blocking Issues

None.

## Exact Fix Prompt For Fixer

$(if ($status -eq "PASS") { "No fixer needed." } else { "Revert or remove all non-ai/reports/*.md changes and rerun reviewer." })
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8

if ($status -ne "PASS") {
  throw "Reviewer failed because changed files are not limited to ai/reports/*.md."
}

Write-Host "AI_REVIEWER_EXECUTE_PROBE_PASS"
