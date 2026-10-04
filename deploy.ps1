# Copia el mod a la carpeta de mods del juego para probarlo en local.
# Uso: .\deploy.ps1   (desde D:\Kevin\Downloads\PZ-Economia)
$src = Join-Path $PSScriptRoot "mod\EcoPesos"
$dst = Join-Path $env:USERPROFILE "Zomboid\mods\EcoPesos"

if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
Copy-Item -Recurse -Force $src $dst
Write-Host "EcoPesos copiado a $dst"
