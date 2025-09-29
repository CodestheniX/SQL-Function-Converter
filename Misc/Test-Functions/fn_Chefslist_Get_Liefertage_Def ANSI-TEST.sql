CREATE FUNCTION %PROC% (IN @Kun_Nummer INTEGER) //Künde mit Ü ??
RETURNS VARCHAR(7)
BEGIN  
  DECLARE varResult VARCHAR(7); //Lieferbare Tage => Standard: 1111110 (Mo-Sa. = Ja ; So. = Nein)
  
  IF EXISTS (SELECT Kundenabruf.Kun_Nummer FROM Kundenabruf WHERE Kundenabruf.Kun_Nummer = @Kun_Nummer) THEN
    SET varResult = '';
    FOR lopLiefertage AS csrLiefertage CURSOR FOR
      SELECT 
        row_num AS Liefertag
      FROM sa_rowgenerator(0, 6)
    FOR READ ONLY DO
      IF EXISTS (SELECT Kundenabruf.Kun_Nummer FROM Kundenabruf WHERE Kundenabruf.Kun_Nummer = @Kun_Nummer AND Kundenabruf.Abr_Liefertag = Liefertag) THEN
        SET varResult = varResult + '1';
      ELSE 
        SET varResult = varResult + '0';
      END IF;    
    END FOR;
  ELSE
    SET varResult = '1111110';    
  END IF;
  
  RETURN varResult;
END
;