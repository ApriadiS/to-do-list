unit UQuickReportLog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection, QRCtrls,
  QuickRpt, Vcl.ExtCtrls;

type
  TF_QuickReportLog = class(TForm)
    QuickRep1: TQuickRep;
    TitleBand1: TQRBand;
    waktuQLbl: TQRLabel;
    QRLabel2: TQRLabel;
    DetailBand1: TQRBand;
    QRDBText1: TQRDBText;
    QRDBText3: TQRDBText;
    judulLbl: TQRLabel;
    ZConnection: TZConnection;
    ZQuery: TZQuery;
  private
    FUserId: Integer; // Untuk konsistensi, walau tidak dipakai
    { Private declarations }
  public
    constructor CreateWithUserId(AOwner: TComponent; AUserId: Integer);
    { Public declarations }
  end;

var
  F_QuickReportLog: TF_QuickReportLog;

implementation

{$R *.dfm}

constructor TF_QuickReportLog.CreateWithUserId(AOwner: TComponent; AUserId: Integer);
begin
  inherited Create(AOwner);
  FUserId := AUserId; // Tidak digunakan, hanya untuk konsistensi
    // Initialize the database connection
  if not ZConnection.Connected then
    ZConnection.Connect;
  // Set the SQL query to fetch all logs, newest first
  ZQuery.SQL.Text := 'SELECT * FROM activity_task_history ORDER BY changed_at DESC';
  ZQuery.Open;
  // Set the report title
  judulLbl.Caption := 'LAPORAN LOG';
  // Set the log details
  QRDBText1.DataField := 'changed_at';
  QRDBText3.DataField := 'description';
  // Refresh the report
  QuickRep1.Refresh;
  // Preview the report
  QuickRep1.Preview;
end;

end.
