object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #27979#35797#31243#24207
  ClientHeight = 332
  ClientWidth = 566
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label6: TLabel
    Left = 74
    Top = 16
    Width = 148
    Height = 13
    Caption = #27880#20837#21518','#20462#25913#26412#31243#24207#19968#20123#20449#24687
  end
  object Label8: TLabel
    Left = 320
    Top = 16
    Width = 149
    Height = 13
    Caption = #27880#20837#21518','#36890#36807'CE'#33050#26412#25913#21464#25112#26007
  end
  object Panel1: TPanel
    Left = 8
    Top = 62
    Width = 257
    Height = 216
    Caption = 'Panel1'
    Ctl3D = False
    ParentCtl3D = False
    ShowCaption = False
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 7
      Width = 78
      Height = 13
      Caption = 'Hook API'#27979#35797
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 16
      Top = 40
      Width = 52
      Height = 13
      Caption = #24403#21069#26102#38388':'
    end
    object TimeLabel: TLabel
      Left = 74
      Top = 40
      Width = 47
      Height = 13
      Caption = 'TimeLabel'
    end
    object Label10: TLabel
      Left = 16
      Top = 80
      Width = 52
      Height = 13
      Caption = #31383#21475#26631#39064':'
    end
    object WinTextLabel: TLabel
      Left = 74
      Top = 80
      Width = 65
      Height = 13
      Caption = 'WinTextLabel'
    end
    object Label12: TLabel
      Left = 16
      Top = 122
      Width = 52
      Height = 13
      Caption = #24377#20986#20449#24687':'
    end
    object MsgEdit: TEdit
      Left = 74
      Top = 120
      Width = 121
      Height = 19
      TabStop = False
      TabOrder = 0
      Text = 'Hello ABC'
    end
    object ShowMsgButton: TButton
      Left = 74
      Top = 145
      Width = 75
      Height = 25
      Caption = #24377#20986#20449#24687
      TabOrder = 1
      OnClick = ShowMsgButtonClick
    end
  end
  object Panel2: TPanel
    Left = 288
    Top = 61
    Width = 257
    Height = 217
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 1
    object Label3: TLabel
      Left = 16
      Top = 8
      Width = 120
      Height = 13
      Caption = 'CE '#33258#21160#27719#32534#33050#26412#27979#35797
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 16
      Top = 64
      Width = 44
      Height = 13
      Caption = ' '#24403#21069'HP:'
    end
    object hpLabel: TLabel
      Left = 105
      Top = 64
      Width = 6
      Height = 13
      Caption = '0'
    end
    object ShowDmgLabel: TLabel
      Left = 152
      Top = 59
      Width = 3
      Height = 13
      Color = clFuchsia
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clFuchsia
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label5: TLabel
      Left = 122
      Top = 40
      Width = 24
      Height = 13
      Caption = #21451#26041
    end
    object Label7: TLabel
      Left = 16
      Top = 96
      Width = 42
      Height = 13
      Caption = #24403#21069'MP:'
    end
    object MPLabel: TLabel
      Left = 104
      Top = 96
      Width = 6
      Height = 13
      Caption = '0'
    end
    object Label9: TLabel
      Left = 10
      Top = 179
      Width = 42
      Height = 13
      Caption = #24403#21069'MP:'
    end
    object AntMpLabel: TLabel
      Left = 98
      Top = 179
      Width = 6
      Height = 13
      Caption = '0'
    end
    object Label11: TLabel
      Left = 10
      Top = 147
      Width = 44
      Height = 13
      Caption = ' '#24403#21069'HP:'
    end
    object AnthpLabel: TLabel
      Left = 99
      Top = 147
      Width = 6
      Height = 13
      Caption = '0'
    end
    object AntShowDmgLabel: TLabel
      Left = 146
      Top = 147
      Width = 3
      Height = 13
      Color = clFuchsia
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clFuchsia
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label14: TLabel
      Left = 124
      Top = 123
      Width = 24
      Height = 13
      Caption = #25932#26041
    end
    object hitButton: TButton
      Left = 174
      Top = 118
      Width = 75
      Height = 25
      Caption = #20114#30456#25915#20987
      TabOrder = 0
      OnClick = hitButtonClick
    end
    object ResetButton: TButton
      Left = 201
      Top = 9
      Width = 40
      Height = 25
      Caption = #37325#32622
      TabOrder = 1
      OnClick = ResetButtonClick
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 184
    Top = 48
  end
  object Timer2: TTimer
    Interval = 400
    OnTimer = Timer2Timer
    Left = 504
    Top = 64
  end
  object Timer3: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = Timer3Timer
    Left = 464
    Top = 64
  end
  object Timer4: TTimer
    Enabled = False
    Left = 376
    Top = 280
  end
end
