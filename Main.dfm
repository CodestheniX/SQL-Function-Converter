object frmSQLFunctionConverter: TfrmSQLFunctionConverter
  Left = 0
  Top = 0
  Caption = 'SQL Function Converter'
  ClientHeight = 641
  ClientWidth = 1268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = menMain
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 1268
    Height = 641
    Align = alClient
    TabOrder = 0
    object splLeft: TSplitter
      Left = 451
      Top = 1
      Height = 639
      ExplicitLeft = 444
      ExplicitTop = -2
      ExplicitHeight = 638
    end
    object splRight: TSplitter
      Left = 814
      Top = 1
      Height = 639
      ExplicitLeft = 811
      ExplicitTop = 2
      ExplicitHeight = 638
    end
    object pnlInput: TPanel
      Left = 1
      Top = 1
      Width = 450
      Height = 639
      Align = alLeft
      TabOrder = 0
      object lblInput: TLabel
        Left = 1
        Top = 1
        Width = 448
        Height = 29
        Align = alTop
        Alignment = taCenter
        Caption = 'Eingabe'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 95
      end
      object memInput: TMemo
        Left = 1
        Top = 30
        Width = 448
        Height = 567
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object pnlInputButton: TPanel
        Left = 1
        Top = 597
        Width = 448
        Height = 41
        Align = alBottom
        TabOrder = 1
        object btnConvert: TButton
          Left = 1
          Top = 1
          Width = 446
          Height = 39
          Align = alClient
          Caption = 'Konvert'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnConvertClick
        end
      end
    end
    object pnlOutput: TPanel
      Left = 817
      Top = 1
      Width = 450
      Height = 639
      Align = alClient
      TabOrder = 2
      object lblOutput: TLabel
        Left = 1
        Top = 1
        Width = 448
        Height = 29
        Align = alTop
        Alignment = taCenter
        Caption = 'Ausgabe'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 101
      end
      object memOutput: TMemo
        Left = 1
        Top = 30
        Width = 448
        Height = 567
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object pnlOutputButton: TPanel
        Left = 1
        Top = 597
        Width = 448
        Height = 41
        Align = alBottom
        TabOrder = 1
        object btnCopy: TButton
          Left = 1
          Top = 1
          Width = 446
          Height = 39
          Align = alClient
          Caption = 'Kopieren'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnCopyClick
        end
      end
    end
    object pnlParameter: TPanel
      Left = 454
      Top = 1
      Width = 360
      Height = 639
      Align = alLeft
      TabOrder = 1
      object lblParameter: TLabel
        Left = 1
        Top = 1
        Width = 358
        Height = 29
        Align = alTop
        Alignment = taCenter
        Caption = 'Parameter'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 125
      end
      object grdParameter: TStringGrid
        Left = 1
        Top = 30
        Width = 358
        Height = 567
        Align = alClient
        ColCount = 4
        DefaultColWidth = 110
        FixedColor = clAppWorkSpace
        FixedCols = 0
        RowCount = 2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        GridLineWidth = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goColMoving, goEditing, goFixedRowDefAlign]
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnDblClick = grdParameterDblClick
        OnKeyDown = grdParameterKeyDown
        OnMouseMove = grdParameterMouseMove
        OnSelectCell = grdParameterSelectCell
      end
      object pnlParameterButton: TPanel
        Left = 1
        Top = 597
        Width = 358
        Height = 41
        Align = alBottom
        TabOrder = 1
        object btnRefresh: TButton
          Left = 1
          Top = 1
          Width = 356
          Height = 39
          Align = alClient
          Caption = 'Aktualisieren'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnRefreshClick
        end
      end
    end
  end
  object menMain: TMainMenu
    Left = 20
    Top = 33
    object mitDatei: TMenuItem
      Caption = 'Datei'
      object mitLoadScript: TMenuItem
        Caption = 'Skript laden'
        ShortCut = 16460
        OnClick = mitLoadScriptClick
      end
      object mitSaveOutput: TMenuItem
        Caption = 'Ausgabe speichern'
        ShortCut = 16467
        OnClick = mitSaveOutputClick
      end
    end
    object mitBearbeiten: TMenuItem
      Caption = 'Bearbeiten'
      object mitAdjustColumn: TMenuItem
        Caption = 'Spaltenbreite anpassen'
        ShortCut = 112
        OnClick = mitAdjustColumnClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mitConvert: TMenuItem
        Caption = 'Eingabe konvertieren'
        ShortCut = 120
        OnClick = btnConvertClick
      end
      object mitRefresh: TMenuItem
        Caption = 'Ausgabe aktualisieren'
        ShortCut = 116
        OnClick = btnRefreshClick
      end
    end
    object mitOptionen: TMenuItem
      Caption = 'Optionen'
      object mitReturnToSelect: TMenuItem
        Caption = 'Funktion | Return in SELECT umwandeln '
        Checked = True
        OnClick = mitReturnToSelectClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mitShowComments: TMenuItem
        Caption = 'Kommentare im Grid anzeigen'
        Checked = True
        OnClick = mitShowCommentsClick
      end
      object mitStyles: TMenuItem
        Caption = 'Styles'
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object btnClearConfig: TMenuItem
        Caption = 'Konfiguration zur'#252'cksetzen'
        OnClick = btnClearConfigClick
      end
    end
  end
  object dlgSave: TSaveTextFileDialog
    DefaultExt = 'sql'
    Filter = 'SQL-Datei (.sql)|*.sql|Text-Datei (.txt)|*.txt'
    Encodings.Strings = (
      'UTF-8')
    ShowEncodingList = False
    Left = 126
    Top = 33
  end
  object dlgOpen: TOpenDialog
    Filter = 
      'SQL-Dateien (*.sql)|*.sql|Text-Dateien (*.txt)|*.txt|Alle Dateie' +
      'n (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'SQL-Datei ausw'#228'hlen'
    Left = 75
    Top = 33
  end
end
