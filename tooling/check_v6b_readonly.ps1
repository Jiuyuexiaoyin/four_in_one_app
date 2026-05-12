Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "D:\AI\Projects\four_in_one_app"

Set-Location -LiteralPath $projectRoot

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

function Format-ReadOnlyCommand {
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

function Invoke-ReadOnlyStep {
  param(
    [string]$Name,
    [string]$File,
    [string[]]$Arguments
  )

  Write-Host ""
  Write-Host "===== STEP START: $Name ====="
  Write-Host ("COMMAND: " + (Format-ReadOnlyCommand $File $Arguments))

  & $File @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }

  Write-Host "EXIT_CODE: $exitCode"
  if ($exitCode -ne 0) {
    Write-Host "FAILED_STEP: $Name"
    exit $exitCode
  }

  Write-Host "===== STEP PASSED: $Name ====="
}

Write-Host "V6B read-only validation started"

Invoke-ReadOnlyStep "Dart version" $dart @("--version")
Invoke-ReadOnlyStep "Flutter version" $flutter @("--version")

Write-Host ""
Write-Host "===== GROUP START: Read-only formatting checks for V6B files ====="
Invoke-ReadOnlyStep "Check format goal_item.dart" $dart @(
  "format",
  "-o",
  "none",
  "--set-exit-if-changed",
  "lib\features\goals\domain\models\goal_item.dart"
)
Invoke-ReadOnlyStep "Check format goals_store.dart" $dart @(
  "format",
  "-o",
  "none",
  "--set-exit-if-changed",
  "lib\features\goals\application\goals_store.dart"
)
Invoke-ReadOnlyStep "Check format goals_local_storage.dart" $dart @(
  "format",
  "-o",
  "none",
  "--set-exit-if-changed",
  "lib\features\goals\data\goals_local_storage.dart"
)
Invoke-ReadOnlyStep "Check format goals_page.dart" $dart @(
  "format",
  "-o",
  "none",
  "--set-exit-if-changed",
  "lib\features\goals\presentation\pages\goals_page.dart"
)
Invoke-ReadOnlyStep "Check format plan_tree_row.dart" $dart @(
  "format",
  "-o",
  "none",
  "--set-exit-if-changed",
  "lib\shared\widgets\product\plan_tree_row.dart"
)
Invoke-ReadOnlyStep "Check format goals_persistence_test.dart" $dart @(
  "format",
  "-o",
  "none",
  "--set-exit-if-changed",
  "test\goals_persistence_test.dart"
)
Invoke-ReadOnlyStep "Check format goals_flow_test.dart" $dart @(
  "format",
  "-o",
  "none",
  "--set-exit-if-changed",
  "test\goals_flow_test.dart"
)
Write-Host "===== GROUP PASSED: Read-only formatting checks for V6B files ====="

Write-Host ""
Write-Host "===== GROUP START: Focused Plan tests ====="
Invoke-ReadOnlyStep "Focused test goals_persistence_test.dart" $flutter @(
  "test",
  "--no-pub",
  "test\goals_persistence_test.dart"
)
Invoke-ReadOnlyStep "Focused test goals_flow_test.dart" $flutter @(
  "test",
  "--no-pub",
  "test\goals_flow_test.dart"
)
Write-Host "===== GROUP PASSED: Focused Plan tests ====="

Invoke-ReadOnlyStep "Targeted analyze" $flutter @(
  "analyze",
  "--no-pub",
  "lib\features\goals",
  "test\goals_persistence_test.dart",
  "test\goals_flow_test.dart"
)

Invoke-ReadOnlyStep "Full analyze" $flutter @(
  "analyze",
  "--no-pub"
)

Invoke-ReadOnlyStep "Full tests" $flutter @(
  "test",
  "--no-pub"
)

Write-Host ""
Write-Host "V6B read-only validation completed"
