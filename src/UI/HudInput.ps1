function global:ConvertFrom-HudKeyToText {
    param([Parameter(Mandatory = $true)][System.Windows.Input.Key]$Key)

    $keyText = $Key.ToString()
    if ($keyText.Length -eq 1 -and [char]::IsLetter($keyText[0])) {
        return $keyText.ToLowerInvariant()
    }
    if ($keyText -match '^D([0-9])$') {
        return $matches[1]
    }
    if ($keyText -match '^NumPad([0-9])$') {
        return $matches[1]
    }

    return ''
}

function global:ConvertFrom-HudKeyToCandidateNumber {
    param([Parameter(Mandatory = $true)][System.Windows.Input.Key]$Key)

    $keyText = $Key.ToString()
    if ($keyText -match '^D([1-3])$') {
        return [int]$matches[1]
    }
    if ($keyText -match '^NumPad([1-3])$') {
        return [int]$matches[1]
    }

    return 0
}
