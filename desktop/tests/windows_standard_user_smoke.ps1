param(
    [Parameter(Mandatory=$true)][string]$Version
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$setup = Join-Path $root "desktop\dist\Att51_export_Setup_v$Version.exe"
$update = Join-Path $root "desktop\dist\Att51_export_Update_v$Version.exe"
$app = Join-Path $env:ProgramData 'Att51_export'
$name = 'Att51CI' + [guid]::NewGuid().ToString('N').Substring(0, 8)
$password = ConvertTo-SecureString ('At51!' + [guid]::NewGuid().ToString('N') + 'aB1') -AsPlainText -Force
$created = $false
try {
    if (Test-Path $app) { throw 'A prior test installation was not removed' }
    New-LocalUser -Name $name -Password $password -Description 'Temporary non-administrator installer test user' | Out-Null
    $created = $true
    $cred = [pscredential]::new("$env:COMPUTERNAME\$name", $password)
    if ((Get-LocalGroupMember -Group 'Administrators' | Where-Object Name -Like "*\$name").Count -gt 0) {
        throw 'Test user unexpectedly has administrator rights'
    }
    function RunAsUser([string]$path, [string]$arguments) {
        $process = Start-Process -FilePath $path -Credential $cred -LoadUserProfile -ArgumentList $arguments -Wait -PassThru
        if ($process.ExitCode -ne 0) { throw "$path failed for standard user, exit=$($process.ExitCode)" }
    }
    RunAsUser $setup '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /TASKS="!desktopicon"'
    $exe = Join-Path $app 'Att51_export.exe'
    if (-not (Test-Path $exe)) { throw 'Non-admin setup did not install under ProgramData' }
    RunAsUser $exe '--self-test-settings'
    $settings = Join-Path $app 'data\source-paths.json'
    if (-not (Test-Path $settings)) { throw 'Standard user could not write saved paths' }
    $before = (Get-FileHash $settings -Algorithm SHA256).Hash
    RunAsUser $update '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
    RunAsUser $exe '--self-test'
    if ((Get-FileHash $settings -Algorithm SHA256).Hash -ne $before) {
        throw 'Update lost the saved source paths'
    }
    RunAsUser (Join-Path $app 'unins000.exe') '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
    Start-Sleep -Seconds 2
    if (Test-Path $exe) { throw 'Non-admin uninstaller left executable' }
    if (Test-Path $settings) { throw 'Non-admin uninstaller left settings' }
    Write-Host 'STANDARD_USER_NO_ELEVATION_INSTALL_UPDATE_UNINSTALL_PASS'
    Write-Host 'PERSISTED_PATHS_ACROSS_UPDATE_PASS'
} finally {
    if ($created) {
        Remove-LocalUser -Name $name -ErrorAction SilentlyContinue
    }
}
