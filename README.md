# SQL Function Converter

![SQL Function Converter](Misc/Icons/V2/Version%202.png)

Ein kleines Windows-Tool in Delphi/VCL zum schnellen Vorbereiten von SQL-Funktionen und SQL-Prozeduren fuer Tests, Debugging und manuelle Ausfuehrung.

Der Converter liest die Parameter aus einem `CREATE FUNCTION`- oder `CREATE PROCEDURE`-Header, uebernimmt sie in ein editierbares Grid und erzeugt daraus einen lauffaehigen SQL-Block ab `BEGIN` inklusive `DECLARE`- und `SET`-Anweisungen.

## Was das Tool macht

- extrahiert `IN`, `OUT` und `INOUT`-Parameter aus dem SQL-Header
- uebernimmt Name, Datentyp, Default-Wert und Kommentare in ein Grid
- erlaubt das manuelle Anpassen der Parameterwerte vor der Ausgabe
- fuegt automatisch `DECLARE`- und `SET`-Bloecke in den SQL-Body ein
- kann `RETURN` sowie `OUT`/`INOUT`-Parameter optional in ein `SELECT` umwandeln
- kann Kommentar-Marker wie `//***` in SQL-Kommentare `--` konvertieren
- oeffnet die generierte Ausgabe direkt im konfigurierten Editor

## Anwendungsfall

Das Projekt ist praktisch, wenn bestehende SQL Anywhere / ASA-Funktionen oder -Prozeduren schnell in einen testbaren Ausfuehrungsblock ueberfuehrt werden sollen, ohne Parameter jedes Mal von Hand als Variablen vorzubereiten.

Typischer Ablauf:

1. SQL-Definition in die linke Eingabe einfuegen oder per Datei laden.
2. Mit `Konvert` die Parameter analysieren lassen.
3. Werte im mittleren Grid anpassen.
4. Mit `Aktualisieren` den Ausgabe-SQL-Block erzeugen.
5. Die Ausgabe speichern oder direkt im Editor oeffnen.

## Funktionen im Detail

### Parameter-Erkennung

Unterstuetzt werden unter anderem:

- `IN`, `OUT` und `INOUT`
- Datentypen wie `VARCHAR(100)`, `INTEGER`, `DATE`, `LONG VARCHAR`
- Default-Werte wie `DEFAULT NULL`, `DEFAULT ''` oder `DEFAULT TODAY()`
- Inline-Kommentare mit `//`, `/*` oder `--`

### Ausgabe-Erzeugung

Die generierte Ausgabe beginnt beim `BEGIN`-Block der uebergebenen SQL-Definition. Der Converter:

- fuegt neue `DECLARE`-Anweisungen fuer die Parameter ein
- setzt vorhandene Werte per `SET`
- ergaenzt bei Bedarf eine `SELECT`-Rueckgabe fuer `RETURN` und `OUT`-Parameter

### Editor-Integration

Es koennen mehrere Editoren hinterlegt werden, z. B.:

- Notepad
- Notepad++
- Visual Studio Code

Zusatzparameter fuer den Editor-Aufruf lassen sich ebenfalls speichern.

## Beispiel

Aus einer Definition wie:

```sql
CREATE FUNCTION %PROC% (IN @Kun_Nummer INTEGER DEFAULT NULL) // Kunde
RETURNS VARCHAR(7)
BEGIN
  DECLARE varResult VARCHAR(7);
  RETURN varResult;
END;
```

wird ein Ausgabeblock in dieser Art erzeugt:

```sql
BEGIN
  DECLARE varResult VARCHAR(7);

  --Start: DECLARE der Parameter
  DECLARE @Kun_Nummer INTEGER;
  --Ende: DECLARE der Parameter

  --Start: SET der Parameter
  SET @Kun_Nummer = NULL;
  --Ende: SET der Parameter

  SELECT varResult;
END;
```

Die genaue Ausgabe haengt von den gesetzten Optionen und den eingetragenen Parameterwerten ab.

## Bedienung

### Hauptansicht

- links: SQL-Eingabe
- mitte: erkannte Parameter inklusive Werte und Kommentare
- rechts: erzeugte Ausgabe

### Wichtige Aktionen

- `Konvert`: liest den Header ein und fuellt das Grid
- `Aktualisieren`: uebernimmt die Grid-Werte in die Ausgabe
- `Im Editor oeffnen`: schreibt die Ausgabe in eine Datei und startet den gewaehlten Editor

### Nuetzliche Shortcuts

- `F9`: Eingabe konvertieren
- `F5`: Ausgabe aktualisieren
- `F1`: aktuelle Spaltenbreite an Inhalt anpassen
- `Entf`: aktuelle Grid-Zelle leeren
- `Enter`: im Grid zur naechsten Zeile springen

## Konfiguration

Die Anwendung speichert ihre Einstellungen standardmaessig unter:

```text
%APPDATA%\SQL Function Converter\
```

Verwendete Dateien:

- `Fx_Settings.ini` fuer Fensterzustand, Spalten, Theme und Konvertierungsoptionen
- `Fx_Editors.ini` fuer Editor-Profile und den aktiven Ausgabe-Editor
- `Fx_Output.sql` als temporaere/generierte Ausgabedatei fuer den Editor-Aufruf

Falls das Verzeichnis unter `%APPDATA%` nicht angelegt werden kann, verwendet die Anwendung stattdessen das Verzeichnis der EXE.

## Projektstruktur

```text
.
|- SQLFunctionConverter.dpr        Projektstart
|- Main.pas / Main.dfm             Hauptfenster und Konvertierungslogik
|- EditorSettings.pas / .dfm       Verwaltung der Ausgabe-Editoren
|- ConverterConst.pas              Konstanten und Konfigurationsschluessel
|- Misc/Test-Functions/            Beispiel- und Test-SQLs
`- Release/SQLFunctionConverter.exe Vorcompilierte EXE
```

## Voraussetzungen

- Windows
- Embarcadero Delphi / RAD Studio mit VCL
- Zielplattform: `Win32`

Das Projekt ist als klassische VCL-Desktop-Anwendung aufgebaut.

## Build

Projektdatei:

```text
SQLFunctionConverter.dproj
```

Zum Bauen einfach in Delphi/RAD Studio oeffnen und als `Win32` kompilieren.

## Hinweise

- Das Tool ist auf SQL-Header mit klassischem `CREATE FUNCTION`- bzw. `CREATE PROCEDURE`-Aufbau ausgelegt.
- Die Erkennung basiert auf String-Verarbeitung und Regex, nicht auf einem vollstaendigen SQL-Parser.
- Sehr spezielle oder ungewoehnlich formatierte Definitionen koennen daher Nacharbeit im Grid erfordern.

## Testdaten

Unter [Misc/Test-Functions](Misc/Test-Functions) liegen mehrere Beispielskripte, mit denen sich die Konvertierung schnell ausprobieren laesst.
