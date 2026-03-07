object frmEditorSettings: TfrmEditorSettings
  Left = 0
  Top = 0
  Caption = 'Editor f'#252'r Ausgabe ausw'#228'hlen...'
  ClientHeight = 185
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 152
    Align = alClient
    TabOrder = 0
    object splMain: TSplitter
      Left = 131
      Top = 1
      Height = 150
      ExplicitLeft = 173
      ExplicitTop = -4
      ExplicitHeight = 186
    end
    object pnlEditors: TPanel
      Left = 1
      Top = 1
      Width = 130
      Height = 150
      Align = alLeft
      TabOrder = 0
      object lbxEditors: TListBox
        Left = 1
        Top = 31
        Width = 128
        Height = 94
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
        OnClick = lbxEditorsClick
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
        Top = 125
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
          OnClick = btnAddClick
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
          OnClick = btnDeleteClick
        end
      end
    end
    object pnlProperties: TPanel
      Left = 134
      Top = 1
      Width = 371
      Height = 150
      Align = alClient
      TabOrder = 1
      TabStop = True
      DesignSize = (
        371
        150)
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
        Top = 36
        Width = 275
        Height = 22
        Hint = 
          'Erlaubte Zeichen:'#13#10'A-Z, a-z, 0-9 und + - _ ! ? % $ & < > # * ~ (' +
          ' )'
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 25
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtNameExit
      end
      object edtPath: TEdit
        Left = 88
        Top = 69
        Width = 254
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnExit = edtPathExit
      end
      object chkUseEditor: TCheckBox
        Left = 5
        Top = 100
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
        OnClick = chkUseEditorClick
      end
      object btnTestEditor: TButton
        Left = 290
        Top = 120
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
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
        OnClick = btnTestEditorClick
      end
      object btnSelectPath: TButton
        Left = 341
        Top = 69
        Width = 22
        Height = 22
        Anchors = [akTop, akRight]
        Caption = '...'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = btnSelectPathClick
      end
    end
  end
  object pnlBot: TPanel
    Left = 0
    Top = 152
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
  object dlgOpen: TOpenDialog
    Filter = 'Ausf'#252'hrbare Dateien (*.exe)|*.exe|Alle Dateien (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Editor-Datei ausw'#228'hlen'
    Left = 89
    Top = 35
  end
end
