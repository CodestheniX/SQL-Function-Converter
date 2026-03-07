unit ConverterConst;

{ TODO -c:
  Must
    -

   Should
    - Error-Handling beim Konvert

   Could
    - Doppelklick => Editor
    => 27.01.26 - Hier weiter machen!
}


{ DONE -c:
  Must
    - GridToParameter
    - Zeilen ohne Daten (Nur Kommentare)
    - IN @.. ; OUT @...
      (Wird aber aktuell wie ein Input-Parameter behandelt)
    - GridParameterToOutput
      - OUT-Parameter => Mit dem Handling weiter machen!!

   Should
    - Shortcuts für die Buttons
    - Enter im Grid: Zeile runter
    - Nach Konvert -> 3. Column markieren
    - Größe speichern und reseten

   Could
    - Kommentare speichern und dann anzeigen
    - Buzzwords farblich kennzeichnen
      => Lassen wir weg - Die Memo kann keinen Richtext und TSynEdit ist nicht Style-aware...
}

interface

const
  //*** Form
  PROGRAMM_NAME           = 'SQL Function Converter';
  DEFAULT_STYLE           = 'Amakrits';
  FRM_HEIGHT              = 700;
  FRM_WIDTH               = 1284;
  PNL_INPUT_WIDTH         = 450;
  PNL_PARAMETER_WIDTH     = 360;
  PNL_OUTPUT_WIDTH        = 450;
  MIN_COL_WIDTH           = 110;
  MIN_COL_WIDTH_DIRECTION =  40;


  //*** Fx_Settings.ini: Sections & Keys der Konfiguration
  CONFIG_FILENAME = 'Fx_Settings.ini';
  //Section: Form
  CONFIG_SEC_FORM              = 'Form';
  CONFIG_KEY_STYLE             = 'Style';
  CONFIG_KEY_HEIGHT            = 'Height';
  CONFIG_KEY_WIDTH             = 'Width';
  CONFIG_KEY_SHOWCOMMENTS      = 'ShowComments';
  CONFIG_KEY_PNLINPUTWIDTH     = 'pnlInputWidth';
  CONFIG_KEY_PNLPARAMETERWIDTH = 'pnlParameterWidth';
  CONFIG_KEY_PNLOUTPUTWIDTH    = 'pnlOutputWidth';

  //Section: Output
  CONFIG_SEC_OUTPUT         = 'Output';
  CONFIG_KEY_RETURNTOSELECT = 'ReturnToSelect';


  //*** Fx_Editors.ini: Sections & Keys der Editorsettings
  EDITORS_FILENAME = 'Fx_Editors.ini';
  //Section: Editor
  EDITORS_SEC_EDITOR = 'Editor';
  EDITORS_KEY_ACTIVE = 'Active';

  //Section: Editor_...
  EDITORS_SEC_EDITOR_X  = 'Editor_';
  EDITORS_KEY_PATH      = 'Path';
  EDITORS_KEY_PARAMETER = 'Parameter';


  //*** Ermittlung des Dateinamen
  CREATE_FUNCTION     = 'CREATE FUNCTION ';
  CREATE_PROCEDURE    = 'CREATE PROCEDURE ';


  //*** Parameter (Kopf)
  PARAMETER_START     = '@';
  PARAMETER_END       = ')';
  PARAMETER_DELIMITER = ',';
  FUNCTION_END        = 'RETURNS';
  PROCEDURE_START     = 'BEGIN';
  DEFAULT_START       = ' DEFAULT ';
  DECLARE             = 'DECLARE';


  //*** Grid "Variablen"
  COL_DIRECTION = 0;
  COL_NAME      = 1;
  COL_DATATYPE  = 2;
  COL_VALUE     = 3;
  COL_COMMENT   = 4;


  //*** Sonstiges
  CR   = #13;
  CRLF = #13#10;
  SELECTED_EDITOR_SYMBOL = '►';

implementation

end.
