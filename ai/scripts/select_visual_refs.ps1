$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$referenceRoot = Join-Path $repoPath "docs\references"
$reportsDir = Join-Path $repoPath "ai\reports"
$outputPath = Join-Path $reportsDir "visual_refs_selected.txt"
$imageExtensions = @(".png", ".jpg", ".jpeg", ".webp")

Set-Location -Path $repoPath

Write-Host "AI_VISUAL_REF_SELECTION_START"
Write-Host "Reference root: $referenceRoot"

if (-not (Test-Path -Path $referenceRoot)) {
  throw "Reference root not found: $referenceRoot"
}

New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

function Get-ImageRefs {
  param([string]$Path)

  if (-not (Test-Path -Path $Path)) {
    return @()
  }

  return @(
    Get-ChildItem -Path $Path -Recurse -File |
      Where-Object { $imageExtensions -contains $_.Extension.ToLowerInvariant() } |
      Sort-Object FullName
  )
}

function Get-ZipRefs {
  param([string]$Path)

  if (-not (Test-Path -Path $Path)) {
    return @()
  }

  return @(
    Get-ChildItem -Path $Path -Recurse -File -Filter "*.zip" |
      Sort-Object FullName
  )
}

function Convert-ToRelativePath {
  param([string]$FullName)

  return $FullName.Substring($repoPath.Length + 1)
}

function Add-Section {
  param(
    [System.Collections.Generic.List[string]]$Lines,
    [string]$Title,
    [array]$Files
  )

  $Lines.Add("")
  $Lines.Add("## $Title")
  $Lines.Add("Count: $($Files.Count)")
  foreach ($file in $Files) {
    $Lines.Add("- Absolute: $($file.FullName)")
    $Lines.Add("  Relative: $(Convert-ToRelativePath -FullName $file.FullName)")
  }
}

$currentAppRefs = Get-ImageRefs -Path (Join-Path $referenceRoot "current_app_ui")
$tasteBoardRefs = Get-ImageRefs -Path (Join-Path $referenceRoot "ui_taste_board\selected")
$benchmarkRefs = Get-ImageRefs -Path (Join-Path $referenceRoot "app_content")
$zipRefs = Get-ZipRefs -Path $referenceRoot

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("AI_VISUAL_REF_SELECTION")
$lines.Add("Reference root: $referenceRoot")
$lines.Add("Generated at: $(Get-Date -Format o)")

Add-Section -Lines $lines -Title "1. Current App UI" -Files $currentAppRefs
Add-Section -Lines $lines -Title "2. Desired UI Taste Board" -Files $tasteBoardRefs
Add-Section -Lines $lines -Title "3. Functional Benchmark Apps" -Files $benchmarkRefs
Add-Section -Lines $lines -Title "4. Zip Archives Found" -Files $zipRefs

Set-Content -Path $outputPath -Value $lines -Encoding UTF8

Write-Host "Current App UI count: $($currentAppRefs.Count)"
Write-Host "Desired UI Taste Board count: $($tasteBoardRefs.Count)"
Write-Host "Functional Benchmark Apps count: $($benchmarkRefs.Count)"
Write-Host "Zip Archives Found count: $($zipRefs.Count)"
Write-Host "Visual reference selection written: $outputPath"
