unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids,
  ClipBrd, IniFiles, Vcl.Menus, Vcl.ExtDlgs, Vcl.Styles, Vcl.Themes, System.IOUtils, ShellAPI,
  System.RegularExpressions, EditorSettings, ConverterConst, SynEdit,
  SynEditHighlighter, SynHighlighterSQL;

type
  TfrmSQLFunctionConverter = class(TForm)
    pnlMain: TPanel;
    pnlInput: TPanel;
    pnlOutput: TPanel;
    splLeft: TSplitter;
    pnlParameter: TPanel;
    lblParameter: TLabel;
    splRight: TSplitter;
    grdParameter: TStringGrid;
    pnlInputButton: TPanel;
    btnConvert: TButton;
    pnlOutputButton: TPanel;
    btnOpenOutput: TButton;
    pnlParameterButton: TPanel;
    btnRefresh: TButton;
    menMain: TMainMenu;
    mitDatei: TMenuItem;
    mitLoadScript: TMenuItem;
    mitSaveOutput: TMenuItem;
    lblInput: TLabel;
    lblOutput: TLabel;
    mitOptionen: TMenuItem;
    mitStyles: TMenuItem;
    N1: TMenuItem;
    mitAdjustColumn: TMenuItem;
    mitShowComments: TMenuItem;
    mitReturnToSelect: TMenuItem;
    N2: TMenuItem;
    dlgSave: TSaveTextFileDialog;
    dlgOpen: TOpenDialog;
    mitBearbeiten: TMenuItem;
    mitConvert: TMenuItem;
    mitRefresh: TMenuItem;
    mitClearConfig: TMenuItem;
    mitEditorConfig: TMenuItem;
    mitConvertComments: TMenuItem;
    mitOpenConfigPath: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    synInput: TSynEdit;
    SynSQLHighlighter: TSynSQLSyn;
    synOutput: TSynEdit;
    procedure btnConvertClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mitLoadScriptClick(Sender: TObject);
    procedure btnOpenOutputClick(Sender: TObject);
    procedure mitStyleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure grdParameterSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure btnRefreshClick(Sender: TObject);
    procedure grdParameterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mitAdjustColumnClick(Sender: TObject);
    procedure mitShowCommentsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure grdParameterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure mitReturnToSelectClick(Sender: TObject);
    procedure mitSaveOutputClick(Sender: TObject);
    procedure mitClearConfigClick(Sender: TObject);
    procedure grdParameterDblClick(Sender: TObject);
    procedure mitEditorConfigClick(Sender: TObject);
    procedure mitConvertCommentsClick(Sender: TObject);
    procedure mitOpenConfigPathClick(Sender: TObject);
  private
    ConfigFile : TIniFile; //Konfigurationen für die Main-Form
    EditorsFile: TIniFile; //Hinterlegte Editoren & aktiver Editor
    iLastRow : integer;
    iLastCol : integer;
    function AdjustColumn(iCol : integer): integer;
    function GetOffset(sText: String; checkDatatype: boolean): integer;
    function GetLineWithoutComment(sLine: String): String;
    function GetOutParameterList: TStringlist;
    function GetAppFilePath(sFilename: String): String;
    function GetActiveEditorProperty(sSection : String): String;
    function FindEditorExe(const sExeName: string): string;
    procedure InitForm;
    procedure InitGrid(FillHeader : boolean);
    procedure InitStyles;
    procedure InitEditors;
    procedure ApplySynEditTheme;
    procedure ParameterToGrid;
    procedure GridParameterToOutput;
    procedure ExtractComment(var sParameter, sComment: String);
    procedure WriteVariableRow(sParameter: String);
    procedure AdjustGrid;
    procedure HandleCommentColumnVisibility;
    procedure SetSavefileName;
    procedure InsertParameterToStatement(var slStatement: TStringlist);
    procedure CreateOutputSection(var slStatement: TStringlist);
  end;

var
  frmSQLFunctionConverter: TfrmSQLFunctionConverter;

implementation

{$R *.dfm}

function TfrmSQLFunctionConverter.AdjustColumn(iCol : integer) : integer;
var
  iRow : integer;
  iMaxWidth  : integer;
  iTextWidth : integer;
begin
  with grdParameter do begin
    if (iCol <> COL_DIRECTION) then
      iMaxWidth := MIN_COL_WIDTH
    else
      iMaxWidth := MIN_COL_WIDTH_DIRECTION
    ;
    if (RowCount > 0) then begin
      for iRow := 1 to RowCount -1 do begin
        iTextWidth := Canvas.TextWidth(Cells[iCol, iRow]) + GridLineWidth + 10;
        if (iTextWidth > iMaxWidth) then begin
          iMaxWidth := iTextWidth;
        end;
      end;
      ColWidths[iCol] := iMaxWidth;
    end;
  end;
  Result := iMaxWidth;
end;

procedure TfrmSQLFunctionConverter.AdjustGrid;
var
  iCol        : integer;
  iMaxWidth   : integer;
  iPanelWidth : integer;
begin
  with grdParameter do begin
    //Setzen des Headers
    if (RowCount > 1) then
      FixedRows := 1
    ;
    //Anpassung der Spaltenbreiten an die Länge des Inhalts - Nur bis Wert
    iPanelWidth := 0;
    for iCol := 0 to COL_VALUE do begin
      iMaxWidth   := AdjustColumn(iCol);
      iPanelWidth := iPanelWidth + iMaxWidth;
    end;

    //Kommentar-Spalte fix setzen
    if (mitShowComments.Checked) then begin
      ColWidths[COL_COMMENT] := MIN_COL_WIDTH;
      iPanelWidth := iPanelWidth + ColWidths[COL_COMMENT];
    end;

    //Panel anpassen
    pnlParameter.Width := iPanelWidth + 25;
  end;
end;

procedure TfrmSQLFunctionConverter.ApplySynEditTheme;
var
  clFontColor: TColor;
begin
  clFontColor := StyleServices.GetStyleFontColor(sfEditBoxTextNormal);

  //Editor
  synInput.Color := StyleServices.GetStyleColor(scEdit);
  synInput.Font.Color := clFontColor;

  synOutput.Color := synInput.Color;
  synOutput.Font.Color := clFontColor;

  //synInput.SelectedColor.Foreground := StyleServices.GetSystemColor(clHighlightText); -> Geht nicht, da der Highlighter das überschreibt...
  synInput.SelectedColor.Background  := StyleServices.GetSystemColor(clHighlight);
  synOutput.SelectedColor.Background := synInput.SelectedColor.Background;

  //Rand (Gutter)
  synInput.Gutter.Color := StyleServices.GetStyleColor(scPanel);
  synInput.Gutter.BorderColor := StyleServices.GetSystemColor(clWindow);
  synInput.Gutter.Font.Color  := clFontColor;

  synOutput.Gutter.Color := synInput.Gutter.Color;
  synOutput.Gutter.BorderColor := synInput.Gutter.BorderColor;
  synOutput.Gutter.Font.Color  := clFontColor;
end;

procedure TfrmSQLFunctionConverter.mitClearConfigClick(Sender: TObject);
begin
  if (GetKeyState(VK_SHIFT) < 0) then begin
    //Bei gedrückter SHIFT-Taste die Config im Editor öffnen (To-Know: Wird nach dem Verlassen des Programms überschrieben!)
    if (FileExists(ConfigFile.FileName)) then
      ShellExecute(
        0,
        'open',
        PChar(ConfigFile.FileName),
        nil,
        nil,
        SW_SHOWNORMAL
      )
    else
      MessageDlg('Konfigurationsdatei nicht gefunden!', TMsgDlgType.mtError, [mbOK], 0)
    ;
  end
  else begin
    if (MessageDlg('Achtung | Soll die Konfiguration zurückgesetzt werden?' , TMsgDlgType.mtConfirmation, mbYesNo, 0) = mrYes) then begin
      with ConfigFile do begin
        EraseSection(CONFIG_SEC_FORM);
        EraseSection(CONFIG_SEC_OUTPUT);
      end;
      TStyleManager.SetStyle(DEFAULT_STYLE);
      InitForm;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.mitConvertCommentsClick(Sender: TObject);
begin
  mitConvertComments.Checked := not mitConvertComments.Checked;
  ConfigFile.WriteBool(CONFIG_SEC_OUTPUT, CONFIG_KEY_CONVERTCOMMENTS, mitConvertComments.Checked);
end;

procedure TfrmSQLFunctionConverter.btnConvertClick(Sender: TObject);
begin
  //Konvert der Parameter ins Grid
  ParameterToGrid;

  //Möglichen Dateinamen ermitteln
  SetSavefileName;

  //Die Spalte "Wert" in der ersten Zeile selektieren
  with grdParameter do begin
    Col := COL_VALUE;
    if (RowCount > 1) then
      Row := 1
    ;
    SetFocus;
  end;
end;

//#DankeGemini...
function TfrmSQLFunctionConverter.FindEditorExe(const sExeName: String): String;
var
  slBaseFolders: TStringList;
  sFolder, sFoundPath: string;

  function SearchInSubDirs(const sRoot, sTargetExe: String): String;
  var
    SR: TSearchRec;
  begin
    Result := '';
    //1. Direkt im Root prüfen
    if FileExists(sRoot + '\' + sTargetExe) then
      Exit(sRoot + '\' + sTargetExe)
    ;

    //2.In den Unterordnern suchen (nur 1 Ebene tief für Performance)
    if FindFirst(sRoot + '\*', faDirectory, SR) = 0 then begin
      try
        repeat
          if (SR.Attr and faDirectory <> 0) and (SR.Name <> '.') and (SR.Name <> '..') then begin
            if FileExists(sRoot + '\' + SR.Name + '\' + sTargetExe) then begin
              Result := sRoot + '\' + SR.Name + '\' + sTargetExe;
              Break;
            end;
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;

begin
  Result := '';
  slBaseFolders := TStringList.Create;
  try
    slBaseFolders.Add(GetEnvironmentVariable('WinDir') + '\System32');
    slBaseFolders.Add(GetEnvironmentVariable('ProgramW6432'));
    slBaseFolders.Add(GetEnvironmentVariable('ProgramFiles(x86)'));
    slBaseFolders.Add(GetEnvironmentVariable('LocalAppData') + '\Programs');

    for sFolder in slBaseFolders do begin
      if (sFolder <> '') and (DirectoryExists(sFolder)) then begin
        sFoundPath := SearchInSubDirs(sFolder, sExeName);
        if (sFoundPath <> '') then begin
          Result := sFoundPath;
          Break;
        end;
      end;
    end;
  finally
    slBaseFolders.Free;
  end;
end;

procedure TfrmSQLFunctionConverter.InitEditors;
const
  //Liste aller initialen Editoren & der passenden Bezeichnungen
  EDITOR_EXES     : array[0..2] of String = ('notepad.exe', 'notepad++.exe', 'code.exe');
  EDITOR_INI_NAMES: array[0..2] of String = ('Editor_Notepad', 'Editor_Notepad++', 'Editor_vsCode');
var
  ii: integer;
  sFoundPath: string;
  isStandardSet: boolean;
begin
  if not FileExists(EditorsFile.FileName) then begin
    isStandardSet := False;
    //Definierte Editoren durchsuchen
    for ii := Low(EDITOR_EXES) to High(EDITOR_EXES) do begin
      sFoundPath := FindEditorExe(EDITOR_EXES[ii]);
      if (sFoundPath <> '') then begin
        //Ersten Editor als Standard setzen
        if (not isStandardSet) then begin
          EditorsFile.WriteString(EDITORS_SEC_EDITOR, EDITORS_KEY_ACTIVE, EDITOR_INI_NAMES[ii]);
          isStandardSet := True;
        end;
        EditorsFile.WriteString(EDITOR_INI_NAMES[ii], EDITORS_KEY_PATH, sFoundPath);
        EditorsFile.WriteString(EDITOR_INI_NAMES[ii], EDITORS_KEY_PARAMETER, '');
      end;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.InitForm;
begin
  with ConfigFile do begin
    //Menü
    mitShowComments.Checked    := ReadBool(CONFIG_SEC_FORM  , CONFIG_KEY_SHOWCOMMENTS   , true);
    mitReturnToSelect.Checked  := ReadBool(CONFIG_SEC_OUTPUT, CONFIG_KEY_RETURNTOSELECT , true);
    mitConvertComments.Checked := ReadBool(CONFIG_SEC_OUTPUT, CONFIG_KEY_CONVERTCOMMENTS, true);

    //Form
    frmSQLFunctionConverter.Width  := ReadInteger(CONFIG_SEC_FORM, CONFIG_KEY_WIDTH , FRM_WIDTH);
    frmSQLFunctionConverter.Height := ReadInteger(CONFIG_SEC_FORM, CONFIG_KEY_HEIGHT, FRM_HEIGHT);

    //Panels
    pnlInput.Width     := ReadInteger(CONFIG_SEC_FORM, CONFIG_KEY_PNLINPUTWIDTH    , PNL_INPUT_WIDTH);
    pnlParameter.Width := ReadInteger(CONFIG_SEC_FORM, CONFIG_KEY_PNLPARAMETERWIDTH, PNL_PARAMETER_WIDTH);
    pnlOutput.Width    := ReadInteger(CONFIG_SEC_FORM, CONFIG_KEY_PNLOUTPUTWIDTH   , PNL_OUTPUT_WIDTH);
  end;

  //Parameter-Grid
  InitGrid(True);

  //Styles
  InitStyles;
  ApplySynEditTheme;

  //Falls was drin steht - Direkt konvertieren
  btnConvert.OnClick(self);
end;

procedure TfrmSQLFunctionConverter.InitGrid(FillHeader : boolean);
var
  iRow: integer;
begin
  with grdParameter do begin
    //Initalisierung des Grids
    if (FillHeader) then begin
      RowCount  := 2;
      FixedRows := 1;
      Cells[COL_DIRECTION, 0] := 'Art';
      Cells[COL_NAME     , 0] := 'Bezeichnung';
      Cells[COL_DATATYPE , 0] := 'Datentyp';
      Cells[COL_VALUE    , 0] := 'Wert';
      Cells[COL_COMMENT  , 0] := 'Kommentar';
    end
    else begin
      for iRow := 1 to RowCount do begin
        Rows[iRow].Clear;
      end;
      RowCount := 1;
    end;
  end;
  HandleCommentColumnVisibility;
end;

procedure TfrmSQLFunctionConverter.InitStyles;
var
  sStyle    : String;
  slStyles  : TStringlist;
  mMenueItem: TMenuItem;
begin
  slStyles := TStringList.Create;
  try
    slStyles.Sorted := True;
    mitStyles.Clear;
    for sStyle in TStyleManager.StyleNames do begin
      slStyles.Add(sStyle);
    end;

    for sStyle in slStyles do begin
      mMenueItem := TMenuItem.Create(mitStyles);
      mMenueItem.Caption := sStyle;
      mMenueItem.OnClick := mitStyleClick;
      if (TStyleManager.ActiveStyle.Name = sStyle) then
        mMenueItem.Checked := True
      ;
      mitStyles.Add(mMenueItem);
    end;
  finally
    slStyles.Free;
  end;
end;

procedure TfrmSQLFunctionConverter.InsertParameterToStatement(var slStatement: TStringlist);
var
  slDeclares     : TStringlist;
  slSets         : TStringlist;
  ii             : integer;
  iPosLastDeclare: integer;
  sCurrentLine   : String;
  sName          : String;
  sDatatype      : String;
  sValue         : String;
begin
  slDeclares := TStringList.Create;
  slSets     := TStringList.Create;
  try
    //Ermittlung vom letzten "DECLARE"
    //Wichtig: Funktioniert sicherlich nicht in allen Varianten einwandfrei!
    ii := 0;
    iPosLastDeclare := 0;
    while ii < slStatement.Count do begin
      sCurrentLine := GetLineWithoutComment(Trim(slStatement[ii]));
      if (sCurrentLine.StartsWith(DECLARE, True)) then begin
        //Mehrere Zeilen prüfen wegen Local Temp. Tables
        while (ii < slStatement.Count) and not sCurrentLine.EndsWith(';') do begin
          Inc(ii);
          sCurrentLine := GetLineWithoutComment(Trim(slStatement[ii]));
        end;
        iPosLastDeclare := ii;
      end;
      Inc(ii);
    end;

    //DECLAREs & SETs für die Parameter aus dem Grid erzeugen
    with grdParameter do begin
      for ii := 1 to RowCount - 1 do begin
        sName     := Trim(Cells[COL_NAME, ii]);
        sDatatype := Trim(Cells[COL_DATATYPE, ii]);
        sValue    := Trim(Cells[COL_VALUE, ii]);

        slDeclares.Add(Format('  DECLARE %s %s;', [sName, sDatatype]));
        if (sValue <> '') then
          slSets.Add(Format('  SET %s = %s;', [sName, sValue]))
        ;
      end;
    end;

    //Falls DECLAREs vorhanden -> Block einfügen
    with slDeclares do begin
      if (Count > 0) then begin
        Insert(0, CRLF + '  --Start: DECLARE der Parameter');
        Add('  --Ende: DECLARE der Parameter' + CRLF);
        for ii := 0 to Count - 1 do begin
          slStatement.Insert(iPosLastDeclare + 1 + ii, slDeclares[ii]);
        end;
      end;
    end;

    //Falls SETs vorhanden -> Block einfügen
    with slSets do begin
      if (Count > 0) then begin
        iPosLastDeclare := iPosLastDeclare + slDeclares.Count;
        Insert(0, '  --Start: SET der Parameter');
        Add('  --Ende: SET der Parameter' + CRLF);
        for ii := 0 to Count - 1 do begin
          slStatement.Insert(iPosLastDeclare + 1 + ii, slSets[ii]);
        end;
      end;
    end;

  finally
    slDeclares.Free;
    slSets.Free;
  end;
end;

procedure TfrmSQLFunctionConverter.mitAdjustColumnClick(Sender: TObject);
begin
  AdjustColumn(grdParameter.Col);
end;

procedure TfrmSQLFunctionConverter.mitLoadScriptClick(Sender: TObject);
begin
  if (dlgOpen.Execute) then begin
    try
      try
        //Versuch die Datei als UTF-8 zu laden
        synInput.Lines.LoadFromFile(dlgOpen.FileName, TEncoding.UTF8);
      except
        //Wenn das nicht klappt - Im Default (ANSI) laden
        synInput.Lines.LoadFromFile(dlgOpen.FileName);
      end;
      btnConvert.OnClick(self);
    except
      on E: Exception do begin
        MessageDlg('Fehler beim Laden der Datei!', TMsgDlgType.mtError, [mbOK], 0);
      end;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.mitOpenConfigPathClick(Sender: TObject);
var
  sPath: String;
begin
  if (not assigned(ConfigFile)) then
    Exit
  ;
  sPath := ExtractFilePath(ConfigFile.FileName);

  if (not DirectoryExists(sPath)) then begin
    MessageDlg('Verzeichnis existiert nicht!', mtError, [mbOK], 0);
    Exit;
  end;
  ShellExecute(Handle, 'open', PChar(sPath), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmSQLFunctionConverter.mitSaveOutputClick(Sender: TObject);
begin
  if (dlgSave.Execute) then begin
    synOutput.Lines.SaveToFile(dlgSave.FileName, TEncoding.UTF8);
  end;
end;

procedure TfrmSQLFunctionConverter.mitEditorConfigClick(Sender: TObject);
var
  fEditorSettings: TfrmEditorSettings;
begin
  if (GetKeyState(VK_SHIFT) < 0) then begin
    //Bei gedrückter SHIFT-Taste die Editorsettings im Editor öffnen
    if (FileExists(EditorsFile.FileName)) then
      ShellExecute(
        0,
        'open',
        PChar(EditorsFile.FileName),
        nil,
        nil,
        SW_SHOWNORMAL
      )
    else
      MessageDlg('Editorsettings nicht gefunden!', TMsgDlgType.mtError, [mbOK], 0)
    ;
  end
  else begin
    fEditorSettings := TfrmEditorSettings.Create(Self, EditorsFile);
    try
      fEditorSettings.ShowModal;
    finally
      fEditorSettings.Free;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.mitReturnToSelectClick(Sender: TObject);
begin
  mitReturnToSelect.Checked := not mitReturnToSelect.Checked;
  ConfigFile.WriteBool(CONFIG_SEC_OUTPUT, CONFIG_KEY_RETURNTOSELECT, mitReturnToSelect.Checked);
end;

procedure TfrmSQLFunctionConverter.mitShowCommentsClick(Sender: TObject);
begin
  mitShowComments.Checked := not mitShowComments.Checked;
  HandleCommentColumnVisibility;
  ConfigFile.WriteBool(CONFIG_SEC_FORM, CONFIG_KEY_SHOWCOMMENTS, mitShowComments.Checked);
end;

procedure TfrmSQLFunctionConverter.mitStyleClick(Sender: TObject);
var
  sStyle : String;
  ii     : integer;
begin
  if (MessageDlg('Achtung | Beim Wechseln des Styles wird die Form neugeladen.' + CRLF + 'Soll der Style gewechselt werden?' , TMsgDlgType.mtWarning, mbYesNo, 0) = mrYes) then begin
    sStyle := StringReplace(TMenuItem(Sender).Caption, '&', '', [rfReplaceAll, rfIgnoreCase]);
    TStyleManager.SetStyle(sStyle);
    (Sender as TMenuItem).Checked := True;
    for ii := 0 to mitStyles.Count -1 do begin
    if (not mitStyles.Items[ii].Equals(Sender)) then
      mitStyles.Items[ii].Checked := False;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.WriteVariableRow(sParameter: String);
var
  iPosStart : integer;
  iPosEnd   : integer;
  sName     : String;
  sDatatype : String;
  sValue    : String;
  sComment  : String;
  sDirection: String;
begin
  ExtractComment(sParameter, sComment);
  if (sParameter <> '') and (Length(sParameter) > 5) then begin
    //Die "Richtung"/Art des Parameters (IN / INOUT / OUT) - Vom Anfang bis zum ersten Leerzeichen
    iPosStart := 0;
    iPosEnd := Pos(PARAMETER_START, sParameter, 1);
    //Nichts gefunden? Dann ist es standardmäßig ein "IN"
    if (iPosEnd <> 1) then
      sDirection := Trim(Copy(sParameter, iPosStart, iPosEnd - 1))
    else
      sDirection := 'IN'
    ;
    sParameter := Trim(Copy(sParameter, iPosEnd, sParameter.Length));

    //Die Bezeichnung - Vom @ bis zum ersten Leerzeichen
    iPosStart  := sParameter.IndexOf(PARAMETER_START);
    iPosEnd    := Pos(' ', sParameter, iPosStart + 1);
    sName      := Trim(Copy(sParameter, iPosStart, iPosEnd));
    sParameter := Trim(Copy(sParameter, iPosEnd, sParameter.Length));

    //Der Default-Wert - Vom Wort "DEFAULT" bis zum Ende (- Offset)
    iPosStart := UpperCase(sParameter).IndexOf(DEFAULT_START);
    if (iPosStart > 0) then begin
      iPosStart  := iPosStart + Length(DEFAULT_START);
      iPosEnd    := Length(sParameter) - GetOffset(sParameter, false);
      sValue     := Trim(Copy(sParameter, iPosStart, iPosEnd - iPosStart + 1));
      sParameter := Trim(Copy(sParameter, 1, iPosStart - Length(DEFAULT_START)));
    end;

    //Der Datentyp - Vom Ende der Bezeichnung bis zum Wort "Default" oder bis zum Ende
    iPosStart := 0;
    iPosEnd   := sParameter.Length - GetOffset(sParameter, true);
    sDatatype := Trim(Copy(sParameter, iPosStart, iPosEnd));

    //Zum Schluss noch alle Werte in die Grid-Zeile packen
    with grdParameter do begin
      RowCount := RowCount + 1;
      Cells[COL_DIRECTION, RowCount -1] := sDirection;
      Cells[COL_NAME     , RowCount -1] := sName;
      Cells[COL_DATATYPE , RowCount -1] := sDatatype;
      Cells[COL_VALUE    , RowCount -1] := sValue;
      Cells[COL_COMMENT  , RowCount -1] := sComment;
    end;
    Application.ProcessMessages;
  end;
end;

function TfrmSQLFunctionConverter.GetOffset(sText: String; checkDatatype: boolean): integer;
begin
  //Überprüfen, ob der Text mit ',' endet oder ...
  Result := 0;
  if (sText.EndsWith(',')) then
    Result := 1
  ;

  //mit ')' endet
  if (sText.EndsWith(')')) then begin
    Result := 1;
    if (sText.Length > 1) then begin
      if (checkDatatype and CharInSet(sText[sText.Length - 1], ['0'..'9']))// Wird nach dem Datentypen geschaut, soll das Offset wieder entfernt werden, falls das vorletzte Zeichen nummerisch ist. Grund: VARCHAR(x)
      or (not checkDatatype and CharInSet(sText[sText.Length - 1], ['('])) // Wird nicht nach dem Datentypen geschaut (Default), soll das Offset wieder entfernt werden, falls das vorletzte Zeichen '(' ist. Grund: TODAY()
      then
        Result := 0
      ;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.grdParameterDblClick(Sender: TObject);
var
  currentPoint: TPoint;
  iCol, iRow: Integer;
begin
  //Geklickte Zelle ermitteln
  currentPoint := grdParameter.ScreenToClient(Mouse.CursorPos);
  grdParameter.MouseToCell(currentPoint.X, currentPoint.Y, iCol, iRow);

  //Spaltenbreite anpassen, falls Klick in Überschriftszeile
  if (iRow = 0) then
    AdjustColumn(iCol);
end;


procedure TfrmSQLFunctionConverter.grdParameterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  iNextRow : integer;
begin
  with grdParameter do begin
    //Bei ENTER die nächste Zeile selektieren
    if (Key = VK_RETURN) then begin
      if RowCount > 1 then begin
        if EditorMode then
          EditorMode := False
        ;
        Application.ProcessMessages;

        iNextRow := Row + 1;
        if iNextRow >= RowCount then
          iNextRow := 1
        ;
        Row := iNextRow;
        Key := 0;
      end;
    end;

    //Bei ENTFERNEN die Zelle leeren
    if (Key = VK_DELETE) and (not EditorMode) then begin
      Cells[Col, Row] := '';
    end;

    //Bei F1 die Breite der Column auf den max. Wert setzen
    if (Key = VK_F1) then begin
      AdjustColumn(grdParameter.Col);
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.grdParameterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  iCol : integer;
  iRow : integer;
begin
  //Inhalt als Hint anzeigen - Wichtig bei Kommentaren
  with grdParameter do begin
    MouseToCell(X, Y, iCol, iRow);
    if (iCol <> -1) and (iRow <> -1) then
      Hint := Cells[iCol, iRow]
    ;

    if (iLastCol <> iCol) or (iLastRow <> iRow) then begin
      Application.CancelHint;
      iLastCol := iCol;
      iLastRow := iRow;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.grdParameterSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if (aRow = 0) then
    grdParameter.Options := grdParameter.Options - [goEditing]
  else
    grdParameter.Options := grdParameter.Options + [goEditing]
  ;
end;

procedure TfrmSQLFunctionConverter.GridParameterToOutput;
var
  slStatement : TStringList;
  iPosStart   : integer;
begin
  slStatement := TStringList.Create;
  try
    //Alles vor dem BEGIN kicken
    slStatement.Text := synInput.Text;
    iPosStart := Pos(PROCEDURE_START, UpperCase(slStatement.Text));
    slStatement.Text := Trim(Copy(slStatement.Text, iPosStart, Length(slStatement.Text)));

    //DECLARE & SET-Blöcke erstellen
    InsertParameterToStatement(slStatement);

    //RETURN / INOUT/OUT-Parameter in SELECT umwandeln
    if (mitReturnToSelect.Checked) then
      CreateOutputSection(slStatement)
    ;

    //Kommentare konvertieren: //** in --
    if (mitConvertComments.Checked) then begin
      //slStatement.Text := StringReplace(slStatement.Text, '//***', '--', [rfReplaceAll]);
      //slStatement.Text := StringReplace(slStatement.Text, '//**' , '--', [rfReplaceAll]);
      slStatement.Text := TRegEx.Replace(slStatement.Text,'//\*+', '--');
    end;

    synOutput.Lines.Assign(slStatement);
  finally
    slStatement.Free;
  end;
end;

procedure TfrmSQLFunctionConverter.HandleCommentColumnVisibility;
begin
  if (mitShowComments.Checked) then
    grdParameter.ColWidths[COL_COMMENT] := MIN_COL_WIDTH
  else
    grdParameter.ColWidths[COL_COMMENT] := 0
  ;
end;

procedure TfrmSQLFunctionConverter.btnOpenOutputClick(Sender: TObject);
var
  hRes: HINST;
  sOutputFile  : String;
  sParameters  : String;
  sActiveEditor: String;
begin
  //Ausgabe im Standard-Editor öffnen
  sActiveEditor := GetActiveEditorProperty(EDITORS_KEY_PATH);
  if (Trim(sActiveEditor) = '') then begin
    MessageDlg('Standard-Editor nicht gefunden!', TMsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;

  sOutputFile := GetAppFilePath(OUTPUT_FILENAME);
  sParameters := GetActiveEditorProperty(EDITORS_KEY_PARAMETER) + ' "' + sOutputFile + '"';
  TFile.WriteAllText(sOutputFile, synOutput.Lines.Text);

  //Datei im Editor öffnen
  hRes := ShellExecute(
    Handle,
    'open',
    PChar(sActiveEditor),
    PChar(sParameters),
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
//  with Clipboard do begin
//    Clear;
//    AsText := synOutput.Text;
//  end;
end;

procedure TfrmSQLFunctionConverter.btnRefreshClick(Sender: TObject);
begin
  //Übernahme des Grid-Parameter in die Ausgabe & Fokus auf den Button "Kopieren" setzen
  GridParameterToOutput;
  btnOpenOutput.SetFocus;
end;

function TfrmSQLFunctionConverter.GetOutParameterList: TStringlist;
var
  ii   : integer;
  sName: String;
begin
  Result := TStringList.Create;
  Result.Delimiter := ',';
  Result.StrictDelimiter := True;
  //Grid durchlaufen und die OUT-Parameter holen
  with grdParameter do begin
    for ii := 1 to RowCount - 1 do begin
      if (UpperCase(Trim(Cells[COL_DIRECTION, ii])) = 'OUT')
      or (UpperCase(Trim(Cells[COL_DIRECTION, ii])) = 'INOUT')
      then begin
        sName := Trim(Cells[COL_NAME, ii]);
        if (sName <> '') then
          Result.Add(sName)
        ;
      end;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.CreateOutputSection(var slStatement: TStringlist);
var
  ii: integer;
  iPosEnd: integer;
  returnFound: boolean;
  sLine: String;
  sOutParameter: String;
begin
  //OUT-Parameter zusammensetzen
  sOutParameter := GetOutParameterList.DelimitedText;
  if (sOutParameter <> '') then
    sOutParameter := StringReplace(sOutParameter, ',', ', ', [rfReplaceAll]) + ';' + CRLF
  ;
  returnFound := False;
  iPosEnd := 1;
  for ii := 0 to slStatement.Count - 1 do begin
    sLine := slStatement[ii];
    if (Trim(sLine).StartsWith('RETURN', True)) then begin
      returnFound := True;
      //Kommentar kicken & RETURN durch SELECT ersetzen
      sLine := StringReplace(GetLineWithoutComment(sLine), 'RETURN', 'SELECT', [rfReplaceAll, rfIgnoreCase]);

      //Falls es noch OUT-Parameter gibt, dann diese anhängen
      if (sOutParameter <> '') then
        sLine := sLine.TrimRight([';']) + ', ' + sOutParameter
      ;
      slStatement[ii] := sLine;
    end;

    //Direkt die Position des letzten END speichern, falls man sie unten benötigt
    if (Trim(sLine).StartsWith('END', True)) then
      iPosEnd := ii;
    ;
  end;

  //Wurde kein RETURN gefunden, wird bei vorhandenen OUT-Parametern das SELECT vor dem letzten END eingefügt
  if (not returnFound) and (sOutParameter <> '') then begin
    //Nicht die beste Lösung, aber nur hinzufügen, wenn es tatsächlich eins der letzten ENDs ist
    if (iPosEnd > slStatement.Count - 3) then
      slStatement.Insert(iPosEnd, 'SELECT ' + sOutParameter)
    ;
  end;
end;

procedure TfrmSQLFunctionConverter.ExtractComment(var sParameter, sComment : String);
var
  iPos: integer;
begin
  //Kommentare speichern und kicken
  iPos := sParameter.IndexOf('//');
  if (iPos = -1) then
    iPos := sParameter.IndexOf('/*')
  ;
  if (iPos = -1) then
    iPos := sParameter.IndexOf('--')
  ;

  if (iPos <> -1) then begin
    //Kommentar rausholen und ...
    sComment := Trim(Copy(sParameter, iPos, sParameter.Length));
    //rauslöschen
    sParameter := Trim(Copy(sParameter, 0, iPos - 1));
  end;
end;

function TfrmSQLFunctionConverter.GetActiveEditorProperty(sSection : String): String;
var
  sActiveEditor: String;
begin
  Result := '';
  if not Assigned(EditorsFile) or (not FileExists(EditorsFile.FileName)) then
    Exit
  ;
  sActiveEditor := EditorsFile.ReadString(EDITORS_SEC_EDITOR, EDITORS_KEY_ACTIVE, '');
  if (Trim(sActiveEditor) <> '') then
    Result := EditorsFile.ReadString(sActiveEditor, sSection, '')
  ;
end;

function TfrmSQLFunctionConverter.GetAppFilePath(sFilename: String): String;
var
  sPath: String;
begin
  //Versuchen die Config standardmäßig in %APPDATA% zu speichern
  sPath := TPath.Combine(GetEnvironmentVariable('APPDATA'), PROGRAMM_NAME);
  if (not ForceDirectories(sPath)) then
    //Falls das nicht geht, dann im Verzeichnis der Exe
    sPath := ExtractFilePath(Application.ExeName)
  ;

  Result := TPath.Combine(sPath, sFilename);
end;

function TfrmSQLFunctionConverter.GetLineWithoutComment(sLine: String) : String;
var
  iPos: integer;
begin
  //Kommentar suchen und...
  iPos := sLine.IndexOf('//');
  if (iPos = -1) then
    iPos := sLine.IndexOf('/*')
  ;
  if (iPos = -1) then
    iPos := sLine.IndexOf('--')
  ;

  //aus dem Text/der Zeile entfernen
  if (iPos <> -1) then
    sLine := Trim(Copy(sLine, 1, iPos))
  ;

  Result := sLine;
end;

procedure TfrmSQLFunctionConverter.ParameterToGrid;
var
  slParameter       : TStringlist;
  aParameter        : TArray<String>;
  sParameterHeader  : String;
  iPosStart, iPosEnd: integer;
  ii                : integer;
begin
  InitGrid(False);
  //Zuerst den Anfang und das Ende des Kopf ermitteln & die Paramter rausfiltern
  //Unschön, aber wir machen´s so - Zuerst nach dem ersten @ suchen und dann von der Stelle rückwärts nach der ersten "(" suchen wg. IN/OUT
  iPosStart := Pos(PARAMETER_START, synInput.Text, 1);
  while (iPosStart > 0) and (synInput.Text[iPosStart] <> '(') do begin
    Dec(iPosStart);
  end;
  iPosEnd := Pos(FUNCTION_END, UpperCase(synInput.Text), 1) - iPosStart;
  if (iPosEnd <= 0) then
    iPosEnd := Pos(PROCEDURE_START, UpperCase(synInput.Text), 1) - iPosStart
  ;

  if (iPosStart <> 0) and (iPosEnd <> 0) then begin
    sParameterHeader := Copy(synInput.Text, iPosStart + 1, iPosEnd);
    slParameter := TStringList.Create;
    try
      slParameter.Delimiter := ',';
      with slParameter do begin
        Clear;
        Add(
          Trim(
            StringReplace(
              sParameterHeader,
              CR,
              CRLF,
              [rfReplaceAll]
            )
          )
        );
      end;

      //Die Parameter anhand des Carrige Returns & Linefeeds splitten & ins Grid packen
      aParameter := slParameter.Text.Split([CRLF]);
      for ii := 0 to Length(aParameter) - 1 do begin
        WriteVariableRow(Trim(aParameter[ii]));
      end;
      AdjustGrid;
      GridParameterToOutput;
    finally
      slParameter.Free;
    end;
  end;
end;

procedure TfrmSQLFunctionConverter.SetSavefileName;
var
  iPosStart, iPosEnd: integer;
  aFilename : String;
begin
  frmSQLFunctionConverter.Caption := PROGRAMM_NAME;
  //Prüfen, ob es sich um eine Funktion oder Prozedur handelt und alles davor entfernen
  iPosStart := UpperCase(synInput.Text).IndexOf(CREATE_FUNCTION);
  if (iPosStart > -1) then
    iPosStart := iPosStart + Length(CREATE_FUNCTION)
  else
    iPosStart := UpperCase(synInput.Text).IndexOf(CREATE_PROCEDURE) + Length(CREATE_PROCEDURE)
  ;
  aFilename := Trim(Copy(synInput.Text, iPosStart, 50));

  //Nach der ersten offenen Klammer suchen und alles dazwischen als Filename speichern
  iPosEnd   := UpperCase(aFilename).IndexOf('(');
  aFilename := Trim(Copy(aFilename, 1, iPosEnd));

  if (Trim(aFilename) = '') then
    aFilename := 'Output'
  else
    frmSQLFunctionConverter.Caption := PROGRAMM_NAME + ' | ' + aFilename;
  ;

  dlgSave.FileName := aFilename;
end;

procedure TfrmSQLFunctionConverter.FormShow(Sender: TObject);
begin
  InitForm;
end;

procedure TfrmSQLFunctionConverter.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with ConfigFile do begin
    WriteString (CONFIG_SEC_FORM, CONFIG_KEY_STYLE            , TStyleManager.ActiveStyle.Name);
    WriteInteger(CONFIG_SEC_FORM, CONFIG_KEY_WIDTH            , frmSQLFunctionConverter.Width);
    WriteInteger(CONFIG_SEC_FORM, CONFIG_KEY_HEIGHT           , frmSQLFunctionConverter.Height);
    WriteInteger(CONFIG_SEC_FORM, CONFIG_KEY_PNLINPUTWIDTH    , pnlInput.Width);
    WriteInteger(CONFIG_SEC_FORM, CONFIG_KEY_PNLPARAMETERWIDTH, pnlParameter.Width);
    WriteInteger(CONFIG_SEC_FORM, CONFIG_KEY_PNLOUTPUTWIDTH   , pnlOutput.Width);
  end;
end;

procedure TfrmSQLFunctionConverter.FormCreate(Sender: TObject);
begin
  //Konfigurationsdateien erstellen
  ConfigFile := TIniFile.Create(GetAppFilePath(CONFIG_FILENAME));
  EditorsFile:= TIniFile.Create(GetAppFilePath(EDITORS_FILENAME));

  //Editoren initialisieren
  InitEditors;

  //Style laden
  TStyleManager.TrySetStyle(ConfigFile.ReadString(CONFIG_SEC_FORM, CONFIG_KEY_STYLE, ''), False);
end;

procedure TfrmSQLFunctionConverter.FormDestroy(Sender: TObject);
begin
  ConfigFile.Free;
  EditorsFile.Free;
end;

end.



//-----------------------------------------------------------------------------
// ALTE Prozedur - Mit Arrays
//procedure TfrmFunctionConverter.WriteVariableRow(sParameter: String);
//const
//  caStart = 0;
//  caEnd   = 1;
//var
//  sBezeichnung  : String;
//  sDatentyp     : String;
//  sWert         : String;
//  aPosition     : array [cvBezeichnung..cvWert, caStart..caEnd] of integer;
//begin
//  //ShowMessage(sParameter);
//  if (sParameter <> '') and (Length(sParameter) > 5) then begin
//    DeleteComment(sParameter);
//    //*** Die Start-/ & Stop-Positionen ermitteln
//    // Die Bezeichnung - Vom Start bis zum ersten Leerzeichen
//    aPosition[cvBezeichnung, caStart] := 0;
//    aPosition[cvBezeichnung, caEnd]   := Pos(' ', sParameter, 1);
//
//    //Der Default-Wert - Vom Wort "Default" bis zum Ende (- Offset)
//    aPosition[cvWert, caStart] := UpperCase(sParameter).IndexOf(DEFAULT_START, aPosition[cvBezeichnung, caEnd]);
//    if (aPosition[cvWert, caStart] <> -1) then begin
//      aPosition[cvWert, caStart] := aPosition[cvWert, caStart] + Length(DEFAULT_START);
//      aPosition[cvWert, caEnd]   := sParameter.Length;
//    end;
//
//    //Der Datentyp - Vom Ende der Bezeichnung bis zum Wort "Default" oder bis zum Ende
//    aPosition[cvDatentyp, caStart] := aPosition[cvBezeichnung, caEnd] + 1;
//    if (aPosition[cvWert, caStart] <> -1) then
//      aPosition[cvDatentyp, caEnd] := aPosition[cvWert, caStart] - Length(DEFAULT_START) + 1
//    else
//      aPosition[cvDatentyp, caEnd] := sParameter.Length
//    ;
//    aPosition[cvDatentyp, caEnd] := aPosition[cvDatentyp, caEnd] - aPosition[cvDatentyp, caStart];
//
//    //*** Die Daten ermitteln
//    sBezeichnung  := Trim(Copy(sParameter, aPosition[cvBezeichnung, caStart], aPosition[cvBezeichnung, caEnd]));
//    sDatentyp     := Trim(Copy(sParameter, aPosition[cvDatentyp, caStart]   , aPosition[cvDatentyp, caEnd]));
//    if (aPosition[cvWert, caStart] > 0) then begin
//      sWert := Trim(Copy(sParameter, aPosition[cvWert, caStart], aPosition[cvWert, caEnd]));
//      sWert := Trim(Copy(sWert, 0, sWert.Length - getOffset(sWert)));
//    end;
//
//    //*** Zum Schluss noch alle Werte in die Grid-Zeile packen
//    with grdVariables do begin
//      RowCount := RowCount + 1;
//      Cells[cvBezeichnung, RowCount -1] := sBezeichnung;
//      Cells[cvDatentyp   , RowCount -1] := sDatentyp;
//      Cells[cvWert       , RowCount -1] := sWert;
//    end;
//    Application.ProcessMessages;
//  end;
//end;
