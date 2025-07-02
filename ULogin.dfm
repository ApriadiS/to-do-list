object LoginUnit: TLoginUnit
  Left = 0
  Top = 0
  Caption = 'To-Do-List Login'
  ClientHeight = 132
  ClientWidth = 287
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 14
    Width = 53
    Height = 15
    Caption = 'Username'
  end
  object Label2: TLabel
    Left = 8
    Top = 54
    Width = 50
    Height = 15
    Caption = 'Password'
  end
  object UsernameEdt: TEdit
    Left = 80
    Top = 11
    Width = 195
    Height = 23
    TabOrder = 0
  end
  object KeluarBtn: TButton
    Left = 8
    Top = 99
    Width = 75
    Height = 25
    Caption = 'Keluar'
    TabOrder = 4
    OnClick = KeluarBtnClick
  end
  object PasswordEdt: TEdit
    Left = 80
    Top = 51
    Width = 195
    Height = 23
    PasswordChar = '*'
    TabOrder = 1
  end
  object LoginBtn: TButton
    Left = 200
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Login'
    TabOrder = 2
    OnClick = LoginBtnClick
  end
  object RegisterBtn: TButton
    Left = 103
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Register'
    TabOrder = 3
    OnClick = RegisterBtnClick
  end
  object ZConnection: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    DisableSavepoints = False
    HostName = 'localhost'
    Port = 3306
    Database = 'to-do-list'
    User = 'root'
    Password = ''
    Protocol = 'mysql'
    Left = 88
    Top = 32
  end
  object ZQuery: TZQuery
    Connection = ZConnection
    Params = <>
    Left = 24
    Top = 32
  end
end
