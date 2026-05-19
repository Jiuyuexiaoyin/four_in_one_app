param(
  [ValidateSet("global", "habits", "today", "plan", "focus", "review")]
  [string]$TaskPack = "global",
  [int]$MaxImages = 12
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = Join-Path $repoPath "ai\reports"
$libraryScript = Join-Path $repoPath "ai\scripts\build_visual_library.ps1"
$libraryJsonPath = Join-Path $reportsDir "visual_library_full.json"
$libraryMarkdownPath = Join-Path $reportsDir "visual_library_full.md"
$argsPath = Join-Path $reportsDir "codex_image_args.txt"
$manifestPath = Join-Path $reportsDir "codex_image_manifest.md"
$imageExtensions = @(".png", ".jpg", ".jpeg", ".webp")

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

if (-not (Test-Path -Path $libraryJsonPath)) {
  & $libraryScript
}

function Get-VisualLibraryItems {
  param([string]$Path)

  if (-not (Test-Path -Path $Path)) {
    return @()
  }

  $rawJson = Get-Content -Path $Path -Raw
  if ([string]::IsNullOrWhiteSpace($rawJson)) {
    return @()
  }

  $parsed = $rawJson | ConvertFrom-Json
  $items = [System.Collections.Generic.List[object]]::new()

  function Add-ItemOrChildren {
    param(
      [object]$Value,
      [System.Collections.Generic.List[object]]$Target
    )

    if ($null -eq $Value) {
      return
    }

    $propertyNames = @($Value.PSObject.Properties.Name)
    if ($propertyNames -contains "absolutePath") {
      $Target.Add($Value)
      return
    }

    foreach ($propertyName in @("images", "imageRefs", "items", "references")) {
      if ($propertyNames -contains $propertyName) {
        foreach ($child in @($Value.$propertyName)) {
          Add-ItemOrChildren -Value $child -Target $Target
        }
        return
      }
    }

    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
      foreach ($child in $Value) {
        Add-ItemOrChildren -Value $child -Target $Target
      }
    }
  }

  Add-ItemOrChildren -Value $parsed -Target $items
  return @($items)
}

$library = @(Get-VisualLibraryItems -Path $libraryJsonPath)
if ($library.Count -eq 0) {
  & $libraryScript
  $library = @(Get-VisualLibraryItems -Path $libraryJsonPath)
}

$imageLibrary = @(
  $library | Where-Object {
    $absolutePath = [string]$_.absolutePath
    if ([string]::IsNullOrWhiteSpace($absolutePath)) {
      return $false
    }
    $extension = [System.IO.Path]::GetExtension($absolutePath).ToLowerInvariant()
    return ($imageExtensions -contains $extension) -and (Test-Path -Path $absolutePath)
  }
)

if ($imageLibrary.Count -eq 0) {
  Write-Host "VISUAL_LIBRARY_EMPTY"
  throw "Visual library has no usable image references."
}

function Select-ByPredicate {
  param(
    [array]$Items,
    [scriptblock]$Predicate,
    [string]$Reason
  )

  foreach ($item in @($Items | Where-Object $Predicate)) {
    [PSCustomObject]@{
      item = $item
      reason = $Reason
    }
  }
}

function Add-UniqueSelection {
  param(
    [System.Collections.Generic.List[object]]$Selection,
    [array]$Candidates,
    [int]$Limit
  )

  foreach ($candidate in $Candidates) {
    if ($Selection.Count -ge $Limit) {
      return
    }
    $exists = $false
    foreach ($selected in $Selection) {
      if ($selected.item.absolutePath -eq $candidate.item.absolutePath) {
        $exists = $true
        break
      }
    }
    if (-not $exists) {
      $Selection.Add($candidate)
    }
  }
}

$selected = [System.Collections.Generic.List[object]]::new()

switch ($TaskPack) {
  "global" {
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Current app first-screen before-state example." -Predicate { $_.category -eq "current_app_ui" -and $_.relativePath -match "01|today|今天" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "The Outsiders rhythm/data visual language." -Predicate { $_.source -eq "The Outsiders" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Equinox+ full-screen stage/editorial composition." -Predicate { $_.source -eq "Equinox+" })
  }
  "habits" {
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Current app before-state for habits and shell." -Predicate { $_.category -eq "current_app_ui" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "The Outsiders rhythm examples for habit cadence." -Predicate { $_.source -eq "The Outsiders" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "HabitDone habit execution and list ergonomics." -Predicate { $_.source -eq "HabitDone" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "daymark progression and rhythm reference." -Predicate { $_.source -eq "daymark" })
  }
  "today" {
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Current Today before-state screenshot." -Predicate { $_.category -eq "current_app_ui" -and $_.relativePath -match "01|today|今天" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "The Outsiders rhythm/stage visual object." -Predicate { $_.source -eq "The Outsiders" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Equinox+ editorial headline and stage." -Predicate { $_.source -eq "Equinox+" })
  }
  "plan" {
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Current Plan before-state screenshot." -Predicate { $_.category -eq "current_app_ui" -and $_.relativePath -match "02|plan|计划" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "daymark project/calendar rhythm." -Predicate { $_.source -eq "daymark" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Equinox+ premium editorial composition." -Predicate { $_.source -eq "Equinox+" })
  }
  "focus" {
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Current Focus before-state screenshot." -Predicate { $_.category -eq "current_app_ui" -and $_.relativePath -match "03|focus|专注" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "OffScreen calm usage/focus data presentation." -Predicate { $_.source -eq "OffScreen" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "番茄ToDo focus/timer task execution patterns." -Predicate { $_.source -eq "番茄ToDo" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "The Outsiders rhythm and pulse inspiration." -Predicate { $_.source -eq "The Outsiders" })
  }
  "review" {
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Current Review before-state screenshot." -Predicate { $_.category -eq "current_app_ui" -and $_.relativePath -match "04|review|复盘" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "The Outsiders data visual rhythm." -Predicate { $_.source -eq "The Outsiders" })
    Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "OffScreen calm data panels and usage trends." -Predicate { $_.source -eq "OffScreen" })
  }
}

if ($selected.Count -lt $MaxImages) {
  Add-UniqueSelection -Selection $selected -Limit $MaxImages -Candidates (Select-ByPredicate -Items $imageLibrary -Reason "Fallback from desired taste-board or indexed library." -Predicate { $_.category -eq "desired_ui_taste_board" -or $_.category -eq "current_app_ui" })
}

if ($selected.Count -eq 0) {
  Write-Host "VISUAL_LIBRARY_EMPTY"
  throw "No images selected for task pack: $TaskPack"
}

$imageArgValue = ($selected | ForEach-Object { $_.item.absolutePath }) -join ","
if ([string]::IsNullOrWhiteSpace($imageArgValue)) {
  Write-Host "VISUAL_LIBRARY_EMPTY"
  throw "Selected image argument is empty."
}

Set-Content -Path $argsPath -Value ('--image "{0}"' -f $imageArgValue) -Encoding UTF8

$manifest = [System.Collections.Generic.List[string]]::new()
$manifest.Add("# Codex Image Manifest")
$manifest.Add("")
$manifest.Add(("- Task pack: {0}" -f $TaskPack))
$manifest.Add(("- Selected image count: {0}" -f $selected.Count))
$manifest.Add(("- Full library count: {0}" -f $imageLibrary.Count))
$manifest.Add([string]::Concat('- Full visual library: `', 'ai/reports/visual_library_full.md', '`'))
$manifest.Add("")
$manifest.Add("## Selected Images")
$manifest.Add("")
$manifest.Add("| Relative path | Absolute path | Source | Category | Why selected |")
$manifest.Add("| --- | --- | --- | --- | --- |")
foreach ($entry in $selected) {
  $manifest.Add(('| `{0}` | `{1}` | {2} | {3} | {4} |' -f $entry.item.relativePath, $entry.item.absolutePath, $entry.item.source, $entry.item.category, $entry.reason))
}
$manifest.Add("")
$manifest.Add([string]::Concat('Note: full visual library exists at `', 'ai/reports/visual_library_full.md', '`.'))

Set-Content -Path $manifestPath -Value $manifest -Encoding UTF8

Write-Host "AI_CODEX_IMAGE_ARGS_BUILT"
Write-Host "Task pack: $TaskPack"
Write-Host "Selected image count: $($selected.Count)"
Write-Host "Full library count: $($imageLibrary.Count)"
Write-Host "Args: $argsPath"
Write-Host "Manifest: $manifestPath"
