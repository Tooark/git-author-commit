# Instala o arkgit no PATH do usuário (Windows)
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path $env:LOCALAPPDATA "arkgit"

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Copy-Item (Join-Path $ScriptDir "bin\arkgit.ps1") (Join-Path $TargetDir "arkgit.ps1") -Force

# Cria um wrapper .cmd para o comando funcionar em qualquer terminal
$cmdWrapper = "@echo off`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%LOCALAPPDATA%\arkgit\arkgit.ps1`" %*"
Set-Content -Path (Join-Path $TargetDir "arkgit.cmd") -Value $cmdWrapper -Encoding ASCII

# Adiciona ao PATH do usuário, se necessário
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$TargetDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$TargetDir", "User")
    Write-Host "Pasta adicionada ao PATH do usuário. Abra um novo terminal para usar."
}

Write-Host "arkgit instalado em $TargetDir" -ForegroundColor Green
Write-Host "Teste com: arkgit help"
