CREATE FUNCTION fn_Preisberechnung(IN @BasisPreis NUMERIC(18, 4),
                                   IN @Menge      INTEGER,
								   IN @RabattSatz NUMERIC(5, 2) DEFAULT 0.00,
								   IN @SteuerSatz NUMERIC(5, 2) DEFAULT 19.00,
								   IN @Runden     INTEGER       DEFAULT 1
								  )
RETURNS NUMERIC(18, 4)
BEGIN
  DECLARE varEndPreis NUMERIC(18, 4);

  --Berechnung: (Preis * Menge) - Rabatt + Steuer
  SET varEndPreis = (@BasisPreis * @Menge);
  SET varEndPreis = varEndPreis * (1 - (@RabattSatz / 100));
  SET varEndPreis = varEndPreis * (1 + (@SteuerSatz / 100));

  IF @Runden = 1 THEN
    SET varEndPreis = ROUND(varEndPreis, 2);
  END IF;

  RETURN varEndPreis;
END;