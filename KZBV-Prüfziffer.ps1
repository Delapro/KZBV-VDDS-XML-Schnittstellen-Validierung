# Powershell KZBV-Prüfzifferberechnung
#
# erstellt von easy - innovative software
#
# zur Unterstützung der VDDS-Laborschnittstelle: http://www.vdds.de/content/de/laborschnittstelle.php
# http://www.kzbv.de/papierlose-abrechnung.98.de.html

# ermittelt die zum übergebenen String passende Prüfziffer nach dem
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
    $f | % {
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

    $r=Invoke-WebRequest -Uri "http://www.vdds.de/content/de/auftragsnummern.php"
    $l=$r.Content -split [char]10 | Select-String -AllMatches ">[0-9].*(-ZE-|-KB-|-KFO-).*[0-9]<"
    $l=($l).Matches.Value.TrimStart(">").TrimEnd("<")
    $l=$l -split "<br/>"
    $l|select @{Name="Auftragsnummer";Expression={$_}},@{Name="Prüfziffer";Expression={Get-KZBVPrüfziffer -Auftragsnummer $_}},@{Name="Gültig";Expression={Test-KZBVPrüfziffer -Auftragsnummer $_}}
}