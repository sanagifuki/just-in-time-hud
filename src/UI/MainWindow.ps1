function Show-HudWindow {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$State,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Settings
    )

    $screens = @([System.Windows.Forms.Screen]::AllScreens)
    $displayMonitorIndex = [Math]::Max(0, [int]$Settings.displayMonitorIndex)
    if ($displayMonitorIndex -ge $screens.Count) {
        $displayMonitorIndex = 0
    }
    $screen = $screens[$displayMonitorIndex].Bounds
    $screenDipBounds = Get-HudScreenDipBounds -Bounds $screen
    $visibleLeft = $screenDipBounds.Left
    $visibleTop = $screenDipBounds.Top
    $visibleWidth = $screenDipBounds.Width
    $visibleHeight = $screenDipBounds.Height
    $panelX = [int]$Settings.panelX
    $panelY = [int]$Settings.panelY
    $recentPanelX = [int]$Settings.recentPanelX
    $recentPanelY = [int]$Settings.recentPanelY
    $panelWidth = [int]$Settings.panelWidth
    $panelHeight = [int]$Settings.panelHeight
    $memoPanelX = [int]$Settings.memoPanelX
    $memoPanelY = [int]$Settings.memoPanelY
    $memoPanelWidth = [int]$Settings.memoPanelWidth
    $memoPanelHeight = [int]$Settings.memoPanelHeight
    $panelX = [Math]::Max(0, [Math]::Min($visibleWidth - $panelWidth, $panelX))
    $panelY = [Math]::Max(0, [Math]::Min($visibleHeight - $panelHeight, $panelY))
    $recentPanelX = [Math]::Max(0, [Math]::Min($visibleWidth - $panelWidth, $recentPanelX))
    $recentPanelY = [Math]::Max(0, [Math]::Min($visibleHeight - $panelHeight, $recentPanelY))
    $memoPanelWidth = [Math]::Max(180, [Math]::Min($visibleWidth, $memoPanelWidth))
    $memoPanelHeight = [Math]::Max(100, [Math]::Min($visibleHeight, $memoPanelHeight))
    $memoPanelX = [Math]::Max(0, [Math]::Min($visibleWidth - $memoPanelWidth, $memoPanelX))
    $memoPanelY = [Math]::Max(0, [Math]::Min($visibleHeight - $memoPanelHeight, $memoPanelY))
    $showRecentPanel = [bool]$Settings.showRecentPanel
    $showMemoPanel = [bool]$Settings.showMemoPanel
    $memoPanelVisibility = if ($showMemoPanel) { 'Visible' } else { 'Collapsed' }
    $editorWidth = 920
    $editorHeight = 620
    $editorLeft = $visibleLeft + [Math]::Max(0, [int](($visibleWidth - $editorWidth) / 2))
    $editorTop = $visibleTop + [Math]::Max(0, [int](($visibleHeight - $editorHeight) / 2))
    $fontFamily = [string]$Settings.fontFamily
    $titleFontSize = [double]$Settings.titleFontSize
    $detailTitleFontSize = [double]$Settings.detailTitleFontSize
    $featureTitleFontSize = [double]$Settings.featureTitleFontSize
    $filterFontSize = [double]$Settings.filterFontSize
    $listFontSize = [double]$Settings.listFontSize
    $detailFontSize = [double]$Settings.detailFontSize
    $backgroundColor = ConvertTo-WpfColorCode -Rgba $Settings.backgroundRgba
    $brushConverter = [System.Windows.Media.BrushConverter]::new()
    $script:HudBrushPanelBackground = $brushConverter.ConvertFromString('#F6F8FA')
    $script:HudBrushPanelBorder = $brushConverter.ConvertFromString('#B8C0CC')
    $script:HudBrushSnippetBackground = $brushConverter.ConvertFromString('#E5E7EB')
    $script:HudBrushSnippetCopyBackground = $brushConverter.ConvertFromString('#D1D5DB')
    $script:HudBrushSnippetCopyBackground.Opacity = 0.85
    $script:HudBrushTextStrong = $brushConverter.ConvertFromString('#111827')
    $script:HudBrushTextNormal = $brushConverter.ConvertFromString('#374151')
    $script:HudBrushTextMuted = $brushConverter.ConvertFromString('#6B7280')
    $script:HudBrushTextSubtle = $brushConverter.ConvertFromString('#9CA3AF')
    $script:HudBrushTextPath = $brushConverter.ConvertFromString('#1F2937')
    $script:HudBrushFavoriteStar = $brushConverter.ConvertFromString('#F59E0B')
    $script:HudIsRetreated = $false
    $script:HudPreviousWindowHandle = [HudNativeMethods]::GetForegroundWindow()
    $script:HudCopyResetTimer = $null
    $script:HudRecentCopyResetTimer = $null
    $script:HudRecentFeature = $null
    $script:HudRecentCategoryName = ''
    $script:HudRecentGroupName = ''
    $script:HudRecentHistory = @()
    $script:HudRecentHistoryIndex = 0
    $script:HudRecentHistoryMax = 10
    $script:HudShowRecentPanel = $showRecentPanel
    $script:HudFavoritePanels = [System.Collections.Generic.List[object]]::new()
    $script:HudFavoritePanelPositions = @{}
    $script:HudState = $State
    $script:HudFavoritePanelWidth = $panelWidth
    $script:HudFavoritePanelHeight = $panelHeight
    $script:HudFavoritePanelX = $recentPanelX
    $script:HudFavoritePanelY = $recentPanelY
    $script:HudFavoriteVisibleWidth = $visibleWidth
    $script:HudFavoriteVisibleHeight = $visibleHeight
    $script:HudFavoriteFontFamily = $fontFamily
    $script:HudFavoriteTitleFontSize = $titleFontSize
    $script:HudFavoriteDetailTitleFontSize = $detailTitleFontSize
    $script:HudFavoriteFeatureTitleFontSize = $featureTitleFontSize
    $script:HudFavoriteFilterFontSize = $filterFontSize
    $script:HudFavoriteDetailFontSize = $detailFontSize
    $script:HudSnippetMaxHeight = [Math]::Max(40, [double]$Settings.snippetMaxHeight)
    $script:HudFavoriteButton = $null
    $script:HudEditorWindow = $null
    $script:HudEditorRefreshing = $false
    $script:HudEditorDirty = $false
    $script:HudEditorCloseButtonClosing = $false
    $script:HudDragTarget = $null
    $script:HudDragStartPoint = $null
    $script:HudDragStartMargin = $null

    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$script:AppName"
        WindowStyle="None"
        ResizeMode="NoResize"
        AllowsTransparency="True"
        Background="$backgroundColor"
        Topmost="True"
        ShowInTaskbar="True"
        Left="$visibleLeft"
        Top="$visibleTop"
        Width="$visibleWidth"
        Height="$visibleHeight"
        KeyboardNavigation.TabNavigation="None"
        KeyboardNavigation.ControlTabNavigation="None">
    <Grid Background="$backgroundColor"
          Focusable="True"
          Name="Root"
          KeyboardNavigation.TabNavigation="None"
          KeyboardNavigation.ControlTabNavigation="None">
        <Border Name="Panel"
                Width="$panelWidth"
                Height="$panelHeight"
                HorizontalAlignment="Left"
                VerticalAlignment="Top"
                Margin="$panelX,$panelY,0,0"
                Background="#F6F8FA"
                BorderBrush="#B8C0CC"
                BorderThickness="1"
                Padding="12,12,12,8">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Name="FilterRow" Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <Grid Name="MainHeaderDragArea"
                      Grid.Row="0"
                      Background="Transparent">
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Name="TitleMarkerText"
                                   Text="▮"
                                   FontFamily="$fontFamily"
                                   FontSize="$titleFontSize"
                                   FontWeight="SemiBold"
                                   Margin="0,0,2,0"/>
                        <TextBlock Name="TitleText"
                                   FontFamily="$fontFamily"
                                   FontSize="$titleFontSize"
                                   FontWeight="SemiBold"
                                   Foreground="#1F2937"/>
                    </StackPanel>
                    <StackPanel Orientation="Horizontal"
                                HorizontalAlignment="Right"
                                VerticalAlignment="Top">
                        <TextBlock Name="MainDragHandle"
                                   Text="・・・"
                                   Width="28"
                                   Height="20"
                                   TextAlignment="Center"
                                   Foreground="#9CA3AF"
                                   FontFamily="$fontFamily"
                                   FontSize="$filterFontSize"/>
                        <Button Name="EditItemsButton"
                                Content="Edit"
                                Width="34"
                                Height="20"
                                Padding="0"
                                BorderThickness="0"
                                Background="Transparent"
                                Foreground="#6B7280"
                                FontFamily="$fontFamily"
                                FontSize="$filterFontSize"/>
                        <Button Name="FavoriteButton"
                                Content="☆"
                                Width="24"
                                Height="20"
                                Padding="0"
                                BorderThickness="0"
                                Background="Transparent"
                                Foreground="#6B7280"
                                FontFamily="$fontFamily"
                                FontSize="$titleFontSize"
                                Visibility="Collapsed"/>
                        <Button Name="MinimizeButton"
                                Content="ー"
                                Width="24"
                                Height="20"
                                Padding="0"
                                BorderThickness="0"
                                Background="Transparent"
                                Foreground="#6B7280"
                                FontFamily="$fontFamily"
                                FontSize="$titleFontSize"/>
                        <Button Name="CloseButton"
                                Content="×"
                                Width="24"
                                Height="20"
                                Padding="0"
                                BorderThickness="0"
                                Background="Transparent"
                                Foreground="#6B7280"
                                FontFamily="$fontFamily"
                                FontSize="$titleFontSize"/>
                    </StackPanel>
                </Grid>
                <TextBlock Name="FilterText"
                           Grid.Row="1"
                           FontFamily="$fontFamily"
                           FontSize="$filterFontSize"
                           Foreground="#6B7280"
                           Margin="0,6,0,0"/>
                <TextBlock Name="FeatureTitleText"
                           Grid.Row="2"
                           FontFamily="$fontFamily"
                           FontSize="$featureTitleFontSize"
                           FontWeight="SemiBold"
                           Foreground="#111827"
                           TextWrapping="Wrap"
                           Visibility="Collapsed"
                           Margin="0,4,0,8"/>
                <ListBox Name="CandidateList"
                         Grid.Row="3"
                         FontFamily="$fontFamily"
                         FontSize="$listFontSize"
                         Margin="0,2,0,4"/>
                <TextBlock Name="DetailText"
                           Grid.Row="4"
                           FontFamily="$fontFamily"
                           FontSize="$detailFontSize"
                           TextWrapping="Wrap"
                           Background="#F6F8FA"
                           Foreground="#374151"/>
                <Border Name="DetailPanel"
                        Grid.Row="3"
                        Grid.RowSpan="2"
                        Visibility="Collapsed"
                        Background="#F6F8FA"
                        BorderThickness="0"
                        Padding="0"
                        Margin="0,0,0,0">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <ScrollViewer Grid.Row="0"
                                      Margin="0,0,0,14"
                                      VerticalScrollBarVisibility="Auto"
                                      HorizontalScrollBarVisibility="Disabled"
                                      CanContentScroll="False">
                            <StackPanel>
                            <TextBlock Name="ShortcutLabel"
                                       Text="Snippets:"
                                       FontFamily="$fontFamily"
                                       FontSize="$filterFontSize"
                                       Foreground="#6B7280"
                                       Margin="0,0,0,4"/>
                            <StackPanel Name="SnippetList"
                                        Margin="0,0,0,16"/>
                            <TextBlock
                                       Text="Description:"
                                       FontFamily="$fontFamily"
                                       FontSize="$filterFontSize"
                                       Foreground="#6B7280"
                                       Margin="0,0,0,4"/>
                            <TextBox Name="DescriptionText"
                                     FontFamily="$fontFamily"
                                     FontSize="$detailFontSize"
                                     Foreground="#374151"
                                     Background="Transparent"
                                     BorderThickness="0"
                                     Padding="0"
                                     IsReadOnly="True"
                                     IsReadOnlyCaretVisible="False"
                                     TextWrapping="Wrap"
                                     AcceptsReturn="True"
                                     VerticalScrollBarVisibility="Disabled"
                                     HorizontalScrollBarVisibility="Disabled"/>
                            </StackPanel>
                        </ScrollViewer>
                        <Border Grid.Row="1"
                                BorderBrush="#D1D5DB"
                                BorderThickness="0,1,0,0"
                                Padding="0,5,0,0">
                            <TextBlock Name="DetailHelpText"
                                       FontFamily="$fontFamily"
                                       FontSize="$filterFontSize"
                                       Foreground="#374151"
                                       Text="Space: 退避    Esc: 機能リストへ戻る"/>
                        </Border>
                    </Grid>
                </Border>
            </Grid>
        </Border>
        <Border Name="RecentPanel"
                Width="$panelWidth"
                Height="$panelHeight"
                HorizontalAlignment="Left"
                VerticalAlignment="Top"
                Margin="$recentPanelX,$recentPanelY,0,0"
                Background="#F6F8FA"
                BorderBrush="#B8C0CC"
                BorderThickness="1"
                Padding="12,12,12,8"
                Visibility="Visible">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <TextBlock Name="RecentPathText"
                           Grid.Row="0"
                           FontFamily="$fontFamily"
                           FontSize="$detailTitleFontSize"
                           FontWeight="SemiBold"
                           Foreground="#1F2937"/>
                <TextBlock Name="RecentDragHandle"
                           Grid.Row="0"
                           Text="・・・"
                           Width="28"
                           Height="20"
                           TextAlignment="Center"
                           Foreground="#9CA3AF"
                           FontFamily="$fontFamily"
                           FontSize="$filterFontSize"
                           HorizontalAlignment="Right"
                           Margin="0,0,26,0"/>
                <Button Name="RecentCloseButton"
                        Grid.Row="0"
                        Content="×"
                        Width="24"
                        Height="20"
                        Padding="0"
                        BorderThickness="0"
                        Background="Transparent"
                        Foreground="#6B7280"
                        FontFamily="$fontFamily"
                        FontSize="$titleFontSize"
                        HorizontalAlignment="Right"
                        VerticalAlignment="Top"/>
                <ScrollViewer Grid.Row="1"
                              Margin="0,4,0,0"
                              VerticalScrollBarVisibility="Auto"
                              HorizontalScrollBarVisibility="Disabled"
                              CanContentScroll="False">
                    <StackPanel>
                        <Border Name="RecentFeatureTitleDragArea"
                                Background="Transparent"
                                Margin="0,0,0,8">
                            <TextBlock Name="RecentFeatureTitleText"
                                       FontFamily="$fontFamily"
                                       FontSize="$featureTitleFontSize"
                                       FontWeight="SemiBold"
                                       Foreground="#111827"
                                       TextWrapping="Wrap"/>
                        </Border>
                        <Grid Name="RecentShortcutArea">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <TextBlock Grid.Row="0"
                                       Text="Snippets:"
                                       FontFamily="$fontFamily"
                                       FontSize="$filterFontSize"
                                       Foreground="#6B7280"
                                       Margin="0,0,0,4"/>
                            <StackPanel Name="RecentSnippetList"
                                        Grid.Row="1"
                                        Margin="0,0,0,12"/>
                        </Grid>
                        <StackPanel>
                            <TextBlock Text="Description:"
                                       FontFamily="$fontFamily"
                                       FontSize="$filterFontSize"
                                       Foreground="#6B7280"
                                       Margin="0,0,0,4"/>
                            <TextBox Name="RecentDescriptionText"
                                     FontFamily="$fontFamily"
                                     FontSize="$detailFontSize"
                                     Foreground="#374151"
                                     Background="Transparent"
                                     BorderThickness="0"
                                     Padding="0"
                                     IsReadOnly="True"
                                     IsReadOnlyCaretVisible="False"
                                     TextWrapping="Wrap"
                                     AcceptsReturn="True"
                                     VerticalScrollBarVisibility="Disabled"
                                     HorizontalScrollBarVisibility="Disabled"/>
                        </StackPanel>
                    </StackPanel>
                </ScrollViewer>
                <StackPanel Grid.Row="2"
                            Orientation="Horizontal"
                            HorizontalAlignment="Right"
                            Margin="0,6,0,1">
                    <Button Name="RecentPrevButton"
                            Content="＜"
                            Width="24"
                            Height="20"
                            Padding="0"
                            BorderThickness="0"
                            Background="Transparent"
                            Foreground="#6B7280"
                            FontFamily="$fontFamily"
                            FontSize="$filterFontSize"/>
                    <TextBlock Name="RecentHistoryText"
                               Text="0/0"
                               Width="42"
                               TextAlignment="Center"
                               FontFamily="$fontFamily"
                               FontSize="$filterFontSize"
                               Foreground="#6B7280"
                               VerticalAlignment="Center"/>
                    <Button Name="RecentNextButton"
                            Content="＞"
                            Width="24"
                            Height="20"
                            Padding="0"
                            BorderThickness="0"
                            Background="Transparent"
                            Foreground="#6B7280"
                            FontFamily="$fontFamily"
                            FontSize="$filterFontSize"/>
                </StackPanel>
            </Grid>
        </Border>
        <Border Name="MemoPanel"
                Width="$memoPanelWidth"
                Height="$memoPanelHeight"
                HorizontalAlignment="Left"
                VerticalAlignment="Top"
                Margin="$memoPanelX,$memoPanelY,0,0"
                Background="#F6F8FA"
                BorderBrush="#B8C0CC"
                BorderThickness="1"
                Padding="12,10,12,10"
                Visibility="$memoPanelVisibility">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <Grid Name="MemoHeaderDragArea"
                      Grid.Row="0"
                      Background="Transparent"
                      Margin="0,0,0,3">
                    <TextBlock Text="Memo"
                               FontFamily="$fontFamily"
                               FontSize="$titleFontSize"
                               FontWeight="SemiBold"
                               Foreground="#1F2937"/>
                    <TextBlock Name="MemoDragHandle"
                               Text="・・・"
                               Width="28"
                               Height="20"
                               TextAlignment="Center"
                               Foreground="#9CA3AF"
                               FontFamily="$fontFamily"
                               FontSize="$filterFontSize"
                               HorizontalAlignment="Right"/>
                </Grid>
                <TextBox Name="MemoTextBox"
                         Grid.Row="1"
                         FontFamily="$fontFamily"
                         FontSize="$detailFontSize"
                         Foreground="#374151"
                         Background="#F6F8FA"
                         BorderBrush="#ABADB3"
                         BorderThickness="1"
                         Padding="6"
                         AcceptsReturn="True"
                         AcceptsTab="True"
                         TextWrapping="Wrap"
                         VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Disabled"/>
                <Border Grid.Row="2"
                        Padding="0,5,0,0">
                    <TextBlock FontFamily="$fontFamily"
                               FontSize="$filterFontSize"
                               Foreground="#374151"
                               Text="Shift+Tab: 入力開始 / 終了    Esc: 入力終了"/>
                </Border>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

    $reader = [System.Xml.XmlNodeReader]::new($xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    if (Test-Path -LiteralPath $script:DefaultHudIconPath) {
        $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create([System.Uri]::new($script:DefaultHudIconPath))
    }
    $root = $window.FindName('Root')
    $script:HudRoot = $root
    $panel = $window.FindName('Panel')
    $mainHeaderDragArea = $window.FindName('MainHeaderDragArea')
    $titleMarker = $window.FindName('TitleMarkerText')
    $title = $window.FindName('TitleText')
    $mainDragHandle = $window.FindName('MainDragHandle')
    $minimizeButton = $window.FindName('MinimizeButton')
    $editItemsButton = $window.FindName('EditItemsButton')
    $favoriteButton = $window.FindName('FavoriteButton')
    $script:HudFavoriteButton = $favoriteButton
    $closeButton = $window.FindName('CloseButton')
    $filter = $window.FindName('FilterText')
    $filterRow = $window.FindName('FilterRow')
    $featureTitle = $window.FindName('FeatureTitleText')
    $list = $window.FindName('CandidateList')
    $detail = $window.FindName('DetailText')
    $detailPanel = $window.FindName('DetailPanel')
    $shortcutLabel = $window.FindName('ShortcutLabel')
    $snippetList = $window.FindName('SnippetList')
    $descriptionText = $window.FindName('DescriptionText')
    $recentPanel = $window.FindName('RecentPanel')
    $recentPathText = $window.FindName('RecentPathText')
    $recentDragHandle = $window.FindName('RecentDragHandle')
    $recentFeatureTitleDragArea = $window.FindName('RecentFeatureTitleDragArea')
    $recentFeatureTitleText = $window.FindName('RecentFeatureTitleText')
    $recentShortcutArea = $window.FindName('RecentShortcutArea')
    $recentSnippetList = $window.FindName('RecentSnippetList')
    $recentDescriptionText = $window.FindName('RecentDescriptionText')
    $recentCloseButton = $window.FindName('RecentCloseButton')
    $recentPrevButton = $window.FindName('RecentPrevButton')
    $recentHistoryText = $window.FindName('RecentHistoryText')
    $recentNextButton = $window.FindName('RecentNextButton')
    $memoPanel = $window.FindName('MemoPanel')
    $memoHeaderDragArea = $window.FindName('MemoHeaderDragArea')
    $memoDragHandle = $window.FindName('MemoDragHandle')
    $memoTextBox = $window.FindName('MemoTextBox')
    $script:HudMemoPanel = $memoPanel
    $script:HudMemoTextBox = $memoTextBox
    Add-HudMemoPanelContextMenu
    $script:HudRecentPanel = $recentPanel
    $script:HudRecentPathText = $recentPathText
    $script:HudRecentFeatureTitleText = $recentFeatureTitleText
    $script:HudRecentShortcutArea = $recentShortcutArea
    $script:HudRecentSnippetList = $recentSnippetList
    $script:HudRecentDescriptionText = $recentDescriptionText
    $script:HudRecentPrevButton = $recentPrevButton
    $script:HudRecentHistoryText = $recentHistoryText
    $script:HudRecentNextButton = $recentNextButton
    Add-HudRecentPanelContextMenu

    function Set-EditorStatus {
        param([string]$Text)
        $editorStatusText.Text = $Text
    }

    function Set-EditorLabelText {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Controls.TextBlock]$Label,
            [Parameter(Mandatory = $true)]
            [string]$Text,
            [Parameter(Mandatory = $true)]
            [bool]$Dirty
        )

        $Label.Text = if ($Dirty) { "$Text *" } else { $Text }
    }

    function Clear-EditorDirtyMarkers {
        if ($null -eq $editorCategoryLabel) { return }
        $editorCategoryDirtyMark.Visibility = [System.Windows.Visibility]::Collapsed
        $editorGroupDirtyMark.Visibility = [System.Windows.Visibility]::Collapsed
        Set-EditorLabelText -Label $editorTitleLabel -Text 'Title:' -Dirty $false
        Set-EditorLabelText -Label $editorShortcutLabel -Text 'Snippets:' -Dirty $false
        Set-EditorLabelText -Label $editorDescriptionLabel -Text 'Description:' -Dirty $false
    }

    function Set-EditorDirtyMark {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Controls.TextBlock]$Mark,
            [Parameter(Mandatory = $true)]
            [bool]$Dirty
        )

        $Mark.Visibility = if ($Dirty) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    }

    function Set-EditorDirty {
        param([bool]$Dirty)
        $script:HudEditorDirty = $Dirty
        if (-not $Dirty) {
            Clear-EditorDirtyMarkers
        }
        if ($null -ne $editorStatusText) {
            Set-EditorStatus "Editing: $script:DefaultHudDataPath"
        }
    }

    function Save-EditorItems {
        Save-HudJson -Path $script:DefaultHudDataPath -Items @($State.Items)
        Set-EditorDirty $false
        Set-EditorStatus "Saved: $script:DefaultHudDataPath"
    }

    function Set-EditorChangedStatus {
        param([Parameter(Mandatory = $true)][string]$Text)

        Set-EditorDirty $true
        Set-EditorStatus $Text
    }

    function Get-EditorSelectedCategory {
        return $editorCategoryList.SelectedItem
    }

    function Get-EditorSelectedGroup {
        return $editorGroupList.SelectedItem
    }

    function Get-EditorSelectedFeature {
        return $editorFeatureList.SelectedItem
    }

    function Refresh-EditorFeatureFields {
        $feature = Get-EditorSelectedFeature
        $script:HudEditorRefreshing = $true
        if ($null -eq $feature) {
            $editorTitleBox.Text = ''
            $editorShortcutBox.Text = ''
            $editorCopyableBox.IsChecked = $false
            $editorFavoriteBox.IsChecked = $false
            $editorDescriptionBox.Text = ''
            $script:HudEditorRefreshing = $false
            Clear-EditorDirtyMarkers
            return
        }

        $editorTitleBox.Text = [string]$feature.title
        $snippets = @(Get-HudFeatureSnippets -Feature $feature)
        $editorShortcutBox.Text = Join-HudSnippetTextsForEditor -Snippets $snippets
        $editorCopyableBox.IsChecked = (Test-HudProperty -Target $feature -Name 'copyable') -and [bool]$feature.copyable
        $editorFavoriteBox.IsChecked = (Test-HudProperty -Target $feature -Name 'favorite') -and [bool]$feature.favorite
        $editorDescriptionBox.Text = [string]$feature.description
        $script:HudEditorRefreshing = $false
        Clear-EditorDirtyMarkers
    }

    function Refresh-EditorFeatureList {
        $selected = Get-EditorSelectedFeature
        $script:HudEditorRefreshing = $true
        $group = Get-EditorSelectedGroup
        $features = if ($null -ne $group) { @($group.features) } else { @() }
        Set-HudListBoxItems -ListBox $editorFeatureList -Items $features -Selected $selected
        $script:HudEditorRefreshing = $false
        Refresh-EditorFeatureFields
    }

    function Refresh-EditorGroupList {
        $selected = Get-EditorSelectedGroup
        $script:HudEditorRefreshing = $true
        $category = Get-EditorSelectedCategory
        $editorCategoryNameBox.Text = if ($null -ne $category) { [string]$category.name } else { '' }
        $groups = if ($null -ne $category) { @($category.groups) } else { @() }
        Set-HudListBoxItems -ListBox $editorGroupList -Items $groups -Selected $selected
        $group = Get-EditorSelectedGroup
        $editorGroupNameBox.Text = if ($null -ne $group) { [string]$group.name } else { '' }
        $script:HudEditorRefreshing = $false
        Refresh-EditorFeatureList
    }

    function Refresh-EditorCategoryList {
        $selected = Get-EditorSelectedCategory
        $script:HudEditorRefreshing = $true
        Set-HudListBoxItems -ListBox $editorCategoryList -Items @($State.Items) -Selected $selected
        $script:HudEditorRefreshing = $false
        Refresh-EditorGroupList
    }

    function Apply-EditorCategoryName {
        $category = Get-EditorSelectedCategory
        if ($null -eq $category) { return }
        Set-HudProperty -Target $category -Name 'name' -Value $editorCategoryNameBox.Text
        $editorCategoryList.Items.Refresh()
        Set-EditorDirty $true
        Set-EditorDirtyMark -Mark $editorCategoryDirtyMark -Dirty $false
    }

    function Apply-EditorGroupName {
        $group = Get-EditorSelectedGroup
        if ($null -eq $group) { return }
        Set-HudProperty -Target $group -Name 'name' -Value $editorGroupNameBox.Text
        $editorGroupList.Items.Refresh()
        Set-EditorDirty $true
        Set-EditorDirtyMark -Mark $editorGroupDirtyMark -Dirty $false
        Refresh-HudView
    }

    function Apply-EditorFeatureFields {
        param([string[]]$DirtyFields = @('Title', 'Shortcut', 'Description'))

        $feature = Get-EditorSelectedFeature
        if ($null -eq $feature) { return }
        Set-HudProperty -Target $feature -Name 'title' -Value $editorTitleBox.Text
        Set-HudProperty -Target $feature -Name 'description' -Value $editorDescriptionBox.Text

        Set-HudFeatureSnippetsFromText -Feature $feature -Text $editorShortcutBox.Text -Copyable ([bool]$editorCopyableBox.IsChecked)
        if ([bool]$editorFavoriteBox.IsChecked) {
            Set-HudProperty -Target $feature -Name 'favorite' -Value $true
        }
        else { Remove-HudProperty -Target $feature -Name 'favorite' }
        if ($DirtyFields -contains 'Title') {
            Set-EditorLabelText -Label $editorTitleLabel -Text 'Title:' -Dirty $false
        }
        if ($DirtyFields -contains 'Shortcut') {
            Set-EditorLabelText -Label $editorShortcutLabel -Text 'Snippets:' -Dirty $false
        }
        if ($DirtyFields -contains 'Description') {
            Set-EditorLabelText -Label $editorDescriptionLabel -Text 'Description:' -Dirty $false
        }
        if ($null -ne $editorFeatureList.SelectedItem) {
            $editorFeatureList.Items.Refresh()
        }
        Set-EditorDirty $true
    }

    function Save-EditorCurrentFields {
        $category = Get-EditorSelectedCategory
        if ($null -ne $category) {
            Set-HudProperty -Target $category -Name 'name' -Value $editorCategoryNameBox.Text
        }

        $group = Get-EditorSelectedGroup
        if ($null -ne $group) {
            Set-HudProperty -Target $group -Name 'name' -Value $editorGroupNameBox.Text
        }

        $feature = Get-EditorSelectedFeature
        if ($null -eq $feature) {
            return
        }

        Set-HudProperty -Target $feature -Name 'title' -Value $editorTitleBox.Text
        Set-HudProperty -Target $feature -Name 'description' -Value $editorDescriptionBox.Text

        Set-HudFeatureSnippetsFromText -Feature $feature -Text $editorShortcutBox.Text -Copyable ([bool]$editorCopyableBox.IsChecked)
        if ([bool]$editorFavoriteBox.IsChecked) {
            Set-HudProperty -Target $feature -Name 'favorite' -Value $true
        }
        else { Remove-HudProperty -Target $feature -Name 'favorite' }
    }

    function Register-EditorEvents {
        $editorCategoryList.Add_SelectionChanged({
            if ($script:HudEditorRefreshing) { return }
            Refresh-EditorGroupList
        })
        $editorGroupList.Add_SelectionChanged({
            if ($script:HudEditorRefreshing) { return }
            $group = Get-EditorSelectedGroup
            $editorGroupNameBox.Text = if ($null -ne $group) { [string]$group.name } else { '' }
            Refresh-EditorFeatureList
        })
        $editorFeatureList.Add_SelectionChanged({
            if ($script:HudEditorRefreshing) { return }
            Refresh-EditorFeatureFields
        })
        $editorCategoryNameBox.Add_LostFocus({ Apply-EditorCategoryName })
        $editorGroupNameBox.Add_LostFocus({ Apply-EditorGroupName })
        $editorTitleBox.Add_LostFocus({ Apply-EditorFeatureFields -DirtyFields @('Title') })
        $editorShortcutBox.Add_LostFocus({ Apply-EditorFeatureFields -DirtyFields @('Shortcut') })
        $editorDescriptionBox.Add_LostFocus({ Apply-EditorFeatureFields -DirtyFields @('Description') })
        $editorCopyableBox.Add_Click({
            Apply-EditorFeatureFields -DirtyFields @('Shortcut')
            Save-EditorItems
            Refresh-HudFavoritePanelsFromEvent
        })
        $editorFavoriteBox.Add_Click({
            Apply-EditorFeatureFields -DirtyFields @()
            Save-EditorItems
            Refresh-HudFavoritePanelsFromEvent
        })
        $editorCategoryNameBox.Add_TextChanged({
            if (-not $script:HudEditorRefreshing) {
                Set-EditorDirtyMark -Mark $editorCategoryDirtyMark -Dirty $true
            }
        })
        $editorGroupNameBox.Add_TextChanged({
            if (-not $script:HudEditorRefreshing) {
                Set-EditorDirtyMark -Mark $editorGroupDirtyMark -Dirty $true
            }
        })
        $editorTitleBox.Add_TextChanged({
            if (-not $script:HudEditorRefreshing) {
                Set-EditorLabelText -Label $editorTitleLabel -Text 'Title:' -Dirty $true
            }
        })
        $editorShortcutBox.Add_TextChanged({
            if (-not $script:HudEditorRefreshing) {
                Set-EditorLabelText -Label $editorShortcutLabel -Text 'Snippets:' -Dirty $true
            }
        })
        $editorDescriptionBox.Add_TextChanged({
            if (-not $script:HudEditorRefreshing) {
                Set-EditorLabelText -Label $editorDescriptionLabel -Text 'Description:' -Dirty $true
            }
        })
        $editorCategoryNameBox.Add_KeyDown({
            param($sender, $event)
            if ($event.Key -eq [System.Windows.Input.Key]::Enter) {
                Apply-EditorCategoryName
                $event.Handled = $true
            }
        })
        $editorGroupNameBox.Add_KeyDown({
            param($sender, $event)
            if ($event.Key -eq [System.Windows.Input.Key]::Enter) {
                Apply-EditorGroupName
                $event.Handled = $true
            }
        })
        $editorAddCategoryButton.Add_Click({
            $newCategory = [pscustomobject]@{
                name = 'NewCategory'
                groups = @(New-EditorDefaultGroup)
            }
            $State.Items = @($State.Items) + $newCategory
            Refresh-EditorCategoryList
            $editorCategoryList.SelectedIndex = $editorCategoryList.Items.Count - 1
            Set-EditorChangedStatus 'Added category.'
        })
        $editorDeleteCategoryButton.Add_Click({
            if ($editorCategoryList.SelectedIndex -lt 0) { return }
            $category = Get-EditorSelectedCategory
            $State.Items = Remove-HudArrayItem -Items @($State.Items) -RemoveItem $category
            Refresh-EditorCategoryList
            Set-EditorChangedStatus 'Deleted category.'
        })
        $editorAddGroupButton.Add_Click({
            $category = Get-EditorSelectedCategory
            if ($null -eq $category) { return }
            $newGroup = New-EditorDefaultGroup
            Set-HudProperty -Target $category -Name 'groups' -Value (@($category.groups) + $newGroup)
            Refresh-EditorGroupList
            $editorGroupList.SelectedIndex = $editorGroupList.Items.Count - 1
            Set-EditorChangedStatus 'Added group.'
        })
        $editorDeleteGroupButton.Add_Click({
            $category = Get-EditorSelectedCategory
            $group = Get-EditorSelectedGroup
            if ($null -eq $category -or $null -eq $group) { return }
            Set-HudProperty -Target $category -Name 'groups' -Value (Remove-HudArrayItem -Items @($category.groups) -RemoveItem $group)
            Refresh-EditorGroupList
            Set-EditorChangedStatus 'Deleted group.'
        })
        $editorAddFeatureButton.Add_Click({
            $group = Get-EditorSelectedGroup
            if ($null -eq $group) { return }
            $newFeature = New-EditorDefaultFeature
            Set-HudProperty -Target $group -Name 'features' -Value (@($group.features) + $newFeature)
            Refresh-EditorFeatureList
            $editorFeatureList.SelectedIndex = $editorFeatureList.Items.Count - 1
            Set-EditorChangedStatus 'Added feature.'
        })
        $editorDeleteFeatureButton.Add_Click({
            $group = Get-EditorSelectedGroup
            $feature = Get-EditorSelectedFeature
            if ($null -eq $group -or $null -eq $feature) { return }
            Set-HudProperty -Target $group -Name 'features' -Value (Remove-HudArrayItem -Items @($group.features) -RemoveItem $feature)
            Refresh-EditorFeatureList
            Set-EditorChangedStatus 'Deleted feature.'
        })
        $editorSaveButton.Add_Click({
            Save-EditorJson
        })
        $editorCloseButton.Add_Click({ Close-EditorPanel })
    }

    function Save-EditorJson {
        Save-EditorCurrentFields
        Save-EditorItems
    }

    function Ensure-EditorWindow {
        if ($null -ne $script:HudEditorWindow) {
            return
        }

        $script:HudEditorWindow = New-HudEditorWindow -Left $editorLeft -Top $editorTop -FontFamily $fontFamily
        Use-EditorWindowControls -EditorWindow $script:HudEditorWindow
        Register-EditorEvents
        $script:HudEditorWindow.Add_Closed({
            $script:HudEditorCloseButtonClosing = $false
            $script:HudEditorWindow = $null
        })
    }

    function Set-HudWindowMode {
        $window.Background = $backgroundColor
        $root.Background = $backgroundColor
        $window.Left = $visibleLeft
        $window.Top = $visibleTop
        $window.Width = $visibleWidth
        $window.Height = $visibleHeight
    }

    function Show-EditorPanel {
        if ($null -ne $script:HudEditorWindow) {
            if ($script:HudEditorWindow.IsVisible) {
                $script:HudEditorWindow.Activate() | Out-Null
                return
            }
        }

        Hide-HudSession
        Ensure-EditorWindow
        Refresh-EditorCategoryList
        Set-EditorStatus "Editing: $script:DefaultHudDataPath"
        $script:HudEditorWindow.Show()
        $script:HudEditorWindow.Activate() | Out-Null
    }

    function Close-EditorPanel {
        if ($null -ne $script:HudEditorWindow) {
            Save-EditorJson
            $script:HudEditorCloseButtonClosing = $true
            $script:HudEditorWindow.Close()
            Show-HudSession
        }
    }

    function Refresh-HudView {
        $screenTitle = switch ($State.Level) {
            'Root' { '<親分類>' }
            'Group' { "$($State.SelectedCategory.name) / <中分類>" }
            'Feature' { "$($State.SelectedCategory.name) / $($State.SelectedGroup.name) / <機能>" }
            'Detail' { "$($State.SelectedCategory.name) / $($State.SelectedGroup.name) /" }
        }
        $titleMarker.Foreground = switch ($State.Level) {
            'Root' { '#DC2626' }
            'Group' { '#2563EB' }
            default { '#16A34A' }
        }
        $title.Text = $screenTitle
        if ($State.Level -eq 'Detail') {
            $filter.Text = ''
            $filterRow.Height = [System.Windows.GridLength]::new(0)
            $title.FontSize = $detailTitleFontSize
            $featureTitle.Visibility = [System.Windows.Visibility]::Visible
            $featureTitle.Text = $State.SelectedFeature.title
            Set-FavoriteButtonStateFromEvent -Feature $State.SelectedFeature
        }
        else {
            $filter.Text = "Text: $($State.TextFilter)"
            $filterRow.Height = [System.Windows.GridLength]::Auto
            $title.FontSize = $titleFontSize
            $featureTitle.Visibility = [System.Windows.Visibility]::Collapsed
            $featureTitle.Text = ''
            Set-FavoriteButtonStateFromEvent -Feature $null
        }
        $list.Items.Clear()

        if ($State.Level -eq 'Detail') {
            $list.Visibility = [System.Windows.Visibility]::Collapsed
            $detail.Visibility = [System.Windows.Visibility]::Collapsed
            $detailPanel.Visibility = [System.Windows.Visibility]::Visible
            $feature = $State.SelectedFeature
            $snippets = @(Get-HudFeatureSnippets -Feature $feature)
            if ($snippets.Count -gt 0) {
                Add-HudSnippetRows -Target $snippetList -Snippets $snippets
                $shortcutLabel.Visibility = [System.Windows.Visibility]::Visible
                $snippetList.Visibility = [System.Windows.Visibility]::Visible
            }
            else {
                $snippetList.Children.Clear()
                $shortcutLabel.Visibility = [System.Windows.Visibility]::Collapsed
                $snippetList.Visibility = [System.Windows.Visibility]::Collapsed
            }
            $descriptionText.Text = $feature.description
            Set-RecentDetail -Feature $feature
        }
        else {
            $list.Visibility = [System.Windows.Visibility]::Visible
            $detail.Visibility = [System.Windows.Visibility]::Visible
            $detailPanel.Visibility = [System.Windows.Visibility]::Collapsed
            $candidates = Get-HudCandidates -State $State
            foreach ($candidate in $candidates) {
                [void]$list.Items.Add($candidate.Label)
            }
            if ($list.Items.Count -gt 0) {
                $list.SelectedIndex = 0
            }

            if ($State.Level -eq 'Feature') {
                $detail.Text = "キー入力で絞り込み。候補が1件になると自動で詳細画面へ進む。`r`nEsc: 戻る, 左クリック: 上, 右クリック: 下, 1/2/3: 上から選択, Tab: 選択中に遷移"
            }
            else {
                $detail.Text = "先頭文字のキー入力で絞り込み。候補が1件になると自動で次へ進む。`r`nEsc: 戻る, 左クリック: 上, 右クリック: 下, 1/2/3: 上から選択, Tab: 選択中に遷移"
            }
        }
    }

    function Reset-HudSessionToRoot {
        $State.Level = 'Root'
        $State.SelectedCategory = $null
        $State.SelectedGroup = $null
        $State.SelectedFeature = $null
        Reset-HudFilter -State $State
        Refresh-HudView
    }

    function Hide-HudSession {
        $script:HudIsRetreated = $true
        [System.Windows.Input.Keyboard]::ClearFocus()
        Reset-HudSessionToRoot
        $window.Left = -32000
        $window.Top = -32000
        $window.Width = 1
        $window.Height = 1
        Refresh-HudFavoritePanelsFromEvent
        if ($script:HudPreviousWindowHandle -ne [IntPtr]::Zero) {
            [HudNativeMethods]::SetForegroundWindow($script:HudPreviousWindowHandle) | Out-Null
        }
    }

    function Focus-HudRootForInput {
        if ($null -ne $script:HudEditorWindow -and $script:HudEditorWindow.IsVisible) {
            return
        }
        if ($memoTextBox.IsKeyboardFocusWithin) {
            return
        }

        [void]$window.Dispatcher.BeginInvoke(
            [Action]{
                if (
                    -not $script:HudIsRetreated -and
                    -not $memoTextBox.IsKeyboardFocusWithin
                ) {
                    $root.Focus() | Out-Null
                    [System.Windows.Input.Keyboard]::Focus($root) | Out-Null
                }
            },
            [System.Windows.Threading.DispatcherPriority]::Input
        )
    }

    function Show-HudSession {
        if ($null -ne $script:HudEditorWindow -and $script:HudEditorWindow.IsVisible) {
            $script:HudEditorWindow.Activate() | Out-Null
            return
        }

        if (-not $script:HudIsRetreated) {
            return
        }
        $script:HudIsRetreated = $false
        Set-HudWindowMode
        Refresh-HudView
        Show-RecentDetailIfAvailable
        Refresh-HudFavoritePanelsFromEvent
        $window.Activate() | Out-Null
        Focus-HudRootForInput
    }

    function Move-ToCandidate {
        param(
            [Parameter(Mandatory = $true)]
            [object]$Selected
        )

        switch ($State.Level) {
            'Root' {
                $State.SelectedCategory = $Selected
                $State.Level = 'Group'
                Reset-HudFilter -State $State
            }
            'Group' {
                $State.SelectedGroup = $Selected
                $State.Level = 'Feature'
                Reset-HudFilter -State $State
            }
            'Feature' {
                $State.SelectedFeature = $Selected
                $State.Level = 'Detail'
                Reset-HudFilter -State $State
            }
            'Detail' {
                Hide-HudSession
            }
        }
    }

    function Move-ToPreviousLevel {
        switch ($State.Level) {
            'Root' {
                Hide-HudSession
                return
            }
            'Group' {
                $State.Level = 'Root'
                $State.SelectedCategory = $null
            }
            'Feature' {
                $State.Level = 'Group'
                $State.SelectedGroup = $null
            }
            'Detail' {
                $State.Level = 'Feature'
                $State.SelectedFeature = $null
            }
        }
        Reset-HudFilter -State $State
    }

    function Select-CurrentCandidate {
        $candidates = Get-HudCandidates -State $State
        if ($candidates.Count -eq 0) {
            return
        }

        $index = [Math]::Max(0, $list.SelectedIndex)
        Move-ToCandidate -Selected $candidates[$index].Value
        Refresh-HudView
    }

    function Move-HudListSelection {
        param(
            [Parameter(Mandatory = $true)]
            [int]$Delta
        )

        if ($State.Level -notin 'Root', 'Group', 'Feature') {
            return
        }
        if ($list.Items.Count -eq 0) {
            return
        }

        $nextIndex = $list.SelectedIndex + $Delta
        if ($nextIndex -lt 0) {
            $nextIndex = $list.Items.Count - 1
        }
        elseif ($nextIndex -ge $list.Items.Count) {
            $nextIndex = 0
        }

        $list.SelectedIndex = $nextIndex
        $list.ScrollIntoView($list.SelectedItem)
    }

    function Invoke-AutoAdvanceIfSingle {
        if ($State.Level -eq 'Detail') {
            return
        }

        while ($State.Level -ne 'Detail') {
            $candidates = Get-HudCandidates -State $State
            if ($candidates.Count -ne 1) {
                return
            }
            Move-ToCandidate -Selected $candidates[0].Value
        }
    }

    function Handle-HudMouseButton {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.MouseButton]$Button,

            [Parameter(Mandatory = $true)]
            [System.Windows.Input.MouseButtonEventArgs]$Event
        )

        if ($null -ne $script:HudEditorWindow -and $script:HudEditorWindow.IsVisible) {
            return
        }

        $source = $Event.OriginalSource
        if (
            $memoTextBox.IsKeyboardFocusWithin -and
            -not (Test-HudMemoSource -Source $source)
        ) {
            Move-HudMemoFocusToRoot
        }

        $dragBandTarget = $null
        while ($null -ne $source) {
            if ($source -is [System.Windows.Controls.Button] -or $source -is [System.Windows.Controls.TextBox]) {
                return
            }
            if ($script:HudFavoritePanels -contains $source) {
                $dragBandTarget = $source
                break
            }
            if ($source -eq $recentPanel) {
                $dragBandTarget = $recentPanel
                break
            }
            if ($source -eq $memoPanel) {
                $dragBandTarget = $memoPanel
                break
            }
            if ($source -is [System.Windows.FrameworkElement] -and $source.Name -in @('MainHeaderDragArea', 'TitleMarkerText', 'TitleText', 'MainDragHandle', 'RecentPathText', 'RecentFeatureTitleDragArea', 'RecentFeatureTitleText', 'RecentDragHandle', 'MemoHeaderDragArea', 'MemoDragHandle')) {
                return
            }
            $source = [System.Windows.Media.VisualTreeHelper]::GetParent($source)
        }

        if ($null -eq $dragBandTarget) {
            $dragBandTarget = $panel
        }

        $panelPoint = $Event.GetPosition($dragBandTarget)
        if (
            $Button -eq [System.Windows.Input.MouseButton]::Left -and
            $panelPoint.X -ge 0 -and
            $panelPoint.X -le $dragBandTarget.ActualWidth -and
            $panelPoint.Y -ge 0 -and
            $panelPoint.Y -le 36
        ) {
            Start-HudPanelDrag -Target $dragBandTarget -Event $Event
            return
        }

        if ($dragBandTarget -ne $panel) {
            return
        }

        if ($Button -eq [System.Windows.Input.MouseButton]::Left) {
            Move-HudListSelection -Delta -1
        }
        elseif ($Button -eq [System.Windows.Input.MouseButton]::Right) {
            Move-HudListSelection -Delta 1
        }
        else {
            return
        }
        $Event.Handled = $true
    }

    function Select-HudCandidateByNumber {
        param(
            [Parameter(Mandatory = $true)]
            [int]$Number
        )

        if ($State.Level -eq 'Detail') {
            return
        }

        $candidates = Get-HudCandidates -State $State
        $index = $Number - 1
        if ($index -lt 0 -or $index -ge $candidates.Count) {
            return
        }

        Move-ToCandidate -Selected $candidates[$index].Value
        Refresh-HudView
    }

    function Back-HudLevel {
        if ($State.TextFilter) {
            Reset-HudFilter -State $State
        }
        else {
            Move-ToPreviousLevel
            if ($script:HudIsRetreated) {
                return
            }
        }
        Refresh-HudView
    }

    function Append-HudTextFilter {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Text
        )

        if ($State.Level -eq 'Detail') {
            return
        }
        $State.TextFilter += $Text
        Invoke-AutoAdvanceIfSingle
        Refresh-HudView
    }

    function Remove-HudFilterLastChar {
        if ($State.TextFilter.Length -gt 0) {
            $State.TextFilter = $State.TextFilter.Substring(0, $State.TextFilter.Length - 1)
        }
        else {
            return
        }
        Refresh-HudView
    }

    function Handle-HudKeyDown {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.KeyEventArgs]$Event
        )

        if ($null -ne $script:HudEditorWindow -and $script:HudEditorWindow.IsVisible) {
            return
        }

        $key = if ($Event.Key -eq [System.Windows.Input.Key]::System) { $Event.SystemKey } else { $Event.Key }
        $isShiftTab = (
            $key -eq [System.Windows.Input.Key]::Tab -and
            ([System.Windows.Input.Keyboard]::Modifiers -band [System.Windows.Input.ModifierKeys]::Shift)
        )
        if ($memoTextBox.IsKeyboardFocusWithin) {
            if ($isShiftTab) {
                Move-HudMemoFocusToRoot
                $Event.Handled = $true
                return
            }
            if ($key -eq [System.Windows.Input.Key]::Escape) {
                Move-HudMemoFocusToRoot
                $Event.Handled = $true
            }
            return
        }

        if ($isShiftTab) {
            Focus-HudMemo
            $Event.Handled = $true
            return
        }

        if ([System.Windows.Input.Keyboard]::Modifiers -band [System.Windows.Input.ModifierKeys]::Control) {
            return
        }

        if ($key -eq [System.Windows.Input.Key]::Space) {
            Hide-HudSession
            $Event.Handled = $true
            return
        }
        if ($key -eq [System.Windows.Input.Key]::Tab) {
            if (@('Root', 'Group', 'Feature') -contains $State.Level) {
                Select-CurrentCandidate
            }
            $Event.Handled = $true
            return
        }
        if ($key -eq [System.Windows.Input.Key]::Enter -and $State.Level -ne 'Detail') {
            Select-CurrentCandidate
            $Event.Handled = $true
            return
        }
        if ($key -eq [System.Windows.Input.Key]::Escape) {
            Back-HudLevel
            $Event.Handled = $true
            return
        }
        if ($key -eq [System.Windows.Input.Key]::Back) {
            Remove-HudFilterLastChar
            $Event.Handled = $true
            return
        }

        $candidateNumber = ConvertFrom-HudKeyToCandidateNumber -Key $key
        if ($candidateNumber -gt 0) {
            Select-HudCandidateByNumber -Number $candidateNumber
            $Event.Handled = $true
            return
        }

        $text = ConvertFrom-HudKeyToText -Key $key
        if ($text) {
            Append-HudTextFilter -Text $text
            $Event.Handled = $true
            return
        }
    }

    function Handle-HudTextInput {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.TextCompositionEventArgs]$Event
        )

        if ($null -ne $script:HudEditorWindow -and $script:HudEditorWindow.IsVisible) {
            return
        }

        if ($memoTextBox.IsKeyboardFocusWithin) {
            return
        }

        if ($Event.Text.Length -eq 1 -and [char]::IsLetterOrDigit($Event.Text[0])) {
            Append-HudTextFilter -Text $Event.Text
            $Event.Handled = $true
        }
    }

    $window.Add_PreviewKeyDown({ param($sender, $event) Handle-HudKeyDown -Event $event })
    $root.Add_PreviewKeyDown({ param($sender, $event) Handle-HudKeyDown -Event $event })
    $list.Add_PreviewKeyDown({ param($sender, $event) Handle-HudKeyDown -Event $event })
    $detail.Add_PreviewKeyDown({ param($sender, $event) Handle-HudKeyDown -Event $event })
    $window.Add_PreviewTextInput({ param($sender, $event) Handle-HudTextInput -Event $event })
    $root.Add_PreviewTextInput({ param($sender, $event) Handle-HudTextInput -Event $event })
    $list.Add_PreviewTextInput({ param($sender, $event) Handle-HudTextInput -Event $event })
    $detail.Add_PreviewTextInput({ param($sender, $event) Handle-HudTextInput -Event $event })
    $window.Add_PreviewMouseLeftButtonDown({ param($sender, $event) Handle-HudMouseButton -Button $event.ChangedButton -Event $event })
    $window.Add_PreviewMouseRightButtonDown({ param($sender, $event) Handle-HudMouseButton -Button $event.ChangedButton -Event $event })
    $mainHeaderDragArea.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $panel -Event $event }.GetNewClosure())
    $titleMarker.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $panel -Event $event }.GetNewClosure())
    $title.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $panel -Event $event }.GetNewClosure())
    $mainDragHandle.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $panel -Event $event }.GetNewClosure())
    $panel.Add_MouseMove({ param($sender, $event) Move-HudPanelDrag -Event $event }.GetNewClosure())
    $panel.Add_MouseLeftButtonUp({ param($sender, $event) Stop-HudPanelDrag -Event $event }.GetNewClosure())
    $recentPathText.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $recentPanel -Event $event }.GetNewClosure())
    $recentFeatureTitleDragArea.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $recentPanel -Event $event }.GetNewClosure())
    $recentFeatureTitleText.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $recentPanel -Event $event }.GetNewClosure())
    $recentDragHandle.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $recentPanel -Event $event }.GetNewClosure())
    $recentPanel.Add_MouseMove({ param($sender, $event) Move-HudPanelDrag -Event $event }.GetNewClosure())
    $recentPanel.Add_MouseLeftButtonUp({ param($sender, $event) Stop-HudPanelDrag -Event $event }.GetNewClosure())
    $memoHeaderDragArea.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $memoPanel -Event $event }.GetNewClosure())
    $memoDragHandle.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $memoPanel -Event $event }.GetNewClosure())
    $memoPanel.Add_MouseMove({ param($sender, $event) Move-HudPanelDrag -Event $event }.GetNewClosure())
    $memoPanel.Add_MouseLeftButtonUp({ param($sender, $event) Stop-HudPanelDrag -Event $event }.GetNewClosure())
    $minimizeButton.Add_Click({ Hide-HudSession })
    $editItemsButton.Add_Click({ Show-EditorPanel })
    $favoriteButton.Add_Click({ Toggle-HudFavoriteFromDetail })
    $closeButton.Add_Click({ $window.Close() })
    $recentCloseButton.Add_Click({ $recentPanel.Visibility = [System.Windows.Visibility]::Collapsed })
    $recentPrevButton.Add_Click({ Move-RecentHistory -Delta 1 })
    $recentNextButton.Add_Click({ Move-RecentHistory -Delta -1 })
    $list.Add_MouseDoubleClick({ Select-CurrentCandidate })
    $window.Add_Activated({
        Show-HudSession
        Focus-HudRootForInput
    })
    $window.Add_Loaded({
        $root.Focus() | Out-Null
        [void]$window.Dispatcher.BeginInvoke(
            [Action]{ Ensure-EditorWindow },
            [System.Windows.Threading.DispatcherPriority]::Background
        )
    })

    Refresh-HudView
    Show-RecentDetailIfAvailable
    Refresh-HudFavoritePanelsFromEvent
    [void]$window.ShowDialog()
}
