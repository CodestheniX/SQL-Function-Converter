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
  private
    EditorProfile : TEditorProfile;
    procedure LoadEditorList;
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

procedure TfrmEditorSettings.LoadEditorList;
var
  slSections    : TStringlist;
  sActiveEditor : String;
  sSectionName  : String;
  sEditorName   : String;
begin
  lbxEditors.Clear;
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
      EditorProfile := TEditorProfile.Create;
      with EditorProfile do begin
        Name      := sEditorName;
        Path      := EditorsFile.ReadString(sSectionName, EDITORS_KEY_PATH, '');
        Parameter := EditorsFile.ReadString(sSectionName, EDITORS_KEY_PARAMETER, '');
        isActive  := SameText(sActiveEditor, sEditorName);
      end;

      lbxEditors.Items.AddObject(EditorProfile.Name, EditorProfile);
    end;
  finally
    slSections.Free;
  end;
end;

end.
