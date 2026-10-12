$projectRoot = Split-Path $PSScriptRoot -Parent
Add-Type -AssemblyName System.Drawing

function Write-BilanqoIcon([string]$IconPath, [int]$Pixels) {
    $bitmap = [System.Drawing.Bitmap]::new($Pixels, $Pixels)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#176B52'))
    $white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $green = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#176B52'))
    # Simple wallet mark, drawn from geometry rather than external artwork.
    $graphics.FillRectangle($white, [single]($Pixels*.22), [single]($Pixels*.32), [single]($Pixels*.56), [single]($Pixels*.39))
    $graphics.FillRectangle($green, [single]($Pixels*.57), [single]($Pixels*.44), [single]($Pixels*.23), [single]($Pixels*.16))
    $graphics.FillEllipse($white, [single]($Pixels*.61), [single]($Pixels*.49), [single]($Pixels*.055), [single]($Pixels*.055))
    $bitmap.Save($IconPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $green.Dispose()
    $white.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

foreach ($density in @{mdpi=48; hdpi=72; xhdpi=96; xxhdpi=144; xxxhdpi=192}.GetEnumerator()) {
    $iconPath = Join-Path $projectRoot "android/app/src/main/res/mipmap-$($density.Key)/ic_launcher.png"
    Write-BilanqoIcon $iconPath $density.Value
}
$iosIcons = Join-Path $projectRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
$contents = Get-Content (Join-Path $iosIcons 'Contents.json') -Raw | ConvertFrom-Json
foreach ($icon in $contents.images) {
    $size = [double]::Parse($icon.size.Split('x')[0], [System.Globalization.CultureInfo]::InvariantCulture)
    $scale = [int]$icon.scale.Replace('x','')
    Write-BilanqoIcon (Join-Path $iosIcons $icon.filename) ([int]($size*$scale))
}
