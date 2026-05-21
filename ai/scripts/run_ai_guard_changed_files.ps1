param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [ValidateSet("probe", "audit", "workflow", "docs", "code_implementation", "ui_implementation", "release")]
  [string]$TaskType = "audit",
  [string]$AllowedFileListPath = "",
  [string]$Mode = "strict"
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"

Set-Location -Path $repoPath

function Normalize-GitPath {
  param([string]$Path)
  return $Path.Replace("\", "/")
}

function Get-ChangedFilesIncludingUntracked {
  $tracked = @(git diff --name-only | ForEach-Object { Normalize-GitPath -Path $_ })
  $untracked = @(git ls-files --others --exclude-standard | ForEach-Object { Normalize-GitPath -Path $_ })
  return @($tracked + $untracked | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
}

function Test-DefaultForbidden {
  param(
    [string]$Path,
    [bool]$ReleaseMode
  )

  if ($Path -eq "pubspec.yaml" -and -not $ReleaseMode) { return $true }
  if ($Path.StartsWith("android/") -and -not $ReleaseMode) { return $true }
  if ($Path.StartsWith("ios/") -and -not $ReleaseMode) { return $true }
  if ($Path.StartsWith("build/") -and -not $ReleaseMode) { return $true }
  if ($Path -like "*.apk" -and -not $ReleaseMode) { return $true }
  if ($Path.StartsWith("docs/references/")) { return $true }
  return $false
}

function Test-AllowedFileListEntry {
  param([string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
  if ($Path -match "\\") { return $false }
  if ($Path -match "^[A-Za-z]:") { return $false }
  if ($Path.StartsWith("/")) { return $false }
  if ($Path.Contains("../")) { return $false }
  if ($Path.StartsWith("..")) { return $false }
  if ($Path.EndsWith("/")) { return $false }
  if ($Path -match "[\*\?\[\]\{\}]") { return $false }
  return $true
}

function Read-AllowedFileList {
  param([string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path)) {
    throw "AllowedFileListPath is required for TaskType $TaskType."
  }

  $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) {
    $Path
  } else {
    Join-Path $repoPath $Path
  }

  if (-not (Test-Path -Path $resolvedPath)) {
    throw "AllowedFileListPath not found: $resolvedPath"
  }

  $entries = @()
  foreach ($line in Get-Content -Path $resolvedPath) {
    $trimmed = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
    if ($trimmed.StartsWith("#")) { continue }
    $normalized = Normalize-GitPath -Path $trimmed
    if (-not (Test-AllowedFileListEntry -Path $normalized)) {
      throw "Invalid allowed file list entry: $trimmed"
    }
    $entries += $normalized
  }

  if ($entries.Count -eq 0) {
    throw "AllowedFileListPath contains no allowed files: $resolvedPath"
  }

  return @($entries | Sort-Object -Unique)
}

function Test-AllowedByTaskType {
  param(
    [string]$Path,
    [string]$CurrentTaskType,
    [string[]]$AllowedFiles
  )

  switch ($CurrentTaskType) {
    "probe" {
      return $Path -match "^ai/reports/[^/]+\.md$"
    }
    "audit" {
      return ($Path -match "^docs/ui_redesign/[^/]+\.md$") -or ($Path -match "^ai/reports/[^/]+\.md$")
    }
    "workflow" {
      return $Path.StartsWith("ai/scripts/") -or
        $Path.StartsWith("ai/prompts/") -or
        $Path.StartsWith(".github/workflows/") -or
        $Path.StartsWith("docs/agent_workflows/") -or
        $Path.StartsWith("ai/tasks/")
    }
    "docs" {
      return $Path.StartsWith("docs/") -and -not $Path.StartsWith("docs/references/")
    }
    "code_implementation" {
      return $AllowedFiles -contains $Path
    }
    "ui_implementation" {
      return $AllowedFiles -contains $Path
    }
    "release" {
      return $AllowedFiles -contains $Path
    }
    default {
      return $false
    }
  }
}

$changedFiles = @(Get-ChangedFilesIncludingUntracked)
$allowedFiles = @()

if ($TaskType -in @("code_implementation", "ui_implementation", "release")) {
  $allowedFiles = @(Read-AllowedFileList -Path $AllowedFileListPath)
}

$forbiddenFiles = @()
foreach ($file in $changedFiles) {
  $releaseMode = $TaskType -eq "release"
  if (Test-DefaultForbidden -Path $file -ReleaseMode $releaseMode) {
    $forbiddenFiles += $file
    continue
  }

  if (-not (Test-AllowedByTaskType -Path $file -CurrentTaskType $TaskType -AllowedFiles $allowedFiles)) {
    $forbiddenFiles += $file
  }
}

Write-Host "AI_GUARD_CHANGED_FILES_START"
Write-Host "TaskFile: $TaskFile"
Write-Host "TaskType: $TaskType"
Write-Host "Mode: $Mode"
Write-Host "AllowedFileListPath: $AllowedFileListPath"
Write-Host "Changed files:"
if ($changedFiles.Count -eq 0) {
  Write-Host "(none)"
} else {
  $changedFiles | ForEach-Object { Write-Host $_ }
}
Write-Host "Allowed files:"
if ($allowedFiles.Count -eq 0) {
  Write-Host "(task-type rules only)"
} else {
  $allowedFiles | ForEach-Object { Write-Host $_ }
}
Write-Host "Forbidden files if any:"
if ($forbiddenFiles.Count -eq 0) {
  Write-Host "(none)"
} else {
  $forbiddenFiles | ForEach-Object { Write-Host $_ }
}

if ($forbiddenFiles.Count -gt 0) {
  Write-Host "FORBIDDEN_CHANGE_DETECTED"
  throw "Changed files are outside the allowed scope for TaskType $TaskType."
}

Write-Host "AI_GUARD_CHANGED_FILES_OK"
