param(
  [Parameter(Mandatory=$true)]
  [ValidatePattern('^\d+\.\d+\.\d+$')]
  [string]$Version
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $root
try {
  $build = Join-Path $root 'desktop\build'
  $publish = Join-Path $root 'desktop\publish'
  $dist = Join-Path $root 'desktop\dist'
  foreach ($path in @($build, $publish, $dist)) {
    if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $path | Out-Null
  }
  $stagedSource = Join-Path $build 'sources'
  New-Item -ItemType Directory -Force -Path $stagedSource | Out-Null
  Copy-Item (Join-Path $root 'desktop\*.py') -Destination $stagedSource
  $versionPath = Join-Path $stagedSource 'version.py'
  [IO.File]::WriteAllText($versionPath, ('VERSION = "' + $Version + '"' + [Environment]::NewLine), [Text.UTF8Encoding]::new($false))

  $icon = Join-Path $build 'app.ico'
  & python desktop/build_icon.py $icon
  if ($LASTEXITCODE -ne 0 -or -not (Test-Path $icon)) { throw 'Icon generation failed' }
  $xsd = Join-Path $root 'extracted\app\fileProtocolLoad_v4.xsd'
  if (-not (Test-Path $xsd)) { throw 'Missing original XSD' }

  $pyArgs = @(
    '--noconfirm', '--clean', '--onedir', '--windowed',
    '--name', 'Att51_export', '--icon', $icon,
    '--paths', (Join-Path $root 'fsa_xml_module'),
    '--add-data', ($icon + ';assets'), '--add-data', ($xsd + ';assets'),
    '--hidden-import', 'win32com.client',
    '--hidden-import', 'pythoncom', '--hidden-import', 'pywintypes',
    '--hidden-import', 'win32timezone',
    '--distpath', $publish, '--workpath', (Join-Path $build 'pyinstaller'),
    '--specpath', $build, (Join-Path $stagedSource 'app.py')
  )
  & python -m PyInstaller @pyArgs
  if ($LASTEXITCODE -ne 0) { throw "PyInstaller failed: $LASTEXITCODE" }

  $exe = Join-Path $publish 'Att51_export\Att51_export.exe'
  if (-not (Test-Path $exe)) { throw 'Executable not generated' }
  $smoke = Start-Process -FilePath $exe -ArgumentList '--self-test' -Wait -PassThru
  if ($smoke.ExitCode -ne 0) { throw "Executable self-test failed: $($smoke.ExitCode)" }

  $iscc = Join-Path ([Environment]::GetFolderPath('ProgramFilesX86')) 'Inno Setup 6\ISCC.exe'
  if (-not (Test-Path $iscc)) { $iscc = Join-Path $env:ProgramFiles 'Inno Setup 6\ISCC.exe' }
  if (-not (Test-Path $iscc)) { throw 'Inno Setup 6 missing' }
  $innoArgs = @("/DAppVersion=$Version", "/DPublishDir=$(Join-Path $publish 'Att51_export')", "/DOutputDir=$dist", "/DIconFile=$icon")
  foreach ($script in @('full.iss', 'update.iss')) {
    & $iscc (Join-Path $root ('desktop\installer\' + $script)) @innoArgs
    if ($LASTEXITCODE -ne 0) { throw "$script failed: $LASTEXITCODE" }
  }
  foreach ($name in @("Att51_export_Setup_v$Version.exe", "Att51_export_Update_v$Version.exe")) {
    $file = Join-Path $dist $name
    if (-not (Test-Path $file)) { throw "Installer missing: $file" }
    $length = (Get-Item $file).Length
    if ($length -lt 1MB) { throw "Installer too small: $file" }
    $hash = (Get-FileHash $file -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Host "BUILT $name $length bytes SHA256=$hash"
  }
  Write-Host "RELEASE_PACKAGE_OK version=$Version"
} finally {
  Pop-Location
}
