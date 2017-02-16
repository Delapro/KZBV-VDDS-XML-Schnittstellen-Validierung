# KZBV-Prüfziffern Validierung

Mittels der KZBV-Prüfziffer-Funktionen kann man KZBV-XML-Auftragsnummern auf deren Richtigkeit prüfen, die Prüfziffer ermitteln usw.

## Anwendung

### Prüfen, ob XML-Auftragsnummer gültig ist

Hier am Beispiel der ersten drei offiziellen Testfallnummern. Es wird True zurückgegeben, wenn die übergebene Auftragsnummer gültig ist.

```Powershell
# Fall 1:
Test-KZBVPrüfziffer -Auftragsnummer 37-9999-1-29-KFO-1-22-3

# Fall 2:
Test-KZBVPrüfziffer -Auftragsnummer 37-9999-1-63-KBR-4-23-7

# Fall 3:
Test-KZBVPrüfziffer -Auftragsnummer 37-9999-1-79-ZE-6-32-0

# kürzeste, gültige XML-Auftragsnummer:
Test-KZBVPrüfziffer -Auftragsnummer 0
```

### Ermitteln der XML-Auftragsnummer-Prüfziffer

Wieder am Beispiel der ersten drei offiziellen Testfallnummern.

```Powershell
# Fall 1, gibt 3 zurück:
Get-KZBVPrüfziffer -Auftragsnummer 37-9999-1-29-KFO-1-22-3

# Fall 2, gibt 7 zurück:
Get-KZBVPrüfziffer -Auftragsnummer 37-9999-1-63-KBR-4-23-7

# Fall 3, gibt 0 zurück:
Get-KZBVPrüfziffer -Auftragsnummer 37-9999-1-79-ZE-6-32-0
```

### Berechnung einer Prüfziffer

```Powershell
# Fall 1, errechnet 3:
Invoke-KZBVPrüfzifferBerechnung -Auftragsnummer 37-9999-1-29-KFO-1-22

# Fall 2, errechnet 7:
Invoke-KZBVPrüfzifferBerechnung -Auftragsnummer 37-9999-1-63-KBR-4-23

# Fall 3, errechnet 0:
Invoke-KZBVPrüfzifferBerechnung -Auftragsnummer 37-9999-1-79-ZE-6-32

# Groß-/Kleinschreibung spielt keine Rolle, ergibt wieder 0:
Invoke-KZBVPrüfzifferBerechnung -Auftragsnummer 37-9999-1-79-ze-6-32
```
