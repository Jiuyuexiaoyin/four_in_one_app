param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [ValidateSet("probe", "audit", "workflow", "docs", "code_implementation", "ui_implementation", "release")]
  [string]$TaskType = "audit",
  [ValidateSet("none", "audit", "habits", "ui-smoke", "full")]
  [string]$VerificationProfile = "none",
  [switch]$Execute,
  [string]$AllowedFileListPath = ""
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$scriptsDir = "D:\AI\Projects\four_in_one_app\ai\scripts"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$reportPath = Join-Path $reportsDir "verifier_report.md"
$flutterPath = "D:\AI\Tools\Flutter\flutter\bin\flutter.bat"
$standardVerifyScript = Join-Path $scriptsDir "run_verify.ps1"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

function Invoke-Guard {
  $guardParams = @{
    TaskFile = $TaskFile
    TaskType = $TaskType
  }

  if (-not [string]::IsNullOrWhiteSpace($AllowedFileListPath)) {
    $guardParams["AllowedFileListPath"] = $AllowedFileListPath
  }

  Write-Host "VERIFIER_GUARD_PARAMS:"
  foreach ($key in ($guardParams.Keys | Sort-Object)) {
    Write-Host ("- {0}: {1}" -f $key, $guardParams[$key])
  }

  if ($guardParams["TaskType"] -eq $guardParams["TaskFile"]) {
    throw "VERIFIER_INTERNAL_BINDING_BUG: Guard TaskType equals TaskFile"
  }

  if ($guardParams["TaskType"] -notin @("probe", "audit", "workflow", "docs", "code_implementation", "ui_implementation", "release")) {
    throw "VERIFIER_INVALID_TASK_TYPE: $($guardParams["TaskType"])"
  }

  & "D:\AI\Projects\four_in_one_app\ai\scripts\run_ai_guard_changed_files.ps1" @guardParams
}

function Invoke-VerifiedCommand {
  param(
    [string]$Label,
    [string[]]$CommandArgs
  )

  Write-Host "AI_VERIFIER_STEP_START: $Label"
  & $flutterPath @CommandArgs
  $exitCode = $LASTEXITCODE
  Write-Host "AI_VERIFIER_STEP_EXIT_CODE: $exitCode"
  if ($exitCode -ne 0) {
    throw "Verification step failed: $Label"
  }
}

Write-Host "AI_VERIFIER_START"
Write-Host "TaskFile: $TaskFile"
Write-Host "TaskType: $TaskType"
Write-Host "VerificationProfile: $VerificationProfile"
Write-Host "Execute: $Execute"
Write-Host "AllowedFileListPath: $AllowedFileListPath"

$status = "PASS"
$message = "Guard completed."

try {
  Invoke-Guard

  if (-not $Execute) {
    $status = "DRY_RUN"
    $message = "Guard completed. Verification profile '$VerificationProfile' was not executed because Execute is false."
  } else {
    switch ($VerificationProfile) {
      "none" {
        $message = "No verification commands requested; guard only."
      }
      "audit" {
        $message = "Audit profile completed; guard only."
      }
      "habits" {
        Invoke-VerifiedCommand -Label "habits_flow_test.dart" -CommandArgs @("test", "--no-pub", "test\habits_flow_test.dart")
        Invoke-VerifiedCommand -Label "app_smoke_test.dart" -CommandArgs @("test", "--no-pub", "test\app_smoke_test.dart")
        $message = "Habits verification profile passed."
      }
      "ui-smoke" {
        Invoke-VerifiedCommand -Label "analyze --no-pub" -CommandArgs @("analyze", "--no-pub")
        Invoke-VerifiedCommand -Label "app_smoke_test.dart" -CommandArgs @("test", "--no-pub", "test\app_smoke_test.dart")
        Invoke-VerifiedCommand -Label "settings_theme_test.dart" -CommandArgs @("test", "--no-pub", "test\settings_theme_test.dart")
        $message = "UI smoke verification profile passed."
      }
      "full" {
        if (-not (Test-Path -Path $standardVerifyScript)) {
          Write-Host "MISSING_STANDARD_VERIFY_SCRIPT"
          throw "Missing standard verification script: $standardVerifyScript"
        }
        & $standardVerifyScript
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
          throw "Standard full verification failed with exit code $exitCode."
        }
        $message = "Full verification profile passed through ai/scripts/run_verify.ps1."
      }
    }
  }
} catch {
  $status = "FAIL"
  $message = $_.Exception.Message
}

$changedFiles = @(
  git diff --name-only
  git ls-files --others --exclude-standard
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Replace("\", "/") } | Sort-Object -Unique

$report = @"
# Verifier Report

VERIFIER STATUS: $status

Task file: $TaskFile
Task type: $TaskType
Verification profile: $VerificationProfile
Execute: $Execute

Message: $message

Changed files:
$($changedFiles | ForEach-Object { "- $_" } | Out-String)
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8

if ($status -eq "FAIL") {
  Write-Host "AI_VERIFIER_REPORT_BEGIN"
  Get-Content -Path $reportPath | ForEach-Object { Write-Host $_ }
  Write-Host "AI_VERIFIER_REPORT_END"
  throw "Verifier failed for $TaskFile."
}

Write-Host "AI_VERIFIER_OK"
