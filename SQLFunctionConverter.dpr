program SQLFunctionConverter;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmSQLFunctionConverter},
  Vcl.Themes,
  Vcl.Styles,
  ConverterConst in 'ConverterConst.pas',
  EditorSettings in 'EditorSettings.pas' {frmEditorSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Amakrits');
  Application.CreateForm(TfrmSQLFunctionConverter, frmSQLFunctionConverter);
  Application.CreateForm(TfrmEditorSettings, frmEditorSettings);
  Application.Run;
end.
