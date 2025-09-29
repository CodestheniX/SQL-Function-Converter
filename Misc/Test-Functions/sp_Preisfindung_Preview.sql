CREATE PROCEDURE sp_Preisfindung (IN @Liefertag    DATE,                    // <Pflichtübergabe
                         IN @Artikel      VARCHAR(10),             // <Pflichtübergabe
                         IN @Kunde        INTEGER,                 // <entweder Kunde
                         IN @Kundengruppe INTEGER DEFAULT NULL,    // <oder Kundengruppe
                         IN @Preisgruppe  INTEGER DEFAULT NULL,    // <oder Preisgruppe
                         IN @mitSelect    INTEGER DEFAULT 1,       // <auf 0 setzen, wenn nur Rückgabe als OUT gewünscht (z.B. andere SP's)
                         OUT @Preis             NUMERIC(18, 4),    // >ermittelter Preis (kann ein Aktions-, Sonder- oder Listenpreis sein)
                         OUT @Rabatt            NUMERIC(5, 2),     // >ermittelter Rabatt (kann nur von Aktionen kommen)
                         OUT @Preisart          INTEGER,           // >0: @Preis = Listenpreis, 1: @Preis = Aktionspreis, 2: @Preis = Sonderpreis
                         OUT @Listenpreis       NUMERIC(18, 4),    // >ermittelter Listenpreis
                         OUT @abDatum           DATE,              // >Datum, ab dem der ermittelte Listenpreis gültig ist
                         OUT @Akt_Nummer        INTEGER,           // >ggf. Aktionsnummer, von der der Preis/Rabatt kommt
                         OUT @Akt_Bezeichnung   VARCHAR(50),       // >ggf. Aktionsbezeichnung
                         OUT @Akt_vonDatum      DATE,              // >ggf. Aktionszeitraum
                         OUT @Akt_bisDatum      DATE)              // >ggf. Aktionszeitraum
BEGIN

  DECLARE varBasisartikel               VARCHAR(10);
  DECLARE varArtikelgruppe              INTEGER;
  DECLARE varAgr_Gewinnzuschlag         INTEGER;
  DECLARE varAgr_Rueckverguetung        INTEGER;
  DECLARE varTeileart                   INTEGER;
  DECLARE varEinzelgebindezuschlag      INTEGER;
  DECLARE varArt_Rabattfaehig           INTEGER;
  DECLARE varSop_Preis                  NUMERIC(18, 4);
  DECLARE varBasispreis                 NUMERIC(18, 4);
  DECLARE varGez_Zuschlag_nominal       NUMERIC(18, 4);
  DECLARE varGez_Zuschlag_prozentual    NUMERIC(5, 2);
  DECLARE varRvg_Rueckverguetung        NUMERIC(5, 2);
  DECLARE varGbz_Zuschlag_nominal       NUMERIC(18, 4);
  DECLARE varGbz_Zuschlag_prozentual    NUMERIC(5, 2);


  //*** Kunden- und Preisgruppe des Kunden ermitteln (wenn dieser übergeben wurde)
  IF @Kunde IS NOT NULL THEN
    SELECT Kgr_Nummer, Pgr_Nummer
    INTO @Kundengruppe, @Preisgruppe
    FROM Kunde 
    WHERE Kun_Nummer = @Kunde;
  END IF;


  //*** Basisartikel, Artikelgruppe, Teileart und Einzelgebindezuschlag ermitteln
  SELECT 
    Art_Nummer_Preis,
    Artikel.Agr_Nummer,
    Agr_Gewinnzuschlag,
    Agr_Rueckverguetung,
    Tei_Nummer,
    Art_Zuschlag,
    Art_Rabattfaehig
  INTO 
    varBasisartikel,
    varArtikelgruppe,
    varAgr_Gewinnzuschlag,
    varAgr_Rueckverguetung,
    varTeileart,
    varEinzelgebindezuschlag,
    varArt_Rabattfaehig
  FROM Artikel 
  JOIN Artikelgruppe
    ON Artikelgruppe.Agr_Nummer = Artikel.Agr_Nummer
  WHERE Art_Nummer = @Artikel;
  SET varBasisartikel = ISNULL(varBasisartikel, @Artikel);


  //*** Sonderpreis für den Artikel ermitteln
  SELECT FIRST
    Sonderpreis.Sop_Preis
  INTO
    varSop_Preis
  FROM Sonderpreis
  WHERE Sonderpreis.Art_Nummer = @Artikel
    AND @Liefertag BETWEEN ISNULL(Sonderpreis.Sop_abDatum, '01.01.0001') AND ISNULL(Sonderpreis.Sop_bisDatum, '31.12.9999')
    AND (
            ((Sonderpreis.Kun_Nummer = @Kunde)          OR (@Kunde IS NULL))
         OR ((Sonderpreis.Kgr_Nummer = @Kundengruppe)   OR (@Kundengruppe IS NULL))
         OR ((Sonderpreis.Pgr_Nummer = @Preisgruppe)    OR (@Preisgruppe IS NULL))
        )
  ORDER BY
    Sonderpreis.Pgr_Nummer,
    Sonderpreis.Kgr_Nummer,
    Sonderpreis.Kun_Nummer,
    Sonderpreis.Sop_Nummer DESC
  ;
  //*** keiner vorhanden? Dann Sonderpreis für den Basisartikel ermitteln
  IF varSop_Preis IS NULL THEN
    SELECT FIRST
      Sonderpreis.Sop_Preis
    INTO
      varSop_Preis
    FROM Sonderpreis
    WHERE Sonderpreis.Art_Nummer = varBasisartikel
      AND @Liefertag BETWEEN ISNULL(Sonderpreis.Sop_abDatum, '01.01.0001') AND ISNULL(Sonderpreis.Sop_bisDatum, '31.12.9999')
      AND (
              ((Sonderpreis.Kun_Nummer = @Kunde)          OR (@Kunde IS NULL))
           OR ((Sonderpreis.Kgr_Nummer = @Kundengruppe)   OR (@Kundengruppe IS NULL))
           OR ((Sonderpreis.Pgr_Nummer = @Preisgruppe)    OR (@Preisgruppe IS NULL))
          )
    ORDER BY
      Sonderpreis.Pgr_Nummer,
      Sonderpreis.Kgr_Nummer,
      Sonderpreis.Kun_Nummer,
      Sonderpreis.Sop_Nummer DESC
    ;
  END IF
  ;


  //*** Einzelgebindezuschlag ermitteln
  SELECT FIRST 
    Gbz_Zuschlag_nominal,
    Gbz_Zuschlag_prozentual
  INTO
    varGbz_Zuschlag_nominal,
    varGbz_Zuschlag_prozentual
  FROM Gebindezuschlag
  WHERE 
    //für die Teileart
    (Tei_Nummer = varTeileart)
    AND
    //für den Kunden, die Kundengruppe oder die Preisgruppe
    (
     ((Kun_Nummer = @Kunde) AND (@Kunde IS NOT NULL))
     OR
     ((Kgr_Nummer = @Kundengruppe) AND (@Kundengruppe IS NOT NULL))
     OR
     ((Pgr_Nummer = @Preisgruppe) AND (@Preisgruppe IS NOT NULL))
    )
  ORDER BY
    Pgr_Nummer,
    Kgr_Nummer,
    Kun_Nummer;

  IF varSop_Preis IS NOT NULL THEN

    //*** Sonderpreis vorhanden -> keine weitere Berechnung (ausser Einzelgebindezuschlag)
    SET @Preis = varSop_Preis;
    SET @Preisart = 2;

    //ggf. Einzelgebindezuschlag
    IF varEinzelgebindezuschlag = 1 THEN
      SET @Preis = @Preis + ISNULL(varGbz_Zuschlag_nominal, 0);
      SET @Preis = @Preis + @Preis * ISNULL(varGbz_Zuschlag_prozentual, 0) / 100;
    END IF;

    //*** Sonderpreis auf 3 Nachkommastellen runden
    SET @Preis = ROUND(@Preis, 3);

  ELSE
    //*** kein Sonderpreis vorhanden -> Aktions- und Listenpreis ermitteln

    //*** Aktionen vorhanden?
    SELECT FIRST
      Aktion.Akt_Nummer,
      Aktion.Akt_Bezeichnung,
      Aktion.Akt_vonDatum,
      Aktion.Akt_bisDatum,
      (IF (ISNULL(AktionArtikel.Art_Nummer, '') = @Artikel) OR (ISNULL(AktionArtikel.Art_Nummer, '') = varBasisartikel) THEN AktionArtikel.Aka_Preis  ELSE NULL ENDIF),
      (IF (ISNULL(AktionArtikel.Art_Nummer, '') = @Artikel) OR (ISNULL(AktionArtikel.Art_Nummer, '') = varBasisartikel) THEN AktionArtikel.Aka_Rabatt ELSE Aktion.Akt_Rabatt ENDIF)
    INTO
      @Akt_Nummer,
      @Akt_Bezeichnung,
      @Akt_vonDatum,
      @Akt_bisDatum,
      @Preis,
      @Rabatt
    FROM Aktion
    LEFT OUTER JOIN AktionArtikel
                 ON AktionArtikel.Akt_Nummer = Aktion.Akt_Nummer
    LEFT OUTER JOIN AktionKunde
                 ON AktionKunde.Akt_Nummer = Aktion.Akt_Nummer
                AND AktionKunde.Kun_Nummer = @Kunde
    LEFT OUTER JOIN AktionKundengruppe
                 ON AktionKundengruppe.Akt_Nummer = Aktion.Akt_Nummer
                AND AktionKundengruppe.Kgr_Nummer = @Kundengruppe
    LEFT OUTER JOIN AktionPreisgruppe
                 ON AktionPreisgruppe.Akt_Nummer = Aktion.Akt_Nummer
                AND AktionPreisgruppe.Pgr_Nummer = @Preisgruppe
                 
    WHERE @Liefertag BETWEEN Aktion.Akt_vonDatum  // nur die am Liefertag gültigen Selektionen
                         AND Aktion.Akt_bisDatum

      AND (   AktionKunde.Kun_Nummer        = @Kunde          // nur Aktionen, die dem Kunden
           OR AktionKundengruppe.Kgr_Nummer = @Kundengruppe   // oder der Kundengruppe
           OR AktionPreisgruppe.Pgr_Nummer  = @Preisgruppe    // oder der Preisgruppe zugeordnet sind
          )

      AND (   AktionArtikel.Art_Nummer = @Artikel // nur Aktionen, die den gesuchten Artikel oder den Basisartikel beinhalten
           OR AktionArtikel.Art_Nummer = varBasisartikel
           OR ISNULL(Aktion.Akt_Rabatt, 0) <> 0)  // oder einen Pauschalrabatt für alle Artikel hinterlegt haben

    // pro Prioritätsstufe haben die Aktionen, die den gesuchten Artikel beinhalten, höhere Priorität als allgemeingültige Aktionen
    ORDER BY // 1. Priorität: Aktionen des Kunden
             ISNULL(AktionKunde.Kun_Nummer, -1) DESC,
             (IF AktionKunde.Kun_Nummer IS NOT NULL AND (ISNULL(AktionArtikel.Art_Nummer, '') = @Artikel)        THEN AktionArtikel.Art_Nummer ELSE '' ENDIF) DESC,
             (IF AktionKunde.Kun_Nummer IS NOT NULL AND (ISNULL(AktionArtikel.Art_Nummer, '') = varBasisartikel) THEN AktionArtikel.Art_Nummer ELSE '' ENDIF) DESC,
             Aktion.Akt_Nummer DESC,
             // 2. Priorität: Aktionen der Kundengruppe des Kunden
             ISNULL(AktionKundengruppe.Kgr_Nummer, -1) DESC,
             (IF AktionKundengruppe.Kgr_Nummer IS NOT NULL AND (ISNULL(AktionArtikel.Art_Nummer, '') = @Artikel)        THEN AktionArtikel.Art_Nummer ELSE '' ENDIF) DESC,
             (IF AktionKundengruppe.Kgr_Nummer IS NOT NULL AND (ISNULL(AktionArtikel.Art_Nummer, '') = varBasisartikel) THEN AktionArtikel.Art_Nummer ELSE '' ENDIF) DESC,
             Aktion.Akt_Nummer DESC,
             // 3. Priorität: Aktionen der Preisgruppe des Kunden bzw. der Preisgruppe 0
             ISNULL(AktionPreisgruppe.Pgr_Nummer, -1) DESC,
             (IF AktionPreisgruppe.Pgr_Nummer IS NOT NULL AND (ISNULL(AktionArtikel.Art_Nummer, '') = @Artikel)        THEN AktionArtikel.Art_Nummer ELSE '' ENDIF) DESC,
             (IF AktionPreisgruppe.Pgr_Nummer IS NOT NULL AND (ISNULL(AktionArtikel.Art_Nummer, '') = varBasisartikel) THEN AktionArtikel.Art_Nummer ELSE '' ENDIF) DESC,
             Aktion.Akt_Nummer DESC;
    
    //*** kein Aktionsrabatt, wenn der Artikel nicht rabattfähig ist
    IF varArt_Rabattfaehig = 0 THEN
      SET @Rabatt = NULL;
      IF @Preis IS NULL THEN
        SET @Akt_Nummer      = NULL;
        SET @Akt_Bezeichnung = NULL;
        SET @Akt_vonDatum    = NULL;
        SET @Akt_bisDatum    = NULL;
      END IF;
    END IF;

    //*** Listenpreis ermitteln (auch, wenn ein Aktionsrabatt ermittelt wurde)

    //*** Basispreis ermitteln
    SELECT FIRST
      Bap_Preis,
      Bap_abDatum
    INTO
      varBasispreis,
      @abDatum
    FROM Basispreis
    WHERE Art_Nummer = varBasisartikel
      AND Bap_abDatum <= @Liefertag
    ORDER BY Bap_abDatum DESC;


    //*** Gewinnzuschlag ermitteln
    IF varAgr_Gewinnzuschlag = 0 THEN
      SET varGez_Zuschlag_nominal = 0;
      SET varGez_Zuschlag_prozentual = 0;
    ELSE
      SELECT FIRST
        Gez_Zuschlag_nominal,
        Gez_Zuschlag_prozentual
      INTO
        varGez_Zuschlag_nominal,
        varGez_Zuschlag_prozentual
      FROM Gewinnzuschlag
      WHERE
        //für die Artikelgruppe oder die Teileart
        (
         (Agr_Nummer = varArtikelgruppe) OR (Tei_Nummer = varTeileart)
        )
        AND
        //für den Kunden, die Kundengruppe oder die Preisgruppe
        (
         ((Kun_Nummer = @Kunde) AND (@Kunde IS NOT NULL))
         OR
         ((Kgr_Nummer = @Kundengruppe) AND (@Kundengruppe IS NOT NULL))
         OR
         ((Pgr_Nummer = @Preisgruppe) AND (@Preisgruppe IS NOT NULL))
        )
      ORDER BY
        Pgr_Nummer,
        Kgr_Nummer,
        Kun_Nummer,
        Tei_Nummer,
        Agr_Nummer;
    END IF;


    //*** Rückvergütung ermitteln
    IF varAgr_Rueckverguetung = 0 THEN
      SET varRvg_Rueckverguetung = 0;
    ELSE 
      SELECT FIRST 
        Rvg_Rueckverguetung
      INTO
        varRvg_Rueckverguetung
      FROM Rueckverguetung
      WHERE 
        //für den Kunden, die Kundengruppe oder die Preisgruppe
        (
         ((Kun_Nummer = @Kunde) AND (@Kunde IS NOT NULL))
         OR
         ((Kgr_Nummer = @Kundengruppe) AND (@Kundengruppe IS NOT NULL))
         OR
         ((Pgr_Nummer = @Preisgruppe) AND (@Preisgruppe IS NOT NULL))
        )
      ORDER BY
        Pgr_Nummer,
        Kgr_Nummer,
        Kun_Nummer;
    END IF;


    //*** Listenpreis berechnen
    
    //Basispreis
    SET @Listenpreis = varBasispreis;
    
    //Gewinnzuschlag
    SET @Listenpreis = @Listenpreis + ISNULL(varGez_Zuschlag_nominal, 0);
    SET @Listenpreis = @Listenpreis + @Listenpreis * ISNULL(varGez_Zuschlag_prozentual, 0) / 100;
      
    //Rückvergütung
    SET @Listenpreis = @Listenpreis / (1 - ISNULL(varRvg_Rueckverguetung, 0) / 100);

    //ggf. Einzelgebindezuschlag
    IF varEinzelgebindezuschlag = 1 THEN
      SET @Listenpreis = @Listenpreis + ISNULL(varGbz_Zuschlag_nominal, 0);
      SET @Listenpreis = @Listenpreis + @Listenpreis * ISNULL(varGbz_Zuschlag_prozentual, 0) / 100;
    END IF;

    // Aktions- oder Listenpreis 
    IF @Preis IS NOT NULL THEN
      SET @Preisart = 1;
    ELSE 
      SET @Preisart = 0;
      SET @Preis = @Listenpreis;
    END IF;

    //*** Preise auf 2 Nachkommastellen runden
    SET @Preis       = ROUND(@Preis, 2);
    SET @Listenpreis = ROUND(@Listenpreis, 2);

  END IF;
  
  // ggf. OUT-Parameter selecten (zur Rückgabe per Query-Result an DLL's)
  IF (@mitSelect = 1) THEN
    SELECT
      @Preis,
      @Rabatt,
      @Preisart,
      @Listenpreis,
      @abDatum,
      @Akt_Nummer,
      @Akt_Bezeichnung,
      @Akt_vonDatum,
      @Akt_bisDatum;
  END IF;

END
;