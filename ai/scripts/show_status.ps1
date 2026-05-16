$ErrorActionPreference = "Stop"

$repoPath = "D:\AI\Projects\four_in_one_app"

Set-Location -Path $repoPath

git branch --show-current
git status --short
git diff --name-only
git log -1 --oneline
