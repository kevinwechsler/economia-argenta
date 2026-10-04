# Genera las imagenes del mod y del Workshop a partir de los originales.
# Uso: powershell -ExecutionPolicy Bypass -File arte\hacer_imagenes.ps1
#
#   arte\poster_original.jpg  -> mod\...\common\poster.png  (512x512, lista de mods del juego)
#                             -> arte\preview.png           (256x256, Steam Workshop, < 1 MB)
#   arte\icono_original.jpg   -> mod\...\common\icon.png    (64x64, fondo magenta -> transparente)
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = "Stop"

$arte = $PSScriptRoot
$common = Join-Path (Split-Path $arte -Parent) "mod\EconomiaArgenta\common"

function Redimensionar($bmp, $w, $h) {
    $out = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($out)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $g.DrawImage($bmp, 0, 0, $w, $h)
    $g.Dispose()
    return $out
}

# --- Poster y preview ---------------------------------------------------
$poster = [System.Drawing.Bitmap]::FromFile((Join-Path $arte "poster_original.jpg"))
$p512 = Redimensionar $poster 512 512
$p512.Save((Join-Path $common "poster.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$p256 = Redimensionar $poster 256 256
$p256.Save((Join-Path $arte "preview.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$poster.Dispose(); $p512.Dispose(); $p256.Dispose()

# --- Icono: quitar el magenta con borde suave ---------------------------
$icono = [System.Drawing.Bitmap]::FromFile((Join-Path $arte "icono_original.jpg"))
$w = $icono.Width; $h = $icono.Height
$limpio = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $icono.GetPixel($x, $y)
        # Que tan "magenta" es el pixel: rojo y azul altos, verde bajo.
        $mag = [Math]::Min($c.R, $c.B) - $c.G
        if ($mag -gt 150) {
            $limpio.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        } elseif ($mag -gt 60) {
            # Borde: semitransparente y sin el tinte rosado.
            $a = [int](255 * (150 - $mag) / 90)
            $limpio.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, [Math]::Min(255, $c.R), $c.G, [Math]::Min($c.G + 40, $c.B)))
        } else {
            $limpio.SetPixel($x, $y, $c)
        }
    }
}
$i64 = Redimensionar $limpio 64 64
$i64.Save((Join-Path $common "icon.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$icono.Dispose(); $limpio.Dispose(); $i64.Dispose()

Get-Item (Join-Path $common "poster.png"), (Join-Path $common "icon.png"), (Join-Path $arte "preview.png") |
    ForEach-Object { "{0}  {1:N0} KB" -f $_.FullName, ($_.Length / 1KB) }
