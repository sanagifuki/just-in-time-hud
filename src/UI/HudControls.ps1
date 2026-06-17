function New-HudReadOnlyTextBox {
    param(
        [AllowNull()][string]$Text,
        [Parameter(Mandatory = $true)][string]$FontFamily,
        [Parameter(Mandatory = $true)][double]$FontSize,
        [Parameter(Mandatory = $true)][System.Windows.Media.Brush]$Foreground,
        [System.Windows.FontWeight]$FontWeight = [System.Windows.FontWeights]::Normal,
        [System.Windows.Thickness]$Padding = [System.Windows.Thickness]::new(0),
        [double]$MaxHeight = -1,
        [System.Windows.Controls.ScrollBarVisibility]$VerticalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Disabled
    )

    $textBox = [System.Windows.Controls.TextBox]::new()
    $textBox.Text = [string]$Text
    $textBox.FontFamily = $FontFamily
    $textBox.FontSize = $FontSize
    $textBox.FontWeight = $FontWeight
    $textBox.Foreground = $Foreground
    $textBox.Background = [System.Windows.Media.Brushes]::Transparent
    $textBox.BorderThickness = [System.Windows.Thickness]::new(0)
    $textBox.Padding = $Padding
    $textBox.IsReadOnly = $true
    $textBox.IsReadOnlyCaretVisible = $false
    $textBox.AcceptsReturn = $true
    $textBox.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $textBox.VerticalScrollBarVisibility = $VerticalScrollBarVisibility
    $textBox.HorizontalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Disabled

    if ($MaxHeight -ge 0) {
        $textBox.MaxHeight = $MaxHeight
    }

    return $textBox
}

function New-HudFlatButton {
    param(
        [Parameter(Mandatory = $true)][object]$Content,
        [double]$Width = -1,
        [double]$Height = -1,
        [double]$MinHeight = -1,
        [Parameter(Mandatory = $true)][string]$FontFamily,
        [Parameter(Mandatory = $true)][double]$FontSize,
        [Parameter(Mandatory = $true)][System.Windows.Media.Brush]$Foreground,
        [System.Windows.Media.Brush]$Background = [System.Windows.Media.Brushes]::Transparent,
        [System.Windows.Thickness]$Padding = [System.Windows.Thickness]::new(0)
    )

    $button = [System.Windows.Controls.Button]::new()
    $button.Content = $Content
    if ($Width -ge 0) { $button.Width = $Width }
    if ($Height -ge 0) { $button.Height = $Height }
    if ($MinHeight -ge 0) { $button.MinHeight = $MinHeight }
    $button.Padding = $Padding
    $button.BorderThickness = [System.Windows.Thickness]::new(0)
    $button.Background = $Background
    $button.Foreground = $Foreground
    $button.FontFamily = $FontFamily
    $button.FontSize = $FontSize
    return $button
}

function Test-HudProperty {
    param(
        [AllowNull()][object]$Target,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return ($null -ne $Target -and $null -ne $Target.PSObject.Properties[$Name])
}

function Remove-HudProperty {
    param(
        [AllowNull()][object]$Target,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if (Test-HudProperty -Target $Target -Name $Name) {
        $Target.PSObject.Properties.Remove($Name)
    }
}

function Remove-HudArrayItem {
    param(
        [AllowNull()][object[]]$Items,
        [AllowNull()][object]$RemoveItem
    )

    $remaining = [System.Collections.Generic.List[object]]::new()
    foreach ($item in @($Items)) {
        if ($item -ne $RemoveItem) {
            $remaining.Add($item)
        }
    }
    return $remaining.ToArray()
}

function Get-HudTextLineCount {
    param([AllowNull()][string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return 1
    }

    $count = 1
    $index = 0
    while ($index -lt $Text.Length) {
        $char = $Text[$index]
        if ($char -eq "`r") {
            $count++
            if (($index + 1) -lt $Text.Length -and $Text[$index + 1] -eq "`n") {
                $index++
            }
        }
        elseif ($char -eq "`n") {
            $count++
        }
        $index++
    }
    return $count
}

function Set-HudListBoxItems {
    param(
        [Parameter(Mandatory = $true)][System.Windows.Controls.ListBox]$ListBox,
        [AllowNull()][object[]]$Items,
        [AllowNull()][object]$Selected
    )

    $ListBox.Items.Clear()
    foreach ($item in @($Items)) {
        [void]$ListBox.Items.Add($item)
    }

    if ($null -ne $Selected -and @($Items) -contains $Selected) {
        $ListBox.SelectedItem = $Selected
    }
    elseif ($ListBox.Items.Count -gt 0) {
        $ListBox.SelectedIndex = 0
    }
}

function Get-HudScreenDipBounds {
    param([Parameter(Mandatory = $true)][System.Drawing.Rectangle]$Bounds)

    $dpiX = [uint32]96
    $dpiY = [uint32]96
    try {
        $point = [HudNativeMethods+POINT]::new()
        $point.x = $Bounds.Left
        $point.y = $Bounds.Top
        $monitor = [HudNativeMethods]::MonitorFromPoint($point, [HudNativeMethods]::MONITOR_DEFAULTTONEAREST)
        if ($monitor -ne [IntPtr]::Zero) {
            [void][HudNativeMethods]::GetDpiForMonitor($monitor, [HudNativeMethods]::MDT_EFFECTIVE_DPI, [ref]$dpiX, [ref]$dpiY)
        }
    }
    catch {
        $dpiX = [uint32]96
        $dpiY = [uint32]96
    }

    $scaleX = [Math]::Max(0.1, [double]$dpiX / 96.0)
    $scaleY = [Math]::Max(0.1, [double]$dpiY / 96.0)

    return [pscustomobject]@{
        Left = [double]$Bounds.Left / $scaleX
        Top = [double]$Bounds.Top / $scaleY
        Width = [double]$Bounds.Width / $scaleX
        Height = [double]$Bounds.Height / $scaleY
        ScaleX = $scaleX
        ScaleY = $scaleY
    }
}
