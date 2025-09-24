CREATE PROCEDURE sp_Artikelsuche_Partie (IN @Suchbegriff        VARCHAR(100) DEFAULT NULL,  //*** Text bzw. Partie (bei numerischer Übergabe)
                         IN @Art_Nummer         INTEGER DEFAULT NULL,       //*** es werden nur Positionen dieses Artikels angezeigt
                         IN @auch_abverkaufte   INTEGER DEFAULT 0,          //*** es werden auch abverkaufte Partien angezeigt 
                                                                            //    -> z.B. für die Partieauswahl in der Reklamationserfassung
                                                                            //    -> nur in Kombination mit einer Artikelnummer zulässig
                         IN @Sto_Nummer         INTEGER DEFAULT NULL,       //*** nur Daten dieses Standorts
                         IN @Gbe_Nummer         INTEGER DEFAULT NULL,       //*** nur für den Geschäftsbereich gültige Artikel
                         IN @bis_Liefertag      DATE DEFAULT '31.12.9999')  //*** es werden nur Partien mit Liefertag <= @bis_Liefertag berücksichtigt
BEGIN

  DECLARE varPartie     INTEGER;
  DECLARE varSuchtext   VARCHAR(100);

  DECLARE LOCAL TEMPORARY TABLE LT_Bestand_Bestellt
   (Ekp_Nummer          INTEGER,
    Art_Nummer          INTEGER,
    Bestand             NUMERIC(18, 4),
    bestellt            NUMERIC(18, 4)
  ) ON COMMIT PRESERVE ROWS;
  
  DECLARE LOCAL TEMPORARY TABLE LT_Verkauf
   (Ekp_Nummer          INTEGER NOT NULL,
    verkauft            NUMERIC(18, 4),
    CONSTRAINT PK_Verkauf PRIMARY KEY (Ekp_Nummer)
  ) ON COMMIT PRESERVE ROWS;
  
  DECLARE LOCAL TEMPORARY TABLE LT_Daten
   (Ekp_Nummer          INTEGER,
    Art_Nummer          INTEGER,
    Agr_Nummer          INTEGER,
    Lan_Kennzeichen     VARCHAR(5),
    verfuegbar          NUMERIC(18, 4),
    Bestand             NUMERIC(18, 4),
    bestellt            NUMERIC(18, 4),
    verkauft            NUMERIC(18, 4)
  ) ON COMMIT PRESERVE ROWS;
  
  
  //*** erstmal nur Partien mit verfügbarem Bestand
  IF @auch_abverkaufte = 0 THEN
 
    IF ISNUMERIC(@Suchbegriff) = 1 THEN
    
      //*** Suche nach Partie
      SET varPartie = @Suchbegriff;
    
      //*** alle Positionen der Partie
      INSERT INTO LT_Bestand_Bestellt
       (Ekp_Nummer,
        Art_Nummer,
        Bestand,
        bestellt)
      SELECT
        EKPosition.Ekp_Nummer,
        EKPosition.Art_Nummer,
        Artikelbestand.Abe_Bestand / ISNULL(Artikelbestand.Abe_Inhalt, 1)     AS Bestand,
        IF  EKBelegart.Eka_Nummer = 1 
        AND EKKopf.Sto_Nummer = ISNULL(@Sto_Nummer, EKKopf.Sto_Nummer)
        THEN 
          EKPosition.Ekp_Kolli 
        ENDIF                                                                   AS bestellt
      FROM EKKopf
      JOIN EKBelegart
        ON EKBelegart.Ekb_Nummer = EKKopf.Ekb_Nummer
      JOIN EKPosition
        ON EKPosition.Ekk_Nummer = EKKopf.Ekk_Nummer
       AND EKPosition.Art_Nummer = ISNULL(@Art_Nummer, EKPosition.Art_Nummer)
      LEFT OUTER JOIN Artikelbestand
                   ON Artikelbestand.Ekp_Nummer = EKPosition.Ekp_Nummer
                  AND Artikelbestand.Sto_Nummer = ISNULL(@Sto_Nummer, Artikelbestand.Sto_Nummer)
      WHERE EKKopf.Ekk_Nummer = varPartie
        AND EKKopf.Ekk_Liefertag <= @bis_Liefertag
        AND ISNULL(Bestand, bestellt, 0) > 0
      ;
  
    ELSE
  
      //*** Suche nach Volltext
      SET varSuchtext = '%' + REPLACE(TRIM(@Suchbegriff), ' ', '%') + '%';
    
      //*** Artikelbestand
      INSERT INTO LT_Bestand_Bestellt
       (Ekp_Nummer,
        Art_Nummer,
        Bestand)
      SELECT
        Artikelbestand.Ekp_Nummer,
        EKPosition.Art_Nummer,
        Artikelbestand.Abe_Bestand / ISNULL(Artikelbestand.Abe_Inhalt, 1) AS Bestand
      FROM Artikelbestand
      JOIN EKPosition
        ON EKPosition.Ekp_Nummer = Artikelbestand.Ekp_Nummer
      WHERE EKPosition.Ekp_Text LIKE varSuchtext
        AND Artikelbestand.Sto_Nummer = ISNULL(@Sto_Nummer, Artikelbestand.Sto_Nummer)
        AND Artikelbestand.Art_Nummer = ISNULL(@Art_Nummer, Artikelbestand.Art_Nummer)
        AND ISNULL(Bestand, 0) > 0
      ;
    
      //*** Bestellungen
      INSERT INTO LT_Bestand_Bestellt
       (Ekp_Nummer,
        Art_Nummer,
        bestellt)
      SELECT
        EKPosition.Ekp_Nummer,
        EKPosition.Art_Nummer,
        EKPosition.Ekp_Kolli
      FROM EKBelegart
      JOIN EKKopf
        ON EKKopf.Ekb_Nummer = EKBelegart.Ekb_Nummer
       AND EKKopf.Ekk_Liefertag <= @bis_Liefertag
       AND EKKopf.Sto_Nummer = ISNULL(@Sto_Nummer, EKKopf.Sto_Nummer)
      JOIN EKPosition
        ON EKPosition.Ekk_Nummer = EKKopf.Ekk_Nummer
       AND EKPosition.Art_Nummer = ISNULL(@Art_Nummer, EKPosition.Art_Nummer)
      WHERE EKBelegart.Eka_Nummer = 1 //<- nur Automatik "Bestellung"
        AND EKPosition.Ekp_Text LIKE varSuchtext
        AND ISNULL(EKPosition.Ekp_Kolli, 0) > 0
      ;
  
    END IF
    ;
  
    //*** Verkaufsmengen ermitteln
    INSERT INTO LT_Verkauf
     (Ekp_Nummer,
      verkauft)
    SELECT
      LT_Bestand_Bestellt.Ekp_Nummer,
      SUM(
            AuftragPosition.Aup_Menge
          * fn_Einheitsfaktor(AuftragPosition.Aup_Inhalt,
                              AuftragPosition.Aup_Gewicht,
                              AuftragPosition.Aup_Preiseinheit,
                              0)
          ) AS verkauft
    FROM LT_Bestand_Bestellt
    JOIN AuftragPosition
      ON AuftragPosition.Ekp_Nummer = LT_Bestand_Bestellt.Ekp_Nummer
    JOIN Auftrag
      ON Auftrag.Auf_Nummer = AuftragPosition.Auf_Nummer
     AND Auftrag.Sto_Nummer = ISNULL(@Sto_Nummer, Auftrag.Sto_Nummer)
    WHERE NOT EXISTS(SELECT 1
                     FROM ArtikelbestandAbgebucht
                     WHERE ArtikelbestandAbgebucht.Aup_Nummer = AuftragPosition.Aup_Nummer)
    GROUP BY
      LT_Bestand_Bestellt.Ekp_Nummer
    HAVING ISNULL(verkauft, 0) <> 0
    ;
    
  END IF
  ;
  
  //*** abverkaufte Partien ermitteln, wenn 
  IF (@auch_abverkaufte = 1)                                                            //<- dies gewünscht wird
  OR ((@Art_Nummer IS NOT NULL) 
       AND 
       NOT EXISTS(SELECT 1 
                  FROM LT_Bestand_Bestellt
                  LEFT OUTER JOIN LT_Verkauf
                               ON LT_Verkauf.Ekp_Nummer = LT_Bestand_Bestellt.Ekp_Nummer
                  WHERE (  ISNULL(LT_Bestand_Bestellt.Bestand, 0)
                         + ISNULL(LT_Bestand_Bestellt.bestellt, 0)
                         - ISNULL(LT_Verkauf.verkauft, 0)
                        ) > 0)
     ) //<- oder genau ein Artikel gesucht wird und keine Partien mehr verfügbaren Bestand haben
  THEN

    INSERT INTO LT_Bestand_Bestellt
     (Ekp_Nummer,
      Art_Nummer)
    SELECT
      EKPosition.Ekp_Nummer,
      EKPosition.Art_Nummer
    FROM EKPosition
    JOIN EKKopf
      ON EKKopf.Ekk_Nummer = EKPosition.Ekk_Nummer
     AND EKKopf.Sto_Nummer = ISNULL(@Sto_Nummer, EKKopf.Sto_Nummer)
    JOIN EKBelegart
      ON EKBelegart.Ekb_Nummer = EKKopf.Ekb_Nummer
     AND EKBelegart.Eka_Nummer NOT IN (1, 3) //<- Automatik "Bestellung" und "Annahme verweigert" interessiert nicht
    WHERE EKPosition.Art_Nummer = @Art_Nummer
    ;
  
    //*** damit auch die Partien ohne verfügbare Menge geliefert werden
    SET @auch_abverkaufte = 1;
  
  END IF
  ;
  
  //*** Ergebnis bereitstellen
  INSERT INTO LT_Daten
   (Ekp_Nummer,
    Art_Nummer,
    Agr_Nummer,
    Lan_Kennzeichen,
    verfuegbar,
    Bestand,
    bestellt,
    verkauft)
  SELECT
    LT_Bestand_Bestellt.Ekp_Nummer,
    LT_Bestand_Bestellt.Art_Nummer,
    Artikel.Agr_Nummer,
    Land.Lan_Kennzeichen,
    
      ISNULL(LT_Bestand_Bestellt.Bestand, 0)
    + ISNULL(LT_Bestand_Bestellt.bestellt, 0)
    - ISNULL(LT_Verkauf.verkauft, 0)            AS verfuegbar,
    
    LT_Bestand_Bestellt.Bestand,
    LT_Bestand_Bestellt.bestellt,
    
    IF ISNULL(LT_Verkauf.verkauft, 0) <> 0 THEN
      LT_Verkauf.verkauft
    ENDIF
    
  FROM LT_Bestand_Bestellt
  JOIN Artikel
    ON Artikel.Art_Nummer = LT_Bestand_Bestellt.Art_Nummer
  JOIN Artikelgruppe
    ON Artikelgruppe.Agr_Nummer = Artikel.Agr_Nummer
   AND Artikelgruppe.Agr_Leergut = 0 //<- Leergut weg lassen
  LEFT OUTER JOIN Land
               ON Land.Lan_Nummer = Artikel.Lan_Nummer
  LEFT OUTER JOIN LT_Verkauf
               ON LT_Verkauf.Ekp_Nummer = LT_Bestand_Bestellt.Ekp_Nummer
  WHERE ((verfuegbar <> 0) OR (@auch_abverkaufte = 1))
  ;  

  //*** Artikel ohne Bestandsführung löschen
  IF (@Art_Nummer IS NULL) THEN
    DELETE FROM LT_Daten
    FROM LT_Daten
    JOIN Artikel
      ON Artikel.Art_Nummer = LT_Daten.Art_Nummer
    JOIN Artikelgruppe
      ON Artikelgruppe.Agr_Nummer = Artikel.Agr_Nummer
     AND Artikelgruppe.Agr_keineBestandsfuehrung = 1
    ;
  END IF
  ;

  //*** Artikel, die nicht für den Geschäftsbereich gültig sind, entfernen
  IF (@Gbe_Nummer IS NOT NULL) THEN 
    DELETE FROM LT_Daten
    FROM LT_Daten
    JOIN Artikel
      ON Artikel.Art_Nummer = LT_Daten.Art_Nummer
    WHERE NOT EXISTS(SELECT 1 
                     FROM ArtikelGeschaeftsbereich 
                     WHERE ArtikelGeschaeftsbereich.Art_Nummer = LT_Daten.Art_Nummer
                       AND ArtikelGeschaeftsbereich.Gbe_Nummer = @Gbe_Nummer
                       AND ArtikelGeschaeftsbereich.Agb_aktiv = 1)
    ;  
  END IF
  ;

  //*************************************************************************************
  //*************  ACHTUNG - NEUE SPALTEN ANS ENDE STELLEN!!  ***************************
  //*************************************************************************************
  //*** Ergebnis zurückliefern
  SELECT 
    IFNULL(LT_Daten.Art_Nummer, Artikelgruppe.Agr_Bezeichnung, REPLACE(REPLACE(EKPosition.Ekp_Text, '\x0A', ' '), '\x0D', ' ')) AS "Bezeichnung",
    LT_Daten.Lan_Kennzeichen                                                                    AS "Land",
    LT_Daten.verfuegbar                                                                         AS "verfügbar (Kolli)",
    Lieferant.Lie_Kurzbezeichnung                                                               AS "Lieferant",
    EKKopf.Ekk_Liefertag                                                                        AS "Liefertag",
    EKPosition.Ekk_Nummer                                                                       AS "Partie",
    EKPosition.Ekp_Charge                                                                       AS "Charge",
    EKBelegart.Ekb_Bezeichnung                                                                  AS "Belegstatus",
    LT_Daten.Bestand                                                                            AS "Bestand",
    LT_Daten.bestellt                                                                           AS "bestellt",
    LT_Daten.verkauft                                                                           AS "verkauft",
    Standort.Sto_Bezeichnung                                                                    AS "Standort",
    LT_Daten.Ekp_Nummer                                                                         AS "hidden_Ekp_Nummer",
    LT_Daten.Art_Nummer                                                                         AS "hidden_Art_Nummer",
    EKPosition.Ekp_MHD                                                                          AS "MHD"
  FROM LT_Daten
  JOIN Artikelgruppe
    ON Artikelgruppe.Agr_Nummer = LT_Daten.Agr_Nummer
  LEFT OUTER JOIN EKPosition
               ON EKPosition.Ekp_Nummer = LT_Daten.Ekp_Nummer
  LEFT OUTER JOIN Artikel
               ON Artikel.Art_Nummer = LT_Daten.Art_Nummer
  LEFT OUTER JOIN EKKopf
               ON EKKopf.Ekk_Nummer = EKPosition.Ekk_Nummer
  LEFT OUTER JOIN EKBelegart
               ON EKBelegart.Ekb_Nummer = EKKopf.Ekb_Nummer
  LEFT OUTER JOIN Lieferant
               ON Lieferant.Lie_Nummer = EKKopf.Lie_Nummer
  LEFT OUTER JOIN Standort
               ON Standort.Sto_Nummer = EKKopf.Sto_Nummer
  ORDER BY
    EKKopf.Ekk_Liefertag,
    EKPosition.Ekk_Nummer,
    EKPosition.Sort,
    EKBelegart.Sort DESC,
    Artikel.Art_Bezeichnung,
    Artikel.Art_Nummer,
    EKKopf.Ekk_Liefertag,
    EKPosition.Ekk_Nummer,
    LT_Daten.Ekp_Nummer
  ;

END
;