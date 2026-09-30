# Sube los cambios de MANUAL IA a GitHub.
# Uso:  .\actualizar_github.ps1 "Mensaje del cambio"
param([string]$mensaje = "Actualización de MANUAL IA")
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path ".git")) {
    Write-Host "Esta carpeta aún no es un repositorio. Primera vez:" -ForegroundColor Yellow
    Write-Host "  git init"
    Write-Host "  git branch -M main"
    Write-Host "  git remote add origin https://github.com/TU-USUARIO/manual_ia_pro.git"
    Write-Host "Luego ejecuta de nuevo este script."
    exit 1
}

git add -A
$cambios = git status --porcelain
if (-not $cambios) {
    Write-Host "No hay cambios para subir." -ForegroundColor Green
    exit 0
}
git commit -m $mensaje
git push -u origin main
Write-Host "Listo: cambios subidos a GitHub." -ForegroundColor Green
