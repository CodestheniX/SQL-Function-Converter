if exists(select 1 from sys.sysprocedure where proc_name = 'fn_Chefslist_Get_Einheit') then
   drop function fn_Chefslist_Get_Einheit
end if;


CREATE FUNCTION fn_Chefslist_Get_Einheit (IN @Aip_Nummer  INTEGER, // Auftragsimport-Position
                        IN @Einheit     INTEGER) // Art der zurückgelieferten Einheit (0 = Ein_Nummer ; 1 = Preiseinheit)
RETURNS INTEGER
BEGIN  
  DECLARE varEinheit INTEGER;
    
  IF (@Einheit = 0) THEN
    //*** Ein_Nummer
    SELECT 
      IF (Einheit.Ein_Nummer = Artikel.Ein_Nummer) THEN
        Artikel.Ein_Nummer
      ELSE 
        IF (Einheit.Ein_Nummer = Artikel.Ein_Nummer_Inhalt) THEN
          Artikel.Ein_Nummer_Inhalt
        ELSE
          1 // kg
        ENDIF
      ENDIF 
    INTO
      varEinheit
    FROM AuftragImportPosition
    JOIN Artikel
      ON Artikel.Art_Nummer = AuftragImportPosition.Art_Nummer
    JOIN Einheit
      ON Einheit.Ein_Langtext = AuftragImportPosition.Aip_Einheit
    WHERE AuftragImportPosition.Aip_Nummer = @Aip_Nummer
    ;
  
  ELSE     
    //*** Preiseinheit
    SELECT 
      IF (Einheit.Ein_Nummer = Artikel.Ein_Nummer) THEN
        0
      ELSE 
        IF (Einheit.Ein_Nummer = Artikel.Ein_Nummer_Inhalt) THEN
          1
        ELSE
          2
        ENDIF
      ENDIF 
    INTO
      varEinheit
    FROM AuftragImportPosition
    JOIN Artikel
      ON Artikel.Art_Nummer = AuftragImportPosition.Art_Nummer
    JOIN Einheit
      ON Einheit.Ein_Langtext = AuftragImportPosition.Aip_Einheit
    WHERE AuftragImportPosition.Aip_Nummer = @Aip_Nummer
    ;
  
  END IF
  ;
    
  RETURN varEinheit;

END
;
