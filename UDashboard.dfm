object DashboardUnit: TDashboardUnit
  Left = 0
  Top = 0
  Caption = 'To-Do-List Dashboard'
  ClientHeight = 299
  ClientWidth = 664
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  Scaled = False
  OnCreate = FormCreate
  TextHeight = 15
  object WelcomeLbl: TLabel
    Left = 8
    Top = 8
    Width = 49
    Height = 30
    Caption = 'Halo!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 235
    Width = 45
    Height = 15
    Caption = 'Aktivitas'
  end
  object ListViewAktivitas: TListView
    Left = 8
    Top = 44
    Width = 319
    Height = 150
    Columns = <
      item
        Caption = 'Aktivitas'
        MinWidth = 120
        Width = 315
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = ListViewAktivitasSelectItem
  end
  object BukaBtn: TButton
    Left = 200
    Top = 201
    Width = 127
    Height = 25
    Caption = 'Buka Aktiitas'
    TabOrder = 1
    OnClick = BukaBtnClick
  end
  object TambahBtn: TButton
    Left = 59
    Top = 261
    Width = 75
    Height = 25
    Caption = 'Tambah'
    TabOrder = 2
    OnClick = TambahBtnClick
  end
  object UsernameEdt: TEdit
    Left = 59
    Top = 232
    Width = 268
    Height = 23
    TabOrder = 3
  end
  object HapusBtn: TButton
    Left = 155
    Top = 261
    Width = 75
    Height = 25
    Caption = 'Hapus'
    TabOrder = 4
    OnClick = HapusBtnClick
  end
  object EditBtn: TButton
    Left = 252
    Top = 261
    Width = 75
    Height = 25
    Caption = 'Edit'
    TabOrder = 5
    OnClick = EditBtnClick
  end
  object ListViewLog: TListView
    Left = 337
    Top = 44
    Width = 319
    Height = 242
    Columns = <
      item
        Caption = 'Log'
        MinWidth = 120
        Width = 315
      end>
    RowSelect = True
    TabOrder = 6
    ViewStyle = vsReport
  end
  object MainMenu: TMainMenu
    Left = 216
    object MenuDashboard: TMenuItem
      Caption = 'Dashboard'
    end
    object MenuCategory: TMenuItem
      Caption = 'Category'
    end
    object MenuReport: TMenuItem
      Caption = 'Report'
      object SubMenuActivitas: TMenuItem
        Caption = 'Activitas'
      end
      object SubMenuLog: TMenuItem
        Caption = 'Log'
      end
      object SubMenuTugas: TMenuItem
        Caption = 'Tugas'
      end
      object SubMenuAkun: TMenuItem
        Caption = 'Akun'
      end
    end
    object MenuLogout: TMenuItem
      Caption = 'Logout'
      OnClick = MenuLogoutClick
    end
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
    Left = 344
  end
  object ZQuery: TZQuery
    Connection = ZConnection
    Params = <>
    Left = 280
  end
end
