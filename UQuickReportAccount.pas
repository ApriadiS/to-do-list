unit UQuickReportAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, QuickRpt, QRCtrls,
  Data.DB, ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection;

type
  TF_QuickReportAccount = class(TForm)
    QuickRep1: TQuickRep;
    TitleBand1: TQRBand;
    DetailBand1: TQRBand;
    judulLbl: TQRLabel;
    usernameQLbl: TQRLabel;
    QRLabel1: TQRLabel;
    QRLabel2: TQRLabel;
    QRDBText1: TQRDBText;
    QRDBText2: TQRDBText;
    QRDBText3: TQRDBText;
    ZConnection: TZConnection;
    ZQuery: TZQuery;
  private
    FUserId: Integer;
    { Private declarations }
  public
    constructor CreateWithUserId(AOwner: TComponent; AUserId: Integer);
    { Public declarations }
  end;

var
  F_QuickReportAccount: TF_QuickReportAccount;

implementation

{$R *.dfm}

constructor TF_QuickReportAccount.CreateWithUserId(AOwner: TComponent; AUserId: Integer);
begin
  inherited Create(AOwner);
  FUserId := AUserId;
    // Initialize the database connection
  if not ZConnection.Connected then
    ZConnection.Connect;
  // Set the SQL query to fetch user data
  ZQuery.SQL.Text := 'SELECT * FROM users WHERE user_id = :user_id ORDER BY created_at DESC';
  ZQuery.ParamByName('user_id').AsInteger := FUserId;
  ZQuery.Open;
  // Set the report title
  judulLbl.Caption := 'LAPORAN ACCOUNT';
  // Set the username label (ambil username pertama jika ada data)
  if not ZQuery.IsEmpty then
    usernameQLbl.Caption := 'Username: ' + ZQuery.FieldByName('username').AsString
  else
    usernameQLbl.Caption := 'Username: -';
  // Set the Account details
  QRDBText1.DataField := 'username';
  QRDBText2.DataField := 'email';
  QRDBText3.DataField := 'created_at';
  // Refresh the report
  QuickRep1.Refresh;
  // Preview the report
  QuickRep1.Preview;
end;

end.
