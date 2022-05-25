# Powershell KZBV-Prüfzifferberechnung
#
# erstellt von easy - innovative software
#
# zur Unterstützung der VDDS-Laborschnittstelle: https://www.vdds.de/schnittstellen/labor/
# http://www.kzbv.de/papierlose-abrechnung.98.de.html

# ermittelt die zum übergebenen String passende Prüfziffer nach dem
# Algorithmus der KZBV
Function Invoke-KZBVPrüfzifferBerechnung {
    [CmdletBinding()]
    Param(
        [String]$Auftragsnummer
    )

    $PZ_ZAHLEN = "0123456789"
    $PZ_GROSSBUCHSTABEN = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $PZ_KLEINBUCHSTABEN = "abcdefghijklmnopqrstuvwxyz"
    $PZ_TRENNER = "-*"

    $len = $Auftragsnummer.Length
    $pos = 0
    $shift = 1
    $sum = 0

    while ($len-- -gt 0) {
        $byte = [byte]$Auftragsnummer.Substring($pos++, 1)[0]
        $byte = $byte -band 127
        If (($PZ_TRENNER + $PZ_ZAHLEN + $PZ_GROSSBUCHSTABEN + $PZ_KLEINBUCHSTABEN).IndexOf([char]$Byte) -eq -1) {
            throw "Ungültiges Zeichen in Auftragsnummer"
        } else {
            If ($PZ_TRENNER.IndexOf([char]$byte) -ge 0) {
                $byte = [byte]"0"[0]
            }
            # If ($PZ_ZAHLEN.IndexOf($byte.ToString()))
            If ($PZ_GROSSBUCHSTABEN.IndexOf([char]$byte) -ge 0) {
                $byte = $byte -bor 32
            }
            If ($PZ_KLEINBUCHSTABEN.IndexOf([char]$byte) -ge 0) {
                $byte = $byte % 10 + [byte]"0"[0]
            }
        }

        $byte = $byte - [byte]"0"[0]
        $cross = $byte -shl $shift
        If ($cross -gt 9) {
            $cross -= 9
        }
        $sum += $cross

        $shift = $shift -bxor 1

    }

    [char]([byte]"0"[0] + $sum % 10)
}

# gibt das letzte Zeichen der XML-Auftragsnummer zurück
Function Get-KZBVPrüfziffer {
   [CmdletBinding()]
    Param(
        [String]$Auftragsnummer
    )

    $Auftragsnummer.Substring($Auftragsnummer.Length -1)
}

# prüft eine XML-Auftragsnummer auf Korrektheit und gibt $true/$false zurück
Function Test-KZBVPrüfziffer {
   [CmdletBinding()]
    Param(
        [String]$Auftragsnummer
    )

    $Prüfziffer = Invoke-KZBVPrüfzifferBerechnung -Auftragsnummer $Auftragsnummer.Substring(0, $Auftragsnummer.Length -1)
    If ($Prüfziffer -eq (Get-KZBVPrüfziffer -Auftragsnummer $Auftragsnummer)) {
        $true
    } else {
        $false
    }
}

# testet alle Dateinamen mit Bindestrich und XML-Endung
Function Test-Directory {
   [CmdletBinding()]
    Param(
        [String]$Directory
    )

    $f = Get-Item -Path "$($Directory)\*.xml"
    $f | ForEach-Object {
                If ($_.Name -match "-") {
                    $n = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                    try {
                        $p = Invoke-KZBVPrüfzifferBerechnung -Auftragsnummer $n.Substring(0, $n.Length -1)
                        $v = Test-KZBVPrüfziffer -Auftragsnummer $n
                    } catch {
                        $p = ""
                        $v = $false
                    }

                    [PSCustomObject]@{"Auftragsnummer"=$n
                                      "Prüfziffer"=$p
                                      "Gültig"=$v
                                     }
                }
            }
}

# führt einen einfachen Test mit offiziell veröffentlichten XML-Auftragsnummern von der VDDS 
# Homepage durch
Function Test-VDDS-Auftragsnummern {

    $r=Invoke-WebRequest -Uri "https://www.vdds.de/schnittstellen/labor/auftragsnummern/"
    $l=$r.Content -split [char]10 | Select-String -AllMatches "(?'Standortnummer'[0-9]{6,6})-(?'Patientenpseudonym'[0-9|a-z]+)-(?'Abrechnungsbereich'(ze|kb|kfo))-(?'Planidentifikation'[0-9|a-z]+)-(?'Plannummer'[0-9]+)-(?'Pruefziffer'[0-9])"
    $l=($l).Matches.Value
    $l|Select-Object @{Name="Auftragsnummer";Expression={$_}},@{Name="Prüfziffer";Expression={Get-KZBVPrüfziffer -Auftragsnummer $_}},@{Name="Gültig";Expression={Test-KZBVPrüfziffer -Auftragsnummer $_}}
}

# ermittelt die Bestandteile der Auftragsnummer nach folgender Struktur: https://github.com/Delapro/KZBV-VDDS-XML-Schnittstellen-Validierung/blob/27eeae177b0c47cbac0a811882f09d600fb84ec2/Laborabrechnungsdaten_(KZBV-VDZI-VDDS)_(V4-5).xsd#L27
Function Get-KZBVAuftragsnummerProperties {
    [CmdletBinding()]
    Param(
        [String]$Auftragsnummer
    )
    
    <#
    Der verbindliche Aufbau der Auftragsnummer (AN) und der Umgang mit ihr wird folgendermaßen definiert:
    1. Erzeugung der AN durch die Praxis-Software des Zahnarztes
       Die Praxis-Software des Zahnarztes stellt sicher, dass die AN im Kontext der Praxis-Software eindeutig ist.
       Sie setzt sich aus den 6 Bestandteilen ...
         - Standortnummer der Praxis (6 numerische Stellen)
         - Patientenpseudonym
         - Abrechnungsbereich (entweder "ZE", "KB" oder "KFO")
         - Planidentifikation
         - Laufende Nummer zum Plan
         - Prüfziffer (siehe Beschreibung sowie C- und Delphi-Algorithmen) 
       ... in diese Reihenfolge zusammen. Zur Trennung der einzelnen Bestandteile ist ausschließlich das "Minus"-Zeichen
       zu verwenden. Für Patientenpseudonym, Planidentifikation und "Laufende Nummer zum Plan" gibt es folgende
       Vorgaben zur Länge:
         - die Angaben müssen vorhanden sein (Mindestlänge 1 Zeichen)
         - die Gesamtlänge von 50 Zeichen der AN darf in Summe nicht überschritten werden
       Die Standortnummer der Praxis setzt sich wie folgt zusammen:
         - letzte beide Ziffern der Zahnarztnummer
         - letzte beide Ziffern der Postleitzahl der Praxis
         - sowie einem 2-stelligen numerischen Zähler (00-99) der Praxissoftware zusammen.
       Das Patientenpseudonym und die Planidentifikation können Ziffern und Buchstaben (keine Umlaute) enthalten.
       Die Laufende Nummer zum Plan und die Prüfziffer bestehen nur aus Ziffern.
    #>

    $m= $Auftragsnummer | Select-String -AllMatches "(?'Standortnummer'[0-9]{6,6})-(?'Patientenpseudonym'[0-9|a-z]+)-(?'Abrechnungsbereich'(ze|kb|kfo))-(?'Planidentifikation'[0-9|a-z]+)-(?'Plannummer'[0-9]+)-(?'Pruefziffer'[0-9])"
    $h = $m.Matches.Groups| ForEach-Object {$d=@{}} {$d.Add($_.Name, $_.Value)} {$d}
    # noch Aufräumarbeiten durchführen, wegen der 0 und 1 ist ein direktes überführen in ein Objekt nicht möglich
    $h.Remove('1')
    $h.Add('Auftragsnummer', $h.Item('0'))
    $h.Remove('0')
    # nun gehts
    New-Object PSObject -Property $h
}
