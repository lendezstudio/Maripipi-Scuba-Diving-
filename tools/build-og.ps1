# Renders tools/og-template.html to assets/img/og/maripipi-scuba-diving-og.jpg (1200x630).
# Requires Google Chrome or Microsoft Edge. Run from the project root:
#   powershell -ExecutionPolicy Bypass -File tools\build-og.ps1
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$browser = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

$outDir = Join-Path $root 'assets\img\og'
New-Item -ItemType Directory -Force $outDir | Out-Null
$png = Join-Path $env:TEMP 'maripipi-og.png'
$template = 'file:///' + ((Join-Path $PSScriptRoot 'og-template.html') -replace '\\', '/')

& $browser --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 `
  --window-size=1200,630 --virtual-time-budget=3000 "--screenshot=$png" $template | Out-Null
Start-Sleep -Milliseconds 500

$img = [System.Drawing.Image]::FromFile($png)
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$p = New-Object System.Drawing.Imaging.EncoderParameters 1
$p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]86)
$out = Join-Path $outDir 'maripipi-scuba-diving-og.jpg'
$img.Save($out, $codec, $p)
"{0}x{1} -> {2}" -f $img.Width, $img.Height, $out
$img.Dispose()
Remove-Item $png
