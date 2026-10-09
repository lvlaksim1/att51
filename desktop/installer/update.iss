#ifndef AppVersion
#define AppVersion "0.1.0"
#endif
#ifndef PublishDir
#define PublishDir "..\publish\Att51_export"
#endif
#ifndef OutputDir
#define OutputDir "..\dist"
#endif
#ifndef IconFile
#define IconFile "..\build\app.ico"
#endif

#define AppName "Att51_export"
#define AppExe "Att51_export.exe"
#define AppGuid "{{4C39F0DF-C81F-48A7-AC82-6B29E916E7C1}"

[Setup]
AppId={#AppGuid}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=lvlaksim1
AppPublisherURL=https://github.com/lvlaksim1/att51
AppSupportURL=https://github.com/lvlaksim1/att51/issues
DefaultDirName={commonappdata}\Att51_export
DefaultGroupName=Att51_export
DisableDirPage=yes
DisableProgramGroupPage=yes
UsePreviousAppDir=no
DirExistsWarning=no
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=Att51_export_Update_v{#AppVersion}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\{#AppExe}
CloseApplications=yes
AppMutex=Att51_export_4C39F0DF_C81F_48A7_AC82_6B29E916E7C1
RestartApplications=no
SetupLogging=no
VersionInfoVersion={#AppVersion}
VersionInfoProductName={#AppName}
VersionInfoDescription=Att51_export update installer

[Files]
Source: "{#PublishDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Att51_export"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"

[Dirs]
Name: "{app}\data"

[UninstallDelete]
Type: filesandordirs; Name: "{app}\updates"
Type: filesandordirs; Name: "{app}\data"
Type: filesandordirs; Name: "{app}\reports"

[Code]

// A previous release (<=0.1.10) did not create AppMutex. Detect that
// legacy running executable before Inno tries to remove/replace it.
// This is intentionally a check, not a forced process termination.

// Files created by an elevated legacy installation may not be writable by
// the currently logged-in user. Do not weaken app EXE directory ACLs.
function InstallDirectoryWritable: Boolean;
var Folder, Probe: String;
begin
  Folder := ExpandConstant('{commonappdata}\Att51_export');
  if not DirExists(Folder) then
  begin
    Result := True;
    Exit;
  end;
  Probe := Folder + '\.att51-rights-check-' + IntToStr(GetTickCount) + '.tmp';
  Result := SaveStringToFile(Probe, 'check', False);
  if Result then
    DeleteFile(Probe);
end;

function PermitInstallRights: Boolean;
var ErrorCode: Integer;
begin
  Result := InstallDirectoryWritable;
  if Result then Exit;
  if IsAdmin then
  begin
    MsgBox('Нет доступа на запись в каталог Att51_export даже при повышенных правах. ' +
      'Проверьте разрешения Windows и защиту файлов.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  if WizardSilent then
  begin
    Log('ATT51_INSTALL_PERMISSION_DENIED: administrator-owned installation; ' +
      'explicit elevation is required');
    Result := False;
    Exit;
  end;
  if ShellExec('runas', ExpandConstant('{srcexe}'), GetCmdTail, '',
               SW_SHOWNORMAL, ewNoWait, ErrorCode) then
  begin
    // The elevated setup takes over. Stop this unelevated copy.
    Result := False;
    Exit;
  end;
  MsgBox('Windows не разрешила повышение прав для обновления Att51_export.', mbError, MB_OK);
  Result := False;
end;

function LegacyAtt51ProcessRunning: Boolean;
var ExitCode: Integer;
begin
  Result := Exec(
    ExpandConstant('{cmd}'),
    '/C tasklist /FI "IMAGENAME eq Att51_export.exe" /NH | findstr /L /I /C:"Att51_export.exe" >NUL',
    '', SW_HIDE, ewWaitUntilTerminated, ExitCode
  ) and (ExitCode = 0);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var Attempt: Integer;
begin
  Result := '';
  for Attempt := 1 to 8 do
  begin
    if not LegacyAtt51ProcessRunning then
      Exit;
    Sleep(500);
  end;
  if LegacyAtt51ProcessRunning then
    Result := 'Программа Att51_export всё ещё запущена.' + #13#10 +
      'Закройте её и завершите процесс Att51_export.exe в диспетчере задач, ' +
      'затем повторите установку.' + #13#10 +
      'Файлы приложения ещё не заменялись.';
end;

function InitializeSetup(): Boolean;
var InstalledExe: String;
begin
  InstalledExe := ExpandConstant('{commonappdata}\Att51_export\Att51_export.exe');
  if not FileExists(InstalledExe) then
  begin
    MsgBox('Att51_export не обнаружен в папке ProgramData\Att51_export.' + #13#10 +
      'Для первой установки используйте Att51_export_Setup.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  Result := PermitInstallRights;
end;

[Run]
Filename: "{app}\{#AppExe}"; Description: "Открыть Att51_export после завершения"; Flags: postinstall nowait skipifsilent
