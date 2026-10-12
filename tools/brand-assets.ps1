Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path $PSScriptRoot -Parent
function Write-Mark([string]$target, [int]$size) {
  $bitmap = [System.Drawing.Bitmap]::new($size, $size)
  $canvas = [System.Drawing.Graphics]::FromImage($bitmap)
  $canvas.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $canvas.Clear([System.Drawing.ColorTranslator]::FromHtml('#176B52'))
  $font = [System.Drawing.Font]::new('Arial', $size * 0.48, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $format = [System.Drawing.StringFormat]::new()
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Center
  $canvas.DrawString('B', $font, [System.Drawing.Brushes]::White, [System.Drawing.RectangleF]::new(0, 0, $size, $size), $format)
  $bitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
  $format.Dispose(); $font.Dispose(); $canvas.Dispose(); $bitmap.Dispose()
}
foreach ($entry in @{mdpi=48;hdpi=72;xhdpi=96;xxhdpi=144;xxxhdpi=192}.GetEnumerator()) {
  Write-Mark (Join-Path $projectRoot "android/app/src/main/res/mipmap-$($entry.Key)/ic_launcher.png") $entry.Value
}
$iconsPath = Join-Path $projectRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
$icons = Get-Content (Join-Path $iconsPath 'Contents.json') -Raw | ConvertFrom-Json
foreach ($image in $icons.images) {
  $size = [double]($image.size.Split('x')[0]) * [int]($image.scale.Replace('x',''))
  Write-Mark (Join-Path $iconsPath $image.filename) ([int]$size)
}
foreach ($entry in @{'LaunchImage.png'=96;'LaunchImage@2x.png'=192;'LaunchImage@3x.png'=288}.GetEnumerator()) {
  Write-Mark (Join-Path $projectRoot "ios/Runner/Assets.xcassets/LaunchImage.imageset/$($entry.Key)") $entry.Value
}
