CREATE PROCEDURE %PROC% (IN @Art_Nummer      INTEGER,       //Artikel
                         IN @Bestellmenge    NUMERIC(18,4), --Bestellmenge
                         IN @Ein_Langtext    VARCHAR(20),   /*Einheit */
                         IN @Datum_Test 	 DATE DEFAULT TODAY())  //*** Einheit						 
BEGIN

  DECLARE varEin_Nummer INTEGER;
  
  // Zuerst die Einheit ermitteln
  SELECT FIRST
    Einheit.Ein_Nummer
  INTO
    varEin_Nummer
  FROM Einheit
  WHERE Einheit.Ein_Langtext = @Ein_Langtext
  ORDER BY
    Einheit.Ein_Nummer
  ;
  
  // Nun die benötigten Daten liefern
  SELECT
    IF (varEin_Nummer = Artikel.Ein_Nummer) THEN
      CEILING(@Bestellmenge)
    ELSE
      IF (varEin_Nummer = Artikel.Ein_Nummer_Inhalt) THEN
        CEILING(@Bestellmenge * fn_Einheitsfaktor(Artikel.Art_Inhalt, Artikel.Art_Gewicht, 1, 0))
      ENDIF
    ENDIF                           AS Kolli_Menge,
    EinheitKolli.Ein_Langtext       AS Kolli_Bezeichnung,
    Artikel.Art_Inhalt              AS Art_Inhalt
  FROM Artikel
  LEFT OUTER JOIN Einheit EinheitKolli
               ON EinheitKolli.Ein_Nummer = Artikel.Ein_Nummer
  WHERE Artikel.Art_Nummer = @Art_Nummer
  
END
;