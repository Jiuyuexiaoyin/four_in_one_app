param(
  [Parameter(Mandatory = $true)]
  [string]$TaskFile,
  [switch]$Execute
)

$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$reportsDir = "D:\AI\Projects\four_in_one_app\ai\reports"
$reportPath = Join-Path $reportsDir "final_report.md"

Set-Location -Path $repoPath
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

Write-Host "AI_REPORTER_START"
Write-Host "Mode: $(if ($Execute) { 'EXECUTE_PLACEHOLDER' } else { 'DRY_RUN' })"
Write-Host "Task file: $TaskFile"
Write-Host "Reports directory: $reportsDir"
Write-Host "Final summary path: $reportPath"

$availableReports = Get-ChildItem -Path $reportsDir -Filter "*.md" -File -ErrorAction SilentlyContinue

if ($availableReports.Count -eq 0) {
  Write-Host "No report files found yet."
} else {
  Write-Host "Available reports:"
  foreach ($report in $availableReports) {
    Write-Host "- $($report.FullName)"
  }
}

$summary = @"
# Final Report

Status: DRY_RUN

Task file: $TaskFile

Reporter did not edit app code, commit changes, build APKs, or run Flutter.

Available reports:
$($availableReports | ForEach-Object { "- $($_.Name)" } | Out-String)
"@

Set-Content -Path $reportPath -Value $summary -Encoding UTF8

Write-Host "AI_REPORTER_DRY_RUN_OK"
