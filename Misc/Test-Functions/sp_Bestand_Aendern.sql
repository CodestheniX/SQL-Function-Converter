CREATE PROCEDURE sp_Bestand_Aendern(IN  @ArtikelNr  INTEGER,        //Artikelnummer
                                    IN  @Bestand    NUMERIC(18, 4), //Bestand in Preiseinheit
                                    OUT @StatusCode INTEGER         //0 = OK, 1 = Nicht gefunden, 2 = Gesperrt
)
BEGIN
  //Initialisierung des Rückgabewertes
  SET @StatusCode = 0; //Alles gut

  //Status setzen basierend auf Existenz im Artikelstamm
  IF NOT EXISTS (SELECT 1 FROM Artikel WHERE Nr = @ArtikelNr) THEN
    SET @StatusCode = 1;
  ELSE
    IF (SELECT Artikel.Sperre FROM Artikel WHERE Nr = @ArtikelNr) IS NOT NULL THEN
      SET @StatusCode = 2;
    ELSE
      //Bestand aktualisieren
      UPDATE Artikelbestand 
      SET Bestand = ISNULL(@Bestand, 0)
      WHERE ArtikelNr = @ArtikelNr
      ;
    END IF
    ;
  END IF
  ;
 
END;