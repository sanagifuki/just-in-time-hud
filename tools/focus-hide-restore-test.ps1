Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class FocusHideRestoreTestNative
{
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
}
"@

function Get-WindowTitle {
    param(
        [IntPtr]$Handle
    )

    if ($Handle -eq [IntPtr]::Zero) {
        return ''
    }

    $builder = [System.Text.StringBuilder]::new(512)
    [FocusHideRestoreTestNative]::GetWindowText($Handle, $builder, $builder.Capacity) | Out-Null
    return $builder.ToString()
}

function Update-StatusText {
    $currentHandle = [FocusHideRestoreTestNative]::GetForegroundWindow()
    $currentTitle = Get-WindowTitle -Handle $currentHandle
    $savedTitle = Get-WindowTitle -Handle $script:SavedWindowHandle

    $statusText.Text = @"
Saved handle: $($script:SavedWindowHandle)
Saved title: $savedTitle

Current handle: $currentHandle
Current title: $currentTitle
"@
}

function Hide-TestWindow {
    $script:IsHidden = $true
    $window.Left = -32000
    $window.Top = -32000
    $window.Width = 1
    $window.Height = 1

    if ($script:SavedWindowHandle -ne [IntPtr]::Zero) {
        [FocusHideRestoreTestNative]::SetForegroundWindow($script:SavedWindowHandle) | Out-Null
    }
}

function Show-TestWindow {
    if (-not $script:IsHidden) {
        return
    }

    $script:IsHidden = $false
    $window.Left = 80
    $window.Top = 120
    $window.Width = 560
    $window.Height = 240
    $window.Activate() | Out-Null
    Update-StatusText
}

$script:SavedWindowHandle = [FocusHideRestoreTestNative]::GetForegroundWindow()
$script:IsHidden = $false

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Focus Hide Restore Test"
        Width="560"
        Height="240"
        Left="80"
        Top="120"
        Topmost="True"
        ShowInTaskbar="True"
        WindowStyle="SingleBorderWindow">
    <Grid Background="#F6F8FA" Margin="12">
        <StackPanel>
            <TextBlock FontSize="16" FontWeight="SemiBold" Text="Focus Hide Restore Test"/>
            <TextBlock Margin="0,12,0,0" Text="Space: hide this window and restore saved focus"/>
            <TextBlock Margin="0,4,0,0" Text="Taskbar / Win+number: show this window again"/>
            <TextBlock Name="StatusText" Margin="0,14,0,0" FontFamily="Consolas" TextWrapping="Wrap"/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$statusText = $window.FindName('StatusText')

$window.Add_KeyDown({
    param($sender, $event)

    if ($event.Key -eq [System.Windows.Input.Key]::Space) {
        Hide-TestWindow
        $event.Handled = $true
    }
})

$window.Add_Activated({
    Show-TestWindow
})

Update-StatusText
$window.Show()
[System.Windows.Threading.Dispatcher]::Run()
