if exists(select 1 from sys.sysprocedure where proc_name = 'fn_Lieferprofil_Webshop') then
   drop function fn_Lieferprofil_Webshop
end if;


CREATE FUNCTION fn_Lieferprofil_Webshop(IN @Nr INTEGER) --KundenNr.
RETURNS VARCHAR(7)
BEGIN  
  DECLARE varResult VARCHAR(7); --Lieferbare Tage => Standard: 1111110 (Mo-Sa. = Ja ; So. = Nein)
  
  IF EXISTS (SELECT KundenLiefertag.Nr FROM KundenLiefertag WHERE KundenLiefertag.Nr = @Nr) THEN
    SET varResult = '';
    FOR lopLiefertage AS csrLiefertage CURSOR FOR
      SELECT 
        row_num AS Liefertag
      FROM sa_rowgenerator(0, 6)
    FOR READ ONLY DO
      IF EXISTS (SELECT KundenLiefertag.Nr FROM KundenLiefertag WHERE KundenLiefertag.Nr = @Nr AND KundenLiefertag.Liefertag = Liefertag) THEN
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
