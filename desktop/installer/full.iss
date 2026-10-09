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
DefaultDirName={autopf}\Att51_export
DefaultGroupName=Att51_export
DisableDirPage=yes
DisableProgramGroupPage=yes
UsePreviousAppDir=no
DirExistsWarning=no
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=Att51_export_Setup_v{#AppVersion}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\{#AppExe}
CloseApplications=yes
RestartApplications=no
SetupLogging=no
VersionInfoVersion={#AppVersion}
VersionInfoProductName={#AppName}
VersionInfoDescription=Att51_export full Windows installer

[Tasks]
Name: "desktopicon"; Description: "Создать ярлык на рабочем столе"; GroupDescription: "Ярлыки"; Flags: unchecked

[Files]
Source: "{#PublishDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Att51_export"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"
Name: "{autodesktop}\Att51_export"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: desktopicon

[UninstallDelete]
Type: filesandordirs; Name: "{app}\updates"
Type: filesandordirs; Name: "{app}\data"
Type: filesandordirs; Name: "{app}\reports"

[Run]
Filename: "{app}\{#AppExe}"; Description: "Запустить Att51_export"; Flags: postinstall nowait skipifsilent
