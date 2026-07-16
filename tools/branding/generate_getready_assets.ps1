[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$javaCommand = Get-Command 'java' -ErrorAction Stop | Select-Object -First 1
$javaPath = $javaCommand.Path

$versionOutput = (& $javaPath '-version' 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) {
  throw "Unable to query Java runtime: $versionOutput"
}

$majorMatch = [regex]::Match($versionOutput, 'version "(?<major>\d+)')
if (-not $majorMatch.Success -or [int]$majorMatch.Groups['major'].Value -lt 21) {
  throw "OpenJDK 21 or newer is required. Found: $versionOutput"
}

Write-Host "Using $javaPath"
Write-Host 'Generating Get Ready brand assets from controlled SVG masters...'

& $javaPath '-Djava.awt.headless=true' (Join-Path $PSScriptRoot 'GenerateGetreadyAssets.java') "--repo-root=$repoRoot"
if ($LASTEXITCODE -ne 0) {
  throw "Get Ready asset generation failed with exit code $LASTEXITCODE"
}
