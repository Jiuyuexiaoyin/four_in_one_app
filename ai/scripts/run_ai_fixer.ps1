param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [ValidateSet("probe", "audit", "workflow", "docs", "code_implementation", "ui_implementation", "release")]
  [string]$TaskType = "audit",
  [switch]$Execute,
  [switch]$UseImages,
  [ValidateSet("global", "habits", "today", "plan", "focus", "review")]
  [string]$TaskPack = "global",
  [string]$FailureReportPath = "",
  [string]$AllowedFileListPath = ""
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$tasksDir = "D:\AI\Projects\four_in_one_app\ai\tasks"
$promptsDir = "D:\AI\Projects\four_in_one_app\ai\prompts"
$scriptsDir = "D:\AI\Projects\four_in_one_app\ai\scripts"
$imageArgsPath = Join-Path $reportsDir "codex_image_args.txt"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

$taskPath = Join-Path $tasksDir $TaskFile
$promptPath = Join-Path $promptsDir "fixer.md"
$reportPath = Join-Path $reportsDir "fixer_report.md"
$verifierReportPath = Join-Path $reportsDir "verifier_report.md"
$reviewerReportPath = Join-Path $reportsDir "reviewer_report.md"
$visualReviewerReportPath = Join-Path $reportsDir "visual_reviewer_report.md"

if (-not (Test-Path -Path $taskPath)) {
  throw "Task file not found: $taskPath"
}
if (-not (Test-Path -Path $promptPath)) {
  throw "Fixer prompt not found: $promptPath"
}

function Read-OptionalFile {
  param(
    [string]$Path,
    [string]$Title
  )

  if (Test-Path -Path $Path) {
    return "## $Title`n`nPath: $Path`n`n$(Get-Content -Path $Path -Raw)"
  }
  return "## $Title`n`nMissing: $Path"
}

function Invoke-Guard {
  $args = @("-TaskFile", $TaskFile, "-TaskType", $TaskType)
  if (-not [string]::IsNullOrWhiteSpace($AllowedFileListPath)) {
    $args += @("-AllowedFileListPath", $AllowedFileListPath)
  }
  & (Join-Path $scriptsDir "run_ai_guard_changed_files.ps1") @args
}

function Get-ImageArgumentValue {
  param([string]$Path)

  if (-not (Test-Path -Path $Path)) {
    return ""
  }

  $raw = (Get-Content -Path $Path -Raw).Trim()
  $match = [regex]::Match($raw, '^--image\s+"(?<value>.*)"$')
  if ($match.Success) {
    return $match.Groups["value"].Value
  }
  return ""
}

$fixerPrompt = Get-Content -Path $promptPath -Raw
$taskText = Get-Content -Path $taskPath -Raw
$failureReportText = if (-not [string]::IsNullOrWhiteSpace($FailureReportPath)) {
  Read-OptionalFile -Path $FailureReportPath -Title "Explicit Failure Report"
} else {
  ""
}

$fixPrompt = @"
# Fixer Prompt

$fixerPrompt

# Task

$taskText

# Blocking Reports

$(Read-OptionalFile -Path $verifierReportPath -Title "Verifier Report")

$(Read-OptionalFile -Path $reviewerReportPath -Title "Code Reviewer Report")

$(Read-OptionalFile -Path $visualReviewerReportPath -Title "Visual Reviewer Report")

$failureReportText

# Fixer Boundaries

Fix only blocking issues from these reports.
Do not broaden scope.
Do not auto-commit.
Do not run Flutter.
Do not build APK.
After editing, the central changed-file guard must pass for TaskType $TaskType.
"@

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
$imageValue = if ($UseImages) { Get-ImageArgumentValue -Path $imageArgsPath } else { "" }
$imagesAvailable = $UseImages -and -not [string]::IsNullOrWhiteSpace($imageValue)
$codexExecCommand = if ($imagesAvailable) {
  "codex exec --sandbox workspace-write --image `"$imageValue`" <fix prompt>"
} else {
  "codex exec --sandbox workspace-write <fix prompt>"
}

Write-Host "AI_FIXER_START"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE' } else { 'DRY_RUN' })"
Write-Host "Task file: $taskPath"
Write-Host "TaskType: $TaskType"
Write-Host "TaskPack: $TaskPack"
Write-Host "UseImages: $UseImages"
Write-Host "AllowedFileListPath: $AllowedFileListPath"
Write-Host "Report path: $reportPath"
Write-Host "Fix prompt length: $($fixPrompt.Length)"
Write-Host "Exact codex exec command that would run:"
Write-Host $codexExecCommand

if (-not $Execute) {
  Set-Content -Path $reportPath -Value "# Fixer Report`n`nStatus: DRY_RUN`n`nWould run: $codexExecCommand`n`nFix prompt:`n`n$fixPrompt`n" -Encoding UTF8
  Write-Host "AI_FIXER_DRY_RUN_OK"
  return
}

if ($env:AI_TEAM_LOOP_FIXER_ENABLED -ne "1") {
  throw "Fixer execute is only allowed from run_ai_team_loop.ps1 when EnableFixer is set."
}
if ($null -eq $codexCommand) {
  throw "Cannot execute fixer because codex command was not found."
}
if ([string]::IsNullOrWhiteSpace($fixPrompt)) {
  throw "EMPTY_FIXER_PROMPT"
}

Invoke-Guard

$codexArgs = @("exec", "--sandbox", "workspace-write")
if ($imagesAvailable) {
  $codexArgs += @("--image", $imageValue)
}

$fixPrompt | & $codexCommand.Source @codexArgs
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
  throw "codex exec fixer failed with exit code $exitCode."
}

Invoke-Guard

$changedFiles = @(
  git diff --name-only
  git ls-files --others --exclude-standard
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Replace("\", "/") } | Sort-Object -Unique

$report = @"
# Fixer Report

Status: EXECUTE_COMPLETE

Task file: $TaskFile
Task type: $TaskType
Task pack: $TaskPack

Changed files:
$($changedFiles | ForEach-Object { "- $_" } | Out-String)

Safety:
- Fixer was invoked from team loop with EnableFixer.
- Central changed-file guard passed after fixer.
- No commit was made.
- Flutter was not run by fixer.
- APK build was not run by fixer.
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Host "AI_FIXER_EXECUTE_OK"
