# ============================================================
# DEPRECATED FOR CURRENT V6B WORKFLOW — DO NOT RUN
# ============================================================
# This script formats files (dart format --set-exit-if-changed),
# writes a log file, and builds a debug APK.
# Running it without explicit user approval for a phone-test
# release will violate the following project rules:
#   - Do not format files without approval
#   - Do not write logs automatically
#   - Do not run flutter build apk
#   - Do not prepare APK
#
# CANONICAL V6B VALIDATION ENTRY: .\tooling\v6b.cmd
# That wrapper calls check_v6b_readonly.ps1, which is safe:
#   - no file formatting
#   - no log files
#   - no APK build
#
# Only run THIS file if the user explicitly starts an
# APK preparation / phone-test release process.
# ============================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "D:\AI\Projects\four_in_one_app"
$logPath = "D:\AI\Projects\four_in_one_app\tooling\v6b_validation_last.log"

Set-Location $projectRoot

$env:ANDROID_SDK_ROOT = "D:\AI\SDKs\Android"
$env:ANDROID_HOME = "D:\AI\SDKs\Android"
$env:JAVA_HOME = "D:\AI\Tools\AndroidStudio\android-studio\jbr"
$env:PUB_CACHE = "D:\AI\Cache\Pub"
$env:GRADLE_USER_HOME = "D:\AI\Cache\Gradle"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:DART_SUPPRESS_ANALYTICS = "true"
$env:FLUTTER_SUPPRESS_ANALYTICS = "true"

$dart = "D:\AI\Tools\Flutter\flutter\bin\cache\dart-sdk\bin\dart.exe"
$flutter = "D:\AI\Tools\Flutter\flutter\bin\flutter.bat"

function Write-V6BLog {
  param([string]$Message)

  Write-Host $Message
  Add-Content -LiteralPath $logPath -Value $Message -Encoding UTF8
}

function Format-V6BCommand {
  param(
    [string]$File,
    [string[]]$Arguments
  )

  $parts = @($File) + $Arguments
  return ($parts | ForEach-Object {
      if ($_ -match '[\s"]') {
        '"' + ($_ -replace '"', '\"') + '"'
      } else {
        $_
      }
    }) -join ' '
}

function Write-V6BOutput {
  param([object[]]$Output)

  if ($null -eq $Output -or $Output.Count -eq 0) {
    Write-V6BLog "(no output)"
    return
  }

  foreach ($item in $Output) {
    $text = ($item | Out-String).TrimEnd()
    if ($text.Length -eq 0) {
      continue
    }

    foreach ($line in ($text -split "`r?`n")) {
      Write-V6BLog $line
    }
  }
}

function Invoke-V6BStep {
  param(
    [string]$Name,
    [string]$File,
    [string[]]$Arguments
  )

  Write-V6BLog ""
  Write-V6BLog "===== STEP START: $Name ====="
  Write-V6BLog ("COMMAND: " + (Format-V6BCommand $File $Arguments))

  $previousErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $output = $null
  $exitCode = 1

  try {
    $output = & $File @Arguments 2>&1
    if ($null -eq $LASTEXITCODE) {
      $exitCode = 0
    } else {
      $exitCode = $LASTEXITCODE
    }
  } catch {
    $output = @($_.Exception.Message)
    $exitCode = 1
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }

  Write-V6BOutput $output
  Write-V6BLog "EXIT_CODE: $exitCode"

  if ($exitCode -ne 0) {
    Write-V6BLog "FAILED_STEP: $Name"
    Write-V6BLog "V6B_EXIT_CODE=$exitCode"
    exit $exitCode
  }

  Write-V6BLog "===== STEP PASSED: $Name ====="
}

Set-Content -LiteralPath $logPath -Value "V6B guarded validation started: $(Get-Date -Format o)" -Encoding UTF8
Write-Host "V6B guarded validation started"

Invoke-V6BStep "Dart version" $dart @("--version")
Invoke-V6BStep "Flutter version" $flutter @("--version")

Write-V6BLog ""
Write-V6BLog "===== GROUP START: Formatting V6B files ====="
Invoke-V6BStep "Format goal_item.dart" $dart @(
  "format",
  "--set-exit-if-changed",
  "lib/features/goals/domain/models/goal_item.dart"
)
Invoke-V6BStep "Format goals_store.dart" $dart @(
  "format",
  "--set-exit-if-changed",
  "lib/features/goals/application/goals_store.dart"
)
Invoke-V6BStep "Format goals_local_storage.dart" $dart @(
  "format",
  "--set-exit-if-changed",
  "lib/features/goals/data/goals_local_storage.dart"
)
Invoke-V6BStep "Format goals_page.dart" $dart @(
  "format",
  "--set-exit-if-changed",
  "lib/features/goals/presentation/pages/goals_page.dart"
)
Invoke-V6BStep "Format plan_tree_row.dart" $dart @(
  "format",
  "--set-exit-if-changed",
  "lib/shared/widgets/product/plan_tree_row.dart"
)
Invoke-V6BStep "Format goals_persistence_test.dart" $dart @(
  "format",
  "--set-exit-if-changed",
  "test/goals_persistence_test.dart"
)
Invoke-V6BStep "Format goals_flow_test.dart" $dart @(
  "format",
  "--set-exit-if-changed",
  "test/goals_flow_test.dart"
)
Write-V6BLog "===== GROUP PASSED: Formatting V6B files ====="

Write-V6BLog ""
Write-V6BLog "===== GROUP START: Focused Plan tests ====="
Invoke-V6BStep "Focused test goals_persistence_test.dart" $flutter @(
  "test",
  "--no-pub",
  "test/goals_persistence_test.dart"
)
Invoke-V6BStep "Focused test goals_flow_test.dart" $flutter @(
  "test",
  "--no-pub",
  "test/goals_flow_test.dart"
)
Write-V6BLog "===== GROUP PASSED: Focused Plan tests ====="

Invoke-V6BStep "Targeted analyze" $flutter @(
  "analyze",
  "--no-pub",
  "lib/features/goals",
  "test/goals_persistence_test.dart",
  "test/goals_flow_test.dart"
)

Invoke-V6BStep "Full analyze" $flutter @(
  "analyze",
  "--no-pub"
)

Invoke-V6BStep "Full tests" $flutter @(
  "test",
  "--no-pub"
)

Invoke-V6BStep "Debug build" $flutter @(
  "build",
  "apk",
  "--debug",
  "--no-pub"
)

Write-V6BLog ""
Write-V6BLog "V6B validation completed"
Write-V6BLog "V6B_EXIT_CODE=0"
