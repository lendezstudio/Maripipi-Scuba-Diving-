# Minimal local preview server (no Node/Python needed).
#   powershell -ExecutionPolicy Bypass -File tools\serve.ps1 [-Port 8080]
# Then open http://localhost:8080/
param([int]$Port = 8080)
$root = Split-Path $PSScriptRoot -Parent
$types = @{
  '.html' = 'text/html; charset=utf-8'; '.css' = 'text/css'; '.js' = 'text/javascript'
  '.jpg' = 'image/jpeg'; '.png' = 'image/png'; '.ico' = 'image/x-icon'; '.svg' = 'image/svg+xml'
  '.woff2' = 'font/woff2'; '.webmanifest' = 'application/manifest+json'; '.txt' = 'text/plain'
}
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
"Serving $root at http://localhost:$Port/  (Ctrl+C to stop)"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
  if ($path -eq '' -or $path.EndsWith('/')) { $path += 'index.html' }
  $file = [IO.Path]::GetFullPath((Join-Path $root $path))
  if ($file.StartsWith($root) -and (Test-Path $file -PathType Leaf)) {
    $bytes = [IO.File]::ReadAllBytes($file)
    $ext = [IO.Path]::GetExtension($file).ToLower()
    $ctx.Response.ContentType = if ($types[$ext]) { $types[$ext] } else { 'application/octet-stream' }
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $ctx.Response.StatusCode = 404
  }
  $ctx.Response.Close()
}
