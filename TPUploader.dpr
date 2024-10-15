program TPUploader;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles,
  uMsgEmPortugues in 'uMsgEmPortugues.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Atualizador de Itens de Consumo (Itens, Fotos, Quantidades)';
  TStyleManager.TrySetStyle('Lavender Classico');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
