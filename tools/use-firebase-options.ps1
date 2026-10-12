$projectRoot = Split-Path $PSScriptRoot -Parent
$optionsPath = Join-Path $projectRoot 'lib/firebase_options.dart'
if (!(Test-Path -LiteralPath $optionsPath)) { throw 'Run flutterfire configure first.' }
$mainPath = Join-Path $projectRoot 'lib/main.dart'
$source = Get-Content -LiteralPath $mainPath -Raw
if (!$source.Contains("import 'firebase_options.dart';")) {
  $source = "import 'firebase_options.dart';`n" + $source
}
$source = $source.Replace('Firebase.initializeApp()', 'Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)')
Set-Content -LiteralPath $mainPath -Value $source
