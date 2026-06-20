function global:Set-RecentPanelVisibility {
    param([bool]$Visible)

    if (-not $script:HudShowRecentPanel -or -not $Visible -or $script:HudIsRetreated) {
        $script:HudRecentPanel.Visibility = [System.Windows.Visibility]::Collapsed
        return
    }

    $script:HudRecentPanel.Visibility = [System.Windows.Visibility]::Visible
}

function global:Add-HudRecentPanelContextMenu {
    if ($null -eq $script:HudRecentPanel) {
        return
    }

    $menu = [System.Windows.Controls.ContextMenu]::new()
    $bringToFrontItem = [System.Windows.Controls.MenuItem]::new()
    $bringToFrontItem.Header = '最前面に表示'
    $bringToFrontItem.Add_Click({
        param($sender, $event)
        Bring-HudPanelToFront -Panel $script:HudRecentPanel
        $event.Handled = $true
    })
    [void]$menu.Items.Add($bringToFrontItem)
    $script:HudRecentPanel.ContextMenu = $menu
}

function global:Update-RecentDetailWindow {
    param(
        [Parameter(Mandatory = $true)][object]$Feature,
        [Parameter(Mandatory = $true)][string]$CategoryName,
        [Parameter(Mandatory = $true)][string]$GroupName
    )

    $script:HudRecentPathText.Text = "$CategoryName / $GroupName /"
    $script:HudRecentFeatureTitleText.Text = $Feature.title
    $script:HudRecentDescriptionText.Text = $Feature.description

    $snippets = @(Get-HudFeatureSnippets -Feature $Feature)
    if ($snippets.Count -gt 0) {
        Add-HudSnippetRows -Target $script:HudRecentSnippetList -Snippets $snippets
        $script:HudRecentShortcutArea.Visibility = [System.Windows.Visibility]::Visible
    }
    else {
        $script:HudRecentSnippetList.Children.Clear()
        $script:HudRecentShortcutArea.Visibility = [System.Windows.Visibility]::Collapsed
    }

    Set-RecentPanelVisibility -Visible $true
}

function global:Update-RecentHistoryNav {
    $count = @($script:HudRecentHistory).Count
    if ($count -le 0) {
        $script:HudRecentHistoryText.Text = '0/0'
        $script:HudRecentPrevButton.IsEnabled = $false
        $script:HudRecentNextButton.IsEnabled = $false
        return
    }

    $script:HudRecentHistoryText.Text = "$($script:HudRecentHistoryIndex + 1)/$count"
    $script:HudRecentPrevButton.IsEnabled = ($count -gt 1)
    $script:HudRecentNextButton.IsEnabled = ($count -gt 1)
}

function global:Show-EmptyRecentDetailWindow {
    $script:HudRecentPathText.Text = '直近 /'
    $script:HudRecentFeatureTitleText.Text = 'まだ詳細を開いていません'
    $script:HudRecentSnippetList.Children.Clear()
    $script:HudRecentShortcutArea.Visibility = [System.Windows.Visibility]::Collapsed
    $script:HudRecentDescriptionText.Text = '詳細画面を開くと、ここに直近の内容が残ります。'
    Update-RecentHistoryNav
    Set-RecentPanelVisibility -Visible $true
}

function global:Show-RecentHistoryEntry {
    $count = @($script:HudRecentHistory).Count
    if ($count -le 0) {
        Show-EmptyRecentDetailWindow
        return
    }

    if ($script:HudRecentHistoryIndex -lt 0) {
        $script:HudRecentHistoryIndex = 0
    }
    elseif ($script:HudRecentHistoryIndex -ge $count) {
        $script:HudRecentHistoryIndex = $count - 1
    }

    $entry = $script:HudRecentHistory[$script:HudRecentHistoryIndex]
    $script:HudRecentFeature = $entry.Feature
    $script:HudRecentCategoryName = $entry.CategoryName
    $script:HudRecentGroupName = $entry.GroupName
    Update-RecentDetailWindow -Feature $entry.Feature -CategoryName $entry.CategoryName -GroupName $entry.GroupName
    Update-RecentHistoryNav
}

function global:Set-RecentDetail {
    param([Parameter(Mandatory = $true)][object]$Feature)

    $entry = [pscustomobject]@{
        Feature = $Feature
        CategoryName = $script:HudState.SelectedCategory.name
        GroupName = $script:HudState.SelectedGroup.name
    }

    $current = if (@($script:HudRecentHistory).Count -gt 0) { $script:HudRecentHistory[0] } else { $null }
    if ($null -eq $current -or $current.Feature -ne $Feature) {
        $history = [System.Collections.Generic.List[object]]::new()
        $history.Add($entry)
        foreach ($historyEntry in @($script:HudRecentHistory)) {
            if ($historyEntry.Feature -eq $Feature) {
                continue
            }
            if ($history.Count -ge $script:HudRecentHistoryMax) {
                break
            }
            $history.Add($historyEntry)
        }
        $script:HudRecentHistory = $history.ToArray()
    }

    $script:HudRecentHistoryIndex = 0
    Show-RecentHistoryEntry
}

function global:Show-RecentDetailIfAvailable {
    if (@($script:HudRecentHistory).Count -le 0) {
        Show-EmptyRecentDetailWindow
        return
    }

    Show-RecentHistoryEntry
}

function global:Move-RecentHistory {
    param([Parameter(Mandatory = $true)][int]$Delta)

    $count = @($script:HudRecentHistory).Count
    if ($count -le 0) {
        return
    }

    $script:HudRecentHistoryIndex = ($script:HudRecentHistoryIndex + $Delta) % $count
    if ($script:HudRecentHistoryIndex -lt 0) {
        $script:HudRecentHistoryIndex += $count
    }
    Show-RecentHistoryEntry
}
