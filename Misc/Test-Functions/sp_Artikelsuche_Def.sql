CREATE PROCEDURE %PROC% (IN @Volltext       VARCHAR(100) DEFAULT NULL,  //*** Volltext-Suche nach Artikelbezeichnung (wird ignoriert bei @mit_Preis =2)
                         IN @mit_Preis      INTEGER DEFAULT 0,          //*** 0=kein Preis, 1=mit Preis, 2=nur Artikel mit Angebotspreis
                         IN @Lan_Nummer     INTEGER DEFAULT NULL,       //*** Herkunftsland oder NULL, wenn alle kommen sollen
                         IN @nur_offene     INTEGER DEFAULT 0,          //*** 0 = ohne VK, ohne Voll; 1 = mit VK, mit Voll; 2 = mit VK, ohne Voll; 3 = ohne VK, mit Voll
                         IN @Kun_Nummer     INTEGER DEFAULT NULL,       //*** Kunde für die Preisfindung
                         IN @Liefertag      DATE DEFAULT TODAY(),       //*** Liefertag für die Preisfindung und ggf. für die Ermittlung des verfügbaren Bestands
                         IN @Kgr_Nummer     INTEGER DEFAULT NULL,       //*** Kundengruppe, Kundenart und Preisgruppe können übergeben werden,
                         IN @Kar_Nummer     INTEGER DEFAULT NULL,       //    sonst werden sie vom übergebenen Kunden ermittelt
                         IN @Pgr_Nummer     INTEGER DEFAULT NULL,
                         IN @mit_Bestand    INTEGER DEFAULT 0,          //*** 1 = der verfügbare Bestand des Artikels wird berechnet und zurückgeliefert
                         IN @Sto_Nummer     INTEGER DEFAULT NULL,        //*** Standort für die Berechnung des verfügbaren Bestands
                         IN @Gbe_Nummer     INTEGER DEFAULT NULL,        //*** Geschäftsbereich für die Sperren
                         IN @Ausgeblendete_Einblenden INTEGER DEFAULT 0) //*** 1 = Ausgeblendete Artikel(Kennzeichen im Artikelstamm) werden trotzdem eingeblendet      
BEGIN

  DECLARE varZeichen            INTEGER;
  DECLARE varSuche_numerisch    INTEGER;
  DECLARE varStatement          LONG VARCHAR;
  DECLARE varPos                INTEGER;
  DECLARE varText               VARCHAR(100);
  DECLARE varJOIN               LONG VARCHAR;
  DECLARE varWHERE              LONG VARCHAR;
  DECLARE varArt_Nummer         INTEGER;
  DECLARE varSpa_Nummer_VK      INTEGER;

  DECLARE LOCAL TEMPORARY TABLE LT_Artikel
   (Art_Nummer          INTEGER,
    Art_Basisartikel    INTEGER,
    Preis               NUMERIC(18, 4),
    Ana_Nummer          INTEGER)
  ON COMMIT PRESERVE ROWS;

  DECLARE LOCAL TEMPORARY TABLE LT_Preisfindung
   (Liefertag               DATE,
    Kun_Nummer              INTEGER,
    Art_Nummer              INTEGER,
    Pra_Nummer              INTEGER,
    Ana_Nummer              INTEGER
  ) ON COMMIT PRESERVE ROWS;

  //*** prüfen, ob nach einer Zahl gesucht wird (wir unterstützen auch noch dier 7er-ASA - deshalb kein ISNUMERIC)
  SET varSuche_numerisch = 1;
  SET varZeichen = 1;
  Check_numerisch:
  WHILE varZeichen <= LENGTH(@Volltext) LOOP
    IF SUBSTRING(@Volltext, varZeichen, 1) NOT BETWEEN '0' AND '9' THEN
      SET varSuche_numerisch = 0;
      LEAVE Check_numerisch;
    END IF;
    SET varZeichen = varZeichen + 1;
  END LOOP;
  
  //*** wenn genau ein Artikel gefunden wird und nicht grade alle Angebotspreise gesucht werden, wird dieser gleich zurückgeliefert
  IF (varSuche_numerisch = 1) AND (@mit_Preis <> 2) THEN
    
    //*** gibt's den Artikel (ungesperrt)?
    SELECT
      Artikel.Art_Nummer
    INTO
      varArt_Nummer
    FROM Artikel
    WHERE Artikel.Art_Nummer = @Volltext
      AND Artikel.Spa_Nummer IS NULL
    ;
    
    //*** Nein - ist die Rufnummer genau einem ungesperrten Artikel hinterlegt?
    IF varArt_Nummer IS NULL THEN
      SELECT
        COUNT(*)
      INTO
        varArt_Nummer
      FROM Artikel
      WHERE Artikel.Art_Rufnummer = @Volltext
        AND Artikel.Spa_Nummer IS NULL
      ;

      IF varArt_Nummer <> 1 THEN
        SET varArt_Nummer = NULL;
      ELSE
        SELECT
          Artikel.Art_Nummer
        INTO
          varArt_Nummer
        FROM Artikel
        WHERE Artikel.Art_Rufnummer = @Volltext
          AND Artikel.Spa_Nummer IS NULL
        ;
      END IF;
    END IF;
      
  END IF;
  
  //*** wenn genau ein Artikel gefunden wurde, wird dieser zurückgeliefert
  IF varArt_Nummer IS NOT NULL THEN
    SELECT '*', varArt_Nummer;
    RETURN;
  ELSE
  
    //*** sonst die Standard-Artikelsuche
    //*** ggf. Kundengruppe, Kundenart und Preisgruppe ermitteln
    IF @mit_Preis <> 0 THEN
      IF (@Kgr_Nummer IS NULL) OR (@Kar_Nummer IS NULL) OR (@Pgr_Nummer IS NULL) THEN
        SELECT
          Kgr_Nummer,
          Kar_Nummer,
          Pgr_Nummer
        INTO
          @Kgr_Nummer,
          @Kar_Nummer,
          @Pgr_Nummer
        FROM Kunde
        WHERE Kun_Nummer = @Kun_Nummer;
      END IF;
    END IF;

    //*** nur Angebotsartikel? -> diese ermitteln
    IF @mit_Preis = 2 THEN
      INSERT INTO LT_Artikel
        (Art_Nummer,
         Art_Basisartikel)
      SELECT DISTINCT
        AngebotArtikel.Art_Nummer,
        Artikel.Art_Basisartikel
      FROM Angebot
      JOIN AngebotArtikel
        ON AngebotArtikel.Ang_Nummer = Angebot.Ang_Nummer
      JOIN Artikel
        ON Artikel.Art_Nummer = AngebotArtikel.Art_Nummer
      LEFT OUTER JOIN AngebotKunde
                   ON AngebotKunde.Ang_Nummer = Angebot.Ang_Nummer
                  AND AngebotKunde.Kun_Nummer = @Kun_Nummer
      LEFT OUTER JOIN AngebotKundengruppe
                   ON AngebotKundengruppe.Ang_Nummer = Angebot.Ang_Nummer
                  AND AngebotKundengruppe.Kgr_Nummer = @Kgr_Nummer
      LEFT OUTER JOIN AngebotKundenart
                   ON AngebotKundenart.Ang_Nummer = Angebot.Ang_Nummer
                  AND AngebotKundenart.Kar_Nummer = @Kar_Nummer
      LEFT OUTER JOIN AngebotPreisgruppe
                   ON AngebotPreisgruppe.Ang_Nummer = Angebot.Ang_Nummer
                  AND AngebotPreisgruppe.Pgr_Nummer = @Pgr_Nummer
      WHERE @Liefertag BETWEEN ISNULL(Angebot.Ang_vonDatum, '01.01.0001')
                           AND ISNULL(Angebot.Ang_bisDatum, '31.12.9999')
        AND (
             (AngebotKunde.Kun_Nummer = @Kun_Nummer)
              OR
             (AngebotKundengruppe.Kgr_Nummer = @Kgr_Nummer)
              OR
             (AngebotKundenart.Kar_Nummer = @Kar_Nummer)
              OR
             (AngebotPreisgruppe.Pgr_Nummer = @Pgr_Nummer)
            )
      ;
  
    ELSE

      //*** Volltext-Suche aufbereiten
      SET varJOIN  = '';
      SET varWHERE = '';
    
      //*** bei numerischer Eingabe wird entweder nach einer Rufnummer oder nach einer bestimmten Artikelgruppe gesucht
      IF (varSuche_numerisch = 1) THEN
        IF EXISTS(SELECT 1 FROM Artikel WHERE Art_Rufnummer = @Volltext AND Spa_Nummer IS NULL) THEN
          SET varWHERE = 'AND Artikel.Art_Rufnummer = ' + @Volltext + ' '
        ELSEIF EXISTS(SELECT 1 FROM Artikelgruppe WHERE Agr_Nummer = @Volltext) THEN
          SET varWHERE = 'AND ' + @Volltext + ' IN (ISNULL(v_Artikelgruppe.V_Agr_Nummer_Stufe1, 0), ' +
                                              '     ISNULL(v_Artikelgruppe.V_Agr_Nummer_Stufe2, 0), ' +
                                              '     ISNULL(v_Artikelgruppe.V_Agr_Nummer_Stufe3, 0), ' +
                                              '     ISNULL(v_Artikelgruppe.V_Agr_Nummer_Stufe4, 0), ' +
                                              '     ISNULL(v_Artikelgruppe.Agr_Nummer, 0)) '
        ;
        END IF;
      ELSE 
        //*** sonst Volltext in der Artikelbezeichnung
        SET varText = '';
        SET varPos = 1;
        WHILE varPos <= LENGTH(@Volltext) LOOP
          SET varText = varText + SUBSTRING(@Volltext, varPos, 1);
  
          IF (SUBSTRING(@Volltext, varPos, 1) = SPACE(1)) OR (varPos = LENGTH(@Volltext)) THEN
            SET varText = TRIM(varText);
            IF varText <> '' THEN
              SET varWHERE = varWHERE + 'AND Artikel.Art_Bezeichnung LIKE ''%' + varText + '%'' ';
              SET varText = '';
            END IF;
          END IF;

          SET varPos = varPos + 1;
        END LOOP;
      END IF;
      
      //*** selektieren wir einen bestimmten Geschäftsbereich?
      IF (@Gbe_Nummer IS NOT NULL) THEN
        SET varJOIN = varJOIN + 'JOIN ArtikelGeschaeftsbereich '
                              + '  ON ArtikelGeschaeftsbereich.Art_Nummer = Artikel.Art_Nummer '
                              + ' AND ArtikelGeschaeftsbereich.Gbe_Nummer = ' + STRING(@Gbe_Nummer) + ' '
        ;
      END IF;
    
      IF (varWHERE <> '') THEN 
        //*** suchen wir nur die nicht gesperrten?
        //*** 0 = ohne VK, ohne Voll; 1 = mit VK, mit Voll; 2 = mit VK, ohne Voll; 3 = ohne VK, mit Voll
        
        (SELECT FIRST Spa_Nummer INTO varSpa_Nummer_VK FROM FIRMA);

        IF (@nur_offene = 0) THEN
          SET varWHERE = varWHERE + 'AND (Artikel.Spa_Nummer IS NULL) ';
        END IF;
        IF (@nur_offene = 1) THEN 
          SET varWHERE = varWHERE + ' ';
        END IF;
        IF (@nur_offene = 2) THEN
          SET varWHERE = varWHERE + 'AND ( (Artikel.Spa_Nummer IS NULL) OR (Artikel.Spa_Nummer = ''' + STRING(varSpa_Nummer_VK) + ''') ) ';
        END IF;
        IF (@nur_offene = 3) THEN
          SET varWHERE = varWHERE + 'AND ( (Artikel.Spa_Nummer IS NULL) OR (Artikel.Spa_Nummer <> ''' + STRING(varSpa_Nummer_VK) + ''') ) ';
        END IF;

        //*** suchen wir nur ein bestimmtes Land?
        IF (@Lan_Nummer IS NOT NULL) THEN
          SET varWHERE = varWHERE + 'AND Artikel.Lan_Nummer = ' + STRING(@Lan_Nummer) + ' ';
        END IF;
        
        IF (ISNULL(@Ausgeblendete_Einblenden, 0) = 0) THEN
          SET varWHERE = varWHERE + 'AND Artikel.Art_Komfortsuche_ausblenden = 0 ';
        END IF;                
    
        //*** gesuchte Artikel in die TempTable übertragen
        SET varStatement =
           'INSERT INTO LT_Artikel '
         + ' (Art_Nummer, '
         + '  Art_Basisartikel) '
         + 'SELECT '
         + '  Artikel.Art_Nummer, '
         + '  Artikel.Art_Basisartikel '
         + 'FROM Artikel '
         + 'LEFT OUTER JOIN v_Artikelgruppe ' 
         + '             ON v_Artikelgruppe.Agr_Nummer = Artikel.Agr_Nummer '
         + varJOIN
         + 'WHERE 0 = 0 '
         + varWHERE;
        EXECUTE IMMEDIATE varStatement;
      END IF;
    
    END IF;
  
    //*** Preisfindung durchführen, wenn gewünscht
    IF @mit_Preis <> 0 THEN

      //gesperrte Artikel löschen
      DELETE FROM LT_Artikel
      FROM LT_Artikel
      JOIN Artikel
        ON Artikel.Art_Nummer = LT_Artikel.Art_Nummer
      WHERE fn_Sperre(@Liefertag, 1, LT_Artikel.Art_Nummer, @Kun_Nummer, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, @Gbe_Nummer) IS NOT NULL
        AND Artikel.Spa_Nummer IS NULL
      ;
      
      //Preisfindung für die gefundenen Artikel durchführen
      UPDATE LT_Artikel SET

        Preis = fn_Preisfindung(@Liefertag,
                                LT_Artikel.Art_Nummer,
                                @Kun_Nummer,
                                @Kgr_Nummer,
                                @Kar_Nummer,
                                @Pgr_Nummer,
                                1) //<- Preisfindung inkl. Speichern der Details

      FROM LT_Artikel
      ;

      //Angebotsnummer bzw. Dummy bei CF-Gastro-Preisen
      UPDATE LT_Artikel SET
        Ana_Nummer = IF LT_Preisfindung.Pra_Nummer = 5 THEN 
                       -1 
                     ELSE 
                       LT_Preisfindung.Ana_Nummer
                     ENDIF
      FROM LT_Artikel
      JOIN LT_Preisfindung
        ON LT_Preisfindung.Art_Nummer = LT_Artikel.Art_Nummer
      ;

    END IF;
  

    //*** Ergebnis zurückliefern
    SELECT
      Artikelgruppe.Sort                                        AS Sort,
      1                                                         AS Artikelposition,
      Artikel.Art_Bezeichnung                                   AS Bezeichnung,
      Land.Lan_Bezeichnung                                      AS Herkunftsland,
      Land.Lan_Kennzeichen                                      AS Lan_Kennzeichen,
      Land.Sort                                                 AS Land_Sortierung,
      Artikel.Lan_Nummer                                        AS Lan_Nummer,
      LT_Artikel.Art_Nummer                                     AS Art_Nummer,
      Artikel.Art_Rufnummer                                     AS Art_Rufnummer,
      LT_Artikel.Preis                                          AS Preis,
      IFNULL(LT_Artikel.Ana_Nummer, 0, 1)                       AS Angebotspreis,
      CASE fn_Preiseinheit(LT_Artikel.Art_Nummer, @Kun_Nummer)
        WHEN 0 THEN Einheit_Kolli.Ein_Langtext
        WHEN 1 THEN Einheit_Inhalt.Ein_Langtext
        WHEN 2 THEN 'kg'
      END                                                       AS Preiseinheit,
      Angebot.Ang_Bezeichnung                                   AS Angebot,
      IF Artikel.Spa_Nummer IS NULL THEN 0 ELSE 1 ENDIF         AS gesperrt,
      
      IF @mit_Bestand = 1 THEN
        fn_verfuegbarer_Bestand(@Sto_Nummer,
                                LT_Artikel.Art_Nummer,
                                @Liefertag,
                                TODAY(),
                                IF Artikel.Art_Inhalt IS NOT NULL THEN 1 ELSE 0 ENDIF,
                                1, //keine gesperrten Chargenbestände berücksichtigen
                                NULL,
                                1) //Gesamtverfügbarkeit (alle Bestände, sowohl regulärer als auch Sonderverkauf)
      ENDIF                                                     AS verfuegbarer_Bestand,
      
      IF @mit_Bestand = 1 THEN
        IF TRUNCNUM(verfuegbarer_Bestand / ISNULL(Artikel.Art_Inhalt, 1), 0) > 0 THEN
          TRUNCNUM(verfuegbarer_Bestand / ISNULL(Artikel.Art_Inhalt, 1), 0)
        ENDIF
      ENDIF                                                     AS verfuegbarer_Bestand_Kolli,
      
      IF @mit_Bestand = 1 THEN
        IF ISNULL(verfuegbarer_Bestand_Kolli, 0) > 0 THEN
          Einheit_Kolli.Ein_Langtext
        ENDIF
      ENDIF                                                     AS Kolli_Einheit,
      
      IF @mit_Bestand = 1 THEN
        IF ((ISNULL(verfuegbarer_Bestand, 0) - ISNULL(verfuegbarer_Bestand_Kolli, 0) * Artikel.Art_Inhalt) <> 0) THEN
          ISNULL(verfuegbarer_Bestand, 0) - ISNULL(verfuegbarer_Bestand_Kolli, 0) * Artikel.Art_Inhalt
        ENDIF
      ENDIF                                                     AS verfuegbarer_Bestand_Inhalt,
      
      IF @mit_Bestand = 1 THEN
        IF ISNULL(verfuegbarer_Bestand_Inhalt, 0) > 0 THEN
          Einheit_Inhalt.Ein_Langtext
        ENDIF
      ENDIF                                                     AS Inhalt_Einheit,
      
      IF EXISTS(SELECT 1 
                FROM Artikelbestand 
                WHERE Artikelbestand.Art_Nummer = LT_Artikel.Art_Nummer 
                  AND Artikelbestand.Abe_Sonderverkauf = 1) THEN 
        1 
      ELSE 
        0 
      ENDIF                                                     AS IstSV
      
    FROM LT_Artikel
    JOIN Artikel
      ON Artikel.Art_Nummer = LT_Artikel.Art_Nummer
    JOIN Artikelgruppe
      ON Artikelgruppe.Agr_Nummer = Artikel.Agr_Nummer
    LEFT OUTER JOIN Land
                 ON Land.Lan_Nummer = Artikel.Lan_Nummer
    LEFT OUTER JOIN Einheit Einheit_Kolli
                 ON Einheit_Kolli.Ein_Nummer = Artikel.Ein_Nummer
    LEFT OUTER JOIN Einheit Einheit_Inhalt
                 ON Einheit_Inhalt.Ein_Nummer = Artikel.Ein_Nummer_Inhalt
    LEFT OUTER JOIN AngebotArtikel
                 ON AngebotArtikel.Ana_Nummer = LT_Artikel.Ana_Nummer  
    LEFT OUTER JOIN Angebot
                 ON Angebot.Ang_Nummer = AngebotArtikel.Ang_Nummer  
               
    UNION ALL

    SELECT DISTINCT
      Artikelgruppe.Sort                                        AS Sort,
      0                                                         AS Artikelposition,
      Artikelgruppe.Agr_Bezeichnung                             AS Bezeichnung,
      NULL                                                      AS Herkunftsland,
      NULL                                                      AS Lan_Kennzeichen,
      NULL                                                      AS Land_Sortierung,
      NULL                                                      AS Lan_Nummer,
      Artikelgruppe.Agr_Nummer                                  AS Art_Nummer,
      NULL                                                      AS Art_Rufnummer,
      NULL                                                      AS Preis,
      NULL                                                      AS Angebotspreis,
      NULL                                                      AS Preiseinheit,
      NULL                                                      AS Angebot,
      NULL                                                      AS gesperrt,
      NULL                                                      AS verfuegbarer_Bestand,
      NULL                                                      AS verfuegbarer_Bestand_Kolli,
      NULL                                                      AS Kolli_Einheit,
      NULL                                                      AS verfuegbarer_Bestand_Inhalt,
      NULL                                                      AS Inhalt_Einheit,
      0                                                         AS IstSV
      
    FROM LT_Artikel
    JOIN Artikel
      ON Artikel.Art_Nummer = LT_Artikel.Art_Nummer
    JOIN Artikelgruppe
      ON Artikelgruppe.Agr_Nummer = Artikel.Agr_Nummer

    ORDER BY 1, 2, 3, 4
    ;

  END IF;

END
;