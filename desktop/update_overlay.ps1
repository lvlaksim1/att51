# Att51_export independent updater: ONE progress window for download/install/restart.
param(
    [Parameter(Mandatory=$true)][string]$Tag,
    [Parameter(Mandatory=$true)][string]$Checksum,
    [Parameter(Mandatory=$true)][long]$Size,
    [Parameter(Mandatory=$true)][int]$ApplicationPid,
    [Parameter(Mandatory=$true)][string]$InstallDir
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$install = [IO.Path]::GetFullPath($InstallDir)
if ([IO.Path]::GetFileName($install) -ine 'Att51_export') { throw 'Недопустимая папка установки' }
if ($Tag -notmatch '^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$' -or $Checksum -notmatch '^[0-9a-fA-F]{64}$' -or $Size -lt 100000 -or $ApplicationPid -le 0) { throw 'Недопустимые параметры обновления' }
$updates = Join-Path $install 'updates'
[IO.Directory]::CreateDirectory($updates) | Out-Null
$ready = Join-Path $updates 'overlay.ready'
$progressFile = Join-Path $updates 'install.progress'
$boot = Join-Path $updates 'newapp.ready'
$name = "Att51_export_Update_$Tag.exe"
$partial = Join-Path $updates ($name + '.download')
$destination = Join-Path $updates $name
$url = "https://github.com/lvlaksim1/att51/releases/download/$Tag/$name"
Remove-Item -LiteralPath $ready, $progressFile, $boot, $partial -Force -ErrorAction SilentlyContinue

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Обновление Att51_export'
$form.Width = 490
$form.Height = 156
$form.FormBorderStyle = 'FixedDialog'
$form.StartPosition = 'CenterScreen'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ControlBox = $false
$form.TopMost = $true
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$label = New-Object System.Windows.Forms.Label
$label.Left = 18
$label.Top = 14
$label.Width = 444
$label.Height = 48
$label.Text = 'Подготовка обновления…'
$form.Controls.Add($label)
$bar = New-Object System.Windows.Forms.ProgressBar
$bar.Left = 18
$bar.Top = 74
$bar.Width = 440
$bar.Height = 21
$bar.Maximum = 100
$form.Controls.Add($bar)

function SetProgress([int]$percent, [string]$message) {
    $bar.Value = [Math]::Min(100, [Math]::Max(0, $percent))
    $label.Text = $message
    [System.Windows.Forms.Application]::DoEvents()
}
function DownloadVerified() {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $request = [Net.HttpWebRequest]::Create($url)
    $request.UserAgent = 'Att51_export/Updater'
    $request.AllowAutoRedirect = $true
    $request.Timeout = 30000
    $request.ReadWriteTimeout = 90000
    $response = $null
    $inputStream = $null
    $outputStream = $null
    try {
        $response = $request.GetResponse()
        $final = $response.ResponseUri
        $trusted = @('github.com','release-assets.githubusercontent.com','objects.githubusercontent.com')
        if ($final.Scheme -ne 'https' -or $final.Host -notin $trusted) { throw 'Недоверенный адрес загрузки' }
        $inputStream = $response.GetResponseStream()
        $outputStream = [IO.File]::Open($partial, [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::None)
        $buffer = New-Object byte[] 131072
        [long]$received = 0
        while (($n = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $received += $n
            if ($received -gt $Size) { throw 'Размер обновления превышает ожидаемый' }
            $outputStream.Write($buffer, 0, $n)
            SetProgress ([int][Math]::Round($received * 50.0 / $Size)) ("Загрузка: " + [Math]::Round($received * 100.0 / $Size) + ' %')
        }
        $outputStream.Flush()
        $outputStream.Dispose()
        $outputStream = $null
        if ($received -ne $Size) { throw 'Размер обновления не совпадает' }
        SetProgress 50 'Проверка контрольной суммы…'
        if ((Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Checksum.ToLowerInvariant()) { throw 'SHA-256 не совпадает' }
        $reader = [IO.File]::OpenRead($partial)
        try {
            if ($reader.ReadByte() -ne 77 -or $reader.ReadByte() -ne 90) { throw 'Обновление не является EXE' }
        } finally { $reader.Dispose() }
        Move-Item -LiteralPath $partial -Destination $destination -Force
    } finally {
        if ($outputStream) { $outputStream.Dispose() }
        if ($inputStream) { $inputStream.Dispose() }
        if ($response) { $response.Dispose() }
    }
}

$form.Add_Shown({
    # Existing program closes only after the overlay is visible.
    Set-Content -LiteralPath $ready -Value 'VISIBLE' -Encoding Ascii
    try {
        SetProgress 0 'Загрузка обновления…'
        DownloadVerified
        SetProgress 50 'Ожидание завершения предыдущей версии…'
        $deadline = [DateTime]::UtcNow.AddSeconds(45)
        while (Get-Process -Id $ApplicationPid -ErrorAction SilentlyContinue) {
            if ([DateTime]::UtcNow -gt $deadline) { throw 'Старая программа не закрылась' }
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 125
        }
        SetProgress 51 'Установка обновления…'
        # The Inno progress callback writes actual bytes processed into install.progress.
        $args = @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/NOCANCEL', '/CLOSEAPPLICATIONS', '/RUNAFTERUPDATE=0', ('/PROGRESSFILE="' + $progressFile + '"'))
        $setup = Start-Process -FilePath $destination -ArgumentList $args -PassThru
        while (-not $setup.HasExited) {
            if (Test-Path -LiteralPath $progressFile) {
                try {
                    $parts = ([IO.File]::ReadAllText($progressFile)).Trim().Split('/')
                    if ($parts.Length -eq 2 -and [double]$parts[1] -gt 0) {
                        SetProgress (51 + [int][Math]::Round(43.0*[double]$parts[0]/[double]$parts[1])) 'Установка обновления…'
                    }
                } catch { } # retry a progress-file write
            }
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 130
            $setup.Refresh()
        }
        if ($setup.ExitCode -ne 0) { throw ("Ошибка установщика: " + $setup.ExitCode) }
        SetProgress 95 'Запуск обновлённой программы…'
        $exe = Join-Path $install 'Att51_export.exe'
        if (-not (Test-Path -LiteralPath $exe)) { throw 'Обновлённая программа не обнаружена' }
        $newApp = Start-Process -FilePath $exe -WorkingDirectory $install -ArgumentList '--update-started' -PassThru
        $until = [DateTime]::UtcNow.AddSeconds(35)
        while (-not (Test-Path -LiteralPath $boot)) {
            $newApp.Refresh()
            if ($newApp.HasExited) { throw 'Приложение завершилось при запуске' }
            if ([DateTime]::UtcNow -gt $until) { throw 'Программа не подтвердила запуск' }
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 150
        }
        SetProgress 100 'Обновление завершено'
        Start-Sleep -Milliseconds 250
        $form.Close()
    } catch {
        $form.ControlBox = $true
        $label.Text = 'Ошибка обновления: ' + $_.Exception.Message
        $bar.Value = 0
        # Failure remains visible; no false automatic success.
    } finally {
        Remove-Item -LiteralPath $ready, $progressFile, $boot, $partial -Force -ErrorAction SilentlyContinue
    }
})
[void]$form.ShowDialog()
