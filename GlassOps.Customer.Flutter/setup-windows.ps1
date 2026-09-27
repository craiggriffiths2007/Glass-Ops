# Run from the extracted Flutter project folder in VS Code's PowerShell terminal.
# Requires the Flutter SDK (3.35+) and Android SDK already installed.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter not found. Install the Flutter SDK and add its bin folder to PATH.'
}

# Flutter creates the Android Gradle wrapper from its own compatible templates.
# Preserve our converted files in case the installed Flutter version rewrites them.
$preserve = @{}
foreach ($file in @('pubspec.yaml', 'lib/main.dart', 'analysis_options.yaml', 'test/models_test.dart')) {
    if (Test-Path $file) { $preserve[$file] = [System.IO.File]::ReadAllBytes((Join-Path $PWD $file)) }
}
try {
    flutter create --platforms=android --project-name glassops_customer_flutter --org uk.co.glassops .
    if ($LASTEXITCODE -ne 0) { throw 'Flutter could not generate the Android project.' }
} finally {
    foreach ($file in $preserve.Keys) {
        [System.IO.File]::WriteAllBytes((Join-Path $PWD $file), $preserve[$file])
    }
}

# Remove Flutter's newly generated demo widget test (it refers to the default
# MyApp class, which this conversion deliberately does not use).
if (Test-Path 'test/widget_test.dart') { Remove-Item 'test/widget_test.dart' }

# Allow the release APK to contact the live Glass Ops HTTPS API.
$manifestPath = 'android/app/src/main/AndroidManifest.xml'
$manifest = [System.IO.File]::ReadAllText((Join-Path $PWD $manifestPath))
$manifest = $manifest -replace 'android:label="[^"]*"', 'android:label="My Repair"'
if (-not $manifest.Contains('android.permission.INTERNET')) {
    $manifest = $manifest.Replace('</manifest>', '    <uses-permission android:name="android.permission.INTERNET" />' + "`n" + '</manifest>')
}
if (-not $manifest.Contains('android:allowBackup=')) {
    $manifest = $manifest.Replace('<application', '<application android:allowBackup="false"')
} else {
    $manifest = $manifest -replace 'android:allowBackup="[^"]*"', 'android:allowBackup="false"'
}
[System.IO.File]::WriteAllText((Join-Path $PWD $manifestPath), $manifest)

# Match the original MAUI Android 24 minimum SDK (Android 7.0).
$gradleKts = 'android/app/build.gradle.kts'
$gradleGroovy = 'android/app/build.gradle'
if (Test-Path $gradleKts) {
    $gradle = [System.IO.File]::ReadAllText((Join-Path $PWD $gradleKts))
    $gradle = $gradle.Replace('minSdk = flutter.minSdkVersion', 'minSdk = 24')
    [System.IO.File]::WriteAllText((Join-Path $PWD $gradleKts), $gradle)
} elseif (Test-Path $gradleGroovy) {
    $gradle = [System.IO.File]::ReadAllText((Join-Path $PWD $gradleGroovy))
    $gradle = $gradle.Replace('minSdkVersion flutter.minSdkVersion', 'minSdkVersion 24')
    [System.IO.File]::WriteAllText((Join-Path $PWD $gradleGroovy), $gradle)
}

flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Could not download Flutter dependencies.' }
dart run flutter_launcher_icons
if ($LASTEXITCODE -ne 0) { throw 'Could not generate Android app icons.' }

Write-Host 'Android project created. Run: flutter analyze; flutter test; flutter run' -ForegroundColor Green
