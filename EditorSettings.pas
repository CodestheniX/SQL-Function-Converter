unit EditorSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IniFiles, ShellAPI, System.IOUtils,
  ConverterConst;

type
  TEditorProfile = class
    public
      Name     : String;
      Path     : String;
      isActive : boolean;
  end;

type
  TfrmEditorSettings = class(TForm)
    pnlMain: TPanel;
    pnlBot: TPanel;
    lbxEditors: TListBox;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    pnlEditors: TPanel;
    pnlProperties: TPanel;
    pnlPropertiesHeader: TPanel;
    pnlEditorsHeader: TPanel;
    lblEditors: TLabel;
    lblProperties: TLabel;
    Splitter1: TSplitter;
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
    procedure FormDestroy(Sender: TObject);
    procedure lbxEditorsClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSelectPathClick(Sender: TObject);
    procedure btnTestEditorClick(Sender: TObject);
  private
    procedure LoadEditorList;
    procedure LoadEditorSettings;
    procedure CreateTestFile(var sFile: String);
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
  eProfile : TEditorProfile;
  sBaseName: String;
  sName    : String;
  iCounter : integer;
begin
  sBaseName := 'Neuer Editor';
  sName     := sBaseName;
  iCounter  := 1;

  while lbxEditors.Items.IndexOf(sName) >= 0 do begin
    Inc(iCounter);
    sName := sBaseName + IntToStr(iCounter);
  end;

  eProfile := TEditorProfile.Create;
  with eProfile do begin
    Name     := sName;
    Path     := '';
    isActive := False;
  end;

  lbxEditors.Items.AddObject(eProfile.Name, eProfile);
  lbxEditors.ItemIndex := lbxEditors.Count - 1;
  LoadEditorSettings;
  edtName.SetFocus;
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

procedure TfrmEditorSettings.btnSelectPathClick(Sender: TObject);
begin
  if (dlgOpen.Execute) then
    edtPath.Text := dlgOpen.FileName
  ;
end;

procedure TfrmEditorSettings.btnTestEditorClick(Sender: TObject);
var
  sTempFile : String;
  hRes : HINST;
begin
  //Falls kein Systembefehl - Pfad prüfen
  if (ExtractFilePath(edtPath.Text) <> '') and (not FileExists(edtPath.Text)) then begin
    MessageDlg('Datei existiert nicht:' + CRLF + edtPath.Text, mtError, [mbOK], 0);
    Exit;
  end;

  //Temp. Test-Datei erzeugen
  CreateTestFile(sTempFile);

  //Datei im Editor öffnen
  hRes := ShellExecute(
    Handle,
    'open',
    PChar(edtPath.Text),
    PChar('"' + sTempFile + '"'),
    nil,
    SW_SHOWNORMAL
  );

  //Fehlerfall anzeigen
  if (hRes <= 32) then
    MessageDlg(
      'Editor konnte nicht gestartet werden.' + CR + SysErrorMessage(GetLastError),
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
  sFile := TPath.Combine(sProgramPath, 'Fx_EditorTest.sql');

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
  end;
end;

procedure TfrmEditorSettings.LoadEditorSettings;
var
  eProfile : TEditorProfile;
begin
  if (lbxEditors.ItemIndex >= 0) then begin
    eProfile := TEditorProfile(lbxEditors.Items.Objects[lbxEditors.ItemIndex]);
    with eProfile do begin
      edtName.Text := Name;
      edtPath.Text := Path;
      chkUseEditor.Checked := isActive;
    end;
  end
  else begin
    edtName.Text := '';
    edtPath.Text := '';
    chkUseEditor.Checked := False;
  end;
  btnDelete.Enabled := not chkUseEditor.Checked;
end;

end.
