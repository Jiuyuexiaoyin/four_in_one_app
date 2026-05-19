$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$referenceRoot = Join-Path $repoPath "docs\references"
$reportsDir = Join-Path $repoPath "ai\reports"
$markdownPath = Join-Path $reportsDir "visual_library_full.md"
$jsonPath = Join-Path $reportsDir "visual_library_full.json"
$imageExtensions = @(".png", ".jpg", ".jpeg", ".webp")

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

if (-not (Test-Path -Path $referenceRoot)) {
  throw "Reference root not found: $referenceRoot"
}

function Convert-ToRelativePath {
  param([string]$FullName)
  return $FullName.Substring($repoPath.Length + 1).Replace("\", "/")
}

function Get-Category {
  param([string]$RelativePath)
  if ($RelativePath -match "current_app_ui") {
    return "current_app_ui"
  }
  if ($RelativePath -match "ui_taste_board" -or $RelativePath -match "selected") {
    return "desired_ui_taste_board"
  }
  if ($RelativePath -match "app_content") {
    return "functional_benchmark_apps"
  }
  return "unclassified_reference"
}

function Get-Purpose {
  param([string]$Category)
  switch ($Category) {
    "current_app_ui" { return "current app problems / before state" }
    "desired_ui_taste_board" { return "desired visual taste direction" }
    "functional_benchmark_apps" { return "functional interaction and content structure reference" }
    "zip_archives" { return "archived screenshots requiring indexing before visual use" }
    default { return "supporting visual reference" }
  }
}

function Get-Source {
  param([string]$RelativePath)
  if ($RelativePath -match "The Outsiders") { return "The Outsiders" }
  if ($RelativePath -match "Equinox") { return "Equinox+" }
  if ($RelativePath -match "HabitDone") { return "HabitDone" }
  if ($RelativePath -match "daymark") { return "daymark" }
  if ($RelativePath -match "OffScreen") { return "OffScreen" }
  if ($RelativePath -match "番茄ToDo") { return "番茄ToDo" }
  return "Unspecified"
}

function Get-Lessons {
  param(
    [string]$Source,
    [string]$Category
  )
  switch ($Source) {
    "The Outsiders" { return "rhythm, data visualization, wave/path/dots, calm premium composition" }
    "Equinox+" { return "full-screen stage, editorial headline, bold but clean composition" }
    "HabitDone" { return "habit execution speed and habit list ergonomics" }
    "daymark" { return "calendar/project rhythm and progression" }
    "OffScreen" { return "focus/usage calm data presentation" }
    "番茄ToDo" { return "focus/timer task execution patterns" }
    default {
      switch ($Category) {
        "current_app_ui" { return "identify weak structure, density, hierarchy, and before-state problems" }
        "desired_ui_taste_board" { return "desired mood, typography, composition, and visual language" }
        "functional_benchmark_apps" { return "interaction structure, information rhythm, and content hierarchy" }
        "zip_archives" { return "archive inventory only until explicitly indexed or unpacked" }
        default { return "general visual reference" }
      }
    }
  }
}

function Get-RecommendedUse {
  param(
    [string]$Category,
    [string]$Source
  )
  if ($Category -eq "current_app_ui") {
    return "Use as before-state comparison and problem diagnosis."
  }
  if ($Category -eq "desired_ui_taste_board") {
    return "Use to define visual taste; do not copy assets blindly."
  }
  if ($Category -eq "functional_benchmark_apps") {
    return "Use for structural inspiration and workflow density; do not clone identity."
  }
  if ($Category -eq "zip_archives") {
    return "List only; unzip or index in a separate approved step before visual use."
  }
  if ($Source -ne "Unspecified") {
    return "Use source-specific lessons for the matching task pack."
  }
  return "Use as supporting context only."
}

function New-ReferenceObject {
  param(
    [System.IO.FileInfo]$File,
    [string]$ForcedCategory
  )

  $relativePath = Convert-ToRelativePath -FullName $File.FullName
  $category = if ($ForcedCategory) { $ForcedCategory } else { Get-Category -RelativePath $relativePath }
  $source = Get-Source -RelativePath $relativePath
  $lessons = Get-Lessons -Source $source -Category $category
  $recommendedUse = Get-RecommendedUse -Category $category -Source $source

  [PSCustomObject]@{
    relativePath = $relativePath
    absolutePath = $File.FullName
    category = $category
    source = $source
    lessons = $lessons
    recommendedUse = $recommendedUse
  }
}

$imageFiles = @(
  Get-ChildItem -Path $referenceRoot -Recurse -File |
    Where-Object { $imageExtensions -contains $_.Extension.ToLowerInvariant() } |
    Sort-Object FullName
)
$zipFiles = @(
  Get-ChildItem -Path $referenceRoot -Recurse -File -Filter "*.zip" |
    Sort-Object FullName
)

$imageRefs = @($imageFiles | ForEach-Object { New-ReferenceObject -File $_ -ForcedCategory $null })
$zipRefs = @($zipFiles | ForEach-Object { New-ReferenceObject -File $_ -ForcedCategory "zip_archives" })
$allRefs = @($imageRefs + $zipRefs)

$categoryCounts = $imageRefs | Group-Object -Property category | Sort-Object Name

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Full Visual Library")
$lines.Add("")
$lines.Add([string]::Concat('Reference root: `', $referenceRoot, '`'))
$lines.Add("")
$lines.Add([string]::Concat([char]45, " Total image count: ", $imageRefs.Count))
$lines.Add([string]::Concat([char]45, " Total zip count: ", $zipRefs.Count))
$lines.Add("")
$lines.Add("## Counts By Category")
$lines.Add("")
$lines.Add("| Category | Count |")
$lines.Add("| --- | ---: |")
foreach ($group in $categoryCounts) {
  $lines.Add("| $($group.Name) | $($group.Count) |")
}

function Add-MarkdownSection {
  param(
    [System.Collections.Generic.List[string]]$Lines,
    [string]$Title,
    [array]$Items
  )

  $Lines.Add("")
  $Lines.Add("## $Title")
  $Lines.Add("")
  $Lines.Add("| Relative path | Absolute path | Category | Source | Lessons | Recommended use |")
  $Lines.Add("| --- | --- | --- | --- | --- | --- |")
  foreach ($item in $Items) {
    $Lines.Add("| `$($item.relativePath)` | `$($item.absolutePath)` | $($item.category) | $($item.source) | $($item.lessons) | $($item.recommendedUse) |")
  }
}

Add-MarkdownSection -Lines $lines -Title "1. Current App UI" -Items @($imageRefs | Where-Object { $_.category -eq "current_app_ui" })
Add-MarkdownSection -Lines $lines -Title "2. Desired UI Taste Board" -Items @($imageRefs | Where-Object { $_.category -eq "desired_ui_taste_board" })
Add-MarkdownSection -Lines $lines -Title "3. Functional Benchmark Apps" -Items @($imageRefs | Where-Object { $_.category -eq "functional_benchmark_apps" })
Add-MarkdownSection -Lines $lines -Title "4. Zip Archives" -Items $zipRefs

Set-Content -Path $markdownPath -Value $lines -Encoding UTF8
$allRefs | ConvertTo-Json -Depth 4 | Set-Content -Path $jsonPath -Encoding UTF8

Write-Host "AI_VISUAL_LIBRARY_BUILT"
Write-Host "Image count: $($imageRefs.Count)"
Write-Host "Zip count: $($zipRefs.Count)"
Write-Host "Markdown: $markdownPath"
Write-Host "JSON: $jsonPath"
