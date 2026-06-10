function Read-HudJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($script:EmbeddedHudDataJson) {
            Write-HudTextFileIfMissing -Path $Path -Text $script:EmbeddedHudDataJson
        }
        elseif ($script:DefaultHudSampleDataPath -and (Test-Path -LiteralPath $script:DefaultHudSampleDataPath)) {
            Write-HudTextFileIfMissing -Path $Path -Text (Get-Content -LiteralPath $script:DefaultHudSampleDataPath -Raw -Encoding UTF8)
        }
        else {
            throw "HUD data file not found: $Path"
        }
    }

    Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Save-HudJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [object[]]$Items
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    $json = @($Items) | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($Path), $json, [System.Text.UTF8Encoding]::new($true))
}

function Write-HudTextFileIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    if (Test-Path -LiteralPath $Path) {
        return
    }

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($Path), $Text, [System.Text.UTF8Encoding]::new($true))
}

function Remove-JsoncComments {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    $builder = [System.Text.StringBuilder]::new()
    $inString = $false
    $isEscaped = $false
    $length = $Text.Length

    for ($index = 0; $index -lt $length; $index++) {
        $char = $Text[$index]
        $next = if ($index + 1 -lt $length) { $Text[$index + 1] } else { [char]0 }

        if ($inString) {
            [void]$builder.Append($char)
            if ($isEscaped) {
                $isEscaped = $false
            }
            elseif ($char -eq '\') {
                $isEscaped = $true
            }
            elseif ($char -eq '"') {
                $inString = $false
            }
            continue
        }

        if ($char -eq '"') {
            $inString = $true
            [void]$builder.Append($char)
            continue
        }

        if ($char -eq '/' -and $next -eq '/') {
            while ($index -lt $length -and $Text[$index] -notin "`r", "`n") {
                $index++
            }
            if ($index -lt $length) {
                [void]$builder.Append($Text[$index])
            }
            continue
        }

        if ($char -eq '/' -and $next -eq '*') {
            $index += 2
            while ($index + 1 -lt $length -and -not ($Text[$index] -eq '*' -and $Text[$index + 1] -eq '/')) {
                $index++
            }
            $index++
            continue
        }

        [void]$builder.Append($char)
    }

    return $builder.ToString()
}

function Read-HudSettings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $defaults = [pscustomobject]@{
        panelX = 32
        panelY = 96
        recentPanelX = 464
        recentPanelY = 96
        saveWindowPositionOnMove = $false
        panelWidth = 420
        panelHeight = 360
        fontFamily = 'Yu Gothic UI'
        titleFontSize = 15
        detailTitleFontSize = 15
        featureTitleFontSize = 15
        filterFontSize = 12
        listFontSize = 14
        detailFontSize = 12
        bitLabels = [pscustomobject]@{
            one = '1'
            zero = '0'
        }
        backgroundRgba = [pscustomobject]@{
            r = 255
            g = 255
            b = 255
            a = 1
        }
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($script:EmbeddedHudSettingsJsonc) {
            Write-HudTextFileIfMissing -Path $Path -Text $script:EmbeddedHudSettingsJsonc
        }
        else {
            return $defaults
        }
    }

    $settings = Remove-JsoncComments -Text (Get-Content -LiteralPath $Path -Raw -Encoding UTF8) | ConvertFrom-Json
    foreach ($name in @('panelX', 'panelY', 'recentPanelX', 'recentPanelY', 'saveWindowPositionOnMove', 'panelWidth', 'panelHeight', 'fontFamily', 'titleFontSize', 'detailTitleFontSize', 'featureTitleFontSize', 'filterFontSize', 'listFontSize', 'detailFontSize')) {
        if ($null -eq $settings.$name) {
            $settings | Add-Member -NotePropertyName $name -NotePropertyValue $defaults.$name -Force
        }
    }
    if ($null -eq $settings.bitLabels) {
        $settings | Add-Member -NotePropertyName 'bitLabels' -NotePropertyValue $defaults.bitLabels -Force
    }
    foreach ($name in @('one', 'zero')) {
        if ($null -eq $settings.bitLabels.$name) {
            $settings.bitLabels | Add-Member -NotePropertyName $name -NotePropertyValue $defaults.bitLabels.$name -Force
        }
    }
    if ($null -eq $settings.backgroundRgba) {
        $settings | Add-Member -NotePropertyName 'backgroundRgba' -NotePropertyValue $defaults.backgroundRgba -Force
    }
    foreach ($name in @('r', 'g', 'b', 'a')) {
        if ($null -eq $settings.backgroundRgba.$name) {
            $settings.backgroundRgba | Add-Member -NotePropertyName $name -NotePropertyValue $defaults.backgroundRgba.$name -Force
        }
    }

    return $settings
}

function ConvertTo-WpfColorCode {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Rgba
    )

    $r = [Math]::Max(0, [Math]::Min(255, [int]$Rgba.r))
    $g = [Math]::Max(0, [Math]::Min(255, [int]$Rgba.g))
    $b = [Math]::Max(0, [Math]::Min(255, [int]$Rgba.b))
    $aValue = [double]$Rgba.a
    if ($aValue -le 1) {
        $a = [Math]::Round($aValue * 255)
    }
    else {
        $a = [Math]::Round($aValue)
    }
    $a = [Math]::Max(0, [Math]::Min(255, [int]$a))

    return ('#{0:X2}{1:X2}{2:X2}{3:X2}' -f $a, $r, $g, $b)
}
