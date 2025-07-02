object RegisterUnit: TRegisterUnit
  Left = 0
  Top = 0
  Caption = 'To-Do-List Register'
  ClientHeight = 204
  ClientWidth = 333
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
  object Label3: TLabel
    Left = 8
    Top = 91
    Width = 110
    Height = 15
    Caption = 'Konfirmasi Password'
  end
  object Label4: TLabel
    Left = 8
    Top = 128
    Width = 29
    Height = 15
    Caption = 'Email'
  end
  object UsernameEdt: TEdit
    Left = 128
    Top = 8
    Width = 195
    Height = 23
    TabOrder = 0
  end
  object KeluarBtn: TButton
    Left = 128
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Keluar'
    TabOrder = 5
    OnClick = KeluarBtnClick
  end
  object PasswordEdt: TEdit
    Left = 128
    Top = 48
    Width = 195
    Height = 23
    PasswordChar = '*'
    TabOrder = 1
  end
  object RegisterBtn: TButton
    Left = 248
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Register'
    TabOrder = 4
    OnClick = RegisterBtnClick
  end
  object KonfirmasiEdt: TEdit
    Left = 128
    Top = 85
    Width = 195
    Height = 23
    PasswordChar = '*'
    TabOrder = 2
  end
  object EmailEdt: TEdit
    Left = 128
    Top = 122
    Width = 195
    Height = 23
    TabOrder = 3
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
    Left = 80
    Top = 168
  end
  object ZQuery: TZQuery
    Connection = ZConnection
    Params = <>
    Left = 16
    Top = 168
  end
end
