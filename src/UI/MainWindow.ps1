function Show-HudWindow {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$State,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Settings
    )

    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $visibleLeft = 0
    $visibleTop = 0
    $visibleWidth = $screen.Width
    $visibleHeight = $screen.Height
    $panelX = [int]$Settings.panelX
    $panelY = [int]$Settings.panelY
    $recentPanelX = [int]$Settings.recentPanelX
    $recentPanelY = [int]$Settings.recentPanelY
    $panelWidth = [int]$Settings.panelWidth
    $panelHeight = [int]$Settings.panelHeight
    $fontFamily = [string]$Settings.fontFamily
    $titleFontSize = [double]$Settings.titleFontSize
    $detailTitleFontSize = [double]$Settings.detailTitleFontSize
    $featureTitleFontSize = [double]$Settings.featureTitleFontSize
    $filterFontSize = [double]$Settings.filterFontSize
    $listFontSize = [double]$Settings.listFontSize
    $detailFontSize = [double]$Settings.detailFontSize
    $backgroundColor = ConvertTo-WpfColorCode -Rgba $Settings.backgroundRgba
    $script:HudBitLabels = $Settings.bitLabels
    $script:HudIsRetreated = $false
    $script:HudPreviousWindowHandle = [HudNativeMethods]::GetForegroundWindow()
    $script:HudCopyResetTimer = $null
    $script:HudRecentCopyResetTimer = $null
    $script:HudRecentFeature = $null
    $script:HudRecentCategoryName = ''
    $script:HudRecentGroupName = ''

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
        Height="$visibleHeight">
    <Grid Background="$backgroundColor" Focusable="True" Name="Root">
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
                <StackPanel Grid.Row="0"
                            Orientation="Horizontal">
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
                <StackPanel Grid.Row="0"
                            Orientation="Horizontal"
                            HorizontalAlignment="Right"
                            VerticalAlignment="Top">
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
                        <Grid Grid.Row="0"
                              Margin="0,0,0,14">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <TextBlock Name="ShortcutLabel"
                                       Grid.Row="0"
                                       Text="Shortcut:"
                                       FontFamily="$fontFamily"
                                       FontSize="$filterFontSize"
                                       Foreground="#6B7280"
                                       Margin="0,0,0,4"/>
                            <Border Name="ShortcutBox"
                                    Grid.Row="1"
                                    Background="#E5E7EB"
                                    CornerRadius="4"
                                    Padding="10,5"
                                    Margin="0,0,0,16"
                                    HorizontalAlignment="Left">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <TextBox Name="ShortcutText"
                                             Grid.Column="0"
                                             FontFamily="$fontFamily"
                                             FontSize="$titleFontSize"
                                             FontWeight="SemiBold"
                                             Foreground="#111827"
                                             Background="Transparent"
                                             BorderThickness="0"
                                             Padding="0,1"
                                             HorizontalAlignment="Stretch"
                                             IsReadOnly="True"
                                             IsReadOnlyCaretVisible="False"/>
                                    <Button Name="CopyShortcutButton"
                                            Grid.Column="1"
                                            Content="Copy"
                                            Width="40"
                                            Margin="0,0,0,0"
                                            Padding="6,0"
                                            BorderThickness="0"
                                            Background="Transparent"
                                            Foreground="#6B7280"
                                            FontFamily="$fontFamily"
                                            FontSize="$filterFontSize"/>
                                </Grid>
                            </Border>
                            <TextBlock Grid.Row="2"
                                       Text="Description:"
                                       FontFamily="$fontFamily"
                                       FontSize="$filterFontSize"
                                       Foreground="#6B7280"
                                       Margin="0,0,0,4"/>
                            <TextBox Name="DescriptionText"
                                     Grid.Row="3"
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
                                     VerticalScrollBarVisibility="Auto"
                                     HorizontalScrollBarVisibility="Disabled"/>
                        </Grid>
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
                Visibility="Collapsed">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <TextBlock Name="RecentPathText"
                           Grid.Row="0"
                           FontFamily="$fontFamily"
                           FontSize="$detailTitleFontSize"
                           FontWeight="SemiBold"
                           Foreground="#1F2937"/>
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
                <TextBlock Name="RecentFeatureTitleText"
                           Grid.Row="1"
                           FontFamily="$fontFamily"
                           FontSize="$featureTitleFontSize"
                           FontWeight="SemiBold"
                           Foreground="#111827"
                           TextWrapping="Wrap"
                           Margin="0,4,0,8"/>
                <Grid Grid.Row="2"
                      Name="RecentShortcutArea">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBlock Grid.Row="0"
                               Text="Shortcut:"
                               FontFamily="$fontFamily"
                               FontSize="$filterFontSize"
                               Foreground="#6B7280"
                               Margin="0,0,0,4"/>
                    <Border Grid.Row="1"
                            Background="#E5E7EB"
                            CornerRadius="4"
                            Padding="10,5"
                            Margin="0,0,0,12"
                            HorizontalAlignment="Left">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBox Name="RecentShortcutText"
                                     Grid.Column="0"
                                     FontFamily="$fontFamily"
                                     FontSize="$titleFontSize"
                                     FontWeight="SemiBold"
                                     Foreground="#111827"
                                     Background="Transparent"
                                     BorderThickness="0"
                                     Padding="0,1"
                                     HorizontalAlignment="Stretch"
                                     IsReadOnly="True"
                                     IsReadOnlyCaretVisible="False"/>
                            <Button Name="RecentCopyShortcutButton"
                                    Grid.Column="1"
                                    Content="Copy"
                                    Width="40"
                                    Padding="6,0"
                                    BorderThickness="0"
                                    Background="Transparent"
                                    Foreground="#6B7280"
                                    FontFamily="$fontFamily"
                                    FontSize="$filterFontSize"/>
                        </Grid>
                    </Border>
                </Grid>
                <Grid Grid.Row="3">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <TextBlock Grid.Row="0"
                               Text="Description:"
                               FontFamily="$fontFamily"
                               FontSize="$filterFontSize"
                               Foreground="#6B7280"
                               Margin="0,0,0,4"/>
                    <TextBox Name="RecentDescriptionText"
                             Grid.Row="1"
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
                             VerticalScrollBarVisibility="Auto"
                             HorizontalScrollBarVisibility="Disabled"/>
                </Grid>
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
    $titleMarker = $window.FindName('TitleMarkerText')
    $title = $window.FindName('TitleText')
    $minimizeButton = $window.FindName('MinimizeButton')
    $closeButton = $window.FindName('CloseButton')
    $filter = $window.FindName('FilterText')
    $filterRow = $window.FindName('FilterRow')
    $featureTitle = $window.FindName('FeatureTitleText')
    $list = $window.FindName('CandidateList')
    $detail = $window.FindName('DetailText')
    $detailPanel = $window.FindName('DetailPanel')
    $shortcutLabel = $window.FindName('ShortcutLabel')
    $shortcutBox = $window.FindName('ShortcutBox')
    $shortcutText = $window.FindName('ShortcutText')
    $copyShortcutButton = $window.FindName('CopyShortcutButton')
    $descriptionText = $window.FindName('DescriptionText')
    $recentPanel = $window.FindName('RecentPanel')
    $recentPathText = $window.FindName('RecentPathText')
    $recentFeatureTitleText = $window.FindName('RecentFeatureTitleText')
    $recentShortcutArea = $window.FindName('RecentShortcutArea')
    $recentShortcutText = $window.FindName('RecentShortcutText')
    $recentCopyShortcutButton = $window.FindName('RecentCopyShortcutButton')
    $recentDescriptionText = $window.FindName('RecentDescriptionText')
    $recentCloseButton = $window.FindName('RecentCloseButton')

    function Update-RecentDetailWindow {
        param(
            [Parameter(Mandatory = $true)]
            [object]$Feature,

            [Parameter(Mandatory = $true)]
            [string]$CategoryName,

            [Parameter(Mandatory = $true)]
            [string]$GroupName
        )

        $recentPathText.Text = "$CategoryName / $GroupName /"
        $recentFeatureTitleText.Text = $Feature.title
        $recentDescriptionText.Text = $Feature.description

        if ($Feature.PSObject.Properties.Name -contains 'shortcut' -and -not [string]::IsNullOrWhiteSpace($Feature.shortcut)) {
            $recentShortcutText.Text = $Feature.shortcut
            $recentShortcutArea.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $recentShortcutText.Text = ''
            $recentShortcutArea.Visibility = [System.Windows.Visibility]::Collapsed
        }

        if (-not [string]::IsNullOrWhiteSpace($recentShortcutText.Text) -and $Feature.PSObject.Properties.Name -contains 'copyable' -and $Feature.copyable) {
            $recentCopyShortcutButton.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $recentCopyShortcutButton.Visibility = [System.Windows.Visibility]::Collapsed
        }

        if (-not $script:HudIsRetreated) {
            $recentPanel.Visibility = [System.Windows.Visibility]::Visible
        }
    }

    function Set-RecentDetail {
        param(
            [Parameter(Mandatory = $true)]
            [object]$Feature
        )

        $script:HudRecentFeature = $Feature
        $script:HudRecentCategoryName = $State.SelectedCategory.name
        $script:HudRecentGroupName = $State.SelectedGroup.name
    }

    function Show-RecentDetailIfAvailable {
        if ($null -eq $script:HudRecentFeature) {
            return
        }

        Update-RecentDetailWindow -Feature $script:HudRecentFeature -CategoryName $script:HudRecentCategoryName -GroupName $script:HudRecentGroupName
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
        }
        else {
            $filter.Text = "Text: $($State.TextFilter)    Bit: $(ConvertTo-HudBitDisplayText -BitText $State.BitFilter)"
            $filterRow.Height = [System.Windows.GridLength]::Auto
            $title.FontSize = $titleFontSize
            $featureTitle.Visibility = [System.Windows.Visibility]::Collapsed
            $featureTitle.Text = ''
        }
        $list.Items.Clear()

        $candidates = Get-HudCandidates -State $State

        if ($State.Level -eq 'Detail') {
            $list.Visibility = [System.Windows.Visibility]::Collapsed
            $detail.Visibility = [System.Windows.Visibility]::Collapsed
            $detailPanel.Visibility = [System.Windows.Visibility]::Visible
            $feature = $State.SelectedFeature
            if ($feature.PSObject.Properties.Name -contains 'shortcut' -and -not [string]::IsNullOrWhiteSpace($feature.shortcut)) {
                $shortcutText.Text = $feature.shortcut
                $shortcutLabel.Visibility = [System.Windows.Visibility]::Visible
                $shortcutBox.Visibility = [System.Windows.Visibility]::Visible
            }
            else {
                $shortcutText.Text = ''
                $shortcutLabel.Visibility = [System.Windows.Visibility]::Collapsed
                $shortcutBox.Visibility = [System.Windows.Visibility]::Collapsed
            }
            $descriptionText.Text = $feature.description
            Set-RecentDetail -Feature $feature
            if (-not [string]::IsNullOrWhiteSpace($shortcutText.Text) -and $feature.PSObject.Properties.Name -contains 'copyable' -and $feature.copyable) {
                $copyShortcutButton.Visibility = [System.Windows.Visibility]::Visible
            }
            else {
                $copyShortcutButton.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }
        else {
            $list.Visibility = [System.Windows.Visibility]::Visible
            $detail.Visibility = [System.Windows.Visibility]::Visible
            $detailPanel.Visibility = [System.Windows.Visibility]::Collapsed
            foreach ($candidate in $candidates) {
                [void]$list.Items.Add($candidate.Label)
            }
            if ($list.Items.Count -gt 0) {
                $list.SelectedIndex = 0
            }

            if ($State.Level -eq 'Feature') {
                $detail.Text = "キー入力 or マウスクリックで絞り込み。候補が1件になると自動で詳細画面へ進む。`r`nEsc: 戻る, 左クリック: $($script:HudBitLabels.one), 右クリック: $($script:HudBitLabels.zero)"
            }
            else {
                $detail.Text = "先頭文字のキー入力で絞り込み。候補が1件になると自動で次へ進む。`r`nEsc: 戻る"
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
        Reset-HudSessionToRoot
        $window.Left = -32000
        $window.Top = -32000
        $window.Width = 1
        $window.Height = 1
        if ($script:HudPreviousWindowHandle -ne [IntPtr]::Zero) {
            [HudNativeMethods]::SetForegroundWindow($script:HudPreviousWindowHandle) | Out-Null
        }
    }

    function Show-HudSession {
        if (-not $script:HudIsRetreated) {
            return
        }
        $script:HudIsRetreated = $false
        $window.Width = $visibleWidth
        $window.Height = $visibleHeight
        Invoke-AutoAdvanceIfSingle
        Refresh-HudView
        Show-RecentDetailIfAvailable
        $window.Left = $visibleLeft
        $window.Top = $visibleTop
        $window.Activate() | Out-Null
        $root.Focus() | Out-Null
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

        if ($State.Level -notin 'Root', 'Group') {
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

    function Handle-HudMouseButton {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.MouseButton]$Button,

            [Parameter(Mandatory = $true)]
            [System.Windows.Input.MouseButtonEventArgs]$Event
        )

        $source = $Event.OriginalSource
        while ($null -ne $source) {
            if ($source -is [System.Windows.Controls.Button] -or $source -is [System.Windows.Controls.TextBox]) {
                return
            }
            $source = [System.Windows.Media.VisualTreeHelper]::GetParent($source)
        }

        if ($State.Level -in 'Root', 'Group') {
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
            return
        }

        Add-HudBitInput -Button $Button
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

    function Back-HudLevel {
        if ($State.TextFilter -or $State.BitFilter) {
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
        elseif ($State.BitFilter.Length -gt 0) {
            $State.BitFilter = $State.BitFilter.Substring(0, $State.BitFilter.Length - 1)
        }
        else {
            return
        }
        Invoke-AutoAdvanceIfSingle
        Refresh-HudView
    }

    function Add-HudBitInput {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.MouseButton]$Button
        )

        if ($State.Level -ne 'Feature') {
            return
        }
        if ($Button -eq [System.Windows.Input.MouseButton]::Left) {
            $State.BitFilter += '1'
        }
        elseif ($Button -eq [System.Windows.Input.MouseButton]::Right) {
            $State.BitFilter += '0'
        }
        else {
            return
        }

        $root.Focus() | Out-Null
        Invoke-AutoAdvanceIfSingle
        Refresh-HudView
    }

    function ConvertFrom-HudKeyToText {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.Key]$Key
        )

        $keyText = $Key.ToString()
        if ($keyText.Length -eq 1 -and [char]::IsLetter($keyText[0])) {
            return $keyText.ToLowerInvariant()
        }
        if ($keyText -match '^D([0-9])$') {
            return $matches[1]
        }
        if ($keyText -match '^NumPad([0-9])$') {
            return $matches[1]
        }

        return ''
    }

    function ConvertFrom-HudKeyToCandidateNumber {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.Key]$Key
        )

        $keyText = $Key.ToString()
        if ($keyText -match '^D([1-3])$') {
            return [int]$matches[1]
        }
        if ($keyText -match '^NumPad([1-3])$') {
            return [int]$matches[1]
        }

        return 0
    }

    function Handle-HudKeyDown {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.KeyEventArgs]$Event
        )

        if ([System.Windows.Input.Keyboard]::Modifiers -band [System.Windows.Input.ModifierKeys]::Control) {
            return
        }

        if ($Event.Key -eq [System.Windows.Input.Key]::Space) {
            Hide-HudSession
            $Event.Handled = $true
            return
        }
        if ($Event.Key -eq [System.Windows.Input.Key]::Tab) {
            if ($State.Level -in 'Root', 'Group') {
                Select-CurrentCandidate
            }
            $Event.Handled = $true
            return
        }
        if ($Event.Key -eq [System.Windows.Input.Key]::Enter -and $State.Level -ne 'Detail') {
            Select-CurrentCandidate
            $Event.Handled = $true
            return
        }
        if ($Event.Key -eq [System.Windows.Input.Key]::Escape) {
            Back-HudLevel
            $Event.Handled = $true
            return
        }
        if ($Event.Key -eq [System.Windows.Input.Key]::Back) {
            Remove-HudFilterLastChar
            $Event.Handled = $true
            return
        }

        $candidateNumber = ConvertFrom-HudKeyToCandidateNumber -Key $Event.Key
        if ($candidateNumber -gt 0) {
            Select-HudCandidateByNumber -Number $candidateNumber
            $Event.Handled = $true
            return
        }

        $text = ConvertFrom-HudKeyToText -Key $Event.Key
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
    $minimizeButton.Add_Click({ Hide-HudSession })
    $closeButton.Add_Click({ $window.Close() })
    $recentCloseButton.Add_Click({ $recentPanel.Visibility = [System.Windows.Visibility]::Collapsed })
    $recentCopyShortcutButton.Add_Click({
        if (-not [string]::IsNullOrEmpty($recentShortcutText.Text)) {
            try {
                [System.Windows.Clipboard]::SetText($recentShortcutText.Text)
                $recentCopyShortcutButton.Content = 'OK'
            }
            catch {
                $recentCopyShortcutButton.Content = 'Failed'
            }
            if ($null -ne $script:HudRecentCopyResetTimer) {
                $script:HudRecentCopyResetTimer.Stop()
            }
            $script:HudRecentCopyResetTimer = [System.Windows.Threading.DispatcherTimer]::new()
            $script:HudRecentCopyResetTimer.Interval = [TimeSpan]::FromMilliseconds(900)
            $script:HudRecentCopyResetTimer.Add_Tick({
                $script:HudRecentCopyResetTimer.Stop()
                $recentCopyShortcutButton.Content = 'Copy'
            })
            $script:HudRecentCopyResetTimer.Start()
        }
    })
    $copyShortcutButton.Add_Click({
        if (-not [string]::IsNullOrEmpty($shortcutText.Text)) {
            try {
                [System.Windows.Clipboard]::SetText($shortcutText.Text)
                $copyShortcutButton.Content = 'OK'
            }
            catch {
                $copyShortcutButton.Content = 'Failed'
            }
            if ($null -ne $script:HudCopyResetTimer) {
                $script:HudCopyResetTimer.Stop()
            }
            $script:HudCopyResetTimer = [System.Windows.Threading.DispatcherTimer]::new()
            $script:HudCopyResetTimer.Interval = [TimeSpan]::FromMilliseconds(900)
            $script:HudCopyResetTimer.Add_Tick({
                $script:HudCopyResetTimer.Stop()
                $copyShortcutButton.Content = 'Copy'
            })
            $script:HudCopyResetTimer.Start()
        }
    })
    $shortcutText.Add_PreviewMouseLeftButtonDown({
        param($sender, $event)

        if ($event.ClickCount -ge 3) {
            $shortcutText.Focus() | Out-Null
            $shortcutText.SelectAll()
            $event.Handled = $true
        }
    })
    $list.Add_MouseDoubleClick({ Select-CurrentCandidate })
    $window.Add_Activated({ Show-HudSession })
    $window.Add_Loaded({ $root.Focus() | Out-Null })

    Invoke-AutoAdvanceIfSingle
    Refresh-HudView
    [void]$window.ShowDialog()
}
