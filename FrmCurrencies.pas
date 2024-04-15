unit FrmCurrencies;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Objects;

type
  TFormCurrencies = class(TForm)
    ListBox: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    BtnOk: TButton;
    BtnCancel: TButton;
    LblCaption: TLabel;
    StyleBook1: TStyleBook;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    procedure ListBoxDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    Currency: String;
    ToBuy: Boolean;
    //Caption: String;
    OnChanged: TNotifyEvent;//procedure(const aCurrency: String) of object;
  end;

var
  FormCurrencies: TFormCurrencies;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

uses Common;

procedure TFormCurrencies.FormActivate(Sender: TObject);
var i: Integer;
begin
if ToBuy
  then Caption := 'Currency To Buy'
  else Caption := 'Currency To Sale';
LblCaption.Text := Caption;
with ListBox do
  begin
  for i:=0 to Count-1 do
    if Items[i].StartsWith(Currency) then
      begin
      ItemIndex := i;
      break;
      end;
  ScrollToItem( ItemByIndex(ItemIndex) );
  end;
end;

procedure TFormCurrencies.FormShow(Sender: TObject);
begin
//with ListBox do
end;

procedure TFormCurrencies.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//
end;

procedure TFormCurrencies.ListBoxDblClick(Sender: TObject);
begin
//self.ModalResult := mrOk;
BtnOkClick(nil);
end;

procedure TFormCurrencies.BtnCancelClick(Sender: TObject);
begin
self.Close();
end;

procedure TFormCurrencies.BtnOkClick(Sender: TObject);
var cur: String;
begin
with ListBox do
  Currency := Copy( Items[ItemIndex], 1, 3 );
self.Close();
if ToBuy
  then cur := CurBuy
  else cur := CurSale;
if cur <> Currency then
  begin
  if ToBuy
    then CurBuy := Currency
    else CurSale := Currency;
  if Assigned(onChanged) then
    OnChanged(nil);
  end;
end;

end.
