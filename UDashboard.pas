unit UDashboard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls, Vcl.StdCtrls,
  Data.DB, ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection, UQuickReportActivity, UQuickReportLog, UQuickReportTask, UQuickReportAccount;

type
  TDashboardUnit = class(TForm)
    ListViewAktivitas: TListView;
    MainMenu: TMainMenu;
    ZConnection: TZConnection;
    ZQuery: TZQuery;
    MenuDashboard: TMenuItem;
    MenuCategory: TMenuItem;
    MenuLogout: TMenuItem;
    WelcomeLbl: TLabel;
    BukaBtn: TButton;
    TambahBtn: TButton;
    Label1: TLabel;
    UsernameEdt: TEdit;
    HapusBtn: TButton;
    EditBtn: TButton;
    ListViewLog: TListView;
    MenuReport: TMenuItem;
    SubMenuActivitas: TMenuItem;
    SubMenuLog: TMenuItem;
    SubMenuTugas: TMenuItem;
    SubMenuAkun: TMenuItem;
    procedure TambahBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure HapusBtnClick(Sender: TObject);
    procedure BukaBtnClick(Sender: TObject);
    procedure MenuLogoutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewAktivitasSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure SubMenuActivitasClick(Sender: TObject);
    procedure SubMenuLogClick(Sender: TObject);
    procedure SubMenuTugasClick(Sender: TObject);
    procedure SubMenuAkunClick(Sender: TObject);
  private
    FUserId: Integer;
    procedure LoadAktivitas;
    procedure LoadLog;
    procedure ClearAktivitasFields;
    function GetSelectedActivityId: Integer;
  public
    procedure SetUser(const AUserId: Integer; const AUsername: string);
    { Public declarations }
  end;

var
  DashboardUnit: TDashboardUnit;

implementation

{$R *.dfm}

uses
  UTask, ULogin;

procedure TDashboardUnit.SetUser(const AUserId: Integer; const AUsername: string);
begin
  FUserId := AUserId;
  WelcomeLbl.Caption := 'Halo, ' + AUsername + '!';
  LoadAktivitas;
  LoadLog;
end;

procedure TDashboardUnit.LoadAktivitas;
begin
  ListViewAktivitas.Items.Clear;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT activity_id, activity_name FROM activities WHERE user_id = :uid';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.Open;
  while not ZQuery.Eof do
  begin
    with ListViewAktivitas.Items.Add do
    begin
      Caption := ZQuery.FieldByName('activity_name').AsString;
      Data := Pointer(ZQuery.FieldByName('activity_id').AsInteger);
    end;
    ZQuery.Next;
  end;
  ZQuery.Close;
end;

procedure TDashboardUnit.LoadLog;
begin
  ListViewLog.Items.Clear;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT change_type, description, changed_at FROM activity_task_history WHERE user_id = :uid ORDER BY changed_at DESC LIMIT 50';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.Open;
  while not ZQuery.Eof do
  begin
    with ListViewLog.Items.Add do
      Caption := Format('%s: %s [%s]', [
        ZQuery.FieldByName('change_type').AsString,
        ZQuery.FieldByName('description').AsString,
        ZQuery.FieldByName('changed_at').AsString
      ]);
    ZQuery.Next;
  end;
  ZQuery.Close;
end;

procedure TDashboardUnit.ClearAktivitasFields;
begin
  UsernameEdt.Text := '';
end;

function TDashboardUnit.GetSelectedActivityId: Integer;
begin
  Result := -1;
  if (ListViewAktivitas.Selected <> nil) then
    Result := Integer(ListViewAktivitas.Selected.Data);
end;

procedure TDashboardUnit.TambahBtnClick(Sender: TObject);
var
  nama: string;
  cek: Integer;
begin
  nama := Trim(UsernameEdt.Text);
  if nama = '' then
  begin
    ShowMessage('Nama aktivitas tidak boleh kosong.');
    Exit;
  end;
  // Cek duplikasi nama aktivitas untuk user yang sama
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT COUNT(*) as cnt FROM activities WHERE user_id = :uid AND LOWER(activity_name) = LOWER(:nama)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('nama').AsString := nama;
  ZQuery.Open;
  cek := ZQuery.FieldByName('cnt').AsInteger;
  ZQuery.Close;
  if cek > 0 then
  begin
    ShowMessage('Nama aktivitas sudah ada.');
    Exit;
  end;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'INSERT INTO activities (user_id, activity_name) VALUES (:uid, :nama)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('nama').AsString := nama;
  ZQuery.ExecSQL;
  // Log
  ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, change_type, description) VALUES (:uid, :chg, :desc)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('chg').AsString := 'Tambah Aktivitas';
  ZQuery.ParamByName('desc').AsString := 'Menambah aktivitas: ' + nama;
  ZQuery.ExecSQL;
  LoadAktivitas;
  LoadLog;
  ClearAktivitasFields;
end;

procedure TDashboardUnit.EditBtnClick(Sender: TObject);
var
  id: Integer;
  nama: string;
  cek: Integer;
begin
  id := GetSelectedActivityId;
  if id = -1 then
  begin
    ShowMessage('Pilih aktivitas yang ingin diedit.');
    Exit;
  end;
  nama := Trim(UsernameEdt.Text);
  if nama = '' then
  begin
    ShowMessage('Nama aktivitas tidak boleh kosong.');
    Exit;
  end;
  // Cek duplikasi nama aktivitas untuk user yang sama, kecuali dirinya sendiri
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT COUNT(*) as cnt FROM activities WHERE user_id = :uid AND LOWER(activity_name) = LOWER(:nama) AND activity_id <> :id';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('nama').AsString := nama;
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.Open;
  cek := ZQuery.FieldByName('cnt').AsInteger;
  ZQuery.Close;
  if cek > 0 then
  begin
    ShowMessage('Nama aktivitas sudah ada.');
    Exit;
  end;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'UPDATE activities SET activity_name = :nama WHERE activity_id = :id AND user_id = :uid';
  ZQuery.ParamByName('nama').AsString := nama;
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ExecSQL;
  // Log
  ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, activity_id, change_type, description) VALUES (:uid, :aid, :chg, :desc)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('aid').AsInteger := id;
  ZQuery.ParamByName('chg').AsString := 'Edit Aktivitas';
  ZQuery.ParamByName('desc').AsString := 'Edit aktivitas menjadi: ' + nama;
  ZQuery.ExecSQL;
  LoadAktivitas;
  LoadLog;
  ClearAktivitasFields;
end;

procedure TDashboardUnit.HapusBtnClick(Sender: TObject);
var
  id: Integer;
  nama: string;
begin
  id := GetSelectedActivityId;
  if id = -1 then
  begin
    Exit;
  end;
  if not ZConnection.Connected then
    ZConnection.Connect;
  // Get nama sebelum hapus
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT activity_name FROM activities WHERE activity_id = :id';
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.Open;
  nama := ZQuery.FieldByName('activity_name').AsString;
  ZQuery.Close;
  // Log dulu sebelum hapus
  ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, activity_id, change_type, description) VALUES (:uid, :aid, :chg, :desc)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('aid').AsInteger := id;
  ZQuery.ParamByName('chg').AsString := 'Hapus Aktivitas';
  ZQuery.ParamByName('desc').AsString := 'Menghapus aktivitas: ' + nama;
  ZQuery.ExecSQL;
  // Hapus
  ZQuery.SQL.Text := 'DELETE FROM activities WHERE activity_id = :id AND user_id = :uid';
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ExecSQL;
  LoadAktivitas;
  LoadLog;
  ClearAktivitasFields;
end;

procedure TDashboardUnit.BukaBtnClick(Sender: TObject);
var
  id: Integer;
  nama: string;
begin
  id := GetSelectedActivityId;
  if id = -1 then
  begin
    ShowMessage('Pilih aktivitas yang ingin dibuka.');
    Exit;
  end;
  // Get nama aktivitas
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT activity_name FROM activities WHERE activity_id = :id';
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.Open;
  nama := ZQuery.FieldByName('activity_name').AsString;
  ZQuery.Close;
  // Buka form tugas
  TaskUnit := TTaskUnit.Create(Self);
  try
    TaskUnit.Caption := 'Tugas: ' + nama;
    TaskUnit.SetActivity(id, FUserId);
    TaskUnit.ShowModal;
  finally
    TaskUnit.Free;
  end;
  LoadLog;
end;

procedure TDashboardUnit.MenuLogoutClick(Sender: TObject);
begin
  // Log aksi logout
  try
    if not ZConnection.Connected then
      ZConnection.Connect;
    ZQuery.Close;
    ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, change_type, description) VALUES (:uid, :chg, :desc)';
    ZQuery.ParamByName('uid').AsInteger := FUserId;
    ZQuery.ParamByName('chg').AsString := 'Logout';
    ZQuery.ParamByName('desc').AsString := 'User logout dari aplikasi';
    ZQuery.ExecSQL;
  except
    // Jika gagal log, abaikan saja
  end;
  Hide;
  LoginUnit := TLoginUnit.Create(Self);
  try
    LoginUnit.ShowModal;
  finally
    LoginUnit.Free;
  end;
end;

procedure TDashboardUnit.SubMenuActivitasClick(Sender: TObject);
begin
  TQuickReportActivityUnit.CreateWithUserId(Self, FUserId);
end;

procedure TDashboardUnit.SubMenuLogClick(Sender: TObject);
begin
  TQuickReportLogUnit.CreateWithUserId(Self, 0);
end;

procedure TDashboardUnit.SubMenuTugasClick(Sender: TObject);
begin
  TQuickReportTaskUnit.CreateWithUserId(Self, FUserId);
end;

procedure TDashboardUnit.SubMenuAkunClick(Sender: TObject);
begin
  TQuickReportAccountUnit.CreateWithUserId(Self, FUserId);
end;

procedure TDashboardUnit.FormCreate(Sender: TObject);
begin
  TambahBtn.OnClick := TambahBtnClick;
  EditBtn.OnClick := EditBtnClick;
  HapusBtn.OnClick := HapusBtnClick;
  BukaBtn.OnClick := BukaBtnClick;
  MenuLogout.OnClick := MenuLogoutClick;
  SubMenuActivitas.OnClick := SubMenuActivitasClick;
  SubMenuLog.OnClick := SubMenuLogClick;
  SubMenuTugas.OnClick := SubMenuTugasClick;
  SubMenuAkun.OnClick := SubMenuAkunClick;
end;

procedure TDashboardUnit.ListViewAktivitasSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and (Item <> nil) then
    UsernameEdt.Text := Item.Caption;
end;

// Arahan event binding:
// Pastikan property OnClick pada TambahBtn, EditBtn, HapusBtn, BukaBtn, dan MenuLogout diatur ke prosedur di atas.
// Contoh: TambahBtn.OnClick := TambahBtnClick; dst.
//
// Untuk mengisi UsernameEdt saat memilih item di ListViewAktivitas, tambahkan event ListViewAktivitas.OnSelectItem
// dan isi UsernameEdt.Text := item.Caption;

end.
