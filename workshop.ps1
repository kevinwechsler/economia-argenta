# Arma la carpeta para subir el mod al Steam Workshop.
# Uso: powershell -ExecutionPolicy Bypass -File workshop.ps1   (desde D:\Kevin\Downloads\PZ-Economia)
#
# Crea / actualiza:
#   %USERPROFILE%\Zomboid\Workshop\EconomiaArgenta\
#       preview.png                       (de arte\preview.png, 256x256)
#       workshop.txt                      (lo crea el juego al subir; se conserva)
#       Contents\mods\EconomiaArgenta\... (el mod)
# Despues: juego > Workshop > Crear y actualizar elementos > EconomiaArgenta.
$ErrorActionPreference = "Stop"
$src = Join-Path $PSScriptRoot "mod\EconomiaArgenta"
$preview = Join-Path $PSScriptRoot "arte\preview.png"
$ws = Join-Path $env:USERPROFILE "Zomboid\Workshop\EconomiaArgenta"
$dstMod = Join-Path $ws "Contents\mods\EconomiaArgenta"

# Mismos controles que deploy.ps1: sin BOM.
$conBom = Get-ChildItem $src -Recurse -File -Include *.json, *.lua, *.txt, *.info | Where-Object {
    $b = [IO.File]::ReadAllBytes($_.FullName)
    $b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF
}
if ($conBom) {
    Write-Host "ERROR: estos archivos tienen BOM y el juego no los va a leer:" -ForegroundColor Red
    $conBom | ForEach-Object { Write-Host "  $($_.FullName)" }
    exit 1
}

if (-not (Test-Path $preview)) {
    Write-Host "ERROR: falta arte\preview.png (256x256). Generala antes de subir." -ForegroundColor Red
    exit 1
}
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($preview)
$ok = ($img.Width -eq 256 -and $img.Height -eq 256)
$img.Dispose()
if (-not $ok) {
    Write-Host "ERROR: arte\preview.png tiene que ser de 256x256." -ForegroundColor Red
    exit 1
}
if ((Get-Item $preview).Length -gt 1MB) {
    Write-Host "ERROR: arte\preview.png pesa mas de 1 MB." -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force $ws | Out-Null
if (Test-Path $dstMod) { Remove-Item -Recurse -Force $dstMod }
New-Item -ItemType Directory -Force (Split-Path $dstMod) | Out-Null
Copy-Item -Recurse -Force $src $dstMod
Copy-Item -Force $preview (Join-Path $ws "preview.png")

$wt = Join-Path $ws "workshop.txt"
if (Test-Path $wt) {
    $id = (Select-String -Path $wt -Pattern '^id=(\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ""
    Write-Host "Carpeta lista para ACTUALIZAR el mod del Workshop (id $id)." -ForegroundColor Green
} else {
    Write-Host "Carpeta lista para la PRIMERA subida." -ForegroundColor Green
}
Write-Host "  $ws"
Write-Host "Ahora: juego > Workshop > Crear y actualizar elementos > EconomiaArgenta."
Write-Host "Descripcion para pegar en Steam: workshop_descripcion.txt"
