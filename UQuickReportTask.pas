unit UQuickReportTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection, QRCtrls,
  QuickRpt, Vcl.ExtCtrls;

type
  TF_QuickReportTask = class(TForm)
    QuickRep1: TQuickRep;
    TitleBand1: TQRBand;
    aktivitasQLbl: TQRLabel;
    QRLabel1: TQRLabel;
    QRLabel2: TQRLabel;
    DetailBand1: TQRBand;
    QRDBText1: TQRDBText;
    QRDBText2: TQRDBText;
    QRDBText3: TQRDBText;
    judulLbl: TQRLabel;
    ZConnection: TZConnection;
    ZQuery: TZQuery;
    QRLabel3: TQRLabel;
    QRDBText4: TQRDBText;
  private
    FUserId: Integer;
    { Private declarations }
  public
    constructor CreateWithUserId(AOwner: TComponent; AUserId: Integer);
    { Public declarations }
  end;

var
  F_QuickReportTask: TF_QuickReportTask;

implementation

{$R *.dfm}

constructor TF_QuickReportTask.CreateWithUserId(AOwner: TComponent; AUserId: Integer);
begin
  inherited Create(AOwner);
  FUserId := AUserId;
  // Initialize the database connection
  if not ZConnection.Connected then
    ZConnection.Connect;

  // Set the SQL query to fetch task data with activity name filtered by user_id
  ZQuery.SQL.Text :=
    'SELECT t.task_id, t.task_name, t.is_completed, t.created_at, a.activity_name ' +
    'FROM tasks t ' +
    'JOIN activities a ON t.activity_id = a.activity_id ' +
    'WHERE a.user_id = :user_id ' +
    'ORDER BY t.created_at DESC';
  ZQuery.ParamByName('user_id').AsInteger := FUserId;
  ZQuery.Open;

  // Set the report title
  judulLbl.Caption := 'LAPORAN TASK';

  // Set the activity name label (ambil activity_name pertama jika ada data)
  if not ZQuery.IsEmpty then
    aktivitasQLbl.Caption := 'Aktivitas: ' + ZQuery.FieldByName('activity_name').AsString
  else
    aktivitasQLbl.Caption := 'Aktivitas: -';

  // Set the Task details
  QRDBText1.DataField := 'activity_name';
  QRDBText2.DataField := 'task_name';
  QRDBText3.DataField := 'is_completed';
  QRDBText4.DataField := 'created_at';

  // Refresh the report
  QuickRep1.Refresh;
  // Preview the report
  QuickRep1.Preview;
end;

end.
