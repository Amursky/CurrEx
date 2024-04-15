unit Common;

interface
uses JSON, System.Classes;

const
  BASE_URL = 'https://openexchangerates.org/api';
  APP_TOKEN = 'b170520e75e445d1ba434b2229027150';
  END_POINT_CURRENCIES = 'currencies.json';
  END_POINT_CONVERT = 'latest.json';

var
  CurSale: String = 'USD';
  CurBuy: String = 'USD';
  CurRate: Currency = 0;
  Currencies: TStrings = nil;

implementation

initialization
Currencies := TStringList.Create;

finalization
Currencies.Free;
end.
