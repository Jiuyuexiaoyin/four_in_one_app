param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [ValidateSet("probe", "audit", "workflow", "docs", "code_implementation", "ui_implementation", "release")]
  [string]$TaskType = "audit",
  [switch]$UseImages,
  [ValidateSet("global", "habits", "today", "plan", "focus", "review")]
  [string]$TaskPack = "global",
  [switch]$Execute
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$tasksDir = "D:\AI\Projects\four_in_one_app\ai\tasks"
$promptsDir = "D:\AI\Projects\four_in_one_app\ai\prompts"
$reportPath = Join-Path $reportsDir "visual_reviewer_report.md"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

$taskPath = Join-Path $tasksDir $TaskFile
$promptPath = Join-Path $promptsDir "visual_reviewer.md"
$visualBriefPath = Join-Path $repoPath "docs\ui_redesign\P7_VISUAL_BRIEF.md"
$referenceManifestPath = Join-Path $repoPath "docs\references\REFERENCE_MANIFEST.md"
$imageManifestPath = Join-Path $reportsDir "codex_image_manifest.md"
$visualLibraryPath = Join-Path $reportsDir "visual_library_full.md"
$implementerReportPath = Join-Path $reportsDir "implementer_report.md"
$reviewerReportPath = Join-Path $reportsDir "reviewer_report.md"
$screenshotsDir = Join-Path $repoPath "screenshots"
$screenshotManifestPath = Join-Path $reportsDir "screenshot_artifacts.txt"

Write-Host "AI_VISUAL_REVIEWER_START"
Write-Host "TaskFile: $TaskFile"
Write-Host "TaskType: $TaskType"
Write-Host "UseImages: $UseImages"
Write-Host "TaskPack: $TaskPack"
Write-Host "Execute: $Execute"

$screenshotFiles = @()
if (Test-Path -Path $screenshotsDir) {
  $screenshotFiles = @(Get-ChildItem -Path $screenshotsDir -Recurse -File -Include "*.png", "*.jpg", "*.jpeg", "*.webp" -ErrorAction SilentlyContinue)
}
$screenshotManifestExists = Test-Path -Path $screenshotManifestPath

function Get-ContextSummary {
  param([string]$Path)

  if (-not (Test-Path -Path $Path)) {
    return "- $Path : missing"
  }

  $content = Get-Content -Path $Path -Raw
  return "- $Path : present ($($content.Length) chars)"
}

$blockingIssues = @()
$nonBlockingIssues = @()

if (-not (Test-Path -Path $taskPath)) {
  $blockingIssues += "Task file is missing: $taskPath"
}
if (-not (Test-Path -Path $promptPath)) {
  $blockingIssues += "Visual reviewer prompt is missing: $promptPath"
}

$uiLikeTask = $TaskType -eq "ui_implementation"
if ($uiLikeTask) {
  if (-not (Test-Path -Path $visualBriefPath)) {
    $blockingIssues += "P7 visual brief is missing."
  }
  if (-not (Test-Path -Path $referenceManifestPath)) {
    $blockingIssues += "Reference manifest is missing."
  }
  if (-not (Test-Path -Path $visualLibraryPath)) {
    $blockingIssues += "Full visual library is missing."
  }
  if (-not (Test-Path -Path $imageManifestPath)) {
    $blockingIssues += "Codex image manifest is missing."
  }
  if ($screenshotFiles.Count -eq 0 -and -not $screenshotManifestExists) {
    $blockingIssues += "Screenshot artifact is required for TaskType ui_implementation."
  }
} else {
  if ($screenshotFiles.Count -eq 0 -and -not $screenshotManifestExists) {
    $nonBlockingIssues += "No screenshot artifact found; screenshot is optional for TaskType $TaskType."
  }
}

$status = if ($blockingIssues.Count -eq 0) { "PASS" } else { "FAIL" }
if (-not $Execute) {
  $status = "DRY_RUN"
}

$manifestPreview = if (Test-Path -Path $imageManifestPath) {
  Get-Content -Path $imageManifestPath -Raw
} else {
  "Missing."
}

$report = @"
# Visual Reviewer Report

VISUAL REVIEW STATUS: $status

Task file: $TaskFile
Task type: $TaskType
Use images: $UseImages
Task pack: $TaskPack

Reference files:
- $visualBriefPath
- $referenceManifestPath
- $visualLibraryPath
- $imageManifestPath

Context files read:
$(Get-ContextSummary -Path $promptPath)
$(Get-ContextSummary -Path $taskPath)
$(Get-ContextSummary -Path $visualBriefPath)
$(Get-ContextSummary -Path $referenceManifestPath)
$(Get-ContextSummary -Path $imageManifestPath)
$(Get-ContextSummary -Path $visualLibraryPath)
$(Get-ContextSummary -Path $implementerReportPath)
$(Get-ContextSummary -Path $reviewerReportPath)

Screenshot artifacts:
$($screenshotFiles | ForEach-Object { "- $($_.FullName)" } | Out-String)
Screenshot artifact manifest: $(if ($screenshotManifestExists) { $screenshotManifestPath } else { "Not available" })

BLOCKING VISUAL ISSUES:
$(if ($blockingIssues.Count -eq 0) { "- None." } else { $blockingIssues | ForEach-Object { "- $_" } | Out-String })

NON-BLOCKING VISUAL ISSUES:
$(if ($nonBlockingIssues.Count -eq 0) { "- None." } else { $nonBlockingIssues | ForEach-Object { "- $_" } | Out-String })

FIX PROMPT FOR FIXER:
$(if ($blockingIssues.Count -eq 0) { "No visual fixer needed." } else { "Resolve only the blocking visual issues listed above. Preserve task scope, Theme Studio, visual references, and existing behavior." })

Image manifest preview:
$manifestPreview
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8

if ($status -eq "FAIL") {
  Write-Host "AI_VISUAL_REVIEWER_REPORT_BEGIN"
  Get-Content -Path $reportPath | ForEach-Object { Write-Host $_ }
  Write-Host "AI_VISUAL_REVIEWER_REPORT_END"
  throw "Visual reviewer failed for $TaskFile."
}

Write-Host "AI_VISUAL_REVIEWER_OK"
