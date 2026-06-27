function global:Start-HudPanelDrag {
    param(
        [Parameter(Mandatory = $true)][System.Windows.FrameworkElement]$Target,
        [Parameter(Mandatory = $true)][System.Windows.Input.MouseButtonEventArgs]$Event
    )

    $script:HudDragTarget = $Target
    $script:HudDragStartPoint = $Event.GetPosition($script:HudRoot)
    $script:HudDragStartMargin = $Target.Margin
    $Target.CaptureMouse() | Out-Null
    $Event.Handled = $true
}

function global:Get-HudClampedPanelMargin {
    param(
        [Parameter(Mandatory = $true)][System.Windows.FrameworkElement]$Target,
        [Parameter(Mandatory = $true)][double]$Left,
        [Parameter(Mandatory = $true)][double]$Top
    )

    $targetWidth = if ($Target.ActualWidth -gt 0) { $Target.ActualWidth } else { $Target.Width }
    $targetHeight = if ($Target.ActualHeight -gt 0) { $Target.ActualHeight } else { $Target.Height }
    if ([double]::IsNaN($targetWidth) -or $targetWidth -le 0) { $targetWidth = $script:HudFavoritePanelWidth }
    if ([double]::IsNaN($targetHeight) -or $targetHeight -le 0) { $targetHeight = $script:HudFavoritePanelHeight }

    $maxLeft = [Math]::Max(0, $script:HudFavoriteVisibleWidth - $targetWidth)
    $maxTop = [Math]::Max(0, $script:HudFavoriteVisibleHeight - $targetHeight)
    $clampedLeft = [Math]::Max(0, [Math]::Min($maxLeft, $Left))
    $clampedTop = [Math]::Max(0, [Math]::Min($maxTop, $Top))
    return [System.Windows.Thickness]::new($clampedLeft, $clampedTop, 0, 0)
}

function global:Get-HudAnchorClampedPanelMargin {
    param(
        [Parameter(Mandatory = $true)][double]$Left,
        [Parameter(Mandatory = $true)][double]$Top
    )

    $maxLeft = [Math]::Max(0, $script:HudFavoriteVisibleWidth - 32)
    $maxTop = [Math]::Max(0, $script:HudFavoriteVisibleHeight - 32)
    $clampedLeft = [Math]::Max(0, [Math]::Min($maxLeft, $Left))
    $clampedTop = [Math]::Max(0, [Math]::Min($maxTop, $Top))
    return [System.Windows.Thickness]::new($clampedLeft, $clampedTop, 0, 0)
}

function global:Get-HudPanelStateInfo {
    param([AllowNull()][System.Windows.FrameworkElement]$Panel)

    if ($null -eq $Panel) {
        return $null
    }
    if ($Panel -eq $script:HudMainPanel) {
        return [pscustomobject]@{ Container = 'panels'; Key = 'main' }
    }
    if ($Panel -eq $script:HudRecentPanel) {
        return [pscustomobject]@{ Container = 'panels'; Key = 'recent' }
    }
    if ($Panel -eq $script:HudMemoPanel) {
        return [pscustomobject]@{ Container = 'panels'; Key = 'memo' }
    }
    if ($null -ne $script:HudFavoritePanels -and $script:HudFavoritePanels.Contains($Panel)) {
        $stateKey = [string]$Panel.Uid
        if (-not [string]::IsNullOrWhiteSpace($stateKey)) {
            return [pscustomobject]@{ Container = 'favoritePanels'; Key = $stateKey }
        }
    }

    return $null
}

function global:Get-HudUiStateContainer {
    param([Parameter(Mandatory = $true)][string]$Name)

    if ($null -eq $script:HudUiState) {
        $script:HudUiState = New-HudUiState
    }
    Ensure-HudObjectProperty -Target $script:HudUiState -Name 'panels' -Value ([pscustomobject]@{})
    Ensure-HudObjectProperty -Target $script:HudUiState -Name 'favoritePanels' -Value ([pscustomobject]@{})
    return $script:HudUiState.$Name
}

function global:Get-HudUiStatePanelEntry {
    param([Parameter(Mandatory = $true)][object]$Info)

    $container = Get-HudUiStateContainer -Name $Info.Container
    $property = $container.PSObject.Properties[$Info.Key]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function global:Set-HudUiStatePanelEntry {
    param(
        [Parameter(Mandatory = $true)][object]$Info,
        [Parameter(Mandatory = $true)][System.Windows.FrameworkElement]$Panel
    )

    $container = Get-HudUiStateContainer -Name $Info.Container
    $entry = [pscustomobject]@{
        x = [Math]::Round([double]$Panel.Margin.Left, 2)
        y = [Math]::Round([double]$Panel.Margin.Top, 2)
        z = [System.Windows.Controls.Panel]::GetZIndex($Panel)
    }
    if ($null -eq $container.PSObject.Properties[$Info.Key]) {
        $container | Add-Member -NotePropertyName $Info.Key -NotePropertyValue $entry -Force
    }
    else {
        $container.PSObject.Properties[$Info.Key].Value = $entry
    }
}

function global:Save-HudPanelUiState {
    param([Parameter(Mandatory = $true)][System.Windows.FrameworkElement]$Panel)

    $info = Get-HudPanelStateInfo -Panel $Panel
    if ($null -eq $info) {
        return
    }

    Set-HudUiStatePanelEntry -Info $info -Panel $Panel
    Save-HudUiStateFromEvent
}

function global:Save-HudAllPanelUiState {
    if ($null -eq $script:HudRoot) {
        return
    }

    foreach ($child in $script:HudRoot.Children) {
        if ($child -is [System.Windows.FrameworkElement]) {
            $info = Get-HudPanelStateInfo -Panel $child
            if ($null -ne $info) {
                Set-HudUiStatePanelEntry -Info $info -Panel $child
            }
        }
    }
    Save-HudUiStateFromEvent
}

function global:Apply-HudUiStateToPanel {
    param([Parameter(Mandatory = $true)][System.Windows.FrameworkElement]$Panel)

    $info = Get-HudPanelStateInfo -Panel $Panel
    if ($null -eq $info) {
        return
    }

    $entry = Get-HudUiStatePanelEntry -Info $info
    if ($null -eq $entry) {
        return
    }

    if ($null -ne $entry.x -and $null -ne $entry.y) {
        $Panel.Margin = Get-HudAnchorClampedPanelMargin -Left ([double]$entry.x) -Top ([double]$entry.y)
    }
    if ($null -ne $entry.z) {
        [System.Windows.Controls.Panel]::SetZIndex($Panel, [int]$entry.z)
    }
}

function global:Apply-HudUiStateToKnownPanels {
    foreach ($panel in @($script:HudMainPanel, $script:HudRecentPanel, $script:HudMemoPanel)) {
        if ($null -ne $panel) {
            Apply-HudUiStateToPanel -Panel $panel
        }
    }
    foreach ($favoritePanel in @($script:HudFavoritePanels)) {
        if ($null -ne $favoritePanel) {
            Apply-HudUiStateToPanel -Panel $favoritePanel
        }
    }
}

function global:Get-HudPanelRect {
    param(
        [Parameter(Mandatory = $true)][double]$Left,
        [Parameter(Mandatory = $true)][double]$Top,
        [Parameter(Mandatory = $true)][double]$Width,
        [Parameter(Mandatory = $true)][double]$Height,
        [double]$Gap = 0
    )

    return [pscustomobject]@{
        Left = $Left - $Gap
        Top = $Top - $Gap
        Right = $Left + $Width + $Gap
        Bottom = $Top + $Height + $Gap
    }
}

function global:Test-HudPanelRectOverlap {
    param(
        [Parameter(Mandatory = $true)][object]$A,
        [Parameter(Mandatory = $true)][object]$B
    )

    return ($A.Left -lt $B.Right -and $A.Right -gt $B.Left -and $A.Top -lt $B.Bottom -and $A.Bottom -gt $B.Top)
}

function global:Test-HudPanelMarginOverlapsVisiblePanel {
    param(
        [Parameter(Mandatory = $true)][double]$Left,
        [Parameter(Mandatory = $true)][double]$Top,
        [Parameter(Mandatory = $true)][double]$Width,
        [Parameter(Mandatory = $true)][double]$Height,
        [double]$Gap = 8
    )

    if ($null -eq $script:HudRoot) {
        return $false
    }

    $candidateRect = Get-HudPanelRect -Left $Left -Top $Top -Width $Width -Height $Height -Gap $Gap
    foreach ($child in $script:HudRoot.Children) {
        if ($child -isnot [System.Windows.FrameworkElement]) {
            continue
        }
        if ($child.Visibility -ne [System.Windows.Visibility]::Visible) {
            continue
        }

        $childWidth = if ($child.ActualWidth -gt 0) { $child.ActualWidth } else { $child.Width }
        $childHeight = if ($child.ActualHeight -gt 0) { $child.ActualHeight } else { $child.Height }
        if ([double]::IsNaN($childWidth) -or [double]::IsNaN($childHeight) -or $childWidth -le 0 -or $childHeight -le 0) {
            continue
        }

        $childRect = Get-HudPanelRect -Left $child.Margin.Left -Top $child.Margin.Top -Width $childWidth -Height $childHeight -Gap $Gap
        if (Test-HudPanelRectOverlap -A $candidateRect -B $childRect) {
            return $true
        }
    }

    return $false
}

function global:Bring-HudPanelToFront {
    param(
        [Parameter(Mandatory = $true)]
        [System.Windows.FrameworkElement]$Panel
    )

    if ($null -eq $script:HudRoot -or -not $script:HudRoot.Children.Contains($Panel)) {
        return
    }

    $orderedPanels = [System.Collections.Generic.List[object]]::new()
    foreach ($child in $script:HudRoot.Children) {
        if ($child -ne $Panel) {
            $orderedPanels.Add($child)
        }
    }
    $orderedPanels.Add($Panel)

    for ($index = 0; $index -lt $orderedPanels.Count; $index++) {
        [System.Windows.Controls.Panel]::SetZIndex($orderedPanels[$index], $index)
    }
    Save-HudAllPanelUiState
}

function global:Move-HudPanelDrag {
    param([Parameter(Mandatory = $true)][System.Windows.Input.MouseEventArgs]$Event)

    if ($null -eq $script:HudDragTarget) {
        return
    }

    $point = $Event.GetPosition($script:HudRoot)
    $dx = $point.X - $script:HudDragStartPoint.X
    $dy = $point.Y - $script:HudDragStartPoint.Y
    $left = [Math]::Max(0, $script:HudDragStartMargin.Left + $dx)
    $top = [Math]::Max(0, $script:HudDragStartMargin.Top + $dy)
    $script:HudDragTarget.Margin = [System.Windows.Thickness]::new($left, $top, 0, 0)
    $Event.Handled = $true
}

function global:Stop-HudPanelDrag {
    param([Parameter(Mandatory = $true)][System.Windows.Input.MouseButtonEventArgs]$Event)

    if ($null -eq $script:HudDragTarget) {
        return
    }

    $dragTarget = $script:HudDragTarget
    $dragTarget.ReleaseMouseCapture()
    $script:HudDragTarget = $null
    $script:HudDragStartPoint = $null
    $script:HudDragStartMargin = $null
    Save-HudPanelUiState -Panel $dragTarget
    $Event.Handled = $true
}
