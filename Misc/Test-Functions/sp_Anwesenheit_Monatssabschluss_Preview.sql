CREATE PROCEDURE sp_Anwesenheit_Monatssabschluss (IN @Monatsletzter DATE,
                         IN @Monatserster  DATE DEFAULT DATEADD(MONTH, -1, @Monatsletzter + 1),
                         IN @Bea_Nummer INTEGER DEFAULT NULL)   //*** nur diesen Mitarbeiter berechnen (NULL = ALLE)
BEGIN

  DECLARE varTim_Nummer             INTEGER;
  DECLARE varZar_Nummer             INTEGER;
  DECLARE varUebertrag_Zeitkonto    INTEGER;
  
  //*** Monatsabschluss starten
  SET varTim_Nummer = fn_Zeitmessung_Start('sp_Anwesenheit_Monatsabschluss (' + DATEFORMAT(@Monatsletzter, 'mm/yyyy') + ')');

  //*** bei Mitarbeitern mit Sollzeit pro Monat im Zeitmodell, wird diese auf den Monatsletzten gebucht
  UPDATE Gesamtzeit SET
    Gez_Sollzeit = Zeitmodell.Zem_Sollzeit_Monat * 60
  FROM Gesamtzeit
  JOIN Bearbeiter
    ON Bearbeiter.Bea_Nummer = Gesamtzeit.Bea_Nummer
  JOIN MitarbeiterKG
    ON MitarbeiterKG.Mkg_Nummer = fn_Mitarbeiter_KG(Bearbeiter.Bea_Nummer, Gesamtzeit.Gez_Datum)
  JOIN Zeitmodell
    ON Zeitmodell.Zem_Nummer = MitarbeiterKG.Zem_Nummer
  WHERE Gesamtzeit.Gez_Datum = @Monatsletzter
    AND Gesamtzeit.Bea_Nummer = ISNULL(@Bea_Nummer, Gesamtzeit.Bea_Nummer)
    AND Zeitmodell.Zem_Sollzeit_Monat IS NOT NULL
  ;

  //*** Zeitkonten aktualisieren
  DELETE FROM Zeitkonto
  WHERE Zeitkonto.Zko_Datum BETWEEN @Monatserster AND @Monatsletzter
    AND Zeitkonto.Bea_Nummer = ISNULL(@Bea_Nummer, Zeitkonto.Bea_Nummer)
  ;
  
  //*** genommene Gleitzeit übertragen
  INSERT INTO Zeitkonto
   (Bea_Nummer,
    Ize_Nummer,
    Zko_Datum,
    Zko_Guthaben,
    Zko_Bemerkungen,
    Zko_automatisch)
  SELECT
    Istzeit.Bea_Nummer,
    Istzeit.Ize_Nummer,
    Istzeit.Ize_Datum,
    -Istzeit.Ize_Istzeit,
    'genommene Gleitzeit',
    2
  FROM Istzeit
  JOIN Bearbeiter
    ON Bearbeiter.Bea_Nummer = Istzeit.Bea_Nummer
  JOIN MitarbeiterKG
    ON MitarbeiterKG.Mkg_Nummer = fn_Mitarbeiter_KG(Bearbeiter.Bea_Nummer, Istzeit.Ize_Datum)
  JOIN Zeitmodell
    ON Zeitmodell.Zem_Nummer = MitarbeiterKG.Zem_Nummer
  JOIN Zeitart
    ON Zeitart.Zar_Nummer = Istzeit.Zar_Nummer
  WHERE Istzeit.Ize_Datum BETWEEN @Monatserster AND @Monatsletzter
    AND Istzeit.Bea_Nummer = ISNULL(@Bea_Nummer, Istzeit.Bea_Nummer)
    AND ISNULL(MitarbeiterKG.Mkg_Zeitkonto, Zeitmodell.Zem_Zeitkonto, 0) = 1
    AND Zeitart.Zaa_Nummer = 3 //<- Automatik-Art Gleitzeit
  ;
  
  //*** Soll/Ist-Differenzen ermitteln und entweder als Überstunden oder ins Zeitkonto einstellen
  SET varZar_Nummer = fn_Zeitart(7);
  FOR lopUeberstunden AS csrUeberstunden CURSOR FOR
    SELECT
      Gesamtzeit.Bea_Nummer                                                                                     AS csrBea_Nummer,
      MIN(MitarbeiterKG.Abt_Nummer)                                                                             AS csrAbt_Nummer,
      MIN(Abrechnungskreis.Akr_Lohnempfaenger)                                                                  AS csrAkr_Lohnempfaenger,
      SUM(Gesamtzeit.Gez_Istzeit) - SUM(Gesamtzeit.Gez_Sollzeit)                                                AS csrDifferenz,
      ISNULL(MIN(MitarbeiterKG.Mkg_Zeitkonto), MIN(Zeitmodell.Zem_Zeitkonto), 0)                                AS csrZeitkonto,
      ISNULL(MIN(MitarbeiterKG.Mkg_Zeitkonto_bis_Stunden), MIN(Zeitmodell.Zem_Zeitkonto_bis_Stunden), 0) * 60   AS csrZeitkonto_bis_Minuten,
      
      ISNULL(
        (SELECT
           SUM(Zeitkonto.Zko_Guthaben)
         FROM Zeitkonto
         WHERE Zeitkonto.Bea_Nummer = Gesamtzeit.Bea_Nummer
           AND Zeitkonto.Zko_Datum <= @Monatsletzter)
             , 0)                                                                                               AS csrZeitkonto_Guthaben
      
    FROM Gesamtzeit
    JOIN Bearbeiter
      ON Bearbeiter.Bea_Nummer = Gesamtzeit.Bea_Nummer
    JOIN MitarbeiterKG
      ON MitarbeiterKG.Mkg_Nummer = fn_Mitarbeiter_KG(Bearbeiter.Bea_Nummer, Gesamtzeit.Gez_Datum)
    LEFT OUTER JOIN Abrechnungskreis
                 ON Abrechnungskreis.Akr_Nummer = MitarbeiterKG.Akr_Nummer
    JOIN Zeitmodell
      ON Zeitmodell.Zem_Nummer = MitarbeiterKG.Zem_Nummer
    WHERE Gesamtzeit.Gez_Datum BETWEEN @Monatserster AND @Monatsletzter
      AND Gesamtzeit.Bea_Nummer = ISNULL(@Bea_Nummer, Gesamtzeit.Bea_Nummer)
    GROUP BY
      csrBea_Nummer
    HAVING
      csrDifferenz IS NOT NULL
  FOR READ ONLY DO
  
    //*** wird ein Zeitkonto geführt?
    IF (csrZeitkonto <> 0) THEN
    
      //*** das Zeitkonto wird maximal bis maximal zur eingestellten Höhe aufgefüllt - restliche Überstunden werden ausbezahlt
      SET varUebertrag_Zeitkonto = csrDifferenz;
      IF (csrDifferenz > 0) THEN //<- nur positive Überzeit wird ggf. gegen die Maximalstunden geprüft
        IF (csrZeitkonto_bis_Minuten > 0) THEN //<- gibt's überhaupt Maximalstunden?
          IF ((csrZeitkonto_Guthaben + csrDifferenz) > csrZeitkonto_bis_Minuten) THEN //<- und wäre das Kontingent mit den neuen Überstunden überzogen?
            
            SET varUebertrag_Zeitkonto = csrZeitkonto_bis_Minuten - csrZeitkonto_Guthaben; //<- jawoll - dann füllen wir maximal das Kontingent auf
            
            IF (varUebertrag_Zeitkonto < 0) THEN //<- wenn's bereits überzogen war, packen wir nicht nochmal was dazu
              SET varUebertrag_Zeitkonto = 0;
            END IF;
            
          END IF;
        END IF;
      END IF;
      SET csrDifferenz = csrDifferenz - varUebertrag_Zeitkonto;
    
      //*** jetzt den eigentlichen Eintrag ins Zeitkonto schreiben
      IF (varUebertrag_Zeitkonto <> 0) THEN
        INSERT INTO Zeitkonto
         (Bea_Nummer,
          Zko_Datum,
          Zko_Guthaben,
          Zko_Bemerkungen,
          Zko_automatisch)
        VALUES
         (csrBea_Nummer,
          @Monatsletzter,
          varUebertrag_Zeitkonto,
          'Übertrag Monat ' + DATEFORMAT(@Monatsletzter, 'mm/yyyy'),
          1)
        ;
      END IF;
    
    END IF;

    //*** (verbleibende) Differenz als Überstunden einstellen (nicht bei Lohnempfängern)
    IF (varZar_Nummer IS NOT NULL) AND (csrDifferenz <> 0) AND (ISNULL(csrAkr_Lohnempfaenger, 0) = 0) THEN
      INSERT INTO Istzeit
       (Bea_Nummer,
        Abt_Nummer,
        Zar_Nummer,
        Ize_Datum,
        Ize_Zuschlag)
      VALUES
       (csrBea_Nummer,
        csrAbt_Nummer,
        varZar_Nummer,
        @Monatsletzter,
        csrDifferenz)
      ;
    END IF;      
  
  END FOR;
    
    
  //*** zum Jahreswechsel den Resturlaub vortragen
  IF MONTH(@Monatsletzter) = 12 THEN

    DELETE FROM Resturlaub
    WHERE Resturlaub.Rur_Jahr = YEAR(@Monatsletzter + 1)
      AND Resturlaub.Bea_Nummer = ISNULL(@Bea_Nummer, Resturlaub.Bea_Nummer)
    ;
  
    INSERT INTO Resturlaub
     (Bea_Nummer,
      Rur_Jahr,
      Rur_Resturlaub)
    SELECT
      Bearbeiter.Bea_Nummer,
      YEAR(@Monatsletzter + 1),
      fn_Urlaub_Restanspruch(Bearbeiter.Bea_Nummer, YEAR(@Monatsletzter)) AS Restanspruch
    FROM Bearbeiter
    WHERE ISNULL(Restanspruch, 0) <> 0
      AND Bearbeiter.Bea_Nummer = ISNULL(@Bea_Nummer, Bearbeiter.Bea_Nummer)
      AND (@Monatsletzter + 1) BETWEEN ISNULL(Bearbeiter.Bea_Eintritt, '01.01.0001')
                                   AND ISNULL(Bearbeiter.Bea_Austritt, '31.12.9999')
    ;

  END IF;
  
  //*** Ende protokollieren
  CALL sp_Zeitmessung_Stopp(varTim_Nummer);
  
END
;