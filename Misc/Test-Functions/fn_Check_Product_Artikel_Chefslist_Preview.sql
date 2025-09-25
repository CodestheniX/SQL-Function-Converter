if exists(select 1 from sys.sysprocedure where proc_name = 'fn_Check_Product_Artikel_Chefslist') then
   drop function fn_Check_Product_Artikel_Chefslist
end if;


CREATE FUNCTION fn_Check_Product_Artikel_Chefslist (@Art_Nummer                VARCHAR(10),   --Artikelnr.
                                     @Art_Bezeichnung_Alt       LONG VARCHAR,  --Artikelbezeichnung
                                     @Art_Bezeichnung_Neu       LONG VARCHAR,
                                     @Art_EAN_Alt               LONG VARCHAR,  --EAN/GTIN
                                     @Art_EAN_Neu               LONG VARCHAR,
                                     @Art_Inhalt_Alt            NUMERIC(18,4), --Inhalt
                                     @Art_Inhalt_Neu            NUMERIC(18,4),
                                     @Art_Gewicht_Alt           NUMERIC(18,4), --Gewicht
                                     @Art_Gewicht_Neu           NUMERIC(18,4),
                                     @Agr_Nummer_Alt            INTEGER,       --Artikelgruppe
                                     @Agr_Nummer_Neu            INTEGER,
                                     @Plk_Nummer_Alt            INTEGER,       --Preislistenkategorie
                                     @Plk_Nummer_Neu            INTEGER,
                                     @Lan_Nummer_Alt            INTEGER,       --Land
                                     @Lan_Nummer_Neu            INTEGER,
                                     @Ein_Nummer_Alt            INTEGER,       --Preiseinheit
                                     @Ein_Nummer_Neu            INTEGER,
                                     @Ein_Nummer_Gebinde_Alt    INTEGER,       --Gebinde-Einheit
                                     @Ein_Nummer_Gebinde_Neu    INTEGER,
                                     @Spa_Nummer_Alt            INTEGER,       --Sperrvermerk
                                     @Spa_Nummer_Neu            INTEGER,
                                     @Art_Sperrvermerk_von_Alt  DATE,          --Sperrvermerk - Von
                                     @Art_Sperrvermerk_von_Neu  DATE,
                                     @Art_Sperrvermerk_bis_Alt  DATE,          --Sperrvermerk - Bis
                                     @Art_Sperrvermerk_bis_Neu  DATE
                                    )
RETURNS INTEGER
BEGIN
  //*** Nur relevante Artikel-Änderungen führen zum Exporteintrag
  DECLARE varResult INTEGER;
  SET varResult = 0;
  
  --IF (fn_ist_CL_Aktiv_Chefslist() = 1) AND (@Spa_Nummer_Neu IS NULL) 
  IF  (fn_ist_CL_Aktiv_Chefslist() = 1) 
  AND (fn_ArtikelSperre_Chefslist(@Art_Nummer) IS NULL)
  THEN
    IF ( ISNULL(@Art_Bezeichnung_Alt     , '')           <> ISNULL(@Art_Bezeichnung_Neu     , '') )
    OR ( ISNULL(@Art_EAN_Alt             , '')           <> ISNULL(@Art_EAN_Neu             , '') )        
    OR ( ISNULL(@Art_Inhalt_Alt          , -1)           <> ISNULL(@Art_Inhalt_Neu          , -1) )
    OR ( ISNULL(@Art_Gewicht_Alt         , -1)           <> ISNULL(@Art_Gewicht_Neu         , -1) )
    OR ( ISNULL(@Agr_Nummer_Alt          , -1)           <> ISNULL(@Agr_Nummer_Neu          , -1) )
    OR ( ISNULL(@Plk_Nummer_Alt          , -1)           <> ISNULL(@Plk_Nummer_Neu          , -1) )
    OR ( ISNULL(@Lan_Nummer_Alt          , -1)           <> ISNULL(@Lan_Nummer_Neu          , -1) )
    OR ( ISNULL(@Ein_Nummer_Alt          , -1)           <> ISNULL(@Ein_Nummer_Neu          , -1) )
    OR ( ISNULL(@Ein_Nummer_Gebinde_Alt  , -1)           <> ISNULL(@Ein_Nummer_Gebinde_Neu  , -1) )
    OR ( ISNULL(@Spa_Nummer_Alt          , -1)           <> ISNULL(@Spa_Nummer_Neu          , -1) )
    OR ( ISNULL(@Art_Sperrvermerk_von_Alt, '01.01.0001') <> ISNULL(@Art_Sperrvermerk_von_Neu, '01.01.0001') )
    OR ( ISNULL(@Art_Sperrvermerk_bis_Alt, '31.12.9999') <> ISNULL(@Art_Sperrvermerk_bis_Neu, '31.12.9999') )
    THEN
      SET varResult = 1;
    END IF
    ;
  END IF;
 
  RETURN varResult;
END;
