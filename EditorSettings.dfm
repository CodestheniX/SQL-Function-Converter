object frmEditorSettings: TfrmEditorSettings
  Left = 0
  Top = 0
  Caption = 'Editor f'#252'r Ausgabe ausw'#228'hlen...'
  ClientHeight = 193
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 160
    Align = alClient
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 131
      Top = 1
      Height = 158
      ExplicitLeft = 173
      ExplicitTop = -4
      ExplicitHeight = 186
    end
    object pnlEditors: TPanel
      Left = 1
      Top = 1
      Width = 130
      Height = 158
      Align = alLeft
      TabOrder = 0
      object lbxEditors: TListBox
        Left = 1
        Top = 31
        Width = 128
        Height = 102
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        Items.Strings = (
          'Standard'
          'Notepad++'
          'vsCode')
        ParentFont = False
        TabOrder = 0
      end
      object pnlEditorsHeader: TPanel
        Left = 1
        Top = 1
        Width = 128
        Height = 30
        Align = alTop
        TabOrder = 1
        object lblEditors: TLabel
          Left = 1
          Top = 1
          Width = 126
          Height = 28
          Align = alClient
          Alignment = taCenter
          Caption = 'Editoren'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          ExplicitWidth = 69
          ExplicitHeight = 19
        end
      end
      object btnEditorButtons: TPanel
        Left = 1
        Top = 133
        Width = 128
        Height = 24
        Align = alBottom
        TabOrder = 2
        object btnAdd: TButton
          Left = 1
          Top = 1
          Width = 65
          Height = 22
          Align = alLeft
          Caption = '+'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object btnDelete: TButton
          Left = 62
          Top = 1
          Width = 65
          Height = 22
          Align = alRight
          Caption = '-'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
      end
    end
    object pnlProperties: TPanel
      Left = 134
      Top = 1
      Width = 371
      Height = 158
      Align = alClient
      TabOrder = 1
      DesignSize = (
        371
        158)
      object lblName: TLabel
        Left = 8
        Top = 40
        Width = 69
        Height = 14
        Caption = 'Bezeichnung'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblPath: TLabel
        Left = 8
        Top = 72
        Width = 24
        Height = 14
        Caption = 'Pfad'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblParameter: TLabel
        Left = 8
        Top = 104
        Width = 56
        Height = 14
        Caption = 'Parameter'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object pnlPropertiesHeader: TPanel
        Left = 1
        Top = 1
        Width = 369
        Height = 30
        Align = alTop
        TabOrder = 0
        object lblProperties: TLabel
          Left = 1
          Top = 1
          Width = 367
          Height = 28
          Align = alClient
          Alignment = taCenter
          Caption = 'Eigenschaften'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          ExplicitWidth = 114
          ExplicitHeight = 19
        end
      end
      object edtName: TEdit
        Left = 88
        Top = 37
        Width = 276
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object edtPath: TEdit
        Left = 88
        Top = 69
        Width = 276
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object edtParameter: TEdit
        Left = 88
        Top = 101
        Width = 276
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
      object chkUseEditor: TCheckBox
        Left = 5
        Top = 132
        Width = 98
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Verwenden'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 4
      end
      object btnTestEditor: TButton
        Left = 289
        Top = 128
        Width = 75
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Testen'
        Constraints.MinWidth = 75
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 5
        TabStop = False
      end
    end
  end
  object pnlBot: TPanel
    Left = 0
    Top = 160
    Width = 506
    Height = 33
    Align = alBottom
    TabOrder = 1
    object pnlButtons: TPanel
      Left = 333
      Top = 1
      Width = 172
      Height = 31
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnCancel: TButton
        Left = 91
        Top = 4
        Width = 75
        Height = 25
        Caption = 'Abbrechen'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ModalResult = 2
        ParentFont = False
        TabOrder = 1
      end
      object btnOK: TButton
        Left = 10
        Top = 4
        Width = 75
        Height = 25
        Caption = 'OK'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ModalResult = 1
        ParentFont = False
        TabOrder = 0
      end
    end
  end
end
