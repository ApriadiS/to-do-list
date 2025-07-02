unit ULogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection, URegister, UDashboard;

type
  TLoginUnit = class(TForm)
    Label1: TLabel;
    UsernameEdt: TEdit;
    ZConnection: TZConnection;
    ZQuery: TZQuery;
    KeluarBtn: TButton;
    Label2: TLabel;
    PasswordEdt: TEdit;
    LoginBtn: TButton;
    RegisterBtn: TButton;
    procedure KeluarBtnClick(Sender: TObject);
    procedure LoginBtnClick(Sender: TObject);
    procedure RegisterBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure ResetFields;
    function isAnyAccountExists: Boolean;
  public
    { Public declarations }
  end;

var
  LoginUnit: TLoginUnit;

implementation

{$R *.dfm}

procedure TLoginUnit.FormCreate(Sender: TObject);
begin
  keluarBtn.OnClick := KeluarBtnClick;
  LoginBtn.OnClick := LoginBtnClick;
  RegisterBtn.OnClick := RegisterBtnClick;
end;

function TLoginUnit.isAnyAccountExists: Boolean;
begin
  Result := False;
  try
    ZQuery.Close;
    ZQuery.SQL.Clear;
    ZQuery.SQL.Text := 'SELECT * FROM users';
    ZQuery.Open;
    Result := not ZQuery.IsEmpty;
  except
    on E: Exception do
      ShowMessage('Terjadi kesalahan saat memeriksa akun: ' + E.Message);
  end;
end;

procedure TLoginUnit.ResetFields;
begin
  UsernameEdt.Text := '';
  PasswordEdt.Text := '';
end;


procedure TLoginUnit.KeluarBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TLoginUnit.LoginBtnClick(Sender: TObject);
var
  userId: Integer;
begin
  // Check if the username and password fields are filled
  if (UsernameEdt.Text = '') or (PasswordEdt.Text = '') then
  begin
    ShowMessage('Username dan Password tidak boleh kosong.');
    Exit;
  end;

  if not isAnyAccountExists then
  begin
    ShowMessage('Belum ada akun terdaftar. Silakan daftar terlebih dahulu.');
    Exit;
  end;

  try
    // Connect to the database jika belum terkoneksi
    if not ZConnection.Connected then
      ZConnection.Connect;

    // Siapkan dan eksekusi query
    ZQuery.Close;
    ZQuery.SQL.Clear;
    ZQuery.SQL.Text := 'SELECT * FROM users WHERE username = :username AND password = :password';
    ZQuery.ParamByName('username').AsString := UsernameEdt.Text;
    ZQuery.ParamByName('password').AsString := PasswordEdt.Text;

    try
      ZQuery.Open;
      // Check if a record was found
      if not ZQuery.IsEmpty then
      begin
        userId := ZQuery.FieldByName('user_id').AsInteger;
        // Log login sukses
        ZQuery.Close;
        ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, change_type, description) VALUES (:uid, :chg, :desc)';
        ZQuery.ParamByName('uid').AsInteger := userId;
        ZQuery.ParamByName('chg').AsString := 'Login';
        ZQuery.ParamByName('desc').AsString := 'Login berhasil untuk user: ' + UsernameEdt.Text;
        ZQuery.ExecSQL;
        ShowMessage('Login berhasil!');
        // MainForm.Show; // Uncomment this line when you have a main form to show
        Hide; // Hide the login form
        // Membuka form dashboard
        DashboardUnit := TDashboardUnit.Create(Self);
        DashboardUnit.SetUser(userId, UsernameEdt.Text);
        DashboardUnit.ShowModal;
      end
      else
      begin
        // Log login gagal
        ZQuery.Close;
        ZQuery.SQL.Text := 'SELECT user_id FROM users WHERE username = :username';
        ZQuery.ParamByName('username').AsString := UsernameEdt.Text;
        ZQuery.Open;
        if not ZQuery.IsEmpty then
          userId := ZQuery.FieldByName('user_id').AsInteger
        else
          userId := 0;
        ZQuery.Close;
        ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, change_type, description) VALUES (:uid, :chg, :desc)';
        ZQuery.ParamByName('uid').AsInteger := userId;
        ZQuery.ParamByName('chg').AsString := 'Login Gagal';
        ZQuery.ParamByName('desc').AsString := 'Percobaan login gagal untuk user: ' + UsernameEdt.Text;
        try
          ZQuery.ExecSQL;
        except
          on E: Exception do
            ShowMessage('Gagal mencatat log login gagal: ' + E.Message);
        end;
        ShowMessage('Username atau password salah.');
        ResetFields; // Reset the fields if login fails
      end;
    finally
      ZQuery.Close;
    end;
  except
    on E: Exception do
      ShowMessage('Gagal login: ' + E.Message);
  end;
end;

procedure TLoginUnit.RegisterBtnClick(Sender: TObject);
begin
  Hide; // Hide the login form before opening the registration form
  // Open the registration form
  RegisterUnit := TRegisterUnit.Create(Self);
  try
    RegisterUnit.ShowModal;
    // Setelah register, log ke activity_task_history jika user baru berhasil dibuat
    if (RegisterUnit.UsernameEdt.Text <> '') then
    begin
      try
        if not ZConnection.Connected then
          ZConnection.Connect;
        // Cari user_id user yang baru saja register
        ZQuery.Close;
        ZQuery.SQL.Text := 'SELECT user_id FROM users WHERE username = :username';
        ZQuery.ParamByName('username').AsString := RegisterUnit.UsernameEdt.Text;
        ZQuery.Open;
        if not ZQuery.IsEmpty then
        begin
          ZQuery.Close;
          ZQuery.SQL.Text := 'INSERT INTO activity_task_history (user_id, change_type, description) VALUES (:uid, :chg, :desc)';
          ZQuery.ParamByName('uid').AsInteger := ZQuery.FieldByName('user_id').AsInteger;
          ZQuery.ParamByName('chg').AsString := 'Register';
          ZQuery.ParamByName('desc').AsString := 'Registrasi user baru: ' + RegisterUnit.UsernameEdt.Text;
          ZQuery.ExecSQL;
        end;
      except
        // Jika gagal log, abaikan saja
      end;
    end;
  finally
    RegisterUnit.Free;
    ResetFields; // Reset fields after registration
  end;
end;
end.
