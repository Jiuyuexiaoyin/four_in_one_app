param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [ValidateSet("probe", "audit", "workflow", "docs", "code_implementation", "ui_implementation", "release")]
  [string]$TaskType = "audit",
  [switch]$Execute,
  [string]$FinalTeamStatus = "UNKNOWN",
  [int]$FixLoopCount = 0
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$reportPath = Join-Path $reportsDir "final_report.md"
$verifierReportPath = Join-Path $reportsDir "verifier_report.md"
$reviewerReportPath = Join-Path $reportsDir "reviewer_report.md"
$visualReviewerReportPath = Join-Path $reportsDir "visual_reviewer_report.md"
$imageManifestPath = Join-Path $reportsDir "codex_image_manifest.md"
$screenshotsDir = Join-Path $repoPath "screenshots"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

function Get-ReportStatus {
  param(
    [string]$Path,
    [string]$Pattern
  )

  if (-not (Test-Path -Path $Path)) {
    return "Missing"
  }
  $line = Get-Content -Path $Path | Where-Object { $_ -match $Pattern } | Select-Object -First 1
  if ([string]::IsNullOrWhiteSpace($line)) {
    return "Present, status line not found"
  }
  return $line
}

$changedFiles = @(
  git diff --name-only
  git ls-files --others --exclude-standard
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Replace("\", "/") } | Sort-Object -Unique

$forbiddenFiles = @(
  $changedFiles | Where-Object {
    $_.StartsWith("docs/references/") -or
    ($TaskType -in @("probe", "audit", "workflow", "docs") -and ($_.StartsWith("lib/") -or $_.StartsWith("test/"))) -or
    ($TaskType -ne "release" -and ($_.StartsWith("android/") -or $_.StartsWith("ios/") -or $_.StartsWith("build/") -or $_ -eq "pubspec.yaml" -or $_ -like "*.apk"))
  }
)

$screenshotFiles = @()
if (Test-Path -Path $screenshotsDir) {
  $screenshotFiles = @(Get-ChildItem -Path $screenshotsDir -Recurse -File -Include "*.png", "*.jpg", "*.jpeg", "*.webp" -ErrorAction SilentlyContinue)
}

$availableReports = @(Get-ChildItem -Path $reportsDir -Filter "*.md" -File -ErrorAction SilentlyContinue)
$verifierStatus = Get-ReportStatus -Path $verifierReportPath -Pattern "VERIFIER STATUS:"
$reviewerStatus = Get-ReportStatus -Path $reviewerReportPath -Pattern "REVIEW STATUS:"
$visualReviewerStatus = Get-ReportStatus -Path $visualReviewerReportPath -Pattern "VISUAL REVIEW STATUS:"
$selectedImageCount = if (Test-Path -Path $imageManifestPath) {
  $line = Get-Content -Path $imageManifestPath | Where-Object { $_ -match "Selected image count:" } | Select-Object -First 1
  if ([string]::IsNullOrWhiteSpace($line)) { "Not available" } else { $line }
} else {
  "Not available"
}

$summary = @"
# Final Report

Final team status: $FinalTeamStatus

Task file: $TaskFile
Task type: $TaskType
Execute: $Execute
Fix loop count: $FixLoopCount

Verifier result: $verifierStatus
Code reviewer result: $reviewerStatus
Visual reviewer result: $visualReviewerStatus

Changed files:
$($changedFiles | ForEach-Object { "- $_" } | Out-String)

Forbidden files if any:
$(if ($forbiddenFiles.Count -eq 0) { "- None." } else { $forbiddenFiles | ForEach-Object { "- $_" } | Out-String })

Artifact paths:
- Reports: $reportsDir
- Image manifest: $(if (Test-Path -Path $imageManifestPath) { $imageManifestPath } else { "Not available" })
- Screenshots: $(if (Test-Path -Path $screenshotsDir) { $screenshotsDir } else { "Not available" })
- APK path if available: Not built by AI-AUTO-1.0.

Screenshot artifacts exist: $($screenshotFiles.Count -gt 0)
Selected image count: $selectedImageCount
User visual approval required: $(if ($TaskType -eq "ui_implementation") { "Yes" } else { "No, unless the task is UI-facing." })

Available reports:
$($availableReports | ForEach-Object { "- $($_.Name)" } | Out-String)

Next suggested command:
Review `ai/reports/final_report.md` and the uploaded AI Task artifacts before approving any next execution step.

Safety:
- Reporter did not edit app code.
- Reporter did not run Flutter.
- Reporter did not build APK.
- Reporter did not commit or merge.
"@

Set-Content -Path $reportPath -Value $summary -Encoding UTF8

Write-Host "AI_REPORTER_START"
Write-Host "Final team status: $FinalTeamStatus"
Write-Host "Task type: $TaskType"
Write-Host "Fix loop count: $FixLoopCount"
Write-Host "AI_REPORTER_OK"
