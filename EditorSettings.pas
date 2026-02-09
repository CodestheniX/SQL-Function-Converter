unit EditorSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IniFiles, ConverterConst;

type
  TfrmEditorSettings = class(TForm)
    pnlMain: TPanel;
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    lbxEditors: TListBox;
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
