CREATE PROCEDURE %PROC% (IN @Bea_Nummer            INTEGER,             // Bearbeiter-Nummer
                         IN @nur_offene            INTEGER DEFAULT 1,   // 1 = nur offene KommScheine
                         IN @Nachladung_ausblenden INTEGER DEFAULT 1)   // 1 = Nachlade-KS ausblenden
BEGIN
  
  //*** Ergebnis zurückliefern
  SELECT
    0                                                                                                      AS "Selektiert",
    Auftrag.Kun_Nummer                                                                                     AS "Kun_Nummer",
    Kunde.Kun_Kurzbezeichnung                                                                              AS "Kun_Kurzbezeichnung",
    STRING(Auftrag.Kun_Nummer, ', ', REPLACE(REPLACE(Kunde.Kun_Kurzbezeichnung, ' ,', ','), ',', ',\n'))   AS "Kunde",
    Auftrag.Tur_Nummer                                                                                     AS "Tur_Nummer",
    Tour.Tur_Bezeichnung                                                                                   AS "Tur_Bezeichnung",
    
    (SELECT SUM(AuftragPosition.Aup_Kolli) FROM AuftragPosition
     LEFT OUTER JOIN KommScheinPosition 
                  ON KommScheinPosition.Aup_Nummer = AuftragPosition.Aup_Nummer
     WHERE KommScheinPosition.Kos_Nummer = KommSchein.Kos_Nummer
    )                                                                                                      AS "Kolli",
    
    
    (SELECT COUNT(*)
     FROM KommSchein
     WHERE KommSchein.Auf_Nummer = LT_KL_Auftrag.Auf_Nummer)                                               AS "Anzahl_KS",
    
    NULL                                                                                                   AS "Status",
    
    (SELECT COUNT(*)
     FROM AuftragPosition
     WHERE AuftragPosition.Auf_Nummer = LT_KL_Auftrag.Auf_Nummer
       AND AuftragPosition.Aup_Nachladen = 1)                                                              AS "Anzahl_Positionen_zum_Nachladen",    
       
    NULL                                                                                                   AS "Anzahl_FehlArtikel",
       
    fn_Abfahrzeit(Auftrag.Auf_Liefertag, Auftrag.Tur_Nummer)                                               AS "Abfahrtzeit",
    IFNULL(Abfahrtzeit, '', DATEFORMAT(Abfahrtzeit, 'dd.mm.yy - hh:mm') + ' Uhr')                          AS "Abfahrt",
    LT_KL_Auftrag.Auf_Nummer                                                                               AS "Auf_Nummer",    
    Auftrag.Auf_KSFreigabe                                                                                 AS "Auf_KSFreigabe",
         
    IF (Auftrag.Auf_LSFreigabe = 1) THEN
      1
    ELSE
      IF (Auftrag.Auf_KSFreigabe = 1) AND ( (Anzahl_Positionen_zum_Nachladen = 0) OR (@Nachladung_ausblenden = 1) ) THEN
        1
      ELSE
        0
      ENDIF
    ENDIF                                                                                                  AS "fertig",

   KommSchein.Lra_Nummer                                                                                   AS "Lra_Nummer",
   Lagerraum.Lra_Bezeichnung                                                                               AS "Lra_Bezeichnung",
   KommSchein.Kos_Nummer                                                                                   AS "Kos_Nummer",     
   Kunde.Kun_VIP                                                                                           AS "Kun_VIP",
   KommScheinStatus.Ksk_Nummer                                                                             AS "Ksk_Nummer", 
   ISNULL(KommScheinStatus.Kos_BL_Status, 0)                                                               AS "Kos_BL_Status"
   
  FROM LT_KL_Auftrag
  
  JOIN Auftrag 
    ON Auftrag.Auf_Nummer = LT_KL_Auftrag.Auf_Nummer
  JOIN Tour
    ON Tour.Tur_Nummer = Auftrag.Tur_Nummer
  JOIN Kunde
    ON Kunde.Kun_Nummer = Auftrag.Kun_Nummer
  LEFT OUTER JOIN KommSchein
               ON KommSchein.Auf_Nummer = LT_KL_Auftrag.Auf_Nummer
  LEFT OUTER JOIN Lagerraum
               ON Lagerraum.Lra_Nummer = KommSchein.Lra_Nummer
  LEFT OUTER JOIN KommScheinStatus
               ON KommScheinStatus.Kos_Nummer = KommSchein.Kos_Nummer
    
  WHERE ((@nur_offene = 0) OR (fertig = 0))
    AND KommSchein.Bea_Nummer = @Bea_Nummer
    
  ORDER BY
    1 - Kunde.Kun_VIP,
    Abfahrtzeit,
    Auftrag.Auf_Liefertag,
    Auftrag.Tur_Nummer,
    Auftrag.Kun_Nummer,
    LT_KL_Auftrag.Auf_Nummer
  ;

END
;
