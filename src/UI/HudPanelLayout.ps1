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

    $script:HudDragTarget.ReleaseMouseCapture()
    $script:HudDragTarget = $null
    $script:HudDragStartPoint = $null
    $script:HudDragStartMargin = $null
    $Event.Handled = $true
}
