CREATE PROCEDURE sp_Inventur_Erstellen_Kontrollliste (IN @Ikl_Nummer   INTEGER,    //--- Primary der Tabelle InventurKontrollliste
                         IN @Gru_Nummer   INTEGER,    //--- Gruppe.Gru_Nummer
                         OUT @Ink_Nummer  INTEGER)    //--- Ausgabewert: Primary der neuen Inventur.
BEGIN

  //*** Rückgabewert für den Primary der neuen Inventur *************************************************************************************************
  DECLARE varInk_Nummer INTEGER;
  
  //*** Temp-Tables für Artikel und Lagerplätze *********************************************************************************************************
  DECLARE LOCAL TEMPORARY TABLE LT_Filter_Artikel
   (Art_Nummer              INTEGER NOT NULL,
  CONSTRAINT PK_Main PRIMARY KEY (Art_Nummer))
  ON COMMIT PRESERVE ROWS;  

  DECLARE LOCAL TEMPORARY TABLE LT_Filter_Lagerplatz
   (Lpl_Nummer              INTEGER NOT NULL,
  CONSTRAINT PK_Main PRIMARY KEY (Lpl_Nummer))
  ON COMMIT PRESERVE ROWS;
  
  //*** Temp-Tables befüllen ****************************************************************************************************************************
  INSERT INTO LT_Filter_Artikel
   (Art_Nummer)
  SELECT
    InventurKontrolllisteArtikel.Art_Nummer
  FROM InventurKontrolllisteArtikel
  WHERE InventurKontrolllisteArtikel.Ikl_Nummer = @Ikl_Nummer
  ;
  
  INSERT INTO LT_Filter_Lagerplatz
   (Lpl_Nummer)
  SELECT
    Lagerplatz.Lpl_Nummer
  FROM Lagerplatz
  ;

 
  //*** Einen neuen Primary für die Tabelle "Inventur" holen ********************************************************************************************
  SET varInk_Nummer = fn_NextNumber('Inventur');
  
  //*** Einen Eintrag in der Tabelle "Inventur" erstellen ***********************************************************************************************
  INSERT INTO Inventur
  ( Ink_Nummer,
    Ikl_Nummer,
    Gru_Nummer,
    Ink_Status
  )
  VALUES
  (
    varInk_Nummer,
    @Ikl_Nummer,
    @Gru_Nummer,
    0
  );
  
  //*** Alle Positionen für diese Inventur in der Tabelle "InventurPosition" eintragen ******************************************************************
  INSERT INTO InventurPosition
  ( Ink_Nummer,
    Lpl_Nummer,
    Art_Nummer,
    Ekp_Nummer,
    Abe_Nummer,
    Pbe_Nummer,
    Inp_Ueberschrift,
    Inp_Kolli_Soll,
    Inp_Rest_Soll
  )
  SELECT varInk_Nummer,
    sp_Lagerbestand.Lpl_Nummer,
    sp_Lagerbestand.Artikel,
    sp_Lagerbestand.Ekp_Nummer,
    sp_Lagerbestand.Abe_Nummer,
    NULL, // --->Pbe_Nummer,
    sp_Lagerbestand.Ueberschrift,
    sp_Lagerbestand.Kolli,
    sp_Lagerbestand.Rest
  FROM sp_Lagerbestand
  (
    1,       //--- Sto_Nummer 
    1,       //--- 1 = es werden nur Artikel mit Bestand geliefert
    1,       //--- 1 = Chargen werden zusätzlich detailliert geliefert //A_14438 Jork-633: AU28 Inventur_Bestandkorrekturen nur noch chargengenau
    NULL,    //--- nur Chargen mit Restlaufzeit unter diesem Prozentsatz
    1,       //--- 1 = Artikel mit VK-Sperre werden auch geliefert (wenn sie Bestand haben, werden sie grundsätzlich geliefert)
    1,       //--- 1 = Artikel mit Vollsperre werden auch geliefert
    0        //--- 0 = Lagerplatz, 1 = Artikelnummer, 2 = Sortiert nach Lidl-Artikelnummer  
  );

  //*** Die Lagerüberschriftszeilen löschen *************************************************************************************************************
  DELETE FROM InventurPosition WHERE 
    InventurPosition.Art_Nummer IS NULL 
    AND InventurPosition.Ink_Nummer = varInk_Nummer
  ;
  
  //*** Alle Artikel welcher in einer anderen noch nicht gebuchten Inventur des heutigen Tages stehen, wieder entfernen *********************************
  DELETE FROM InventurPosition WHERE
    InventurPosition.Ink_Nummer = varInk_Nummer
    AND InventurPosition.Art_Nummer IN (SELECT X.Art_Nummer 
                                        FROM  InventurPosition X
                                        LEFT OUTER JOIN Inventur
                                                     ON Inventur.Ink_Nummer = X.Ink_Nummer
                                        WHERE Inventur.Datum_Anlage >= TODAY() 
                                          AND Inventur.Ink_Status < 2
                                          AND Inventur.Ink_Nummer <> varInk_Nummer
                                       )
  ;

  //*** Den virtuellen Warenannahme-Platz löschen ***
  DELETE FROM InventurPosition WHERE 
    InventurPosition.Lpl_Nummer = (SELECT Firma.Lpl_Nummer_ViWA 
                                   FROM Firma
                                  )
  ;

  //*** Wenn es sowohl eine Artikelzeile und auch eine Chargenzeile für ein und denselben Artikel gibt, dann die Artikelzeile löschen *******************
  //*** A_14438 Jork-633: AU28 Inventur_Bestandkorrekturen nur noch chargengenau.
  DELETE FROM InventurPosition 
  FROM InventurPosition 
  WHERE InventurPosition.Ink_Nummer = varInk_Nummer
    AND (SELECT COUNT(*) 
         FROM InventurPosition IP
         WHERE IP.Art_Nummer = InventurPosition.Art_Nummer
           AND IP.Lpl_Nummer = InventurPosition.Lpl_Nummer) > 1
    AND InventurPosition.Abe_Nummer IS NULL
  ;
  
  //*** Wenn es Palettenbestände gibt, dann die Pbe_Nummer auch zur Inventurposition hinzufügen *********************************************************
  UPDATE Inventurposition SET
    Inventurposition.Pbe_Nummer = (SELECT FIRST Palettenbestand.Pbe_Nummer 
                                   FROM Palettenbestand 
                                   WHERE palettenbestand.Art_Nummer = Inventurposition.Art_Nummer 
                                     AND Palettenbestand.Ekp_Nummer = Inventurposition.Ekp_Nummer 
                                     AND Palettenbestand.Lpl_Nummer = Inventurposition.Lpl_Nummer
                                  )
  WHERE Inventurposition.Ink_Nummer = varInk_Nummer;

  //*** Rückgabewert der StoredProcedure ****************************************************************************************************************
  SELECT varInk_Nummer INTO @Ink_Nummer;  
  
END;