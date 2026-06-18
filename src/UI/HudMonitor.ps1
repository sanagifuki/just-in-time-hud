function global:Get-HudScreenDipBounds {
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
