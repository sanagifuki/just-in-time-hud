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

    $candidates = [System.Collections.Generic.List[object]]::new()
    $filter = [string]$State.TextFilter

    switch ($State.Level) {
        'Root' {
            foreach ($item in @($State.Items)) {
                $name = [string]$item.name
                if ($filter -and -not $name.StartsWith($filter, [System.StringComparison]::OrdinalIgnoreCase)) {
                    continue
                }
                $candidates.Add([pscustomobject]@{ Label = $name; Value = $item })
            }
        }
        'Group' {
            foreach ($item in @($State.SelectedCategory.groups)) {
                $name = [string]$item.name
                if ($filter -and -not $name.StartsWith($filter, [System.StringComparison]::OrdinalIgnoreCase)) {
                    continue
                }
                $candidates.Add([pscustomobject]@{ Label = $name; Value = $item })
            }
        }
        'Feature' {
            foreach ($item in @($State.SelectedGroup.features)) {
                $title = [string]$item.title
                if ($filter -and -not (Test-HudInitialMatch -Text $title -Filter $filter)) {
                    continue
                }
                $candidates.Add([pscustomobject]@{ Label = $title; Value = $item })
            }
        }
        'Detail' {
            return @([pscustomobject]@{ Label = $State.SelectedFeature.title; Value = $State.SelectedFeature })
        }
    }

    return $candidates.ToArray()
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

    $initials = [System.Text.StringBuilder]::new()
    $previousIsAsciiWord = $false
    foreach ($char in $Text.ToCharArray()) {
        $code = [int][char]$char
        $isAsciiWord = (
            ($code -ge 48 -and $code -le 57) -or
            ($code -ge 65 -and $code -le 90) -or
            ($code -ge 97 -and $code -le 122)
        )

        if ($isAsciiWord -and -not $previousIsAsciiWord) {
            [void]$initials.Append($char)
        }
        $previousIsAsciiWord = $isAsciiWord
    }

    return $initials.ToString().StartsWith($Filter, [System.StringComparison]::OrdinalIgnoreCase)
}

function Reset-HudFilter {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$State
    )

    $State.TextFilter = ''
}
