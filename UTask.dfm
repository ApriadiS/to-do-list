object TaskUnit: TTaskUnit
  Left = 0
  Top = 0
  Caption = 'To-Do-List Task'
  ClientHeight = 364
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClick = TugasBelumSelesaiBtnClick
  OnCreate = FormCreate
  TextHeight = 15
  object WelcomeLbl: TLabel
    Left = 8
    Top = 8
    Width = 99
    Height = 30
    Caption = 'Semangat!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 307
    Width = 32
    Height = 15
    Caption = 'Tugas'
  end
  object ListViewTask: TListView
    Left = 8
    Top = 44
    Width = 608
    Height = 254
    Columns = <
      item
        Caption = 'Tugas'
        MinWidth = 120
        Width = 604
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = ListViewTaskSelectItem
  end
  object TambahBtn: TButton
    Left = 37
    Top = 333
    Width = 75
    Height = 25
    Caption = 'Tambah'
    TabOrder = 1
    OnClick = TambahBtnClick
  end
  object HapusBtn: TButton
    Left = 133
    Top = 333
    Width = 75
    Height = 25
    Caption = 'Hapus'
    TabOrder = 2
    OnClick = HapusBtnClick
  end
  object EditBtn: TButton
    Left = 230
    Top = 333
    Width = 75
    Height = 25
    Caption = 'Edit'
    TabOrder = 3
    OnClick = EditBtnClick
  end
  object UsernameEdt: TEdit
    Left = 46
    Top = 304
    Width = 268
    Height = 23
    TabOrder = 4
  end
  object TugasSelesaiBtn: TButton
    Left = 326
    Top = 304
    Width = 122
    Height = 25
    Caption = 'Tugas Selesai'
    TabOrder = 5
    OnClick = TugasSelesaiBtnClick
  end
  object TugasBelumSelesaiBtn: TButton
    Left = 494
    Top = 304
    Width = 122
    Height = 25
    Caption = 'Tugas Belum Selesai'
    TabOrder = 6
    OnClick = TugasBelumSelesaiBtnClick
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
    Left = 392
    Top = 336
  end
  object ZQuery: TZQuery
    Connection = ZConnection
    Params = <>
    Left = 328
    Top = 336
  end
end
