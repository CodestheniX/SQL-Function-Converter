unit EditorSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IniFiles, ConverterConst;

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
  private
    //
  public
    ConfigFile: TIniFile;
    constructor Create(AOwner: TComponent; AConfigFile: TIniFile); reintroduce;
  end;

var
  frmEditorSettings: TfrmEditorSettings;

implementation

{$R *.dfm}

{ TfrmEditorSettings }

constructor TfrmEditorSettings.Create(AOwner: TComponent; AConfigFile: TIniFile);
begin
  inherited Create(AOwner);
  ConfigFile := AConfigFile;
end;

end.
