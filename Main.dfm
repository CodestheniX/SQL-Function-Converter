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
      object synInput: TSynEdit
        Left = 1
        Top = 30
        Width = 448
        Height = 567
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Source Code Pro'
        Font.Style = []
        Font.Quality = fqClearTypeNatural
        ParentColor = True
        PopupMenu = popInput
        TabOrder = 0
        UseCodeFolding = False
        ExtraLineSpacing = 1
        Gutter.DigitCount = 2
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Consolas'
        Gutter.Font.Style = []
        Gutter.ShowLineNumbers = True
        Gutter.GradientSteps = 2
        Gutter.Bands = <
          item
            Kind = gbkMarks
            Width = 13
          end
          item
            Kind = gbkLineNumbers
          end
          item
            Kind = gbkFold
          end
          item
            Kind = gbkTrackChanges
          end
          item
            Kind = gbkMargin
            Width = 3
          end>
        Highlighter = SynSQLHighlighter
        RightEdge = 0
        RightEdgeColor = clNone
        SelectedColor.Background = clSlategray
        SelectedColor.Alpha = 0.250000000000000000
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
      object pnlOutputButton: TPanel
        Left = 1
        Top = 597
        Width = 448
        Height = 41
        Align = alBottom
        TabOrder = 1
        object btnOpenOutput: TButton
          Left = 1
          Top = 1
          Width = 446
          Height = 39
          Align = alClient
          Caption = 'Im Editor '#246'ffnen'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnOpenOutputClick
        end
      end
      object synOutput: TSynEdit
        Left = 1
        Top = 30
        Width = 448
        Height = 567
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Source Code Pro'
        Font.Style = []
        Font.Quality = fqClearTypeNatural
        ParentColor = True
        PopupMenu = popOutput
        TabOrder = 0
        UseCodeFolding = False
        ExtraLineSpacing = 1
        Gutter.DigitCount = 2
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Consolas'
        Gutter.Font.Style = []
        Gutter.ShowLineNumbers = True
        Gutter.GradientSteps = 2
        Gutter.Bands = <
          item
            Kind = gbkMarks
            Width = 13
          end
          item
            Kind = gbkLineNumbers
          end
          item
            Kind = gbkFold
          end
          item
            Kind = gbkTrackChanges
          end
          item
            Kind = gbkMargin
            Width = 3
          end>
        Highlighter = SynSQLHighlighter
        RightEdge = 0
        RightEdgeColor = clNone
        SelectedColor.Background = clSlategray
        SelectedColor.Alpha = 0.250000000000000000
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
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        ExplicitWidth = 125
      end
      object grdParameter: TStringGrid
        Left = 1
        Top = 30
        Width = 358
        Height = 567
        Align = alClient
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
    Left = 492
    Top = 529
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
      object N4: TMenuItem
        Caption = '-'
      end
      object mitEditorConfig: TMenuItem
        Caption = 'Editoren verwalten'#8230
        OnClick = mitEditorConfigClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object mitStyles: TMenuItem
        Caption = 'Design/Theme'
      end
      object mitOpenConfigPath: TMenuItem
        Caption = 'Konfigurationsverzeichnis '#246'ffnen'
        OnClick = mitOpenConfigPathClick
      end
      object mitClearConfig: TMenuItem
        Caption = 'Konfiguration zur'#252'cksetzen'
        OnClick = mitClearConfigClick
      end
    end
    object mitBearbeiten: TMenuItem
      Caption = 'Bearbeiten'
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
      object N1: TMenuItem
        Caption = '-'
      end
      object mitAdjustColumn: TMenuItem
        Caption = 'Spaltenbreite anpassen'
        ShortCut = 112
        OnClick = mitAdjustColumnClick
      end
    end
    object mitOptionen: TMenuItem
      Caption = 'Konvertierung'
      object mitShowComments: TMenuItem
        Caption = 'Kommentare im Grid anzeigen'
        Checked = True
        OnClick = mitShowCommentsClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mitReturnToSelect: TMenuItem
        Caption = 'RETURN && OUT '#8594' SELECT'
        Checked = True
        OnClick = mitReturnToSelectClick
      end
      object mitConvertComments: TMenuItem
        Caption = 'Kommentare: //** '#8594' --'
        Checked = True
        OnClick = mitConvertCommentsClick
      end
    end
  end
  object dlgSave: TSaveTextFileDialog
    DefaultExt = 'sql'
    Filter = 'SQL-Datei (.sql)|*.sql|Text-Datei (.txt)|*.txt'
    Encodings.Strings = (
      'UTF-8')
    ShowEncodingList = False
    Left = 598
    Top = 529
  end
  object dlgOpen: TOpenDialog
    Filter = 
      'SQL-Dateien (*.sql)|*.sql|Text-Dateien (*.txt)|*.txt|Alle Dateie' +
      'n (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'SQL-Datei ausw'#228'hlen'
    Left = 547
    Top = 529
  end
  object SynSQLHighlighter: TSynSQLSyn
    SQLDialect = sqlSybase
    Left = 675
    Top = 529
  end
  object popInput: TPopupMenu
    Left = 491
    Top = 468
    object popInputUndo: TMenuItem
      Caption = 'R'#252'ckg'#228'ngig'
      OnClick = popUndoClick
    end
    object popInputRedo: TMenuItem
      Caption = 'Wiederholen'
      OnClick = popRedoClick
    end
    object pI1: TMenuItem
      Caption = '-'
    end
    object popInputCut: TMenuItem
      Caption = 'Ausschneiden'
      OnClick = popCutClick
    end
    object popInputCopy: TMenuItem
      Caption = 'Kopieren'
      OnClick = popCopyClick
    end
    object popInputInsert: TMenuItem
      Caption = 'Einf'#252'gen'
      OnClick = popInsertClick
    end
  end
  object popOutput: TPopupMenu
    Left = 558
    Top = 468
    object popOutputUndo: TMenuItem
      Caption = 'R'#252'ckg'#228'ngig'
      OnClick = popUndoClick
    end
    object popOutputRedo: TMenuItem
      Caption = 'Wiederholen'
      OnClick = popRedoClick
    end
    object pO1: TMenuItem
      Caption = '-'
    end
    object popOutputCut: TMenuItem
      Caption = 'Ausschneiden'
      OnClick = popCutClick
    end
    object popOutputCopy: TMenuItem
      Caption = 'Kopieren'
      OnClick = popCopyClick
    end
    object popOutputInsert: TMenuItem
      Caption = 'Einf'#252'gen'
      OnClick = popInsertClick
    end
    object pO2: TMenuItem
      Caption = '-'
    end
    object popOutputOpen: TMenuItem
      Caption = 'Im Editor '#246'ffnen'
      OnClick = btnOpenOutputClick
    end
  end
end
