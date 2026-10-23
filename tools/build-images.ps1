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

# --- Logo -------------------------------------------------------------------
# Circular badge from the owner's logo, with the black corners made transparent.
$badgeSrc = [System.Drawing.Image]::FromFile((Join-Path $src 'WhatsApp Image 2026-10-17 at 5.05.23 PM.jpeg'))
# Outer white ring: centre and diameter measured from the source (1079x1086).
$d = 1066  # square from (7,8)
function Export-Badge($size, $path) {
  $b, $g = New-Canvas $size $size
  $g.Clear([System.Drawing.Color]::Transparent)
  $clip = New-Object System.Drawing.Drawing2D.GraphicsPath
  $clip.AddEllipse(0, 0, $size, $size)
  $g.SetClip($clip)
  $g.DrawImage($badgeSrc, (New-Object System.Drawing.Rectangle 0, 0, $size, $size), (New-Object System.Drawing.Rectangle 7, 8, $d, $d), 'Pixel')
  $b.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $b.Dispose()
}
Export-Badge 720 (Join-Path $img 'logo-badge-720.png')
Export-Badge 360 (Join-Path $img 'logo-badge-360.png')
Export-Badge 160 (Join-Path $img 'logo-badge-160.png')
Export-Badge 192 (Join-Path $ico 'icon-192.png')

# Apple touch icon: badge on a solid navy square (iOS ignores transparency).
$b, $g = New-Canvas 180 180
$g.Clear([System.Drawing.Color]::FromArgb(255, 5, 9, 15))
$clip = New-Object System.Drawing.Drawing2D.GraphicsPath; $clip.AddEllipse(6, 6, 168, 168); $g.SetClip($clip)
$g.DrawImage($badgeSrc, (New-Object System.Drawing.Rectangle 6, 6, 168, 168), (New-Object System.Drawing.Rectangle 7, 8, $d, $d), 'Pixel')
$b.Save((Join-Path $ico 'apple-touch-icon.png'), [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $b.Dispose()

# Small favicons use the palm-and-wave emblem from the same logo: the full
# badge's lettering is illegible at 16-32px. Emblem area measured from source.
$emblem = New-Object System.Drawing.Rectangle 48, 352, 290, 196
$smallPngs = @{}
foreach ($s in 16, 32, 48) {
  $b, $g = New-Canvas $s $s
  $g.Clear([System.Drawing.Color]::Transparent)
  $clip = New-Object System.Drawing.Drawing2D.GraphicsPath; $clip.AddEllipse(0, 0, $s, $s); $g.SetClip($clip)
  $g.Clear([System.Drawing.Color]::FromArgb(255, 241, 245, 248))
  $eh = [int][Math]::Round($s * 196 / 290 * 0.86); $ew = [int][Math]::Round($s * 0.86)
  $g.DrawImage($badgeSrc, (New-Object System.Drawing.Rectangle ([int](($s - $ew) / 2)), ([int](($s - $eh) / 2)), $ew, $eh), $emblem, 'Pixel')
  $p = Join-Path $ico "favicon-$s.png"
  $b.Save($p, [System.Drawing.Imaging.ImageFormat]::Png)
  $smallPngs[$s] = [System.IO.File]::ReadAllBytes($p)
  $g.Dispose(); $b.Dispose()
}
$badgeSrc.Dispose()

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
