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
