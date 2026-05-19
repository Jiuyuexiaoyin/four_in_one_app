param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [switch]$Execute
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$reportPath = Join-Path $reportsDir "final_report.md"
$probeTaskFile = "probe_agent_report.md"
$auditTaskFile = "P7H_2A_habit_detail_audit.md"
$reviewerReportPath = Join-Path $reportsDir "reviewer_report.md"
$imageManifestPath = Join-Path $reportsDir "codex_image_manifest.md"
$auditDocPath = Join-Path $repoPath "docs\ui_redesign\P7H_2A_habit_detail_audit.md"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

Write-Host "AI_REPORTER_START"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE_PLACEHOLDER' } else { 'DRY_RUN' })"
Write-Host "Task file: $TaskFile"
Write-Host "Reports directory: $reportsDir"
Write-Host "Final summary path: $reportPath"

if ($Execute -and $TaskFile -ne $probeTaskFile -and $TaskFile -ne $auditTaskFile) {
  throw "Real execute mode is only allowed for $probeTaskFile or $auditTaskFile. Requested: $TaskFile"
}

$availableReports = Get-ChildItem -Path $reportsDir -Filter "*.md" -File -ErrorAction SilentlyContinue
$changedFiles = @(
  git diff --name-only
  git ls-files --others --exclude-standard
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Replace("\", "/") } | Sort-Object -Unique
$forbiddenChanges = @(
  $changedFiles | Where-Object {
    $_.StartsWith("lib/") -or
    $_.StartsWith("test/") -or
    $_.StartsWith("android/") -or
    $_.StartsWith("ios/") -or
    $_.StartsWith("docs/references/") -or
    $_.StartsWith("build/") -or
    $_ -eq "pubspec.yaml" -or
    $_ -like "*.apk"
  }
)

if ($forbiddenChanges.Count -gt 0) {
  Write-Host "FORBIDDEN_CHANGE_DETECTED"
  $forbiddenChanges
  throw "Reporter detected forbidden changed files."
}

$reviewerStatus = "Unknown"
if (Test-Path -Path $reviewerReportPath) {
  $reviewerStatusLine = Get-Content -Path $reviewerReportPath |
    Where-Object { $_ -match "REVIEW STATUS:" } |
    Select-Object -First 1
  if (-not [string]::IsNullOrWhiteSpace($reviewerStatusLine)) {
    $reviewerStatus = $reviewerStatusLine
  }
}

$auditDocExists = Test-Path -Path $auditDocPath
$selectedImageCount = "Not available"
if (Test-Path -Path $imageManifestPath) {
  $selectedImageCountLine = Get-Content -Path $imageManifestPath |
    Where-Object { $_ -match "Selected image count:" } |
    Select-Object -First 1
  if (-not [string]::IsNullOrWhiteSpace($selectedImageCountLine)) {
    $selectedImageCount = $selectedImageCountLine
  }
}

if ($availableReports.Count -eq 0) {
  Write-Host "No report files found yet."
} else {
  Write-Host "Available reports:"
  foreach ($report in $availableReports) {
    Write-Host "- $($report.FullName)"
  }
}

$summary = @"
# Final Report

Status: $(if ($Execute) { "EXECUTE_PROBE_SUMMARY" } else { "DRY_RUN" })

Task file: $TaskFile
Reviewer status: $reviewerStatus
Audit document exists: $auditDocExists
Visual image manifest path: $(if (Test-Path -Path $imageManifestPath) { $imageManifestPath } else { "Not available" })
Selected image count: $selectedImageCount

Reporter did not edit app code, commit changes, build APKs, or run Flutter.
No forbidden app source/test/pubspec/native/reference/build/APK changes were detected by reporter.

Changed files:
$($changedFiles | ForEach-Object { "- $_" } | Out-String)

Available reports:
$($availableReports | ForEach-Object { "- $($_.Name)" } | Out-String)
"@

Set-Content -Path $reportPath -Value $summary -Encoding UTF8

Write-Host "AI_REPORTER_OK"
