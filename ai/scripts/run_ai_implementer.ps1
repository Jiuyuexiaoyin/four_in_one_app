param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [switch]$Execute,
  [switch]$UseImages,
  [ValidateSet("global", "habits", "today", "plan", "focus", "review")]
  [string]$TaskPack = "global"
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$tasksDir = "D:\AI\Projects\four_in_one_app\ai\tasks"
$promptsDir = "D:\AI\Projects\four_in_one_app\ai\prompts"
$probeTaskFile = "probe_agent_report.md"
$imageArgsPath = Join-Path $reportsDir "codex_image_args.txt"
$allowedProbeReports = @(
  "ai/reports/probe_agent_report.md",
  "ai/reports/planner_report.md",
  "ai/reports/implementer_report.md",
  "ai/reports/reviewer_report.md",
  "ai/reports/final_report.md"
)

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

$taskPath = Join-Path $tasksDir $TaskFile
$promptPath = Join-Path $promptsDir "implementer.md"
$reportPath = Join-Path $reportsDir "implementer_report.md"

if (-not (Test-Path -Path $taskPath)) {
  throw "Task file not found: $taskPath"
}
if (-not (Test-Path -Path $promptPath)) {
  throw "Implementer prompt not found: $promptPath"
}

function Assert-NoForbiddenChanges {
  param([string]$Label)

  Write-Host $Label
  $changedFiles = @(git diff --name-only)
  if ($changedFiles.Count -eq 0) {
    Write-Host "(no tracked diff)"
  } else {
    $changedFiles
  }

  foreach ($file in $changedFiles) {
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
$imageArgs = ""
if ($UseImages -and (Test-Path -Path $imageArgsPath)) {
  $imageArgs = (Get-Content -Path $imageArgsPath -Raw).Trim()
}
$codexExecCommand = if ($UseImages -and -not [string]::IsNullOrWhiteSpace($imageArgs)) {
  "codex exec --sandbox workspace-write $imageArgs <safe probe prompt>"
} else {
  "codex exec --sandbox workspace-write <safe probe prompt>"
}

Write-Host "AI_IMPLEMENTER_START"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE' } else { 'DRY_RUN' })"
Write-Host "Task file: $taskPath"
Write-Host "Prompt file: $promptPath"
Write-Host "Report path: $reportPath"
Write-Host "Use images: $UseImages"
Write-Host "Task pack: $TaskPack"

if ($null -eq $codexCommand) {
  Write-Host "codex command not found. Dry-run only."
} else {
  Write-Host "codex command found: $($codexCommand.Source)"
  Write-Host "Exact codex exec command that would run:"
  Write-Host $codexExecCommand
}

if (-not $Execute) {
  Set-Content -Path $reportPath -Value "# Implementer Report`n`nStatus: DRY_RUN`n`nWould run: $codexExecCommand`n" -Encoding UTF8
  Write-Host "AI_IMPLEMENTER_DRY_RUN_OK"
  return
}

if ($TaskFile -ne $probeTaskFile) {
  throw "Real execute mode is only allowed for $probeTaskFile. Requested: $TaskFile"
}

if ($null -eq $codexCommand) {
  throw "Cannot execute implementer because codex command was not found."
}

Assert-NoForbiddenChanges -Label "AI_IMPLEMENTER_BEFORE_DIFF"

$taskText = Get-Content -Path $taskPath -Raw
$safePrompt = @"
You are running the AI-AUTO safe execute probe for four_in_one_app.

Only create ai/reports/probe_agent_report.md.
Do not modify app source code, tests, pubspec, native files, docs/references, build outputs, APK files, or tooling.
Do not commit.
Do not run Flutter.
Do not build APK.

Write ai/reports/probe_agent_report.md with:
- task name
- current timestamp
- runner user if available
- statement that no app source code was changed
- statement that this is a safe pipeline probe

Task file content:
$taskText
"@

Write-Host "Running safe probe codex exec."
if ($UseImages) {
  Write-Host "Image args requested, but execute mode only attaches images for UI-related tasks. Safe probe runs without images."
}
& $codexCommand.Source exec --sandbox workspace-write $safePrompt
$exitCode = $LASTEXITCODE

Assert-NoForbiddenChanges -Label "AI_IMPLEMENTER_AFTER_DIFF"

if ($exitCode -ne 0) {
  throw "codex exec failed with exit code $exitCode."
}

$changedFiles = @(git diff --name-only)
$report = @"
# Implementer Report

Status: EXECUTE_PROBE_COMPLETE

Task file: $TaskFile
Allowed report files:
$($allowedProbeReports | ForEach-Object { "- $_" } | Out-String)

Tracked diff after implementer:
$($changedFiles | ForEach-Object { "- $_" } | Out-String)

Safety:
- No commit was made.
- Flutter was not run by this script.
- APK build was not run by this script.
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Host "AI_IMPLEMENTER_EXECUTE_PROBE_OK"
