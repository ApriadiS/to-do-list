unit UTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection, Vcl.ComCtrls;

type
  TTaskUnit = class(TForm)
    ListViewTask: TListView;
    ZConnection: TZConnection;
    ZQuery: TZQuery;
    WelcomeLbl: TLabel;
    TambahBtn: TButton;
    HapusBtn: TButton;
    EditBtn: TButton;
    Label1: TLabel;
    UsernameEdt: TEdit;
    TugasSelesaiBtn: TButton;
    TugasBelumSelesaiBtn: TButton;
    procedure LoadTasks(FilterCompleted: Integer = -1);
    procedure TambahBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure HapusBtnClick(Sender: TObject);
    procedure TugasSelesaiBtnClick(Sender: TObject);
    procedure TugasBelumSelesaiBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewTaskSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ListViewTaskDrawItem(Sender: TCustomListView; Item: TListItem; Rect: TRect; State: TOwnerDrawState);
  private
    FActivityId: Integer;
    FUserId: Integer;
    procedure ClearTaskFields;
    function GetSelectedTaskId: Integer;
    function GetSelectedTaskCompleted: Integer;
    
  public
    procedure SetActivity(const AActivityId, AUserId: Integer);
    { Public declarations }
  end;

var
  TaskUnit: TTaskUnit;

implementation

{$R *.dfm}


procedure TTaskUnit.SetActivity(const AActivityId, AUserId: Integer);
begin
  FActivityId := AActivityId;
  FUserId := AUserId;
  LoadTasks;
end;

procedure TTaskUnit.LoadTasks(FilterCompleted: Integer = -1);
var
  baseName: string;
  isCompleted: Integer;
  taskId: Integer;
begin
  ListViewTask.Items.Clear;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  if FilterCompleted = -1 then
    ZQuery.SQL.Text := 'SELECT task_id, task_name, is_completed FROM tasks WHERE activity_id = :aid'
  else
    ZQuery.SQL.Text := 'SELECT task_id, task_name, is_completed FROM tasks WHERE activity_id = :aid AND is_completed = :comp';
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  if FilterCompleted <> -1 then
    ZQuery.ParamByName('comp').AsInteger := FilterCompleted;
  ZQuery.Open;
  while not ZQuery.Eof do
  begin
    baseName := Trim(StringReplace(ZQuery.FieldByName('task_name').AsString, ' [SELESAI]', '', [rfReplaceAll, rfIgnoreCase]));
    isCompleted := ZQuery.FieldByName('is_completed').AsInteger;
    taskId := ZQuery.FieldByName('task_id').AsInteger;
    with ListViewTask.Items.Add do
    begin
      if isCompleted = 1 then
        Caption := baseName + ' [SELESAI]'
      else
        Caption := baseName;
      Data := Pointer(taskId);
    end;
    ZQuery.Next;
  end;
  ZQuery.Close;
end;

procedure TTaskUnit.ClearTaskFields;
begin
  UsernameEdt.Text := '';
end;

function TTaskUnit.GetSelectedTaskId: Integer;
begin
  Result := -1;
  if (ListViewTask.Selected <> nil) then
    Result := Integer(ListViewTask.Selected.Data);
end;

function TTaskUnit.GetSelectedTaskCompleted: Integer;
var
  id: Integer;
begin
  Result := -1;
  id := GetSelectedTaskId;
  if id = -1 then Exit;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT is_completed FROM tasks WHERE task_id = :id';
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.Open;
  if not ZQuery.IsEmpty then
    Result := ZQuery.FieldByName('is_completed').AsInteger;
  ZQuery.Close;
end;

procedure TTaskUnit.TambahBtnClick(Sender: TObject);
var
  nama: string;
  cek: Integer;
begin
  nama := Trim(UsernameEdt.Text);
  if nama = '' then
  begin
    ShowMessage('Nama tugas tidak boleh kosong.');
    Exit;
  end;
  // Cek duplikasi nama tugas dalam satu aktivitas
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT COUNT(*) as cnt FROM tasks WHERE activity_id = :aid AND LOWER(task_name) = LOWER(:nama)';
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ParamByName('nama').AsString := nama;
  ZQuery.Open;
  cek := ZQuery.FieldByName('cnt').AsInteger;
  ZQuery.Close;
  if cek > 0 then
  begin
    ShowMessage('Nama tugas sudah ada dalam aktivitas ini.');
    Exit;
  end;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'INSERT INTO tasks (activity_id, task_name) VALUES (:aid, :nama)';
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ParamByName('nama').AsString := nama;
  ZQuery.ExecSQL;
  // Log
  ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, activity_id, task_id, change_type, description) VALUES (:uid, :aid, LAST_INSERT_ID(), :chg, :desc)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ParamByName('chg').AsString := 'Tambah Tugas';
  ZQuery.ParamByName('desc').AsString := 'Menambah tugas: ' + nama;
  ZQuery.ExecSQL;
  LoadTasks;
  ClearTaskFields;
end;

procedure TTaskUnit.EditBtnClick(Sender: TObject);
var
  id: Integer;
  nama: string;
  cek: Integer;
begin
  id := GetSelectedTaskId;
  if id = -1 then
  begin
    ShowMessage('Pilih tugas yang ingin diedit.');
    Exit;
  end;
  nama := Trim(UsernameEdt.Text);
  if nama = '' then
  begin
    ShowMessage('Nama tugas tidak boleh kosong.');
    Exit;
  end;
  // Cek duplikasi nama tugas dalam satu aktivitas, kecuali untuk dirinya sendiri
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT COUNT(*) as cnt FROM tasks WHERE activity_id = :aid AND LOWER(task_name) = LOWER(:nama) AND task_id <> :id';
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ParamByName('nama').AsString := nama;
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.Open;
  cek := ZQuery.FieldByName('cnt').AsInteger;
  ZQuery.Close;
  if cek > 0 then
  begin
    ShowMessage('Nama tugas sudah ada dalam aktivitas ini.');
    Exit;
  end;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  ZQuery.SQL.Text := 'UPDATE tasks SET task_name = :nama WHERE task_id = :id AND activity_id = :aid';
  ZQuery.ParamByName('nama').AsString := nama;
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ExecSQL;
  // Log
  ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, activity_id, task_id, change_type, description) VALUES (:uid, :aid, :tid, :chg, :desc)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ParamByName('tid').AsInteger := id;
  ZQuery.ParamByName('chg').AsString := 'Edit Tugas';
  ZQuery.ParamByName('desc').AsString := 'Edit tugas menjadi: ' + nama;
  ZQuery.ExecSQL;
  LoadTasks;
  ClearTaskFields;
end;

procedure TTaskUnit.HapusBtnClick(Sender: TObject);
var
  id: Integer;
  nama: string;
begin
  id := GetSelectedTaskId;
  if id = -1 then
  begin
    ShowMessage('Pilih tugas yang ingin dihapus.');
    Exit;
  end;
  if not ZConnection.Connected then
    ZConnection.Connect;
  // Get nama sebelum hapus
  ZQuery.Close;
  ZQuery.SQL.Text := 'SELECT task_name FROM tasks WHERE task_id = :id';
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.Open;
  nama := ZQuery.FieldByName('task_name').AsString;
  ZQuery.Close;
  // Log dulu sebelum hapus
  ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, activity_id, task_id, change_type, description) VALUES (:uid, :aid, :tid, :chg, :desc)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ParamByName('tid').AsInteger := id;
  ZQuery.ParamByName('chg').AsString := 'Hapus Tugas';
  ZQuery.ParamByName('desc').AsString := 'Menghapus tugas: ' + nama;
  ZQuery.ExecSQL;
  // Baru hapus
  ZQuery.SQL.Text := 'DELETE FROM tasks WHERE task_id = :id AND activity_id = :aid';
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ExecSQL;
  LoadTasks;
  ClearTaskFields;
end;

procedure TTaskUnit.TugasSelesaiBtnClick(Sender: TObject);
var
  id: Integer;
  isCompleted: Integer;
begin
  id := GetSelectedTaskId;
  if id = -1 then
  begin
      ShowMessage('Pilih tugas yang ingin ditandai selesai.');
      Exit;
  end;
  isCompleted := GetSelectedTaskCompleted;
  if isCompleted = 1 then
  begin
    ShowMessage('Tugas sudah ditandai selesai.');
    Exit;
  end;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  // Update status tugas
  ZQuery.SQL.Text := 'UPDATE tasks SET is_completed = 1 WHERE task_id = :id AND activity_id = :aid';
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ExecSQL;
  // Log (hanya jika update berhasil)
  ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, activity_id, task_id, change_type, description) VALUES (:uid, :aid, :tid, :chg, :desc)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ParamByName('tid').AsInteger := id;
  ZQuery.ParamByName('chg').AsString := 'Tugas Selesai';
  ZQuery.ParamByName('desc').AsString := 'Menandai tugas selesai.';
  try
    ZQuery.ExecSQL;
  except
    ShowMessage('Gagal mencatat perubahan tugas. Silakan coba lagi.');
    Exit; // Keluar jika gagal log
  end;
  LoadTasks;
end;

procedure TTaskUnit.TugasBelumSelesaiBtnClick(Sender: TObject);
var
  id: Integer;
  isCompleted: Integer;
begin
  id := GetSelectedTaskId;
  if id = -1 then
  begin
    ShowMessage('Pilih tugas yang ingin ditandai belum selesai.');
    Exit;
  end;
  isCompleted := GetSelectedTaskCompleted;
  if isCompleted = 0 then
  begin
    ShowMessage('Tugas sudah ditandai belum selesai.');
    Exit;
  end;
  if not ZConnection.Connected then
    ZConnection.Connect;
  ZQuery.Close;
  // Update status tugas
  ZQuery.SQL.Text := 'UPDATE tasks SET is_completed = 0 WHERE task_id = :id AND activity_id = :aid';
  ZQuery.ParamByName('id').AsInteger := id;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ExecSQL;
  // Log (hanya jika update berhasil)
  ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, activity_id, task_id, change_type, description) VALUES (:uid, :aid, :tid, :chg, :desc)';
  ZQuery.ParamByName('uid').AsInteger := FUserId;
  ZQuery.ParamByName('aid').AsInteger := FActivityId;
  ZQuery.ParamByName('tid').AsInteger := id;
  ZQuery.ParamByName('chg').AsString := 'Tugas Belum Selesai';
  ZQuery.ParamByName('desc').AsString := 'Menandai tugas belum selesai.';
  try
    ZQuery.ExecSQL;
  except
    ShowMessage('Gagal mencatat perubahan tugas. Silakan coba lagi.');
    Exit; // Keluar jika gagal log
  end;
  LoadTasks;
end;

procedure TTaskUnit.FormCreate(Sender: TObject);
begin
  TambahBtn.OnClick := TambahBtnClick;
  EditBtn.OnClick := EditBtnClick;
  HapusBtn.OnClick := HapusBtnClick;
  TugasSelesaiBtn.OnClick := TugasSelesaiBtnClick;
  TugasBelumSelesaiBtn.OnClick := TugasBelumSelesaiBtnClick;
end;

procedure TTaskUnit.ListViewTaskSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and (Item <> nil) then
    UsernameEdt.Text := Item.Caption;
end;

procedure TTaskUnit.ListViewTaskDrawItem(Sender: TCustomListView; Item: TListItem;
  Rect: TRect; State: TOwnerDrawState);
var
  Flags: Integer;
  ItemText: string;
  FontStyle: TFontStyles;
begin
  ItemText := Item.Caption;
  Flags := DrawTextBiDiModeFlags(DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  // Tidak perlu coretan, cukup tampilkan teks biasa
  FontStyle := [];
  Sender.Canvas.Font := ListViewTask.Font;
  Sender.Canvas.Font.Style := FontStyle;
  Sender.Canvas.FillRect(Rect);
  DrawText(Sender.Canvas.Handle, PChar(ItemText), Length(ItemText), Rect, Flags);
end;

// Arahan event binding:
// Pastikan property OnClick pada TambahBtn, EditBtn, HapusBtn, TugasSelesaiBtn, dan TugasBelumSelesaiBtn diatur ke prosedur di atas.
// Contoh: TambahBtn.OnClick := TambahBtnClick; dst.
//
// Untuk mengisi UsernameEdt saat memilih item di ListViewTask, tambahkan event ListViewTask.OnSelectItem
// dan isi UsernameEdt.Text := item.Caption;
end.