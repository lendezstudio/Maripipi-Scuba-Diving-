# Generates optimized site images from /source-assets.
# Run from the project root:  powershell -ExecutionPolicy Bypass -File tools\build-images.ps1
# Source files are never modified.

Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$src  = Join-Path $root 'source-assets'
$img  = Join-Path $root 'assets\img'
$ico  = Join-Path $root 'assets\icons'
New-Item -ItemType Directory -Force $img, $ico | Out-Null

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }

function Save-Jpeg($bmp, $path, $quality = 78) {
  $p = New-Object System.Drawing.Imaging.EncoderParameters 1
  $p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]$quality)
  $bmp.Save($path, $jpegCodec, $p)
}

function New-Canvas($w, $h) {
  $b = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($b)
  $g.InterpolationMode = 'HighQualityBicubic'
  $g.SmoothingMode = 'HighQuality'
  $g.PixelOffsetMode = 'HighQuality'
  $g.CompositingQuality = 'HighQuality'
  return @($b, $g)
}

# Crop a source rectangle and write it at each requested output width.
function Export-Crop($file, $x, $y, $w, $h, $widths, $name, $quality = 78) {
  $i = [System.Drawing.Image]::FromFile((Join-Path $src $file))
  foreach ($ow in $widths) {
    $oh = [int][Math]::Round($h * $ow / $w)
    $b, $g = New-Canvas $ow $oh
    $g.DrawImage($i, (New-Object System.Drawing.Rectangle 0, 0, $ow, $oh), (New-Object System.Drawing.Rectangle $x, $y, $w, $h), 'Pixel')
    Save-Jpeg $b (Join-Path $img "$name-$ow.jpg") $quality
    "{0}-{1}.jpg  {2}x{3}" -f $name, $ow, $ow, $oh
    $g.Dispose(); $b.Dispose()
  }
  $i.Dispose()
}

# --- Photography ------------------------------------------------------------
# Hero (illustrative, Pexels / pspov): landscape crop centred on the descending diver and light shaft.
Export-Crop 'pexels-pspov-3113226.jpg' 0 640 3662 2290 @(2400, 1600, 1000) 'hero-diver-wide' 74
# Hero portrait crop for small screens.
Export-Crop 'pexels-pspov-3113226.jpg' 0 300 3662 4880 @(1000, 700) 'hero-diver-tall' 74
# Divers above a reef wall (illustrative, Pexels / Graham Henderson). Crop excludes the sea snake.
Export-Crop 'pexels-graham-henderson-37078134-7169290.jpg' 900 0 1800 1005 @(1600, 1000) 'divers-reef-wall' 78
# Supplied Maripipi destination photographs (owner-supplied; licensing to be confirmed).
Export-Crop 'photo0jpg.jpg' 0 0 1200 1200 @(1200, 800) 'island-ridge-peak' 80
Export-Crop 'images (1).jpg' 0 0 452 678 @(452) 'island-ridge-cottages' 84
Export-Crop 'download.jpg' 0 0 289 312 @(289) 'island-headland' 86
# Illustrative above-water photos (Pexels). No names or registration marks visible.
Export-Crop 'pexels-thephotokai-38354745.jpg' 0 0 6548 4365 @(1400, 900) 'outrigger-dusk' 78
Export-Crop 'pexels-cliffordpatricio-16311569.jpg' 700 0 4877 3902 @(1000, 700) 'outrigger-golden' 78

# --- Logo -------------------------------------------------------------------
# Dive-mask logo (transparent PNG). Trim rectangle = visible artwork plus a few px.
$logoSrc = [System.Drawing.Image]::FromFile((Join-Path $src 'Logo.png'))
$trim = New-Object System.Drawing.Rectangle 40, 42, 1582, 866
function Export-Logo($width, $path) {
  $h = [int][Math]::Round($width * $trim.Height / $trim.Width)
  $b, $g = New-Canvas $width $h
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.DrawImage($logoSrc, (New-Object System.Drawing.Rectangle 0, 0, $width, $h), $trim, 'Pixel')
  $b.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  "{0}  {1}x{2}" -f (Split-Path $path -Leaf), $width, $h
  $g.Dispose(); $b.Dispose()
}
Export-Logo 1200 (Join-Path $img 'logo-mask-1200.png')
Export-Logo 640 (Join-Path $img 'logo-mask-640.png')
Export-Logo 200 (Join-Path $img 'logo-mask-200.png')

# Square icons: mask centred on a transparent (or navy, for iOS) square.
function Export-Icon($size, $path, $bg, $fill) {
  $b, $g = New-Canvas $size $size
  $g.Clear($bg)
  $w = [int][Math]::Round($size * $fill)
  $h = [int][Math]::Round($w * $trim.Height / $trim.Width)
  $g.DrawImage($logoSrc, (New-Object System.Drawing.Rectangle ([int](($size - $w) / 2)), ([int](($size - $h) / 2)), $w, $h), $trim, 'Pixel')
  $b.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $b.Dispose()
}
$clear = [System.Drawing.Color]::Transparent
$navy = [System.Drawing.Color]::FromArgb(255, 5, 9, 15)
Export-Icon 192 (Join-Path $ico 'icon-192.png') $clear 1.0
Export-Icon 180 (Join-Path $ico 'apple-touch-icon.png') $navy 0.86
$smallPngs = @{}
foreach ($s in 16, 32, 48) {
  $p = Join-Path $ico "favicon-$s.png"
  Export-Icon $s $p $clear 1.0
  $smallPngs[$s] = [System.IO.File]::ReadAllBytes($p)
}
$logoSrc.Dispose()

# favicon.ico containing PNG-encoded 16, 32 and 48px images.
$sizes = 16, 32, 48
$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ms
$bw.Write([UInt16]0); $bw.Write([UInt16]1); $bw.Write([UInt16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
foreach ($s in $sizes) {
  $bw.Write([byte]$s); $bw.Write([byte]$s); $bw.Write([byte]0); $bw.Write([byte]0)
  $bw.Write([UInt16]1); $bw.Write([UInt16]32)
  $bw.Write([UInt32]$smallPngs[$s].Length); $bw.Write([UInt32]$offset)
  $offset += $smallPngs[$s].Length
}
foreach ($s in $sizes) { $bw.Write($smallPngs[$s]) }
[System.IO.File]::WriteAllBytes((Join-Path $root 'favicon.ico'), $ms.ToArray())
Remove-Item (Join-Path $ico 'favicon-48.png'), (Join-Path $ico 'favicon-16.png')
'favicon.ico + icons written'
