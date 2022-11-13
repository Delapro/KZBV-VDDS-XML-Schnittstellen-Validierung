# KZBV-Prüfziffern Validierung

Mittels der KZBV-Prüfziffer-Funktionen kann man KZBV-XML-Auftragsnummern auf deren Richtigkeit prüfen, die Prüfziffer ermitteln usw. Als Grundlage diente der Algorithmus aus der Vorgabe der KZBV: Datei "pz_aufnr.c", "C"-Quelltext zur Berechnung der Pruefziffer fuer die Auftragsnummer, vom 20.07.2011.

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

# kurzeste, gültige XML-Auftragsnummer nach aktuell gültigem Schema, Pipelinevariante:
'123456-1-ZE-1-1-0' | Test-KZBVPrüfziffer
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

### Prüfung der dem VDDS zur Verfügung gestellten XML-Auftragsnummern

Ladet die XML-Auftragsnummern von der Seite https://www.vdds.de/schnittstellen/labor/auftragsnummern, testet diese und gibt jeweils das Ergebnis sowie die Prüfziffer aus:

```Powershell
Test-VDDS-Auftragsnummern
# erzeugt die Ausgabe
    Auftragsnummer                Prüfziffer Gültig
    --------------                ---------- ------
    289202-600-ZE-8040-30-3       3            True
    289202-600-ZE-8040-31-5       5            True
    289201-1102-KFO-6870-1-7      7            True
    289201-1102-KFO-6870-2-8      8            True
    289201-44-KB-8086-1-0         0            True
    289202-300-KB-8090-1-9        9            True
    450401-F2145-ZE-17160-387-8   8            True
    450401-F2425-ZE-17161-388-1   1            True
    450401-F4016-ZE-17162-389-4   4            True
    450401-F403-ZE-17163-390-4    4            True
    450401-F1236-ZE-17164-391-2   2            True
    450401-F3968-ZE-17165-392-7   7            True
    567001-1-ZE-27-12-4           4            True
    567001-1-ZE-25-13-4           4            True
    567001-1-KB-28-12-5           5            True
    567001-2-KB-5-12-4            4            True
    567001-2-KFO-3-13-7           7            True
    567001-5-KFO-1-12-6           6            True
    113501-12345G1802-ZE-1500-4-9 9            True
    463701-949G2003-ZE-2002-1-1   1            True
    463704-8155G2806-KB-2003-2-1  1            True
    023501-100G0101-KB-1475-3-1   1            True
    060501-24G1501-KFO-1-56-4     4            True
    060502-10G0102-KFO-1-4879-0   0            True
    552300-2-ZE-287-1-8           8            True
    552300-136-ZE-288-1-1         1            True
    552300-59-KFO-285-1-1         1            True
    552300-64-KFO-286-1-3         3            True
    552300-145-KB-289-1-4         4            True
    552300-21-KB-290-1-2          2            True
    005101-1-KB-2-1-4             4            True
    005101-1-KB-3-1-6             6            True
    005101-1-ZE-19-1-0            0            True
    005101-1-ZE-20-1-3            3            True
    994501-2-ZE-1-1-2             2            True
    994501-2-KB-1-1-2             2            True
    994501-2-KFO-1-1-8            8            True
    994501-3-ZE-1-1-3             3            True
    994501-3-KB-1-1-3             3            True
    994501-3-KFO-1-1-9            9            True
    111100-6-ZE-1-1-0             0            True
    111100-4749-ZE-2-1-6          6            True
    111100-16-ZE-3-1-9            9            True
    111100-9-ZE-4-1-9             9            True
    111100-7-ZE-5-1-0             0            True
    111100-4742-ZE-6-1-5          5            True
    451901-207-ZE-645-1-8         8            True
    451901-80-ZE-749-1-3          3            True
    824102-252-KFO-23-2-9         9            True
    824102-231-KFO-31-2-0         0            True
    691301-220-KB-61-1-3          3            True
    691301-230-KB-38-1-5          5            True
```

Was hier gleich auffällt, dass alle korrekt sind niemand hat ungültige Nummern zur Verfügung gestellt.

### Zerlegung einer XML-Auftragsnummer

Mittels der Funktion ```Get-KZBVAuftragsnummerProperties``` kann man eine XML-Auftragsnummer in seine Bestandteile zerlegen:

```Powershell
Get-KZBVAuftragsnummerProperties -Auftragsnummer 289202-600-ZE-8040-30-3

    Auftragsnummer     : 289202-600-ZE-8040-30-3
    Plannummer         : 30
    Abrechnungsbereich : ZE
    Standortnummer     : 289202
    Planidentifikation : 8040
    Pruefziffer        : 3
    Patientenpseudonym : 600

# Oder alle Testnummern in Tabelle ausgeben:
Test-VDDS-Auftragsnummern| Get-KZBVAuftragsnummerProperties| ft
```

### Herunterladen der Beispiel-XML-Dateien

Ladet die ZIP-Testdateien mit den XML-Beispieldateien von der VDDS-Seite herunter und entpackt diese in das Verzeichnis Testdaten.

```Powershell
If (-Not (Test-Path .\TestDaten -Type Container)) {New-Item Testdaten -Type Directory}
Get-VDDS-XMLAuftragsdateiBeispielLinks|% {Start-BitsTransfer $_;Expand-Archive (($_ -split '/')[-1]) -DestinationPath .\Testdaten -Force}

# Ausgabe der verwendeten Schemata und Version der Beispieldateien:
dir *.xml| % {$x=[xml](Get-Content $_); [PSCustomObject]@{Schema=$x.Laborabrechnung.noNamespaceSchemaLocation;File=$_.Name;Version=$x.Laborabrechnung.Version}}

    Schema                                            File                                   Version
    ------                                            ----                                   -------
    Laborabrechnungsdaten_(KZBV-VDZI)_4.xsd           018401-1000-KB-2411001-2-3.XML         4.0
    Laborabrechnungsdaten_(KZBV-VDZI)_4.xsd           018401-19000-KB-240200000-30001-5.XML  4.0
    Laborabrechnungsdaten_(KZBV-VDZI)_4.xsd           018401-19000-KFO-240400000-20001-6.XML 4.0
    Laborabrechnungsdaten_(KZBV-VDZI-VDDS)_(V4-2).xsd 018401-19000-ZE-240300001-30002-0.xml  4.2
    Laborabrechnungsdaten_(KZBV-VDZI)_4.xsd           018401-5-ZE-2416176-2-4.XML            4.0
    Laborabrechnungsdaten_(KZBV-VDZI-VDDS)_(V4-2).xsd 023501-100G0101-KB-1475-3-1.xml        4.2
                                                      06-300799-1-31-KBR-176-1-2.xml         4.2
    ...

# Ausgabe der verwendeten Schemata:
dir *.xml| % {$x=[xml](Get-Content $_); [PSCustomObject]@{Schema=$x.Laborabrechnung.noNamespaceSchemaLocation;File=$_.Name}}|group Schema|select name, count

    Name                                              Count
    ----                                              -----
    Laborabrechnungsdaten_(KZBV-VDZI)_4.xsd              24
    Laborabrechnungsdaten_(KZBV-VDZI-VDDS)_(V4-2).xsd    34
                                                        9
    Laborabrechnungsdaten_(KZBV-VDZI-VDDS) (V4-2).xsd    14
    Laborabrechnungsdaten_(KZBV-VDZI)_(V4-2).xsd          9
```

### Ermitteln der gültigen BEL2-Nummern aus einer Schemadatei

```Get-Bel2Positionen``` gibt eine Liste von gültigen BEL2-Nummern zurück. Funktioniert aber erst ab Schema-Version 4.2.

```Powershell
Get-Bel2Positionen '.\Laborabrechnungsdaten_(KZBV-VDZI-VDDS)_(V4-5).xsd' | select -First 5
0010
0015
0018
0021
0022
```
