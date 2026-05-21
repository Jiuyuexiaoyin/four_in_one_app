param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [ValidateSet("probe", "audit", "workflow", "docs", "code_implementation", "ui_implementation", "release")]
  [string]$TaskType = "audit",
  [switch]$Execute,
  [switch]$UseImages,
  [ValidateSet("global", "habits", "today", "plan", "focus", "review")]
  [string]$TaskPack = "global",
  [int]$MaxFixLoops = 2,
  [ValidateSet("none", "audit", "habits", "ui-smoke", "full")]
  [string]$VerificationProfile = "none",
  [switch]$EnableFixer,
  [string]$AllowedFileListPath = ""
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$scriptsDir = "D:\AI\Projects\four_in_one_app\ai\scripts"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

function Invoke-Step {
  param(
    [string]$Name,
    [scriptblock]$Action
  )

  Write-Host "AI_TEAM_LOOP_STAGE_START: $Name"
  & $Action
  Write-Host "AI_TEAM_LOOP_STAGE_OK: $Name"
}

function Invoke-Guard {
  $guardParams = @("-TaskFile", $TaskFile, "-TaskType", $TaskType)
  if (-not [string]::IsNullOrWhiteSpace($AllowedFileListPath)) {
    $guardParams += @("-AllowedFileListPath", $AllowedFileListPath)
  }
  & (Join-Path $scriptsDir "run_ai_guard_changed_files.ps1") @guardParams
}

function Invoke-Verifier {
  $verifierParams = @(
    "-TaskFile", $TaskFile,
    "-TaskType", $TaskType,
    "-VerificationProfile", $VerificationProfile
  )
  if ($Execute) { $verifierParams += "-Execute" }
  if (-not [string]::IsNullOrWhiteSpace($AllowedFileListPath)) {
    $verifierParams += @("-AllowedFileListPath", $AllowedFileListPath)
  }
  & (Join-Path $scriptsDir "run_ai_verifier.ps1") @verifierParams
}

function Invoke-CodeReviewer {
  $reviewerParams = @("-TaskFile", $TaskFile, "-TaskType", $TaskType)
  if ($Execute) { $reviewerParams += "-Execute" }
  if ($UseImages) { $reviewerParams += "-UseImages" }
  if (-not [string]::IsNullOrWhiteSpace($AllowedFileListPath)) {
    $reviewerParams += @("-AllowedFileListPath", $AllowedFileListPath)
  }
  & (Join-Path $scriptsDir "run_ai_reviewer.ps1") @reviewerParams
}

function Invoke-VisualReviewer {
  $visualReviewerParams = @("-TaskFile", $TaskFile, "-TaskType", $TaskType, "-TaskPack", $TaskPack)
  if ($UseImages) { $visualReviewerParams += "-UseImages" }
  if ($Execute) { $visualReviewerParams += "-Execute" }
  & (Join-Path $scriptsDir "run_ai_visual_reviewer.ps1") @visualReviewerParams
}

function Invoke-Reporter {
  param(
    [string]$FinalStatus,
    [int]$FixLoopCount
  )

  $reporterParams = @(
    "-TaskFile", $TaskFile,
    "-TaskType", $TaskType,
    "-FinalTeamStatus", $FinalStatus,
    "-FixLoopCount", $FixLoopCount
  )
  if ($Execute) { $reporterParams += "-Execute" }
  & (Join-Path $scriptsDir "run_ai_reporter.ps1") @reporterParams
}

Write-Host "AI_TEAM_LOOP_START"
Write-Host "Task file: $TaskFile"
Write-Host "Task type: $TaskType"
Write-Host "Execute: $Execute"
Write-Host "Use images: $UseImages"
Write-Host "Task pack: $TaskPack"
Write-Host "Max fix loops: $MaxFixLoops"
Write-Host "Verification profile: $VerificationProfile"
Write-Host "Enable fixer: $EnableFixer"
Write-Host "Allowed file list path: $AllowedFileListPath"
Write-Host "No auto-commit, no auto-merge, no APK build."

$finalStatus = "PASS"
$fixLoopCount = 0
$blockingFailure = $null

try {
  Invoke-Step -Name "show_status" -Action { & (Join-Path $scriptsDir "show_status.ps1") }
  Invoke-Step -Name "preflight_guard" -Action { Invoke-Guard }

  if ($UseImages) {
    Invoke-Step -Name "build_visual_library" -Action { & (Join-Path $scriptsDir "build_visual_library.ps1") }
    Invoke-Step -Name "build_codex_image_args" -Action { & (Join-Path $scriptsDir "build_codex_image_args.ps1") -TaskPack $TaskPack -MaxImages 12 }
  }

  Invoke-Step -Name "planner" -Action { & (Join-Path $scriptsDir "run_ai_planner.ps1") -TaskFile $TaskFile }

  Invoke-Step -Name "implementer" -Action {
    $implementerParams = @("-TaskFile", $TaskFile, "-TaskPack", $TaskPack)
    if ($Execute) { $implementerParams += "-Execute" }
    if ($UseImages) { $implementerParams += "-UseImages" }
    & (Join-Path $scriptsDir "run_ai_implementer.ps1") @implementerParams
  }

  $stagesPassed = $false
  while (-not $stagesPassed) {
    try {
      Invoke-Step -Name "verifier" -Action { Invoke-Verifier }
      Invoke-Step -Name "code_reviewer" -Action { Invoke-CodeReviewer }
      Invoke-Step -Name "visual_reviewer" -Action { Invoke-VisualReviewer }
      $stagesPassed = $true
    } catch {
      $blockingFailure = $_.Exception.Message
      Write-Host "AI_TEAM_LOOP_BLOCKING_FAILURE: $blockingFailure"

      if (-not $EnableFixer) {
        throw
      }
      if ($fixLoopCount -ge $MaxFixLoops) {
        throw "Max fixer loops reached: $MaxFixLoops"
      }

      $fixLoopCount += 1
      Write-Host "AI_TEAM_LOOP_FIX_LOOP_START: $fixLoopCount"
      $env:AI_TEAM_LOOP_FIXER_ENABLED = "1"
      $fixerArgs = @("-TaskFile", $TaskFile, "-TaskType", $TaskType, "-TaskPack", $TaskPack)
      if ($Execute) { $fixerArgs += "-Execute" }
      if ($UseImages) { $fixerArgs += "-UseImages" }
      if (-not [string]::IsNullOrWhiteSpace($AllowedFileListPath)) {
        $fixerArgs += @("-AllowedFileListPath", $AllowedFileListPath)
      }
      & (Join-Path $scriptsDir "run_ai_fixer.ps1") @fixerArgs
      Invoke-Guard
    }
  }
} catch {
  $finalStatus = "FAIL"
  $blockingFailure = $_.Exception.Message
}

Invoke-Reporter -FinalStatus $finalStatus -FixLoopCount $fixLoopCount

if ($finalStatus -ne "PASS") {
  Write-Host "AI_TEAM_LOOP_FAILED"
  Write-Host $blockingFailure
  exit 1
}

Write-Host "AI_TEAM_LOOP_OK"
