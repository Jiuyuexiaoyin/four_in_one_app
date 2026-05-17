$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$referenceRoot = Join-Path $repoPath "docs\references"

Set-Location -Path $repoPath

Write-Host "AI_VISUAL_REFS_START"
Write-Host "Reference root: $referenceRoot"

if (-not (Test-Path -Path $referenceRoot)) {
  throw "Reference root not found: $referenceRoot"
}

$imageExtensions = @(".png", ".jpg", ".jpeg", ".webp")
$images = Get-ChildItem -Path $referenceRoot -Recurse -File |
  Where-Object { $imageExtensions -contains $_.Extension.ToLowerInvariant() } |
  Sort-Object FullName

$zips = Get-ChildItem -Path $referenceRoot -Recurse -File -Filter "*.zip" |
  Sort-Object FullName

Write-Host "Image count: $($images.Count)"
foreach ($image in $images) {
  Write-Host $image.FullName
}

Write-Host "Zip count: $($zips.Count)"
foreach ($zip in $zips) {
  Write-Host $zip.FullName
}
