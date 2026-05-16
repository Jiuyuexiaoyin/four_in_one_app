$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$flutter = "D:\AI\Tools\Flutter\flutter\bin\flutter.bat"

Set-Location -Path $repoPath

& $flutter analyze --no-pub
if ($LASTEXITCODE -ne 0) {
  throw "flutter analyze --no-pub failed with exit code $LASTEXITCODE."
}

$testFiles = @(
  "test/app_smoke_test.dart",
  "test/settings_theme_test.dart",
  "test/today_overview_test.dart",
  "test/habits_flow_test.dart",
  "test/goals_flow_test.dart"
)

foreach ($testFile in $testFiles) {
  & $flutter test --no-pub $testFile
  if ($LASTEXITCODE -ne 0) {
    throw "flutter test --no-pub $testFile failed with exit code $LASTEXITCODE."
  }
}

Write-Host "AI_TARGETED_TESTS_OK"
