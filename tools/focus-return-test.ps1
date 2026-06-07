Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class FocusReturnTestNative
{
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

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
    [FocusReturnTestNative]::GetWindowText($Handle, $builder, $builder.Capacity) | Out-Null
    return $builder.ToString()
}

$previousWindowHandle = [FocusReturnTestNative]::GetForegroundWindow()
$previousWindowTitle = Get-WindowTitle -Handle $previousWindowHandle

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Previous Window"
        Width="520"
        Height="180"
        Left="80"
        Top="120"
        Topmost="True"
        ShowInTaskbar="True"
        WindowStyle="SingleBorderWindow">
    <Grid Background="#F6F8FA" Margin="12">
        <StackPanel>
            <TextBlock FontSize="16" FontWeight="SemiBold" Text="Previous Window"/>
            <TextBlock Margin="0,12,0,0" Text="Handle:"/>
            <TextBlock Name="HandleText" Margin="0,2,0,0" FontFamily="Consolas"/>
            <TextBlock Margin="0,10,0,0" Text="Title:"/>
            <TextBlock Name="TitleText" Margin="0,2,0,0" TextWrapping="Wrap"/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$window.FindName('HandleText').Text = $previousWindowHandle.ToString()
$window.FindName('TitleText').Text = $previousWindowTitle

[void]$window.ShowDialog()
