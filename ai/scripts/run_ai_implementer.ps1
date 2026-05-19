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
$auditTaskFile = "P7H_2A_habit_detail_audit.md"
$imageArgsPath = Join-Path $reportsDir "codex_image_args.txt"
$allowedProbeReports = @(
  "ai/reports/probe_agent_report.md",
  "ai/reports/planner_report.md",
  "ai/reports/implementer_report.md",
  "ai/reports/reviewer_report.md",
  "ai/reports/final_report.md"
)
$allowedAuditFiles = @(
  "docs/ui_redesign/P7H_2A_habit_detail_audit.md",
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

function Assert-OnlyAllowedChanges {
  param(
    [string[]]$ChangedFiles,
    [string[]]$AllowedFiles
  )

  foreach ($file in $ChangedFiles) {
    if ($AllowedFiles -notcontains $file) {
      Write-Host "FORBIDDEN_CHANGE_DETECTED"
      Write-Host $file
      throw "Changed file is outside the allowed audit/probe outputs: $file"
    }
  }
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

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
$imageValue = if ($UseImages) { Get-ImageArgumentValue -Path $imageArgsPath } else { "" }
$codexExecCommand = if ($UseImages -and -not [string]::IsNullOrWhiteSpace($imageValue)) {
  "codex exec --sandbox workspace-write --image `"$imageValue`" <task prompt>"
} else {
  "codex exec --sandbox workspace-write <task prompt>"
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

if ($TaskFile -ne $probeTaskFile -and $TaskFile -ne $auditTaskFile) {
  throw "Real execute mode is only allowed for $probeTaskFile or $auditTaskFile. Requested: $TaskFile"
}

if ($null -eq $codexCommand) {
  throw "Cannot execute implementer because codex command was not found."
}

Assert-NoForbiddenChanges -Label "AI_IMPLEMENTER_BEFORE_DIFF"

$taskText = Get-Content -Path $taskPath -Raw
if ($TaskFile -eq $probeTaskFile) {
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
  $allowedOutputs = $allowedProbeReports
  $statusLabel = "EXECUTE_PROBE_COMPLETE"
} else {
  $visualBrief = "docs/ui_redesign/P7_VISUAL_BRIEF.md"
  $referenceManifest = "docs/references/REFERENCE_MANIFEST.md"
  $visualLibrary = "ai/reports/visual_library_full.md"
  $imageManifest = "ai/reports/codex_image_manifest.md"
  $visualSelection = "ai/reports/visual_refs_selected.txt"
  $safePrompt = @"
You are running AI-AUTO P7H-2A Habit Detail Rhythm Audit for four_in_one_app.

This is audit-only. Do not modify app source code, tests, pubspec, native files, docs/references, build outputs, APK files, or tooling.
Do not commit.
Do not run Flutter.
Do not build APK.

Only create docs/ui_redesign/P7H_2A_habit_detail_audit.md.

Read and use this context if present:
- $visualBrief
- $referenceManifest
- $visualLibrary
- $imageManifest
- $visualSelection

The audit must answer:
1. Why current habit detail/month view feels database-like.
2. What must remain for habit semantics and tests.
3. How month grid should become rhythm visualization.
4. How recent records should become minimal/collapsed.
5. How completion distribution/year activity should become calmer.
6. How Theme Studio and habit color should drive the page.
7. Which reference images were used.
8. What P7H-2B should be allowed to edit.
9. What tests P7H-2B must run.
10. Screenshot acceptance checklist.

Reject color-only, token-only, giant card-stack, and generic dark dashboard recommendations.
Preserve Theme Studio/custom colors, habit semantics, existing keys, and test behavior.

Task file content:
$taskText
"@
  $allowedOutputs = $allowedAuditFiles
  $statusLabel = "EXECUTE_AUDIT_COMPLETE"
}

Write-Host "Running safe codex exec."
if ($UseImages -and $TaskFile -eq $auditTaskFile -and -not [string]::IsNullOrWhiteSpace($imageValue)) {
  & $codexCommand.Source exec --sandbox workspace-write --image $imageValue $safePrompt
} else {
  if ($UseImages -and $TaskFile -eq $probeTaskFile) {
    Write-Host "Image args requested, but safe probe runs without images."
  }
  & $codexCommand.Source exec --sandbox workspace-write $safePrompt
}
$exitCode = $LASTEXITCODE

Assert-NoForbiddenChanges -Label "AI_IMPLEMENTER_AFTER_DIFF"
$changedFiles = @(git diff --name-only)
Assert-OnlyAllowedChanges -ChangedFiles $changedFiles -AllowedFiles $allowedOutputs

if ($exitCode -ne 0) {
  throw "codex exec failed with exit code $exitCode."
}

$report = @"
# Implementer Report

Status: $statusLabel

Task file: $TaskFile
Allowed output files:
$($allowedOutputs | ForEach-Object { "- $_" } | Out-String)

Tracked diff after implementer:
$($changedFiles | ForEach-Object { "- $_" } | Out-String)

Safety:
- No commit was made.
- Flutter was not run by this script.
- APK build was not run by this script.
"@

Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Host "AI_IMPLEMENTER_EXECUTE_PROBE_OK"
