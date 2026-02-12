unit EditorSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IniFiles, ConverterConst;

type
  TEditorProfile = class
    public
      Name      : String;
      Path      : String;
      Parameter : String;
      isActive  : boolean;
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
    lblParameter: TLabel;
    edtName: TEdit;
    edtPath: TEdit;
    edtParameter: TEdit;
    chkUseEditor: TCheckBox;
    btnTestEditor: TButton;
    btnEditorButtons: TPanel;
    btnAdd: TButton;
    btnDelete: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure lbxEditorsClick(Sender: TObject);
  private
    procedure LoadEditorList;
    procedure LoadEditorSettings;
  public
    EditorsFile: TIniFile;
    constructor Create(AOwner: TComponent; var AEditorsFile: TIniFile); reintroduce;
  end;

var
  frmEditorSettings: TfrmEditorSettings;

implementation

{$R *.dfm}

{ TfrmEditorSettings }

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
      sEditorName := Copy(sSectionName, Length(EDITORS_SEC_EDITOR_X) + 1, MaxInt);

      //Profile auslesen & anzeigen
      eProfile := TEditorProfile.Create;
      with eProfile do begin
        Name      := sEditorName;
        Path      := EditorsFile.ReadString(sSectionName, EDITORS_KEY_PATH, '');
        Parameter := EditorsFile.ReadString(sSectionName, EDITORS_KEY_PARAMETER, '');
        isActive  := SameText(sActiveEditor, sSectionName);
        if isActive then
          Name := SELECTED_EDITOR_SYMBOL + ' ' + Name;
        ;
      end;
      lbxEditors.Items.AddObject(eProfile.Name, eProfile);
      inc(iLbxItemIndex);

      //Aktive-Editor selektieren
      if eProfile.isActive then begin
        lbxEditors.ItemIndex := iLbxItemIndex;
        lbxEditors.OnClick(self);
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
  eProfile := TEditorProfile(lbxEditors.Items.Objects[lbxEditors.ItemIndex]);
  with eProfile do begin
    if isActive then
      Name := Trim(StringReplace(Name, SELECTED_EDITOR_SYMBOL, '', [rfReplaceAll]));
    ;
    edtName.Text      := Name;
    edtPath.Text      := Path;
    edtParameter.Text := Parameter;
    chkUseEditor.Checked := isActive;
  end;

end;

end.
