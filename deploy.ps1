# Copia el mod a la carpeta de mods del juego para probarlo en local.
# Uso: .\deploy.ps1   (desde D:\Kevin\Downloads\PZ-Economia)
$src = Join-Path $PSScriptRoot "mod\EcoPesos"
$dst = Join-Path $env:USERPROFILE "Zomboid\mods\EcoPesos"

# El juego no lee archivos UTF-8 con BOM (ese caracter invisible al inicio
# rompe la carga de traducciones y deja la partida colgada en "Error 1").
$conBom = Get-ChildItem $src -Recurse -File -Include *.json, *.lua, *.txt, *.info | Where-Object {
    $b = [IO.File]::ReadAllBytes($_.FullName)
    $b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF
}
if ($conBom) {
    Write-Host "ERROR: estos archivos tienen BOM y el juego no los va a leer:" -ForegroundColor Red
    $conBom | ForEach-Object { Write-Host "  $($_.FullName)" }
    exit 1
}

if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
Copy-Item -Recurse -Force $src $dst
Write-Host "EcoPesos copiado a $dst"
