$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$androidLocalProperties = Join-Path $projectRoot 'android\local.properties'
$adbPath = $null

if ($env:ANDROID_HOME) {
  $candidate = Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe'
  if (Test-Path $candidate) {
    $adbPath = $candidate
  }
}

if (-not $adbPath -and (Test-Path $androidLocalProperties)) {
  $sdkDirLine = Get-Content $androidLocalProperties |
    Where-Object { $_ -like 'sdk.dir=*' } |
    Select-Object -First 1

  if ($sdkDirLine) {
    $sdkDir = $sdkDirLine.Substring('sdk.dir='.Length).Replace('\\', '\')
    $candidate = Join-Path $sdkDir 'platform-tools\adb.exe'
    if (Test-Path $candidate) {
      $adbPath = $candidate
    }
  }
}

if (-not $adbPath) {
  throw 'ADB was not found. Set ANDROID_HOME or update android/local.properties.'
}

$flutterCommand = 'D:\flutter_windows_3.35.5-stable\flutter\bin\flutter.bat'
$releaseApk = Join-Path $projectRoot 'build\app\outputs\flutter-apk\app-release.apk'

Push-Location $projectRoot
try {
  & $flutterCommand build apk --release
  & $adbPath devices
  & $adbPath install -r $releaseApk
} finally {
  Pop-Location
}
