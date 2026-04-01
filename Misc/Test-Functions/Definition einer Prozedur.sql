CREATE PROCEDURE %PROC% (IN @Volltext    VARCHAR(256) DEFAULT NULL, //*** Volltext-Suche nach Bezeichnung
                         IN @mit_Bestand INTEGER DEFAULT 0,         //*** 1 = Nur Artikel mit Bestand
                         IN @Liefertag   DATE DEFAULT TODAY()       //*** Liefertag für Preisfindung & Bestandermittlung
                        )
BEGIN

  DECLARE Suche_numerisch INTEGER;
  DECLARE Text LONG VARCHAR;

  DECLARE LOCAL TEMPORARY TABLE LT_Artikel
   (ArtikelNr INTEGER,
    Preis     NUMERIC(18, 4)
   )
  ON COMMIT PRESERVE ROWS;

  SET Suche_numerisch = 1;
  SET Zeichen = @Volltext;

  --Nur ein Beispiel ;-)

END
;