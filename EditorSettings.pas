{ TODO : Next: Speichern der Listbox in der Ini}
unit EditorSettings;
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IniFiles, ShellAPI,
  System.IOUtils, System.RegularExpressions, ConverterConst;

type
  TEditorProfile = class
    public
      Name     : String;
      Path     : String;
      Parameter: String;
      isActive : boolean;
  end;

type
  TfrmEditorSettings = class(TForm)
    pnlMain: TPanel;
    pnlBot: TPanel;
    lbxEditors: TListBox;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnSave: TButton;
    pnlEditors: TPanel;
    pnlProperties: TPanel;
    pnlPropertiesHeader: TPanel;
    pnlEditorsHeader: TPanel;
    lblEditors: TLabel;
    lblProperties: TLabel;
    splMain: TSplitter;
    lblName: TLabel;
    lblPath: TLabel;
    edtName: TEdit;
    edtPath: TEdit;
    chkUseEditor: TCheckBox;
    btnTestEditor: TButton;
    btnEditorButtons: TPanel;
    btnAdd: TButton;
    btnDelete: TButton;
    dlgOpen: TOpenDialog;
    btnSelectPath: TButton;
    edtParameter: TEdit;
    lblParameter: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure lbxEditorsClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSelectPathClick(Sender: TObject);
    procedure btnTestEditorClick(Sender: TObject);
    procedure edtNameExit(Sender: TObject);
    procedure edtPathExit(Sender: TObject);
    procedure chkUseEditorClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    isRefreshing: boolean;
    procedure CreateTestFile(var sFile: String);
    procedure LoadEditorList;
    procedure LoadEditorSettings;
    procedure RefreshEditorList;
    procedure ClearEditorConfig;
  public
    EditorsFile: TIniFile;
    constructor Create(AOwner: TComponent; var AEditorsFile: TIniFile); reintroduce;
  end;

var
  frmEditorSettings: TfrmEditorSettings;

implementation

{$R *.dfm}

{ TfrmEditorSettings }

procedure TfrmEditorSettings.btnAddClick(Sender: TObject);
var
  eProfile  : TEditorProfile;
  sBaseName : String;
  sName     : String;
  ii        : integer;
  iCounter  : integer;
  nameExists: boolean;
begin
  isRefreshing := True;
  sBaseName := 'Editor';
  sName := sBaseName;
  iCounter := 1;

  repeat
    nameExists := False;
    for ii := 0 to lbxEditors.Count - 1 do begin
      if (SameText(TEditorProfile(lbxEditors.Items.Objects[ii]).Name, sName)) then begin
        nameExists := True;
        Break;
      end;
    end;

    if (nameExists) then begin
      inc(iCounter);
      sName := sBaseName + IntToStr(iCounter);
    end;

  until not nameExists;

  eProfile := TEditorProfile.Create;
  with eProfile do begin
    Name     := sName;
    Path     := '';
    Parameter:= '';
    isActive := False;
  end;

  lbxEditors.Items.AddObject(eProfile.Name, eProfile);
  lbxEditors.ItemIndex := lbxEditors.Count - 1;
  LoadEditorSettings;
  edtName.SetFocus;
  isRefreshing := False;
end;

procedure TfrmEditorSettings.btnDeleteClick(Sender: TObject);
var
  eProfile : TEditorProfile;
  iIndex   : Integer;
begin
  iIndex := lbxEditors.ItemIndex;
  if (iIndex < 0) then
    Exit
  ;

  //Profil löschen & freigeben
  eProfile := TEditorProfile(lbxEditors.Items.Objects[iIndex]);
  eProfile.Free;
  lbxEditors.Items.Delete(iIndex);

  //Nächstes Profil selektieren
  if (lbxEditors.Count > 0) then begin
    if (iIndex >= lbxEditors.Count) then
      iIndex := lbxEditors.Count - 1
    ;
    lbxEditors.ItemIndex := iIndex;
  end
  else
    lbxEditors.ItemIndex := -1
  ;

  LoadEditorSettings;
end;

procedure TfrmEditorSettings.btnSaveClick(Sender: TObject);
var
  eProfile: TEditorProfile;
  sSection: String;
  ii : integer;
begin
  if (not assigned(EditorsFile)) then
    Exit
  ;

  //Zuerst die aktuelle Editor-Settings löschen
  ClearEditorConfig;

  //Alle Editor-Profile neu eintragen
  for ii := 0 to lbxEditors.Count - 1 do begin
    eProfile := TEditorProfile(lbxEditors.Items.Objects[ii]);

    sSection := EDITORS_SEC_EDITOR_X + eProfile.Name;
    EditorsFile.WriteString(sSection, EDITORS_KEY_PATH, eProfile.Path);
    EditorsFile.WriteString(sSection, EDITORS_KEY_PARAMETER, eProfile.Parameter);

    if eProfile.isActive then
      EditorsFile.WriteString(EDITORS_SEC_EDITOR, EDITORS_KEY_ACTIVE, sSection)
    ;
  end;
end;

procedure TfrmEditorSettings.ClearEditorConfig;
var
  slSections: TStringList;
  sSection  : String;
begin
  slSections := TStringList.Create;
  try
    EditorsFile.ReadSections(slSections);
    for sSection in slSections do begin
      if sSection.StartsWith(EDITORS_SEC_EDITOR_X) then
        EditorsFile.EraseSection(sSection)
      ;
    end;
  finally
    slSections.Free;
  end;
end;

procedure TfrmEditorSettings.btnSelectPathClick(Sender: TObject);
begin
  if (dlgOpen.Execute) then
    edtPath.Text := dlgOpen.FileName
  ;
end;

procedure TfrmEditorSettings.btnTestEditorClick(Sender: TObject);
var
  sTempFile : String;
  sParameter: String;
  hRes : HINST;
begin
  //Pfad prüfen
  if (Trim(edtPath.Text) = '') then begin
    MessageDlg('Pfad darf nicht leer sein!', mtError, [mbOK], 0);
    edtPath.SetFocus;
    Exit;
  end;

  //Falls Pfad nicht leer & kein Systembefehl ist, dann Pfad prüfen
  if (ExtractFilePath(edtPath.Text) <> '') and (not FileExists(edtPath.Text)) then begin
    MessageDlg('Datei existiert nicht:' + CRLF + edtPath.Text, mtError, [mbOK], 0);
    Exit;
  end;

  //Temp. Test-Datei erzeugen
  CreateTestFile(sTempFile);

  //Parameter zusammensetzen
  sParameter := Trim(edtParameter.Text) + ' "' + sTempFile + '"';

  //Datei im Editor öffnen
  hRes := ShellExecute(
    Handle,
    'open',
    PChar(edtPath.Text),
    PChar(sParameter),
    nil,
    SW_SHOWNORMAL
  );

  //Fehlerfall anzeigen
  if (hRes <= 32) then
    MessageDlg(
      'Editor konnte nicht gestartet werden!' + CR + SysErrorMessage(GetLastError),
      mtError,
      [mbOK],
      0
    )
  ;
end;

procedure TfrmEditorSettings.CreateTestFile(var sFile: String);
var
  sProgramPath : String;
begin
  sProgramPath := TPath.Combine(GetEnvironmentVariable('APPDATA'), PROGRAMM_NAME);
  if (not ForceDirectories(sProgramPath)) then
    //Falls das nicht geht, dann im Verzeichnis der Exe
    sProgramPath := ExtractFilePath(Application.ExeName)
  ;
  sFile := TPath.Combine(sProgramPath, TEST_EDITOR_FILENAME);

  TFile.WriteAllText(
    sFile,
    '--Testdatei für den Editor'                                  + CRLF +
    'BEGIN'                                                       + CRLF +
    '  DECLARE varDB_Name LONG VARCHAR;'                          + CRLF + CRLF +

    '  SELECT'                                                    + CRLF +
    '    DB_PROPERTY(''Name'')'                                   + CRLF +
    '  INTO'                                                      + CRLF +
    '    varDB_Name'                                              + CRLF +
    '  ;'                                                         + CRLF + CRLF +

    '  MESSAGE ''Aktuelle Datenbank: '' || varDB_Name TO CLIENT;' + CRLF + CRLF +

    '  IF (varDB_Name = ''Production'') THEN'                     + CRLF +
    '    EXECUTE IMMEDIATE ''DROP DATABASE '' || varDB_Name;'     + CRLF +
    '    MESSAGE ''Ups ...'' TO CLIENT;'                          + CRLF +
    '  END IF;'                                                   + CRLF + CRLF +

    '  MESSAGE ''System signed by <CSX>'' TO CLIENT;'             + CRLF +
    'END;'                                                        + CRLF
  );
end;

procedure TfrmEditorSettings.edtNameExit(Sender: TObject);
var
  eProfile : TEditorProfile;
  ii    : integer;
  sName : string;
begin
  sName := Trim(TRegEx.Replace(edtName.Text, '[^a-zA-Z0-9+\-_!?%$&<>#*~()]', ''));
  if (sName = '') then begin
    MessageDlg('Bezeichnung darf nicht leer sein!', mtError, [mbOK], 0);
    edtName.SetFocus;
    Exit;
  end;

  //Doppelte Einträge prüfen
  for ii := 0 to lbxEditors.Count - 1 do begin
    if (ii = lbxEditors.ItemIndex) then
      Continue
    ;

    eProfile := TEditorProfile(lbxEditors.Items.Objects[ii]);
    if SameText(eProfile.Name, sName) then begin
      MessageDlg('Bezeichnung existiert bereits!', mtError, [mbOK], 0);
      edtName.SetFocus;
      Exit;
    end;
  end;

  edtName.Text := sName;
  eProfile := TEditorProfile(lbxEditors.Items.Objects[lbxEditors.ItemIndex]);
  eProfile.Name := sName;
  RefreshEditorList;
end;

procedure TfrmEditorSettings.edtPathExit(Sender: TObject);
var
  eProfile : TEditorProfile;
begin
  eProfile := TEditorProfile(lbxEditors.Items.Objects[lbxEditors.ItemIndex]);
  eProfile.Path := edtPath.Text;
end;

procedure TfrmEditorSettings.chkUseEditorClick(Sender: TObject);
var
  eProfile : TEditorProfile;
  ii : integer;
begin
  if (chkUseEditor.Checked) then begin
    //Alle Profile deaktiveren
    for ii := 0 to lbxEditors.Count - 1 do begin
      eProfile := TEditorProfile(lbxEditors.Items.Objects[ii]);
      eProfile.isActive := False;
    end;

    //Aktuelles aktivieren
    eProfile := TEditorProfile(lbxEditors.Items.Objects[lbxEditors.ItemIndex]);
    eProfile.isActive := chkUseEditor.Checked;

    RefreshEditorList;
    btnDelete.Enabled := not eProfile.isActive;
  end;

  if (not chkUseEditor.Checked and not isRefreshing) then begin
    chkUseEditor.Checked := True;
    Exit;
  end;
end;

constructor TfrmEditorSettings.Create(AOwner: TComponent; var AEditorsFile: TIniFile);
begin
  inherited Create(AOwner);
  EditorsFile := AEditorsFile;
  LoadEditorList;
end;

procedure TfrmEditorSettings.FormDestroy(Sender: TObject);
var
  ii: integer;
begin
  //Listbox-Objekte wieder freigeben
  for ii := 0 to lbxEditors.Count -1 do begin
    lbxEditors.Items.Objects[ii].Free;
  end;
end;

procedure TfrmEditorSettings.lbxEditorsClick(Sender: TObject);
begin
  LoadEditorSettings;
end;

procedure TfrmEditorSettings.LoadEditorList;
var
  eProfile      : TEditorProfile;
  slSections    : TStringlist;
  sActiveEditor : String;
  sSectionName  : String;
  sEditorName   : String;
  sDisplayName  : String;
  iLbxItemIndex : integer;
begin
  isRefreshing := True;
  lbxEditors.Clear;
  iLbxItemIndex := -1;
  slSections := TStringlist.Create;
  try
    //Den aktiven Editor rauslesen
    sActiveEditor := EditorsFile.ReadString(EDITORS_SEC_EDITOR, EDITORS_KEY_ACTIVE, '');

    //Profile aus den Editorsettings auslesen
    EditorsFile.ReadSections(slSections);
    for sSectionName in slSections do begin
      //Nur Sections mit "Editor_..." berücksichtigen
      if not sSectionName.StartsWith(EDITORS_SEC_EDITOR_X) then
        Continue
      ;
      sEditorName  := Copy(sSectionName, Length(EDITORS_SEC_EDITOR_X) + 1, MaxInt);
      sDisplayName := sEditorName;

      //Profile auslesen & anzeigen
      eProfile := TEditorProfile.Create;
      with eProfile do begin
        Name      := sEditorName;
        Path      := EditorsFile.ReadString(sSectionName, EDITORS_KEY_PATH, '');
        Parameter := EditorsFile.ReadString(sSectionName, EDITORS_KEY_PARAMETER, '');
        isActive  := SameText(sActiveEditor, sSectionName);
        if (isActive) then
          sDisplayName := SELECTED_EDITOR_SYMBOL + ' ' + sDisplayName
        ;
      end;
      lbxEditors.Items.AddObject(sDisplayName, eProfile);
      inc(iLbxItemIndex);

      //Aktive-Editor selektieren
      if (eProfile.isActive) then begin
        lbxEditors.ItemIndex := iLbxItemIndex;
        LoadEditorSettings;
      end;
    end;
  finally
    slSections.Free;
    isRefreshing := False;
  end;
end;

procedure TfrmEditorSettings.RefreshEditorList;
var
  eProfile : TEditorProfile;
  ii       : integer;
  sDisplayName : String;
begin
  isRefreshing := True;
  lbxEditors.Items.BeginUpdate;
  try
    for ii := 0 to lbxEditors.Items.Count - 1 do begin
      eProfile := TEditorProfile(lbxEditors.Items.Objects[ii]);
      sDisplayName := eProfile.Name;
      if (eProfile.isActive) then
        sDisplayName := SELECTED_EDITOR_SYMBOL + ' ' + sDisplayName
      ;
      lbxEditors.Items[ii] := sDisplayName;
    end;
  finally
    lbxEditors.Items.EndUpdate;
    isRefreshing := False;
  end;
end;

procedure TfrmEditorSettings.LoadEditorSettings;
var
  eProfile : TEditorProfile;
begin
  isRefreshing := True;
  if (lbxEditors.ItemIndex >= 0) then begin
    eProfile := TEditorProfile(lbxEditors.Items.Objects[lbxEditors.ItemIndex]);
    with eProfile do begin
      edtName.Text         := Name;
      edtPath.Text         := Path;
      edtParameter.Text    := Parameter;
      chkUseEditor.Checked := isActive;
    end;
  end
  else begin
    edtName.Text         := '';
    edtPath.Text         := '';
    edtParameter.Text    := '';
    chkUseEditor.Checked := False;
  end;
  btnDelete.Enabled := not chkUseEditor.Checked;
  isRefreshing := False;
end;

end.
