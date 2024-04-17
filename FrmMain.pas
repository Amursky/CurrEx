unit FrmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  FMX.Controls.Presentation, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.DBScope, FMX.ListView,
  Data.DB, Datasnap.DBClient, REST.Response.Adapter, FMX.Edit, FMX.Ani, FMX.Objects, FMX.EditBox,
  FMX.NumberBox, System.Actions, FMX.ActnList, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Comp.UI, FMX.ExtCtrls, FMX.ComboEdit, FMX.ListBox;

type
  TFormMain = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    LblMessage: TLabel;
    BtnRetry: TButton;
    BtnExit: TButton;
    NumBase: TNumberBox;
    LblSale: TLabel;
    BtnBase: TButton;
    LblRate: TLabel;
    NumRate: TNumberBox;
    BtnRate: TButton;
    LblBuy: TLabel;
    NumBuy: TNumberBox;
    BtnBuy: TButton;
    BtnConvert: TButton;
    ActionList1: TActionList;
    ActConvert: TAction;
    FDConnection: TFDConnection;
    QryCreateTable: TFDQuery;
    QrySelectAll: TFDQuery;
    QryInsert: TFDQuery;
    ListView1: TListView;
    ActClear: TAction;
    Button1: TButton;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    StyleBook1: TStyleBook;
    procedure BtnRetryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnRateClick(Sender: TObject);
    procedure ActConvertUpdate(Sender: TObject);
    procedure ActConvertExecute(Sender: TObject);
    procedure NumRateChange(Sender: TObject);
    procedure NumBaseChange(Sender: TObject);
    procedure NumBuyChange(Sender: TObject);
    procedure BtnBaseClick(Sender: TObject);
    procedure BtnBuyClick(Sender: TObject);
    procedure QrySelectAllAfterOpen(DataSet: TDataSet);
    procedure ActClearUpdate(Sender: TObject);
    procedure ActClearExecute(Sender: TObject);
    procedure FDConnectionBeforeConnect(Sender: TObject);
    procedure FDConnectionAfterConnect(Sender: TObject);
  private
    procedure OnGetCurrencies;
    procedure OnGetCurrenciesError(Sender: TObject);
    procedure EnableWorkingMode;
    procedure OnGetRate;
    procedure OnGetRateError(Sender: TObject);
  public
  end;

var
  FormMain: TFormMain;

implementation
{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}
{$R *.LgXhdpiTb.fmx ANDROID}

uses JSON, Math, FMX.DialogService, System.IOUtils, System.Generics.Collections,
     Common, FrmCurrencies;

procedure TFormMain.FormCreate(Sender: TObject);
begin
RESTClient.BaseURL := BASE_URL;
RESTRequest.Resource := END_POINT_CURRENCIES;
with RESTRequest.Params.AddItem do
  begin
  Name := 'app_id';
  Value := APP_TOKEN;
  end;
self.Fill.Color := TAlphaColorRec.Lavender;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
Footer.Enabled := TRUE;
BtnRetry.Visible := FALSE;
BtnExit.Visible := FALSE;
BtnRetry.OnClick(nil);
end;

procedure TFormMain.FDConnectionBeforeConnect(Sender: TObject);
begin
{$IF DEFINED(ANDROID)}
FDConnection.Params.Values['Database'] :=
  TPath.Combine(TPath.GetDocumentsPath, 'CurrEx.s3db');
{$ENDIF}
end;

procedure TFormMain.FDConnectionAfterConnect(Sender: TObject);
begin
FDConnection.ExecSQL('CREATE TABLE IF NOT EXISTS Convertations (Item TEXT NOT NULL)');
end;

procedure TFormMain.BtnExitClick(Sender: TObject);
begin
self.Close;
end;

procedure TFormMain.BtnRetryClick(Sender: TObject);
begin
BtnRetry.Enabled := FALSE;
BtnExit.Enabled := FALSE;
LblMessage.Text := 'connecting server ...';
LblMessage.Repaint;
RESTRequest.ExecuteAsync(OnGetCurrencies, TRUE, TRUE, OnGetCurrenciesError);
end;

procedure TFormMain.OnGetCurrencies;
var i: Integer;
    jo: TJSONObject;
begin
  try
    if RESTResponse.StatusCode = 200
      then
        if Assigned(RESTResponse.JSONValue)
          then
            begin
            jo := TJSONObject.ParseJSONValue(RESTResponse.Content) as TJSONObject;
            with jo do
              for i:=0 to Count-1 do
                with Pairs[i] do
                  Currencies.AddObject( JsonString.Value + '  ' + JsonValue.Value, nil );
            FormCurrencies.ListBox.Items.Assign(Currencies);
            FormCurrencies.OnChanged := BtnRateClick;
            EnableWorkingMode;
            end
          else
            raise Exception.Create('empty answer from server')
    else
      raise Exception.Create('server reported error: ' + #10 + RESTResponse.Content);
  except on E: Exception do
    OnGetCurrenciesError(E)
  end;
end;

procedure TFormMain.OnGetCurrenciesError(Sender: TObject);
begin
BtnRetry.Visible := TRUE;
BtnRetry.Enabled := TRUE;
BtnExit.Visible := TRUE;
BtnExit.Enabled := TRUE;
if Sender is Exception
  then LblMessage.Text := Exception(Sender).Message
  else LblMessage.Text := 'server not answering';
end;

procedure TFormMain.EnableWorkingMode;
begin
BtnRetry.Free;
BtnExit.Free;
LblMessage.Text := '';
LblMessage.Align := TAlignLayout.Client;
BtnBase.Text := CurSale;
with RESTRequest.Params.AddItem do
  begin
  Name := 'base';
  Value := CurSale;
  end;
BtnBuy.Text := CurBuy;
with RESTRequest.Params.AddItem do
  begin
  Name := 'symbols';
  Value := CurBuy;
  end;
FormCurrencies.ListBox.Items.Assign(Currencies);
FormCurrencies.ToBuy := TRUE;
FormCurrencies.Currency := CurBuy;
FormCurrencies.OnActivate(nil);
QrySelectAll.Active := TRUE;
BtnRateClick(nil);
end;

procedure TFormMain.BtnRateClick(Sender: TObject);
begin
LblMessage.Text := 'connecting server ...';
LblMessage.Repaint;
NumBase.Enabled := FALSE;
NumRate.Enabled := FALSE;
NumBuy.Enabled := FALSE;
BtnBase.Enabled := FALSE;
BtnRate.Enabled := FALSE;
BtnBuy.Enabled := FALSE;
RESTRequest.Resource := END_POINT_CONVERT;
RESTRequest.Params.ParameterByName('base').Value := CurSale;
RESTRequest.Params.ParameterByName('symbols').Value := CurBuy;
RESTRequest.ExecuteAsync(OnGetRate, TRUE, TRUE, OnGetRateError);
end;

procedure TFormMain.OnGetRate;
var
  jo: TJSONObject;
  err: String;
begin
try
  try
    if RESTResponse.StatusCode = 200
      then
        if Assigned(RESTResponse.JSONValue)
          then
            begin
            jo := TJSONObject.ParseJSONValue(RESTResponse.Content) as TJSONObject;
            if jo.TryGetValue<TJSONObject>('rates', jo)
              then
                if jo.TryGetValue<Currency>(CurBuy, CurRate)
                  then
                    begin
                    LblMessage.Text := '';
                    NumRate.Value := RoundTo(CurRate, -4);
                    BtnBase.Text := CurSale;
                    BtnBuy.Text := CurBuy;
                    end
                  else
                    raise Exception.Create('error parsing sever answer')
              else
                raise Exception.Create('error parsing sever answer');
            end
          else
            raise Exception.Create('empty answer from server')
    else
      begin
      jo := TJSONObject.ParseJSONValue(RESTResponse.Content) as TJSONObject;
      if jo.TryGetValue<String>('description', err)
        then raise Exception.Create(err)
        else
          if RESTResponse.Content <> ''
            then raise Exception.Create(RESTResponse.Content)
            else raise Exception.Create('server error');
      end;
  except on E: Exception do
    begin
    if BtnBase.Text <> CurSale then
      CurSale := BtnBase.Text;
    if BtnBuy.Text <> CurBuy then
      CurBuy := BtnBuy.Text;
    OnGetRateError(E)
    end;
  end;
finally
  NumBase.Enabled := CurRate > 0;
  NumRate.Enabled := CurRate > 0;
  NumBuy.Enabled := CurRate > 0;
  BtnBase.Enabled := TRUE;
  BtnRate.Enabled := TRUE;
  BtnBuy.Enabled := TRUE;
end;
end;

procedure TFormMain.OnGetRateError(Sender: TObject);
var msg: String;
begin
if Sender is Exception
  then msg := Exception(Sender).Message
  else msg := 'server not answering';
TDialogService.MessageDialog(msg, TMsgDlgType.mtError,
    [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
LblMessage.Text := '';
end;

procedure TFormMain.NumBaseChange(Sender: TObject);
var
  evt: TNotifyEvent;
begin
evt := NumBuy.OnChange;
NumBuy.OnChange := nil;
try
  NumBuy.Value := RoundTo(NumBase.Value * NumRate.Value, -2);
finally
  NumBuy.OnChange := evt;
end;
end;

procedure TFormMain.NumBuyChange(Sender: TObject);
var
  evt: TNotifyEvent;
begin
evt := NumBuy.OnChange;
NumBase.OnChange := nil;
try
  NumBase.Value := RoundTo(NumBuy.Value / NumRate.Value, -2);
finally
  NumBase.OnChange := evt;
end;
end;

procedure TFormMain.NumRateChange(Sender: TObject);
begin
NumBaseChange(nil);
end;

procedure TFormMain.BtnBaseClick(Sender: TObject);
//var mr: TModalResult;
begin
with FormCurrencies do
  begin
  ToBuy := FALSE;
  Currency := CurSale;
  Show;
  {
  mr := ShowModal;
  if mr = mrOk then
    if CurSale <> Currency then
      begin
      CurSale := Currency;
      BtnRate.OnClick(nil);
      end;
  }
  end;
 end;

procedure TFormMain.BtnBuyClick(Sender: TObject);
//var mr: TModalResult;
begin
with FormCurrencies do
  begin
  ToBuy := TRUE;
  Currency := CurBuy;
  Show;
  end;
end;

procedure TFormMain.ActClearExecute(Sender: TObject);
begin
{FDConnection.ExecSQL('delete from Convertations');
QrySelectAll.Close();
QrySelectAll.Open;}
//  doesn't work !
TDialogService.MessageDialog('Clear the history of convertations ?',
      TMsgDlgType.mtCustom, [TMsgDlgBtn.mbCancel, TMsgDlgBtn.mbYes],
      TMsgDlgBtn.mbCancel, 0,
          procedure(const aResult: TModalResult)  // always 1 ???
          begin
            if aResult = mrOk then
              begin
              FDConnection.ExecSQL('delete from Convertations');
              QrySelectAll.Close();
              QrySelectAll.Open;
              end;
          end
);

end;

procedure TFormMain.ActClearUpdate(Sender: TObject);
begin
with ListView1 do
  ActClear.Enabled := Items.Count > 0;
end;

procedure TFormMain.ActConvertUpdate(Sender: TObject);
begin
ActConvert.Enabled := (CurSale <> CurBuy) and (CurRate > 0) and
                      (NumBase.Value > 0) and (NumBuy.Value > 0);
end;

procedure TFormMain.ActConvertExecute(Sender: TObject);
begin
QryInsert.ParamByName('Item').AsString := NumBase.Text + ' ' + CurSale + ' -> '
  + NumBuy.Text + ' ' + CurBuy + ' by ' + NumRate.Text;
QryInsert.Connection.StartTransaction;
try
  QryInsert.ExecSQL();
  QrySelectAll.Close();
  QrySelectAll.Open;
  QryInsert.Connection.Commit;
except
  on E: Exception do
    begin
    QryInsert.Connection.Rollback;
    TDialogService.MessageDialog(E.Message, TMsgDlgType.mtError,
        [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
    end;
end;
end;

procedure TFormMain.QrySelectAllAfterOpen(DataSet: TDataSet);
begin
DataSet.Last;
ListView1.Items.Clear;
while not DataSet.Bof do
  begin
  ListView1.Items.Add.Text := DataSet.Fields[0].AsString;
  DataSet.Prior;
  end;
end;

end.
