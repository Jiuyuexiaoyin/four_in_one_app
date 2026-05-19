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
$auditTaskFile = "P7H_2A_habit_detail_audit.md"
$imageManifestPath = Join-Path $reportsDir "codex_image_manifest.md"
$auditReportPath = Join-Path $repoPath "docs\ui_redesign\P7H_2A_habit_detail_audit.md"
$allowedAuditFiles = @(
  "docs/ui_redesign/P7H_2A_habit_detail_audit.md",
  "ai/reports/planner_report.md",
  "ai/reports/implementer_report.md",
  "ai/reports/reviewer_report.md",
  "ai/reports/final_report.md"
)

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

function Test-IsAllowedAuditFile {
  param([string]$Path)
  return $allowedAuditFiles -contains $Path
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

if ($TaskFile -ne $probeTaskFile -and $TaskFile -ne $auditTaskFile) {
  throw "Real execute mode is only allowed for $probeTaskFile or $auditTaskFile. Requested: $TaskFile"
}

Assert-NoForbiddenChanges -ChangedFiles $nameOnly

if ($TaskFile -eq $probeTaskFile) {
  $blockingIssues = @($nameOnly | Where-Object { -not (Test-IsAllowedProbeReport -Path $_) })
} else {
  $blockingIssues = @($nameOnly | Where-Object { -not (Test-IsAllowedAuditFile -Path $_) })
  if (-not (Test-Path -Path $auditReportPath)) {
    $blockingIssues += "Missing docs/ui_redesign/P7H_2A_habit_detail_audit.md"
  } else {
    $auditText = Get-Content -Path $auditReportPath -Raw
    if ($auditText -notmatch "docs/references|visual_library_full|codex_image_manifest|current_app_ui|The Outsiders|Equinox") {
      $blockingIssues += "Audit does not cite visual references."
    }
    if ($auditText -notmatch "Theme Studio|custom color|habit color") {
      $blockingIssues += "Audit ignores Theme Studio or habit color."
    }
    if ($auditText -notmatch "P7H-2B") {
      $blockingIssues += "Audit does not define P7H-2B next scope."
    }
    if ($auditText -match "color-only|token-only|card-stack only|generic dark dashboard") {
      $blockingIssues += "Audit suggests or permits a rejected color-only/token-only/card-stack direction."
    }
    if ($auditText.Length -lt 1200) {
      $blockingIssues += "Audit is too short and likely generic."
    }
  }
}

$status = if ($blockingIssues.Count -eq 0) { "PASS" } else { "FAIL" }

$report = @"
# Reviewer Report

REVIEW STATUS: $status

Task file: $TaskFile

## Changed Files

$($nameOnly | ForEach-Object { "- $_" } | Out-String)

## Blocking Issues

$(if ($status -eq "PASS") { "None." } else { $blockingIssues | ForEach-Object { "- $_" } | Out-String })

## Non-Blocking Issues

None.

## Exact Fix Prompt For Fixer

$(if ($status -eq "PASS") { "No fixer needed." } else { "Revise the audit so changed files are limited to allowed outputs, visual references are cited, Theme Studio is addressed, and P7H-2B scope/tests/screenshot checklist are concrete." })
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8

if ($status -ne "PASS") {
  throw "Reviewer failed for $TaskFile."
}

Write-Host "AI_REVIEWER_EXECUTE_PASS"
