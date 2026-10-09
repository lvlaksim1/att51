param(
    [Parameter(Mandatory=$true)][string]$Encoded
)
$ErrorActionPreference = 'Stop'
$payload = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Encoded)) | ConvertFrom-Json
$profile = [string]$payload.Profile
$env:USERPROFILE = $profile
$env:LOCALAPPDATA = Join-Path $profile 'AppData\Local'
$env:APPDATA = Join-Path $profile 'AppData\Roaming'
$env:TEMP = Join-Path $env:LOCALAPPDATA 'Temp'
$env:TMP = $env:TEMP
New-Item -Path $env:TEMP -ItemType Directory -Force | Out-Null
$process = Start-Process -FilePath ([string]$payload.Program) -ArgumentList ([string]$payload.Arguments) -Wait -PassThru
exit $process.ExitCode
