object frmEditorSettings: TfrmEditorSettings
  Left = 0
  Top = 0
  Caption = 'Editor f'#252'r Ausgabe ausw'#228'hlen...'
  ClientHeight = 221
  ClientWidth = 426
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
    Width = 426
    Height = 188
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 72
    ExplicitTop = 32
    ExplicitWidth = 185
    ExplicitHeight = 41
    object lbxEditors: TListBox
      Left = 40
      Top = 24
      Width = 121
      Height = 97
      ItemHeight = 15
      Items.Strings = (
        'Notepad++'
        'Standard'
        'vsCode')
      TabOrder = 0
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 188
    Width = 426
    Height = 33
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 180
    object btnOK: TButton
      Left = 263
      Top = 5
      Width = 75
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 344
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
