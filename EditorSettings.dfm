object frmEditorSettings: TfrmEditorSettings
  Left = 0
  Top = 0
  Caption = 'Editor f'#252'r Ausgabe ausw'#228'hlen...'
  ClientHeight = 191
  ClientWidth = 462
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
    Width = 462
    Height = 158
    Align = alClient
    TabOrder = 0
    ExplicitTop = -1
    ExplicitWidth = 401
    ExplicitHeight = 188
    object Splitter1: TSplitter
      Left = 137
      Top = 1
      Height = 156
      ExplicitLeft = 173
      ExplicitTop = -4
      ExplicitHeight = 186
    end
    object pnlEditors: TPanel
      Left = 1
      Top = 1
      Width = 136
      Height = 156
      Align = alLeft
      TabOrder = 0
      ExplicitHeight = 186
      object lbxEditors: TListBox
        Left = 1
        Top = 31
        Width = 134
        Height = 124
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        Items.Strings = (
          'Notepad++'
          'Standard'
          'vsCode')
        ParentFont = False
        TabOrder = 0
        ExplicitLeft = 16
        ExplicitTop = 48
        ExplicitWidth = 121
        ExplicitHeight = 97
      end
      object pnlEditorsHeader: TPanel
        Left = 1
        Top = 1
        Width = 134
        Height = 30
        Align = alTop
        TabOrder = 1
        ExplicitWidth = 174
        object lblEditors: TLabel
          Left = 1
          Top = 1
          Width = 132
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
    end
    object pnlProperties: TPanel
      Left = 140
      Top = 1
      Width = 321
      Height = 156
      Align = alClient
      TabOrder = 1
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 395
      ExplicitHeight = 186
      DesignSize = (
        321
        156)
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
        Top = 70
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
        Top = 100
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
        Width = 319
        Height = 30
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 221
        object lblProperties: TLabel
          Left = 1
          Top = 1
          Width = 317
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
        Width = 226
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        ExplicitWidth = 302
      end
      object edtPath: TEdit
        Left = 88
        Top = 67
        Width = 226
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        ExplicitWidth = 302
      end
      object edtParameter: TEdit
        Left = 88
        Top = 97
        Width = 226
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        ExplicitWidth = 302
      end
    end
  end
  object pnlBot: TPanel
    Left = 0
    Top = 158
    Width = 462
    Height = 33
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 188
    ExplicitWidth = 426
    object pnlButtons: TPanel
      Left = 289
      Top = 1
      Width = 172
      Height = 31
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitLeft = 224
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
