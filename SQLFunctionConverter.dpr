program SQLFunctionConverter;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmFunctionConverter},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TfrmFunctionConverter, frmFunctionConverter);
  Application.Run;
end.
