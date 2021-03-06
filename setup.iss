; "Inno Download Plugin" from "Third-Party Files" is required
; http://www.jrsoftware.org/is3rdparty.php
#include <idp.iss>

#define AppName "ARK Smart Breeding"
#define AppPublisher "cadon & friends"
#define AppURL "https://github.com/cadon/ARKStatsExtractor"
#define AppExeName "ARK Smart Breeding.exe"
#define ReleaseDir "ARKBreedingStats\bin\Release"
#define ReleaseDirUpdater "ASB-Updater\bin\Release"
#define OutputDir "_publish"
#define AppVersion GetFileVersion(ReleaseDir + "\" + AppExeName)

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{8DDA440C-714D-4BE6-AD7B-F549ABB1BB02}
AppName={#AppName}
AppVersion={#AppVersion}
;AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={pf}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=yes
OutputDir={#OutputDir}
OutputBaseFilename=setup-ArkSmartBreeding-{#AppVersion}
Compression=lzma
SolidCompression=yes
CloseApplications=yes
UninstallDisplayIcon={app}\{#AppExeName}

[CustomMessages]
DotNetFrameworkNeededCaption=.NET Framework 4.7.2 required
german.DotNetFrameworkNeededCaption=.NET Framework 4.7.2 ben�tigt
DotNetFrameworkNeededDescription=To run {#AppName} the .NET Framework 4.7.2 is required.
german.DotNetFrameworkNeededDescription=Um {#AppName} auszuf�hren wird .NET Framework 4.7.2 ben�tigt.
DotNetFrameworkNeededSubCaption=Check the box below to download and install .NET Framework 4.7.2.
german.DotNetFrameworkNeededSubCaption=Markieren Sie das folgende K�stchen, um .NET Framework 4.7.2 herunterzuladen und zu installieren.
DotNetFrameworkInstall=Download and install .NET Framework 4.7.2
german.DotNetFrameworkInstall=Herunterladen und Installation von .NET Framework 4.7.2
IDP_DownloadFailed=Download of .NET Framework 4.7.2 failed. .NET Framework 4.7.2 is required to run {#AppName}.
german.IDP_DownloadFailed=Herunterladen von .NET Framework 4.7.2 fehlgeschlagen. .NET Framework 4.7.2 wird ben�tigt um {#AppName} auszuf�hren.
IDP_RetryCancel=Click 'Retry' to try downloading the files again, or click 'Cancel' to terminate setup.
german.IDP_RetryCancel=Klicken Sie 'Wiederholen', um das Herunterladen der Dateien erneut zu versuchen, oder klicken Sie auf "Abbrechen", um die Installation abzubrechen.
InstallingDotNetFramework=Installing .NET Framework 4.7.2. This might take a few minutes...
german.InstallingDotNetFramework=Installiere .NET Framework 4.7.2. Das wird eine Weile dauern ...
DotNetFrameworkFailedToLaunch=Failed to launch .NET Framework Installer with error "%1". Please fix the error then run this installer again.
german.DotNetFrameworkFailedToLaunch=Starten des .NET Framework Installer fehlgeschlagen mit Fehler "%1". Bitte den Fehler beheben und dieses Installationsprogramm erneut ausf�hren.
DotNetFrameworkFailed1602=.NET Framework installation was cancelled. This installation can continue, but be aware that this application may not run unless the .NET Framework installation is completed successfully.
german.DotNetFrameworkFailed1602=Die .NET Framework Installation wurde abgebrochen. Diese Installation kann fortgesetzt werden. Beachten Sie jedoch, dass diese Anwendung m�glicherweise nicht ausgef�hrt wird, bis die .NET Framework-Installation erfolgreich abgeschlossen wurde.
DotNetFrameworkFailed1603=A fatal error occurred while installing the .NET Framework. Please fix the error, then run the installer again.
german.DotNetFrameworkFailed1603=Ein schwerwiegender Fehler trat w�hrend der Installiion des .NET Frameworks auf. Bitte den Fehler beheben und dieses Installationsprogramm erneut ausf�hren.
DotNetFrameworkFailed5100=Your computer does not meet the requirements of the .NET Framework.
german.DotNetFrameworkFailed5100=Ihr Computer erf�llt nicht die Voraussetzungen f�r das .NET Framework.
DotNetFrameworkFailedOther=The .NET Framework installer exited with an unexpected status code "%1". Please review any other messages shown by the installer to determine whether the installation completed successfully, and abort this installation and fix the problem if it did not.
german.DotNetFrameworkFailedOther=Die .NET Framework Installation endete mit dem nicht erwarteten Statuscode "%1". �berpr�fen Sie alle anderen vom Installationsprogramm angezeigten Meldungen, um festzustellen, ob die Installation erfolgreich abgeschlossen wurde, und falls nicht, brechen Sie die Installation ab und beheben Sie das Problem.

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
;Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.xml"
Source: "{#ReleaseDirUpdater}\asb-updater.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{group}\{cm:ProgramOnTheWeb,{#AppName}}"; Filename: "{#AppURL}"
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Flags: nowait postinstall skipifsilent unchecked; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"

[UninstallRun]
Filename: "taskkill"; Parameters: "/im ""{#AppExeName}"""; Flags: runhidden

[Code]

var
  requiresRestart: boolean;
  DotNetPage: TInputOptionWizardPage;
  InstallDotNetFramework: Boolean;

function DotNetFrameworkIsMissing(): Boolean;
var
  bSuccess: Boolean;
  regVersion: Cardinal;
begin
  Result := True;

  bSuccess := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release', regVersion);
  if (True = bSuccess) and (regVersion >= 461308) then begin
    Result := False;
  end;
end;

procedure InitializeWizard;
begin
  DotNetPage := CreateInputOptionPage(wpSelectTasks, ExpandConstant('{cm:DotNetFrameworkNeededCaption}'),
    ExpandConstant('{cm:DotNetFrameworkNeededDescription}'), ExpandConstant('{cm:DotNetFrameworkNeededSubCaption}'), False, False);
  DotNetPage.Add(ExpandConstant('{cm:DotNetFrameworkInstall}'));
  DotNetPage.Values[0] := True;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if (PageID = DotNetPage.ID) and not DotNetFrameworkIsMissing() then
    Result := True
  else
    Result := False;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if (CurPageID = DotNetPage.ID) and DotNetFrameworkIsMissing() then begin
    if DotNetPage.Values[0] then begin
      InstallDotNetFramework := True;
      idpAddFile('http://go.microsoft.com/fwlink/?LinkId=863262', ExpandConstant('{tmp}\NetFrameworkInstaller.exe'));
      idpDownloadAfter(wpReady);
    end;
  end;
  Result := True;
end;

function InstallFramework(): String;
var
  StatusText: string;
  ResultCode: Integer;
begin
  exit;
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := CustomMessage('InstallingDotNetFramework');
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
    if not Exec(ExpandConstant('{tmp}\NetFrameworkInstaller.exe'), '/passive /norestart /showrmui /showfinalerror', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    begin
      Result := FmtMessage(CustomMessage('DotNetFrameworkFailedToLaunch'), [SysErrorMessage(resultCode)]);
    end
    else
    begin
      // See https://msdn.microsoft.com/en-us/library/ee942965(v=vs.110).aspx#return_codes
      case resultCode of
        0: begin
          // Successful
        end;
        1602 : begin
          MsgBox(CustomMessage('DotNetFrameworkFailed1602'), mbInformation, MB_OK);
        end;
        1603: begin
          Result := CustomMessage('DotNetFrameworkFailed1603');
        end;
        1641: begin
          requiresRestart := True;
        end;
        3010: begin
          requiresRestart := True;
        end;
        5100: begin
          Result := CustomMessage('DotNetFrameworkFailed5100');
        end;
        else begin
          MsgBox(FmtMessage(CustomMessage('DotNetFrameworkFailedOther'), [IntToStr(resultCode)]), mbError, MB_OK);
        end;
      end;
    end;
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
    
    DeleteFile(ExpandConstant('{tmp}\NetFrameworkInstaller.exe'));
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  // 'NeedsRestart' only has an effect if we return a non-empty string, thus aborting the installation.
  // If the installers indicate that they want a restart, this should be done at the end of installation.
  // Therefore we set the global 'restartRequired' if a restart is needed, and return this from NeedRestart()

  if InstallDotNetFramework then
  begin
    Result := InstallFramework();
  end;
end;

function NeedRestart(): Boolean;
begin
  Result := requiresRestart;
end;
