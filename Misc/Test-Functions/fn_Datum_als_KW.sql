CREATE FUNCTION fn_Datum_als_KW 
(
  IN @Ueberschrift LONG VARCHAR, //Freier Titel
  IN @Datum DATE DEFAULT TODAY()
)
RETURNS LONG VARCHAR
BEGIN

  DECLARE @KalenderWoche VARCHAR(7);

  //** Kalenderwoche berechnen
  SET @KalenderWoche = 
    IF @Datum IS NULL THEN
      NULL
    ELSE
      RIGHT('00' + STRING(DATEPART(CALWEEKOFYEAR, @Datum)), 2) 
      + '/' + 
      STRING(DATEPART(CALYEAROFWEEK, @Datum))
    ENDIF
  ;

  // Optional: Überschrift anhängen
  RETURN 
    IF @Ueberschrift IS NULL OR @Ueberschrift = '' THEN
      @KalenderWoche
    ELSE
      @Ueberschrift + ': ' + @KalenderWoche
    ENDIF
  ;

END;