unit URegister;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection;

type
  TRegisterUnit = class(TForm)
    Label1: TLabel;
    UsernameEdt: TEdit;
    ZConnection: TZConnection;
    ZQuery: TZQuery;
    KeluarBtn: TButton;
    Label2: TLabel;
    PasswordEdt: TEdit;
    RegisterBtn: TButton;
    KonfirmasiEdt: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    EmailEdt: TEdit;
    procedure KeluarBtnClick(Sender: TObject);
    procedure RegisterBtnClick(Sender: TObject);
  private
    { Private declarations }
    function CheckUsernameExists(const Username: string): Boolean;
    function RegisterUser(const Username, Password, Email: string): Boolean;
  public
    { Public declarations }
  end;

var
  RegisterUnit: TRegisterUnit;

implementation

{$R *.dfm}

function TRegisterUnit.CheckUsernameExists(const Username: string): Boolean;
begin
  Result := False; // Default result
  if Username = '' then
    Exit; // Jika username kosong, langsung keluar

  try
    // Connect to the database
    if not ZConnection.Connected then
      ZConnection.Connect;

    // Prepare the SQL query to check if the username exists
    ZQuery.Close; // Make sure query is closed before reusing
    ZQuery.SQL.Clear;
    ZQuery.SQL.Text := 'SELECT COUNT(*) FROM users WHERE username = :username';
    ZQuery.ParamByName('username').AsString := Username;
    
    try
      ZQuery.Open;
      if not ZQuery.IsEmpty then
        Result := ZQuery.Fields[0].AsInteger > 0; // Check if count is greater than 0
    finally
      ZQuery.Close;
    end;
  except
    on E: Exception do
      ShowMessage('Terjadi kesalahan saat memeriksa username: ' + E.Message);
  end;
end;

function TRegisterUnit.RegisterUser(const Username, Password, Email: string): Boolean;
begin
  Result := False; // Default result
  if (Username = '') or (Password = '') or (Email = '') then
  begin
    ShowMessage('Semua kolom harus diisi.');
    Exit;
  end;

  try
    // Connect to the database
    if not ZConnection.Connected then
      ZConnection.Connect;

    // Prepare the SQL query to insert a new user
    ZQuery.Close; // Make sure query is closed before reusing
    ZQuery.SQL.Clear;
    ZQuery.SQL.Text := 'INSERT INTO users (username, password, email) VALUES (:username, :password, :email)';
    ZQuery.ParamByName('username').AsString := Username;
    ZQuery.ParamByName('password').AsString := Password;
    ZQuery.ParamByName('email').AsString := Email;

    try
      // Execute the query
      ZQuery.ExecSQL;
      ShowMessage('Registrasi berhasil!');
      Result := True; // Registration successful
    finally
      ZQuery.Close;
    end;
  except
    on E: Exception do
      ShowMessage('Registrasi gagal: ' + E.Message);
  end;
end;

procedure TRegisterUnit.KeluarBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TRegisterUnit.RegisterBtnClick(Sender: TObject);
begin
  // Check if the username and password fields are filled
  if (UsernameEdt.Text = '') or (PasswordEdt.Text = '') or (KonfirmasiEdt.Text = '') or (EmailEdt.Text = '') then
  begin
    ShowMessage('Semua kolom harus diisi.');
    Exit;
  end;

  // Check if the passwords match
  if PasswordEdt.Text <> KonfirmasiEdt.Text then
  begin
    ShowMessage('Password dan konfirmasi password tidak sama.');
    Exit;
  end;

  if CheckUsernameExists(UsernameEdt.Text) then
  begin
    ShowMessage('Username sudah digunakan. Silakan pilih username lain.');
    Exit;
  end;

  // Register the user
  if RegisterUser(UsernameEdt.Text, PasswordEdt.Text, EmailEdt.Text) then
  begin
    // Optionally, you can clear the fields after successful registration
    UsernameEdt.Clear;
    PasswordEdt.Clear;
    KonfirmasiEdt.Clear;
    EmailEdt.Clear;
  end;
  // Close the registration form after registration
  Close;
end;
end.
