# Writes absolute social-preview URLs, canonical and og:url into index.html.
# Usage (from project root):
#   powershell -ExecutionPolicy Bypass -File tools\set-site-url.ps1 -Url https://www.example-domain.ph/
# Re-run whenever the deployed address changes (e.g. a custom domain).
param([Parameter(Mandatory = $true)][string]$Url)
$ErrorActionPreference = 'Stop'
if (-not $Url.EndsWith('/')) { $Url += '/' }
$file = Join-Path (Split-Path $PSScriptRoot -Parent) 'index.html'
$html = [System.IO.File]::ReadAllText($file)
$og = $Url + 'assets/img/og/maripipi-scuba-diving-og.jpg'
$desc = 'A different world below. Discover Maripipi, Biliran, and start planning your scuba diving visit with care for the islands.'
$block = @"
<!-- site-url:start -->
  <link rel="canonical" href="$Url">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="Maripipi Scuba Diving">
  <meta property="og:url" content="$Url">
  <meta property="og:title" content="Maripipi Scuba Diving">
  <meta property="og:description" content="$desc">
  <meta property="og:image" content="$og">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:image:alt" content="Maripipi Scuba Diving logo over a deep blue underwater scene, with the words Maripipi Scuba Diving, Maripipi, Biliran, Philippines.">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Maripipi Scuba Diving">
  <meta name="twitter:description" content="$desc">
  <meta name="twitter:image" content="$og">
  <meta name="twitter:image:alt" content="Maripipi Scuba Diving logo over a deep blue underwater scene.">
  <!-- site-url:end -->
"@
$html = [regex]::Replace($html, '<!-- site-url:start -->[\s\S]*?<!-- site-url:end -->', $block.Trim())
# JSON-LD: drop any previous url/logo, then add the current ones after "name".
$html = [regex]::Replace($html, '\r?\n\s*"(url|logo)": "[^"]*",', '')
$html = $html.Replace('"name": "Maripipi Scuba Diving",', "`"name`": `"Maripipi Scuba Diving`",`n    `"url`": `"$Url`",`n    `"logo`": `"$($Url)assets/img/logo-badge-360.png`",")
[System.IO.File]::WriteAllText($file, $html, (New-Object System.Text.UTF8Encoding $false))
"Updated index.html for $Url"
