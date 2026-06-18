function global:Get-HudFeatureSnippets {
    param([AllowNull()][object]$Feature)

    if ($null -eq $Feature) {
        return @()
    }

    $snippets = [System.Collections.Generic.List[object]]::new()
    $featureCopyable = (Test-HudProperty -Target $Feature -Name 'copyable') -and [bool]$Feature.copyable
    if ((Test-HudProperty -Target $Feature -Name 'snippets') -and $null -ne $Feature.snippets) {
        foreach ($snippet in @($Feature.snippets)) {
            $text = if ($snippet -is [string]) { [string]$snippet } else { [string]$snippet.text }
            if ([string]::IsNullOrWhiteSpace($text)) { continue }
            $snippets.Add([pscustomobject]@{
                text = $text
                copyable = $featureCopyable
            })
        }
        return $snippets.ToArray()
    }

    if ((Test-HudProperty -Target $Feature -Name 'shortcut') -and -not [string]::IsNullOrWhiteSpace([string]$Feature.shortcut)) {
        return @([pscustomobject]@{
            text = [string]$Feature.shortcut
            copyable = $featureCopyable
        })
    }

    return @()
}

function global:Set-HudFeatureSnippetsFromText {
    param(
        [Parameter(Mandatory = $true)][object]$Feature,
        [AllowNull()][string]$Text,
        [bool]$Copyable
    )

    Remove-HudProperty -Target $Feature -Name 'shortcut'

    if ([string]::IsNullOrWhiteSpace($Text)) {
        Remove-HudProperty -Target $Feature -Name 'snippets'
        Remove-HudProperty -Target $Feature -Name 'copyable'
        return
    }

    $splitText = [regex]::Replace($Text.Trim(), "(?m)^(\s*)\\---(\s*)$", '$1__HUD_ESCAPED_SNIPPET_DELIMITER__$2')
    $parts = [regex]::Split($splitText, "(?m)^\s*---\s*$")
    $snippets = [System.Collections.Generic.List[string]]::new()
    foreach ($part in $parts) {
        $snippetText = $part.Trim().Replace('__HUD_ESCAPED_SNIPPET_DELIMITER__', '---')
        if ([string]::IsNullOrWhiteSpace($snippetText)) { continue }
        $snippets.Add($snippetText)
    }

    if ($snippets.Count -gt 0) {
        Set-HudProperty -Target $Feature -Name 'snippets' -Value @($snippets.ToArray())
        if ($Copyable) {
            Set-HudProperty -Target $Feature -Name 'copyable' -Value $true
        }
        else {
            Remove-HudProperty -Target $Feature -Name 'copyable'
        }
    }
    else {
        Remove-HudProperty -Target $Feature -Name 'snippets'
    }
}

function global:Format-HudSnippetTextForEditor {
    param([AllowNull()][string]$Text)

    if ($null -eq $Text) { return '' }
    return [regex]::Replace([string]$Text, "(?m)^(\s*)---(\s*)$", '$1\---$2')
}

function global:Join-HudSnippetTextsForEditor {
    param([AllowNull()][object[]]$Snippets)

    $texts = [System.Collections.Generic.List[string]]::new()
    foreach ($snippet in @($Snippets)) {
        $texts.Add((Format-HudSnippetTextForEditor -Text ([string]$snippet.text)))
    }
    return [string]::Join("`r`n---`r`n", $texts.ToArray())
}

function global:Add-HudSnippetRows {
    param(
        [Parameter(Mandatory = $true)][System.Windows.Controls.Panel]$Target,
        [Parameter(Mandatory = $true)][object[]]$Snippets
    )

    $Target.Children.Clear()
    $snippetIndex = 0
    foreach ($snippet in $Snippets) {
        $snippetBorder = [System.Windows.Controls.Border]::new()
        $snippetBorder.Background = $script:HudBrushSnippetBackground
        $snippetBorder.CornerRadius = [System.Windows.CornerRadius]::new(4)
        $snippetBorder.Padding = [System.Windows.Thickness]::new(10, 5, 10, 5)
        $bottomMargin = if ($snippetIndex -lt ($Snippets.Count - 1)) { 8 } else { 0 }
        $snippetBorder.Margin = [System.Windows.Thickness]::new(0, 0, 0, $bottomMargin)
        $snippetBorder.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left

        $snippetGrid = [System.Windows.Controls.Grid]::new()
        $snippetGrid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
        $snippetGrid.ColumnDefinitions[0].Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
        $snippetGrid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
        $snippetGrid.ColumnDefinitions[1].Width = [System.Windows.GridLength]::Auto

        $snippetTextBox = New-HudReadOnlyTextBox `
            -Text ([string]$snippet.text) `
            -FontFamily $script:HudFavoriteFontFamily `
            -FontSize $script:HudFavoriteTitleFontSize `
            -Foreground $script:HudBrushTextStrong `
            -FontWeight ([System.Windows.FontWeights]::SemiBold) `
            -Padding ([System.Windows.Thickness]::new(0, 1, 0, 1)) `
            -MaxHeight $script:HudSnippetMaxHeight `
            -VerticalScrollBarVisibility ([System.Windows.Controls.ScrollBarVisibility]::Hidden)
        $snippetTextBox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
        [System.Windows.Controls.Grid]::SetColumn($snippetTextBox, 0)
        [void]$snippetGrid.Children.Add($snippetTextBox)

        $lineCount = Get-HudTextLineCount -Text ([string]$snippet.text)
        $copyLabel = if ($lineCount -le 3) { 'cp' } else { "c`no`np`ny" }
        $copyOkLabel = if ($lineCount -le 3) { 'ok' } else { "o`nk" }
        $copyNgLabel = if ($lineCount -le 3) { 'ng' } else { "n`ng" }
        $snippetCopyButton = New-HudFlatButton `
            -Content $copyLabel `
            -Width 22 `
            -MinHeight 20 `
            -FontFamily $script:HudFavoriteFontFamily `
            -FontSize $script:HudFavoriteFilterFontSize `
            -Foreground $script:HudBrushTextNormal `
            -Background $script:HudBrushSnippetCopyBackground
        $snippetCopyButton.Tag = [pscustomobject]@{
            Copy = $copyLabel
            Ok = $copyOkLabel
            Ng = $copyNgLabel
        }
        $snippetCopyButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
        $snippetCopyButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
        $snippetCopyButton.Margin = [System.Windows.Thickness]::new(8, -5, -10, -5)
        if (-not [bool]$snippet.copyable) {
            $snippetCopyButton.Visibility = [System.Windows.Visibility]::Collapsed
        }
        $snippetCopyButton.Add_Click({
            param($sender, $event)
            $copyLabels = $sender.Tag
            try {
                [System.Windows.Clipboard]::SetText($snippetTextBox.Text)
                $sender.Content = $copyLabels.Ok
            }
            catch {
                $sender.Content = $copyLabels.Ng
            }
            $copyResetTimer = [System.Windows.Threading.DispatcherTimer]::new()
            $copyResetTimer.Interval = [TimeSpan]::FromMilliseconds(900)
            $copyResetTimer.Add_Tick({
                param($timerSender, $timerEvent)
                $timerSender.Stop()
                $sender.Content = $sender.Tag.Copy
            }.GetNewClosure())
            $copyResetTimer.Start()
            $event.Handled = $true
        }.GetNewClosure())
        [System.Windows.Controls.Grid]::SetColumn($snippetCopyButton, 1)
        [void]$snippetGrid.Children.Add($snippetCopyButton)

        $snippetBorder.Child = $snippetGrid
        [void]$Target.Children.Add($snippetBorder)
        $snippetIndex++
    }
}
