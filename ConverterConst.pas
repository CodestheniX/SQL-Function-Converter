unit ConverterConst;

{ TODO -c:
  Must
    - GridParameterToOutput -> Hier weiter
      - OUT-Parameter

   Should
    - Input-Parameter im Grid anders kennzeichnen
    - Error-Handling beim Konvert

   Could
    - Doppelklick => Editor
}


{ DONE -c:
  Must
    - GridToParameter
    - Zeilen ohne Daten (Nur Kommentare)
    - IN @.. ; OUT @...
      (Wird aber aktuell wie ein Input-Parameter behandelt)

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

  //*** Sections & Keys der Konfiguratipn (Ini-Datei)
  //Section: Form
  INI_SEC_FORM              = 'Form';
  INI_KEY_STYLE             = 'Style';
  INI_KEY_HEIGHT            = 'Height';
  INI_KEY_WIDTH             = 'Width';
  INI_KEY_SHOWCOMMENTS      = 'ShowComments';
  INI_KEY_PNLINPUTWIDTH     = 'pnlInputWidth';
  INI_KEY_PNLPARAMETERWIDTH = 'pnlParameterWidth';
  INI_KEY_PNLOUTPUTWIDTH    = 'pnlOutputWidth';

  //Section: Output
  INI_SEC_OUTPUT         = 'Output';
  INI_KEY_RETURNTOSELECT = 'ReturnToSelect';

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
  CR    = #13;
  CRLF  = #13#10;

implementation

end.
