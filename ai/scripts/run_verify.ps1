$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"
$verifyCommand = "D:\AI\Tools\Codex\four_in_one_v6b_verify.cmd"

Set-Location -Path $repoPath

Write-Host "AI_VERIFY_START"
git branch --show-current
git status --short
git diff --name-only

& $verifyCommand
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
  throw "Verification failed with exit code $exitCode."
}

Write-Host "AI_VERIFY_OK"
