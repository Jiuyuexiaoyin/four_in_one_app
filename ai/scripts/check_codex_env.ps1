$ErrorActionPreference = "Continue"

Write-Host "AI_CODEX_ENV_PROBE_START"
whoami
Write-Host "CODEX_HOME=$env:CODEX_HOME"
Write-Host "PATH=$env:PATH"

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue

if ($null -ne $codexCommand) {
  Write-Host "CODEX_SOURCE=$($codexCommand.Source)"
  codex --version
  codex login status
} else {
  Write-Host "CODEX_NOT_FOUND"
  Write-Host "Add Codex CLI to Machine PATH or run the runner service as the JT user."
}

exit 0
