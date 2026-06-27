function global:Set-FavoriteButtonStateFromEvent {
    param([AllowNull()][object]$Feature)

    if ($null -eq $script:HudFavoriteButton) {
        return
    }

    if ($null -eq $Feature) {
        $script:HudFavoriteButton.Visibility = [System.Windows.Visibility]::Collapsed
        return
    }

    $script:HudFavoriteButton.Visibility = [System.Windows.Visibility]::Visible
    if ((Test-HudProperty -Target $Feature -Name 'favorite') -and [bool]$Feature.favorite) {
        $script:HudFavoriteButton.Content = '★'
        $script:HudFavoriteButton.Foreground = $script:HudBrushFavoriteStar
    }
    else {
        $script:HudFavoriteButton.Content = '☆'
        $script:HudFavoriteButton.Foreground = $script:HudBrushTextMuted
    }
}

function global:Get-HudFavoriteDefaultMarginFromEvent {
    param([Parameter(Mandatory = $true)][int]$StackIndex)

    $outerMargin = 24
    $gap = 16
    $cascadeOffset = 18
    $maxCascadeItems = 5
    $cascadeReserve = $cascadeOffset * ($maxCascadeItems - 1)
    $bundleWidth = $script:HudFavoritePanelWidth + $cascadeReserve
    $bundleHeight = $script:HudFavoritePanelHeight + $cascadeReserve
    $stepX = $bundleWidth + $gap
    $stepY = $bundleHeight + $gap
    $minLeft = [Math]::Min($outerMargin, [Math]::Max(0, $script:HudFavoriteVisibleWidth - $bundleWidth))
    $minTop = [Math]::Min($outerMargin, [Math]::Max(0, $script:HudFavoriteVisibleHeight - $bundleHeight))
    $usableWidth = [Math]::Max(1, $script:HudFavoriteVisibleWidth - ($minLeft * 2))
    $usableHeight = [Math]::Max(1, $script:HudFavoriteVisibleHeight - ($minTop * 2))
    $columnCount = [Math]::Max(1, [int][Math]::Floor(($usableWidth + $gap) / $stepX))
    $rowCount = [Math]::Max(1, [int][Math]::Floor(($usableHeight + $gap) / $stepY))
    $slotCount = [Math]::Max(1, $columnCount * $rowCount)
    $slotIndex = $StackIndex % $slotCount
    $columnIndex = $slotIndex % $columnCount
    $rowIndex = [int][Math]::Floor($slotIndex / $columnCount)
    $left = $minLeft + ($stepX * $columnIndex)
    $top = $minTop + ($stepY * $rowIndex)

    return [System.Windows.Thickness]::new($left, $top, 0, 0)
}

function global:Get-HudFavoriteEntries {
    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($category in @($script:HudState.Items)) {
        foreach ($group in @($category.groups)) {
            foreach ($feature in @($group.features)) {
                if ((Test-HudProperty -Target $feature -Name 'favorite') -and [bool]$feature.favorite) {
                    $entries.Add([pscustomobject]@{
                        CategoryName = $category.name
                        GroupName = $group.name
                        Feature = $feature
                    })
                }
            }
        }
    }
    return $entries.ToArray()
}

function global:New-HudFavoritePanelBorder {
    param(
        [Parameter(Mandatory = $true)][object]$Entry,
        [Parameter(Mandatory = $true)][System.Windows.Thickness]$BaseMargin,
        [Parameter(Mandatory = $true)][int]$CascadeIndex,
        [Parameter(Mandatory = $true)][string]$StateKey
    )

    $border = [System.Windows.Controls.Border]::new()
    $border.Width = $script:HudFavoritePanelWidth
    $border.Height = $script:HudFavoritePanelHeight
    $border.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $border.VerticalAlignment = [System.Windows.VerticalAlignment]::Top

    $featureId = "$($Entry.CategoryName)`n$($Entry.GroupName)`n$($Entry.Feature.title)"
    $border.Tag = $featureId
    $border.Uid = $StateKey
    $left = $BaseMargin.Left + (18 * $CascadeIndex)
    $top = $BaseMargin.Top + (18 * $CascadeIndex)
    $border.Margin = [System.Windows.Thickness]::new($left, $top, 0, 0)

    $border.Background = $script:HudBrushPanelBackground
    $border.BorderBrush = $script:HudBrushPanelBorder
    $border.BorderThickness = [System.Windows.Thickness]::new(1)
    $border.Padding = [System.Windows.Thickness]::new(12, 10, 12, 8)
    return $border
}

function global:Bring-HudFavoritePanelToFront {
    param(
        [Parameter(Mandatory = $true)]
        [System.Windows.FrameworkElement]$Panel
    )

    if ($null -eq $script:HudFavoritePanels -or -not $script:HudFavoritePanels.Contains($Panel)) {
        return
    }

    Bring-HudPanelToFront -Panel $Panel

    $orderedPanels = [System.Collections.Generic.List[object]]::new()
    foreach ($favoritePanel in $script:HudFavoritePanels) {
        if ($favoritePanel -ne $Panel) {
            $orderedPanels.Add($favoritePanel)
        }
    }
    $orderedPanels.Add($Panel)

    $script:HudFavoritePanels.Clear()
    foreach ($favoritePanel in $orderedPanels) {
        $script:HudFavoritePanels.Add($favoritePanel)
    }
}

function global:Add-HudFavoritePanelContextMenu {
    param(
        [Parameter(Mandatory = $true)]
        [System.Windows.FrameworkElement]$Panel
    )

    $menu = [System.Windows.Controls.ContextMenu]::new()
    $bringToFrontItem = [System.Windows.Controls.MenuItem]::new()
    $bringToFrontItem.Header = '最前面に表示'
    $bringToFrontItem.Tag = $Panel
    $bringToFrontItem.Add_Click({
        param($sender, $event)
        Bring-HudFavoritePanelToFront -Panel $sender.Tag
        $event.Handled = $true
    })
    [void]$menu.Items.Add($bringToFrontItem)
    $Panel.ContextMenu = $menu
}

function global:Refresh-HudFavoritePanelsFromEvent {
    param([bool]$ForceRebuild = $false)

    if ($null -eq $script:HudRoot) {
        $script:HudFavoritePanels = [System.Collections.Generic.List[object]]::new()
        return
    }

    if ($script:HudIsRetreated) {
        foreach ($favoritePanel in @($script:HudFavoritePanels)) {
            $favoritePanel.Visibility = [System.Windows.Visibility]::Collapsed
        }
        return
    }

    $entries = @(Get-HudFavoriteEntries)
    if (-not $ForceRebuild -and $null -ne $script:HudFavoritePanels -and $script:HudFavoritePanels.Count -eq $entries.Count) {
        $samePanels = $true
        for ($index = 0; $index -lt $entries.Count; $index++) {
            $featureId = "$($entries[$index].CategoryName)`n$($entries[$index].GroupName)`n$($entries[$index].Feature.title)"
            if ([string]$script:HudFavoritePanels[$index].Tag -ne $featureId) {
                $samePanels = $false
                break
            }
        }

        if ($samePanels) {
            foreach ($favoritePanel in @($script:HudFavoritePanels)) {
                $favoritePanel.Visibility = [System.Windows.Visibility]::Visible
            }
            Bring-HudMemoPanelToFront
            return
        }
    }

    foreach ($favoritePanel in @($script:HudFavoritePanels)) {
        $featureId = [string]$favoritePanel.Tag
        if (-not [string]::IsNullOrWhiteSpace($featureId)) {
            $script:HudFavoritePanelPositions[$featureId] = $favoritePanel.Margin
        }
        [void]$script:HudRoot.Children.Remove($favoritePanel)
    }
    $script:HudFavoritePanels = [System.Collections.Generic.List[object]]::new()

    $maxCascadeItems = 5
    $index = 0
    foreach ($entry in $entries) {
        $stackIndex = [int][Math]::Floor($index / $maxCascadeItems)
        $cascadeIndex = $index % $maxCascadeItems
        $baseMargin = Get-HudFavoriteDefaultMarginFromEvent -StackIndex $stackIndex

        $border = New-HudFavoritePanelBorder -Entry $entry -BaseMargin $baseMargin -CascadeIndex $cascadeIndex -StateKey "favorite:$index"
        Add-HudFavoritePanelContextMenu -Panel $border

        $grid = [System.Windows.Controls.Grid]::new()
        $grid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
        $grid.ColumnDefinitions[0].Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
        $grid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
        $grid.ColumnDefinitions[1].Width = [System.Windows.GridLength]::Auto
        $grid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
        $grid.ColumnDefinitions[2].Width = [System.Windows.GridLength]::Auto
        $grid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $grid.RowDefinitions[0].Height = [System.Windows.GridLength]::Auto
        $grid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $grid.RowDefinitions[1].Height = [System.Windows.GridLength]::Auto
        $grid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $grid.RowDefinitions[2].Height = [System.Windows.GridLength]::Auto
        $grid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $grid.RowDefinitions[3].Height = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)

        $pathText = [System.Windows.Controls.TextBlock]::new()
        $pathText.Text = "$($entry.CategoryName) / $($entry.GroupName) /"
        $pathText.FontFamily = $script:HudFavoriteFontFamily
        $pathText.FontSize = $script:HudFavoriteDetailTitleFontSize
        $pathText.FontWeight = [System.Windows.FontWeights]::SemiBold
        $pathText.Foreground = $script:HudBrushTextPath
        $pathText.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $border -Event $event }.GetNewClosure())
        [System.Windows.Controls.Grid]::SetRow($pathText, 0)
        [System.Windows.Controls.Grid]::SetColumn($pathText, 0)
        [void]$grid.Children.Add($pathText)

        $favoriteDragHandle = [System.Windows.Controls.TextBlock]::new()
        $favoriteDragHandle.Text = '・・・'
        $favoriteDragHandle.Width = 28
        $favoriteDragHandle.Height = 20
        $favoriteDragHandle.TextAlignment = [System.Windows.TextAlignment]::Center
        $favoriteDragHandle.Foreground = $script:HudBrushTextSubtle
        $favoriteDragHandle.FontFamily = $script:HudFavoriteFontFamily
        $favoriteDragHandle.FontSize = $script:HudFavoriteFilterFontSize
        $favoriteDragHandle.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $border -Event $event }.GetNewClosure())
        [System.Windows.Controls.Grid]::SetRow($favoriteDragHandle, 0)
        [System.Windows.Controls.Grid]::SetColumn($favoriteDragHandle, 1)
        [void]$grid.Children.Add($favoriteDragHandle)

        $unfavoriteButton = New-HudFlatButton `
            -Content '★' `
            -Width 24 `
            -Height 20 `
            -FontFamily $script:HudFavoriteFontFamily `
            -FontSize $script:HudFavoriteTitleFontSize `
            -Foreground $script:HudBrushFavoriteStar
        $unfavoriteButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
        $unfavoriteButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
        $unfavoriteButton.Add_Click({
            param($sender, $event)
            Remove-HudProperty -Target $entry.Feature -Name 'favorite'
            Save-HudJsonFromEvent
            if ($script:HudState.SelectedFeature -eq $entry.Feature) {
                Set-FavoriteButtonStateFromEvent -Feature $entry.Feature
            }
            Refresh-HudFavoritePanelsFromEvent -ForceRebuild $true
            $event.Handled = $true
        }.GetNewClosure())
        [System.Windows.Controls.Grid]::SetRow($unfavoriteButton, 0)
        [System.Windows.Controls.Grid]::SetColumn($unfavoriteButton, 2)
        [void]$grid.Children.Add($unfavoriteButton)

        $favoriteBodyScroll = [System.Windows.Controls.ScrollViewer]::new()
        $favoriteBodyScroll.VerticalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Auto
        $favoriteBodyScroll.HorizontalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Disabled
        $favoriteBodyScroll.CanContentScroll = $false
        $favoriteBodyScroll.Margin = [System.Windows.Thickness]::new(0, 4, 0, 0)
        [System.Windows.Controls.Grid]::SetRow($favoriteBodyScroll, 1)
        [System.Windows.Controls.Grid]::SetRowSpan($favoriteBodyScroll, 3)
        [System.Windows.Controls.Grid]::SetColumnSpan($favoriteBodyScroll, 3)

        $favoriteBody = [System.Windows.Controls.StackPanel]::new()
        $favoriteBodyScroll.Content = $favoriteBody
        [void]$grid.Children.Add($favoriteBodyScroll)

        $titleDragArea = [System.Windows.Controls.Border]::new()
        $titleDragArea.Background = [System.Windows.Media.Brushes]::Transparent
        $titleDragArea.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)
        $titleDragArea.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $border -Event $event }.GetNewClosure())

        $titleText = [System.Windows.Controls.TextBlock]::new()
        $titleText.Text = [string]$entry.Feature.title
        $titleText.FontFamily = $script:HudFavoriteFontFamily
        $titleText.FontSize = $script:HudFavoriteFeatureTitleFontSize
        $titleText.FontWeight = [System.Windows.FontWeights]::SemiBold
        $titleText.Foreground = $script:HudBrushTextStrong
        $titleText.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $titleDragArea.Child = $titleText
        [void]$favoriteBody.Children.Add($titleDragArea)

        $shortcutArea = [System.Windows.Controls.Grid]::new()
        $shortcutArea.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $shortcutArea.RowDefinitions[0].Height = [System.Windows.GridLength]::Auto
        $shortcutArea.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $shortcutArea.RowDefinitions[1].Height = [System.Windows.GridLength]::Auto

        $shortcutLabel = [System.Windows.Controls.TextBlock]::new()
        $shortcutLabel.Text = 'Snippets:'
        $shortcutLabel.FontFamily = $script:HudFavoriteFontFamily
        $shortcutLabel.FontSize = $script:HudFavoriteFilterFontSize
        $shortcutLabel.Foreground = $script:HudBrushTextMuted
        $shortcutLabel.Margin = [System.Windows.Thickness]::new(0, 0, 0, 4)
        [System.Windows.Controls.Grid]::SetRow($shortcutLabel, 0)
        [void]$shortcutArea.Children.Add($shortcutLabel)

        $favoriteSnippetList = [System.Windows.Controls.StackPanel]::new()
        $favoriteSnippetList.Margin = [System.Windows.Thickness]::new(0, 0, 0, 16)
        [System.Windows.Controls.Grid]::SetRow($favoriteSnippetList, 1)
        [void]$shortcutArea.Children.Add($favoriteSnippetList)

        $favoriteSnippets = @(Get-HudFeatureSnippets -Feature $entry.Feature)
        if ($favoriteSnippets.Count -gt 0) {
            Add-HudSnippetRows -Target $favoriteSnippetList -Snippets $favoriteSnippets
        }
        else {
            $shortcutArea.Visibility = [System.Windows.Visibility]::Collapsed
        }
        [void]$favoriteBody.Children.Add($shortcutArea)

        $descriptionGrid = [System.Windows.Controls.Grid]::new()
        $descriptionGrid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $descriptionGrid.RowDefinitions[0].Height = [System.Windows.GridLength]::Auto
        $descriptionGrid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $descriptionGrid.RowDefinitions[1].Height = [System.Windows.GridLength]::Auto

        $descriptionLabel = [System.Windows.Controls.TextBlock]::new()
        $descriptionLabel.Text = 'Description:'
        $descriptionLabel.FontFamily = $script:HudFavoriteFontFamily
        $descriptionLabel.FontSize = $script:HudFavoriteFilterFontSize
        $descriptionLabel.Foreground = $script:HudBrushTextMuted
        $descriptionLabel.Margin = [System.Windows.Thickness]::new(0, 0, 0, 4)
        [System.Windows.Controls.Grid]::SetRow($descriptionLabel, 0)
        [void]$descriptionGrid.Children.Add($descriptionLabel)

        $descriptionTextBox = New-HudReadOnlyTextBox `
            -Text ([string]$entry.Feature.description) `
            -FontFamily $script:HudFavoriteFontFamily `
            -FontSize $script:HudFavoriteDetailFontSize `
            -Foreground $script:HudBrushTextNormal
        [System.Windows.Controls.Grid]::SetRow($descriptionTextBox, 1)
        [void]$descriptionGrid.Children.Add($descriptionTextBox)
        [void]$favoriteBody.Children.Add($descriptionGrid)

        $border.Child = $grid
        $border.Add_MouseMove({ param($sender, $event) Move-HudPanelDrag -Event $event }.GetNewClosure())
        $border.Add_MouseLeftButtonUp({ param($sender, $event) Stop-HudPanelDrag -Event $event }.GetNewClosure())
        [void]$script:HudRoot.Children.Add($border)
        $script:HudFavoritePanels.Add($border)
        [System.Windows.Controls.Panel]::SetZIndex($border, $script:HudFavoritePanels.Count - 1)
        Apply-HudUiStateToPanel -Panel $border
        $index++
    }
    Bring-HudMemoPanelToFront
}

function global:Toggle-HudFavoriteFromDetail {
    if ($script:HudState.Level -ne 'Detail' -or $null -eq $script:HudState.SelectedFeature) {
        return
    }

    $feature = $script:HudState.SelectedFeature
    if ((Test-HudProperty -Target $feature -Name 'favorite') -and [bool]$feature.favorite) {
        Remove-HudProperty -Target $feature -Name 'favorite'
    }
    else {
        Set-HudProperty -Target $feature -Name 'favorite' -Value $true
    }

    Save-HudJsonFromEvent
    Set-FavoriteButtonStateFromEvent -Feature $feature
    Refresh-HudFavoritePanelsFromEvent -ForceRebuild $true
}
