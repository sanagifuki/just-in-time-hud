function New-HudState {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Items
    )

    [pscustomobject]@{
        Items = $Items
        Level = 'Root'
        SelectedCategory = $null
        SelectedGroup = $null
        SelectedFeature = $null
        TextFilter = ''
    }
}

function Get-HudCandidates {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$State
    )

    switch ($State.Level) {
        'Root' {
            $items = $State.Items
            if ($State.TextFilter) {
                $items = @($items | Where-Object { $_.name.StartsWith($State.TextFilter, [System.StringComparison]::OrdinalIgnoreCase) })
            }
            return @($items | ForEach-Object { [pscustomobject]@{ Label = $_.name; Value = $_ } })
        }
        'Group' {
            $items = @($State.SelectedCategory.groups)
            if ($State.TextFilter) {
                $items = @($items | Where-Object { $_.name.StartsWith($State.TextFilter, [System.StringComparison]::OrdinalIgnoreCase) })
            }
            return @($items | ForEach-Object { [pscustomobject]@{ Label = $_.name; Value = $_ } })
        }
        'Feature' {
            $items = @($State.SelectedGroup.features)
            if ($State.TextFilter) {
                $items = @($items | Where-Object { Test-HudInitialMatch -Text $_.title -Filter $State.TextFilter })
            }
            return @($items | ForEach-Object { [pscustomobject]@{ Label = $_.title; Value = $_ } })
        }
        'Detail' {
            return @([pscustomobject]@{ Label = $State.SelectedFeature.title; Value = $State.SelectedFeature })
        }
    }
}

function Test-HudInitialMatch {
    param(
        [AllowNull()]
        [string]$Text,

        [AllowNull()]
        [string]$Filter
    )

    if ([string]::IsNullOrEmpty($Filter)) {
        return $true
    }
    if ([string]::IsNullOrEmpty($Text)) {
        return $false
    }
    if ($Text.StartsWith($Filter, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    $initials = (([regex]::Matches($Text, '\b[0-9A-Za-z]') | ForEach-Object { $_.Value }) -join '')

    return $initials.StartsWith($Filter, [System.StringComparison]::OrdinalIgnoreCase)
}

function ConvertTo-HudBitDisplayText {
    param(
        [string]$BitText
    )

    if (-not $script:HudBitLabels) {
        return $BitText
    }

    $chars = foreach ($char in $BitText.ToCharArray()) {
        switch ($char) {
            '1' { $script:HudBitLabels.one }
            '0' { $script:HudBitLabels.zero }
            default { [string]$char }
        }
    }
    return ($chars -join '')
}

function Reset-HudFilter {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$State
    )

    $State.TextFilter = ''
}
