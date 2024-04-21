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
  FireDAC.Comp.UI, FMX.ExtCtrls, FMX.ComboEdit, FMX.ListBox, FMX.Layouts,
  FMX.Gestures, System.ImageList, FMX.ImgList, FMX.Effects;

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
    ActionList1: TActionList;
    ActConvert: TAction;
    FDConnection: TFDConnection;
    QryCreateTable: TFDQuery;
    QrySelectAll: TFDQuery;
    QryInsert: TFDQuery;
    ActClearHistory: TAction;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Layout1: TLayout;
    LblBase: TLabel;
    BtnBase: TButton;
    Layout2: TLayout;
    BtnRate: TButton;
    LblRate: TLabel;
    NumRate: TNumberBox;
    LblTime: TLabel;
    Layout3: TLayout;
    LblBuy: TLabel;
    NumBuy: TNumberBox;
    BtnBuy: TButton;
    LayMain: TLayout;
    Layout4: TLayout;
    BtnConvert: TButton;
    ActRepeatConvertation: TAction;
    LayHistory: TLayout;
    Layout5: TLayout;
    BtnClearHistory: TButton;
    BtnUse: TButton;
    LvwHistory: TListView;
    StyleBook1: TStyleBook;
    GestureManager1: TGestureManager;
    Image1: TImage;
    Rectangle3: TRectangle;
    Rectangle4: TRectangle;
    LbxMenu: TListBox;
    ShadowEffect1: TShadowEffect;
    ImageList1: TImageList;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    LbiClearHistory: TListBoxItem;
    ActRevertConvertation: TAction;
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
    //procedure ActClearHistoryUpdate(Sender: TObject);
    procedure ActClearHistoryExecute(Sender: TObject);
    procedure FDConnectionBeforeConnect(Sender: TObject);
    procedure FDConnectionAfterConnect(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ActRepeatConvertationExecute(Sender: TObject);
    //procedure ActRepeatConvertationUpdate(Sender: TObject);
    procedure LvwHistoryGesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormKeyUp(Sender: TObject; var aKey: Word; var aKeyChar: Char;
      aShift: TShiftState);
    procedure ActRevertConvertationExecute(Sender: TObject);
  private
    OnNewRate: procedure of object;
    //Log: TextFile;
    procedure ToLog(const aMsg: String);
    procedure OnGetCurrencies;
    procedure OnGetCurrenciesError(Sender: TObject);
    procedure EnableWorkingMode;
    procedure OnGetRate;
    procedure OnGetRateError(Sender: TObject);
    procedure Convert;
    procedure ShowMenu(aShow: Boolean = TRUE);
    procedure SetNumBuy;
    procedure SetNumBase;
  public
  end;

var
  FormMain: TFormMain;

implementation
{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}

uses JSON, Math, FMX.DialogService, FMX.Platform,
     System.IOUtils, System.Generics.Collections,
     Common, FrmCurrencies;

procedure TFormMain.FormCreate(Sender: TObject);
begin
ToLog('*** CurrEx started ***');
RESTClient.BaseURL := BASE_URL;
RESTRequest.Resource := END_POINT_CURRENCIES;
LblTime.Text := '';
with RESTRequest.Params.AddItem do
  begin
  Name := 'app_id';
  Value := APP_TOKEN;
  end;
self.Fill.Color := TAlphaColorRec.Lavender;
OnNewRate := nil;
LbxMenu.Visible := FALSE;
LvwHistory.Enabled := TRUE;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
ToLog('*** CurrEx finished');
//CloseFile(Log);
CanClose := TRUE;
end;

procedure TFormMain.FormResize(Sender: TObject);
var Screen: IFMXScreenService;
begin
{$IF DEFINED(ANDROID)}
if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(Screen))
  then
    if (Screen.GetScreenOrientation = TScreenOrientation.Portrait) or
        (Screen.GetScreenOrientation = TScreenOrientation.InvertedPortrait) then
        begin
        ToLog('portrait');
        LayMain.Align := TAlignLayout.Top;
        LayMain.Height := 195;
        end
    else if (Screen.GetScreenOrientation = TScreenOrientation.Landscape) or
             (Screen.GetScreenOrientation = TScreenOrientation.InvertedLandscape)
      then
        begin
        ToLog('landscape');
        LayMain.Align := TAlignLayout.Left;
        LayMain.Width := self.Width / 2;
        end
{$ENDIF}
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
Footer.Enabled := TRUE;
BtnRetry.Visible := FALSE;
BtnExit.Visible := FALSE;
BtnRetry.OnClick(nil);
end;

procedure TFormMain.FormKeyUp(Sender: TObject; var aKey: Word; var aKeyChar: Char;
  aShift: TShiftState);
begin
if aKey = vkHardwareBack then
  if LbxMenu.Visible then
    begin
    ShowMenu(FALSE);
    aKey := 0;
    end;
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
ToLog(LblMessage.Text);
end;

procedure TFormMain.EnableWorkingMode;
begin
BtnRetry.Free;
BtnExit.Free;
LblMessage.Text := '';
LblMessage.Align := TAlignLayout.Client;
BtnBase.Text := CurBase;
with RESTRequest.Params.AddItem do
  begin
  Name := 'base';
  Value := CurBase;
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
RESTRequest.Params.ParameterByName('base').Value := CurBase;
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
                    LblTime.Text := FormatDateTime('hh:nn:ss', Now);
                    BtnBase.Text := CurBase;
                    BtnBuy.Text := CurBuy;
                    ToLog(CurBuy + ' / ' + CurBase + ' = ' + FloatToStr(NumRate.Value));
                    if Assigned(OnNewRate) then
                      OnNewRate;
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
    if BtnBase.Text <> CurBase then
      CurBase := BtnBase.Text;
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
ToLog(msg);
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
  Currency := CurBase;
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

procedure TFormMain.ActClearHistoryExecute(Sender: TObject);
var n: Cardinal;
begin
ShowMenu(FALSE);
TDialogService.MessageDialog('Clear the history of convertations ?',
      TMsgDlgType.mtCustom, [TMsgDlgBtn.mbCancel, TMsgDlgBtn.mbYes],
      TMsgDlgBtn.mbCancel, 0,
          procedure(const aResult: TModalResult)  // always 1 ???
          begin
            if aResult = mrYes then
              begin
              n := FDConnection.ExecSQL('delete from Convertations');
              QrySelectAll.Close();
              QrySelectAll.Open;
              ToLog('history cleaned, records: ' + IntToStr(n))
              end;
          end
);
end;
{
procedure TFormMain.ActClearHistoryUpdate(Sender: TObject);
var NewEnabled: Boolean;
begin
with LvwHistory do
  NewEnabled := Items.Count > 0;
if NewEnabled <> ActClearHistory.Enabled then
  if NewEnabled
    then BtnClearHistory.StyleLookup := 'BtnClearStyle'
    else BtnClearHistory.StyleLookup := 'BtnClearStyleDisabled';
ActClearHistory.Enabled := NewEnabled;
end;
}
procedure TFormMain.ActConvertUpdate(Sender: TObject);
var NewEnabled: Boolean;
begin
NewEnabled := (CurBase <> CurBuy) and (CurRate > 0) and
              (NumBase.Value > 0) and (NumBuy.Value > 0);
if NewEnabled <> ActConvert.Enabled then
  if NewEnabled
    then BtnConvert.StyleLookup := 'CornerButtonStyle'
    else BtnConvert.StyleLookup := 'CornerButtonStyleDisabled';
ActConvert.Enabled := NewEnabled;
end;

//var LongTap: Boolean = FALSE;
var ValueToSet: String = '';

procedure TFormMain.ActRepeatConvertationExecute(Sender: TObject);
var words: TArray<String>;
begin
ShowMenu(FALSE);
with LvwHistory do
  if (ItemIndex >= 0) {and (not LongTap)} then
    begin
//    LongTap := TRUE;
    TDialogService.MessageDialog('Use this convertation as a template for the next operation ?',
          TMsgDlgType.mtCustom, [TMsgDlgBtn.mbCancel, TMsgDlgBtn.mbYes],
          TMsgDlgBtn.mbCancel, 0,
              procedure(const aResult: TModalResult)  // always 1 ???
              begin
//                LongTap := FALSE;
                if aResult = mrYes then
                  begin
                  words := Items[ItemIndex].Text.Split([' ']);
                  CurBase := words[1];
                  CurBuy := words[4];
                  OnNewRate := SetNumBase;
                  ValueToSet := words[0];
                  BtnRate.OnClick(nil);
                  end;
              end
    );
    end;
end;

procedure TFormMain.SetNumBase;
begin
OnNewRate := nil;
NumBase.Value := StrToFloat(ValueToSet);
end;

procedure TFormMain.ActRevertConvertationExecute(Sender: TObject);
var words: TArray<String>;
begin
ShowMenu(FALSE);
with LvwHistory do
  if (ItemIndex >= 0) then
    TDialogService.MessageDialog('Use this convertation as a REVERSE template for the next operation ?',
          TMsgDlgType.mtCustom, [TMsgDlgBtn.mbCancel, TMsgDlgBtn.mbYes],
          TMsgDlgBtn.mbCancel, 0,
              procedure(const aResult: TModalResult)  // always 1 ???
              begin
                if aResult = mrYes then
                  begin
                  words := Items[ItemIndex].Text.Split([' ']);
                  CurBase := words[4];
                  CurBuy := words[1];
                  OnNewRate := SetNumBuy;
                  ValueToSet := words[3];
                  BtnRate.OnClick(nil);
                  end;
              end
    );
end;

procedure TFormMain.SetNumBuy;
begin
OnNewRate := nil;
NumBuy.Value := StrToFloat(ValueToSet);
end;
{
procedure TFormMain.ActRepeatConvertationUpdate(Sender: TObject);
var NewVisible: Boolean;
    words: TArray<String>;
begin
with LvwHistory do
  begin
  NewVisible := ItemIndex >= 0;
  if NewVisible then
    begin
    words := Items[ItemIndex].Text.Split([' ']);
    NewVisible := (CurBase <> words[1]) or (CurBuy <> words[4]) or
                  (NumBase.Text <> words[0]);
    end;
  ActRepeatConvertation.Visible := NewVisible;
  end;
end;
}
procedure TFormMain.ShowMenu(aShow: Boolean = TRUE);
begin
with LbxMenu do
  begin
  ItemIndex := -1;
  Visible := aShow;
  Position.Y := (TLayout(Parent).Height - Height) / 2;
  LvwHistory.Enabled := not aShow;
  end;
end;

procedure TFormMain.LvwHistoryGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
var rec: TRectF;
begin
if EventInfo.GestureID = System.UITypes.igiLongTap then
  with LvwHistory do
    begin
    rec := LocalToAbsolute( GetItemRect(LvwHistory.Items.Count-1) );
    if (EventInfo.Location.Y < rec.Bottom) {and ActUse.Visible} then
      begin
      //ActUseExecute(nil);
      ShowMenu;
      Handled := TRUE;
      end;
    end;
end;

procedure TFormMain.Convert;
begin
OnNewRate := nil;
QryInsert.ParamByName('Item').AsString := NumBase.Text + ' ' + CurBase + ' -> '
  + NumBuy.Text + ' ' + CurBuy + ' by ' + NumRate.Text
  + ' / ' + FormatDateTime('dd.mm.yyyy hh:nn', Now);
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

procedure TFormMain.ActConvertExecute(Sender: TObject);
begin
OnNewRate := Convert;
BtnRate.OnClick(nil);
end;

procedure TFormMain.QrySelectAllAfterOpen(DataSet: TDataSet);
var words: TArray<String>;
begin
DataSet.Last;
LvwHistory.Items.Clear;
while not DataSet.Bof do
  begin
  with LvwHistory.Items.Add do
    begin
    words := DataSet.Fields[0].AsString.Split([' / ']);
    Text := words[0];
    Detail := words[1];
    end;
  DataSet.Prior;
  end;
LvwHistory.ItemIndex := IfThen(DataSet.RecordCount > 0, 0, -1);
if (CurRate <= 0) and (LvwHistory.Items.Count > 0) then
  begin // first opening
  LvwHistory.ItemIndex := -1;
  words := LvwHistory.Items[0].Text.Split([' ']);
  CurBase := words[1];
  CurBuy := words[4];
  end;
end;

procedure TFormMain.ToLog(const aMsg: String);
begin
//WriteLn(Log, FormatDateTime('dd.mm.yyyy hh:nn:ss  ', Now) + aMsg);
Log.d(aMsg);
end;

end.
