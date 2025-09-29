if exists(select 1 from sys.sysprocedure where proc_name = 'fn_Check_StockChange') then
   drop function fn_Check_StockChange
end if;


CREATE FUNCTION fn_Check_StockChange (IN @StockChangeType     LONG VARCHAR DEFAULT '', --1=GoodsIn (Wareneingang); 2=Picking (Kommissionierung); 3=Production (Produktionsmeldung); 4=Outsource (Auslagerung/Verladung) ; 5=Relocate (Umlagerung/Lagerumbuchung)
                        IN @StoragePlaceDeltaId LONG VARCHAR DEFAULT '',
                        IN @ProductDeltaId      LONG VARCHAR DEFAULT '',
                        IN @Amount              LONG VARCHAR DEFAULT '',
                        IN @BookedAmount        LONG VARCHAR DEFAULT '',
                        IN @BookedUnitId        LONG VARCHAR DEFAULT '',
                        IN @AmountUnitId        LONG VARCHAR DEFAULT '',
                        IN @BestBeforeDate      LONG VARCHAR DEFAULT '',
                        IN @BatchNumber         LONG VARCHAR DEFAULT ''
                       )
RETURNS VARCHAR(100)
BEGIN
  DECLARE varResult     VARCHAR(100);
  DECLARE varLpl_Nummer INTEGER;
  
  SET varResult = '';  

  --Pflichtfelder OK?
  IF ISNULL(@StockChangeType, '') = '' THEN
    SET varResult = 'Übergabewert "StockChangeType" fehlt';
  END IF;
  
  IF ISNULL(@StoragePlaceDeltaId, '') = '' THEN 
    SET varResult = 'Übergabewert "StoragePlaceDeltaId" fehlt';
  END IF;
  
  IF ISNULL(@ProductDeltaId, '') = '' THEN
    SET varResult = 'Übergabewert "ProductDeltaId" fehlt';
  END IF;
  
  IF ISNULL(@Amount, '') = '' THEN
    SET varResult = 'Übergabewert "Amount" fehlt';
  END IF;
  
  IF ISNULL(@BookedAmount, '') = '' THEN
    SET varResult = 'Übergabewert "BookedAmount" fehlt';
  END IF;
  
  --Feldtypen OK?
  IF (varResult = '') THEN
    IF ISNUMERIC(@StockChangeType) = 0 THEN
      SET varResult = STRING('StockChangeType "', @StockChangeType, '" muss numerisch sein');
    END IF
    ;
    
    IF ISNUMERIC(@StoragePlaceDeltaId) = 0 THEN
      SET varResult = STRING('StoragePlaceDeltaId "', @StoragePlaceDeltaId, '" muss numerisch sein');
    END IF
    ;
    
    IF ISNUMERIC(@ProductDeltaId) = 0 THEN
      SET varResult = STRING('ProductDeltaId "', @ProductDeltaId, '" muss numerisch sein');
    END IF
    ;
    
    IF ISNUMERIC(@Amount) = 0 THEN
      SET varResult = STRING('Amount "', @Amount, '" muss numerisch sein');
    END IF
    ;
    
    IF ISNUMERIC(@BookedAmount) = 0 THEN
      SET varResult = STRING('BookedAmount "', @BookedAmount, '" muss numerisch sein');
    END IF
    ;
    
    IF (ISNULL(@BookedUnitId, '') <> '') AND (ISNUMERIC(@BookedUnitId) = 0) THEN
      SET varResult = STRING('BookedUnitId "', @BookedUnitId, '" muss numerisch sein');
    END IF
    ;
    
    IF (ISNULL(@AmountUnitId, '') <> '') AND (ISNUMERIC(@AmountUnitId) = 0) THEN
      SET varResult = STRING('AmountUnitId "', @AmountUnitId, '" muss numerisch sein');
    END IF
    ;
    
    IF (ISNULL(@BestBeforeDate, '') <> '') AND (ISDATE(@BestBeforeDate) = 0) THEN
      SET varResult = STRING('BestBeforeDate "', @BestBeforeDate, '" muss ein Datumsformat sein');
    END IF
    ;
    
    IF (ISNULL(@BatchNumber, '') <> '') AND (ISNUMERIC(@BatchNumber) = 0) THEN
      SET varResult = STRING('BatchNumber "', @BatchNumber, '" muss numerisch sein');
    END IF
    ;    

  END IF
  ;

  --Logische Dinge OK?
  IF (varResult = '') THEN
    --StockChangeType
    IF (@StockChangeType NOT BETWEEN 1 AND 5) THEN
      SET varResult = STRING('StockChangeType "', @StockChangeType, '" existiert nicht. [1-5]');
    END IF
    ;
    
    --StoragePlaceDeltaId
    CASE fn_Check_StoragePlace(@StoragePlaceDeltaId, @StockChangeType)
      WHEN -2 THEN SET varResult = STRING('Kein Produktionslagerplatz im Firmenstamm hinterlegt');
      WHEN -1 THEN SET varResult = STRING('StoragePlaceDeltaId "', @StoragePlaceDeltaId, '" ist kein Lagerplatz');
      WHEN  0 THEN SET varResult = STRING('StoragePlaceDeltaId "', RIGHT(@StoragePlaceDeltaId, LENGTH(@StoragePlaceDeltaId) - 1), '" (Lpl_Nummer) existiert nicht');
    END CASE
    ;

    --ProductDeltaId
    IF NOT EXISTS(SELECT 1 FROM Artikel WHERE Artikel.Art_Nummer = @ProductDeltaId) THEN
      SET varResult = STRING('ProductDeltaId "', @ProductDeltaId, '" (Art_Nummer) existiert nicht');
    END IF
    ;
    
    --BookedUnitId
    IF  (ISNULL(@BookedUnitId, '') <> '') 
    AND (NOT EXISTS(SELECT 1 FROM Einheit WHERE Einheit.Ein_Nummer = @BookedUnitId))
    THEN
      SET varResult = STRING('BookedUnitId "', @BookedUnitId, '" (Ein_Nummer) existiert nicht');
    END IF
    ;
    
    --AmountUnitId
    IF  (ISNULL(@AmountUnitId, '') <> '')
    AND (NOT EXISTS(SELECT 1 FROM Einheit WHERE Einheit.Ein_Nummer = @AmountUnitId)) 
    THEN
      SET varResult = STRING('AmountUnitId "', @AmountUnitId, '" (Ein_Nummer) existiert nicht');
    END IF
    ;
    
    --Falls es sich nicht um keinen Wareneingang (1 = GoodsIn) oder Produktion (3 = Production) handelt, wird eine passende Ekp_Nummer ermittelt
    IF (@StockChangeType NOT IN (1, 3))
    AND (fn_Get_StockChange_Ekp_Nummer(@StockChangeType, @BatchNumber, @ProductDeltaId) IS NULL)
    THEN
      SET varResult = STRING('Es konnte keine passende Ekp_Nummer ermittelt werden (ProductDeltaId: "', @ProductDeltaId,'" ; BatchNumber: "', @BatchNumber,'")');
    END IF
    ;
    
  END IF
  ;

  --Ergebnis zurück (Leer = OK)
  RETURN varResult;
END
;
