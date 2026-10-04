# Convierte la imagen del billete (fondo magenta) en el icono del juego.
# Uso: powershell -ExecutionPolicy Bypass -File arte\hacer_icono.ps1 <imagen>
# Genera:
#   mod\EconomiaArgenta\common\media\textures\Item_Money.png  (32x32, el que usa el juego)
#   arte\Item_Money_preview.png                               (ampliado x8 para mirarlo)
param([Parameter(Mandatory = $true)][string]$Origen)
Add-Type -AssemblyName System.Drawing

$raiz = Split-Path $PSScriptRoot -Parent
$salida = Join-Path $raiz "mod\EconomiaArgenta\common\media\textures\Item_Money.png"
$preview = Join-Path $PSScriptRoot "Item_Money_preview.png"
$TAM = 32

$src = [System.Drawing.Bitmap]::FromFile((Resolve-Path $Origen).Path)

# 1. Quitar el fondo magenta (con tolerancia: la imagen es JPG).
function EsFondo($c) { return ($c.R -gt 180 -and $c.B -gt 180 -and $c.G -lt 110) }
$w = $src.Width; $h = $src.Height
$limpia = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$minX = $w; $minY = $h; $maxX = 0; $maxY = 0
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $src.GetPixel($x, $y)
        if (EsFondo $c) { $limpia.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0)) }
        else {
            $limpia.SetPixel($x, $y, $c)
            if ($x -lt $minX) { $minX = $x }; if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }; if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

# 2. Recortar al billete y achicar a 32x32 manteniendo la proporcion.
$bw = $maxX - $minX + 1; $bh = $maxY - $minY + 1
$escala = [Math]::Min(($TAM - 2) / $bw, ($TAM - 2) / $bh)
$dw = [int][Math]::Round($bw * $escala); $dh = [int][Math]::Round($bh * $escala)
$icono = New-Object System.Drawing.Bitmap $TAM, $TAM, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($icono)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$destino = New-Object System.Drawing.Rectangle ([int](($TAM - $dw) / 2)), ([int](($TAM - $dh) / 2)), $dw, $dh
$g.DrawImage($limpia, $destino, $minX, $minY, $bw, $bh, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

# 3. Bordes nitidos: cada pixel es opaco o transparente (estilo pixel art).
for ($y = 0; $y -lt $TAM; $y++) {
    for ($x = 0; $x -lt $TAM; $x++) {
        $c = $icono.GetPixel($x, $y)
        if ($c.A -lt 110) { $icono.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0)) }
        else { $icono.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $c.R, $c.G, $c.B)) }
    }
}
$icono.Save($salida, [System.Drawing.Imaging.ImageFormat]::Png)

# 4. Vista ampliada para revisarlo.
$grande = New-Object System.Drawing.Bitmap ($TAM * 8), ($TAM * 8)
$g = [System.Drawing.Graphics]::FromImage($grande)
$g.Clear([System.Drawing.Color]::FromArgb(255, 60, 60, 60))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($icono, 0, 0, $TAM * 8, $TAM * 8)
$g.Dispose()
$grande.Save($preview, [System.Drawing.Imaging.ImageFormat]::Png)

$src.Dispose(); $limpia.Dispose(); $icono.Dispose(); $grande.Dispose()
Write-Host "Icono: $salida"
Write-Host "Vista previa: $preview"
