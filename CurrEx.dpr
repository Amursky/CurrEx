program CurrEx;

uses
  System.StartUpCopy,
  FMX.Forms,
  FrmMain in 'FrmMain.pas' {FormMain},
  FrmCurrencies in 'FrmCurrencies.pas' {FormCurrencies},
  Common in 'Common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormCurrencies, FormCurrencies);
  Application.Run;
end.
