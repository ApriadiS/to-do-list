unit UQuickReportActivity;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection, QRCtrls,
  QuickRpt, Vcl.ExtCtrls;

type
  TF_QuickReportActivity = class(TForm)
    QuickRep1: TQuickRep;
    TitleBand1: TQRBand;
    usernameQLbl: TQRLabel;
    QRLabel2: TQRLabel;
    DetailBand1: TQRBand;
    QRDBText1: TQRDBText;
    QRDBText3: TQRDBText;
    judulLbl: TQRLabel;
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
  F_QuickReportActivity: TF_QuickReportActivity;

implementation

{$R *.dfm}

constructor TF_QuickReportActivity.CreateWithUserId(AOwner: TComponent; AUserId: Integer);
begin
  inherited Create(AOwner);
  FUserId := AUserId;
    // Initialize the database connection
  if not ZConnection.Connected then
    ZConnection.Connect;

  // Set the SQL query to fetch activity data filtered by user_id
  ZQuery.SQL.Text := 'SELECT * FROM activities WHERE user_id = :user_id ORDER BY created_at DESC';
  ZQuery.ParamByName('user_id').AsInteger := FUserId;
  ZQuery.Open;

  // Set the report title
  judulLbl.Caption := 'LAPORAN ACTIVITAS';

  // Set the user_id label (ambil user_id pertama jika ada data)
  if not ZQuery.IsEmpty then
    usernameQLbl.Caption := 'User ID: ' + ZQuery.FieldByName('user_id').AsString
  else
    usernameQLbl.Caption := 'User ID: -';

  // Set the Activity details
  QRDBText1.DataField := 'activity_name';
  QRDBText3.DataField := 'created_at';

  // Refresh the report
  QuickRep1.Refresh;
  // Preview the report
  QuickRep1.Preview;
end;

end.
