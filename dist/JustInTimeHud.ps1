# Auto-generated from src/*.ps1 by build.ps1.
# Edit files under src/ instead of this generated file.
# Source commit: 489a752

$script:EmbeddedHudDataJson = @'
[
  {
    "name": "Terminalaaaaaa",
    "groups": [
      {
        "name": "Giaaaa",
        "features": [
          {
            "title": "Status（変更状況を確認）",
            "bitTag": "1",
            "shortcut": "git status --shortd",
            "description": "作業ツリーの変更状asfa況を短い形式で確認するapdaffsfa",
            "copyable": true,
            "favorite": true
          },
          {
            "title": "Before commit（コミット前確認）",
            "bitTag": "0",
            "description": "コミット前に確認する項目\n\n1. git status --short で含めるファイルを確認する。\n2. git diff で差分を見る。\n3. 生成物や一時ファイルが混ざっていないか確認する",
            "shortcut": "afasdfa\r\nasdfasdfad\r\nasfasdfs\r\nfdasfsda",
            "copyable": true
          }
        ]
      }
    ]
  },
  {
    "name": "Workflow",
    "groups": [
      {
        "name": "Templateaaaaa",
        "features": [
          {
            "title": "Meeting note（打ち合わせメモ）aa",
            "bitTag": "1",
            "shortcut": "目的:\n決定事項:\n未決事項:\n次のアクション:asdfa",
            "copyable": true,
            "description": "短い打ち合わせメモのテンプレート。必要な項目だけ残して使う。asdfaasdfsssafsdasdfas",
            "favorite": true
          }
        ]
      }
    ]
  }
]
'@

$script:EmbeddedHudSettingsJsonc = @'
{
  // HUDパネル左上の表示座標。
  "panelX": 1480,
  "panelY": 20,

  // 直近詳細HUDの左上の表示座標。
  "recentPanelX": 1480,
  "recentPanelY": 395,

  // HUDパネルのサイズ。
  "panelWidth": 420,
  "panelHeight": 360,

  // HUD全体のフォント。
  "fontFamily": "Yu Gothic UI",

  // 通常画面のタイトルサイズ。
  "titleFontSize": 13,

  // 詳細画面上段の分類パス用タイトルサイズ。
  "detailTitleFontSize": 13,

  // 詳細画面の機能名タイトルサイズ。
  "featureTitleFontSize": 18,

  // 補助情報、リスト、詳細本文の文字サイズ。
  "filterFontSize": 12,
  "listFontSize": 12,
  "detailFontSize": 12,

  // 左クリック/右クリックの表示ラベル。内部値は 1 / 0 のまま。
  "bitLabels": {
    "one": "1",
    "zero": "0"
  },

  // 全画面入力面の背景RGBA。aは 0.0-1.0 または 0-255。
  "backgroundRgba": {
    "r": 0,
    "g": 0,
    "b": 0,
    "a": 0.1
  }
}

'@

#region src/App/Bootstrap.ps1
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

if (-not $script:AppRoot) {
    $scriptPath = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
    $script:AppRoot = Split-Path -Parent $scriptPath
}

if (-not ('HudNativeMethods' -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class HudNativeMethods
{
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

}
"@
}

#endregion src/App/Bootstrap.ps1

#region src/Config/AppConfig.ps1
$script:AppName = 'Just-in-Time HUD'
$script:DefaultHudSampleDataPath = Join-Path $script:AppRoot 'data\hud-items.sample.json'
$script:DefaultHudDataPath = if ($script:HudDevelopmentMode) {
    $script:DefaultHudSampleDataPath
}
else {
    Join-Path $script:AppRoot 'hud-items.json'
}
$script:DefaultHudSettingsPath = Join-Path $script:AppRoot 'settings.jsonc'
$script:DefaultHudIconPath = Join-Path $script:AppRoot 'assets\icon.ico'

#endregion src/Config/AppConfig.ps1

#region src/Infrastructure/JsonStore.ps1
function Read-HudJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($script:EmbeddedHudDataJson) {
            Write-HudTextFileIfMissing -Path $Path -Text $script:EmbeddedHudDataJson
        }
        elseif ($script:DefaultHudSampleDataPath -and (Test-Path -LiteralPath $script:DefaultHudSampleDataPath)) {
            Write-HudTextFileIfMissing -Path $Path -Text (Get-Content -LiteralPath $script:DefaultHudSampleDataPath -Raw -Encoding UTF8)
        }
        else {
            throw "HUD data file not found: $Path"
        }
    }

    Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Save-HudJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [object[]]$Items
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    $json = @($Items) | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($Path), $json, [System.Text.UTF8Encoding]::new($true))
}

function Write-HudTextFileIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    if (Test-Path -LiteralPath $Path) {
        return
    }

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($Path), $Text, [System.Text.UTF8Encoding]::new($true))
}

function Remove-JsoncComments {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    $builder = [System.Text.StringBuilder]::new()
    $inString = $false
    $isEscaped = $false
    $length = $Text.Length

    for ($index = 0; $index -lt $length; $index++) {
        $char = $Text[$index]
        $next = if ($index + 1 -lt $length) { $Text[$index + 1] } else { [char]0 }

        if ($inString) {
            [void]$builder.Append($char)
            if ($isEscaped) {
                $isEscaped = $false
            }
            elseif ($char -eq '\') {
                $isEscaped = $true
            }
            elseif ($char -eq '"') {
                $inString = $false
            }
            continue
        }

        if ($char -eq '"') {
            $inString = $true
            [void]$builder.Append($char)
            continue
        }

        if ($char -eq '/' -and $next -eq '/') {
            while ($index -lt $length -and $Text[$index] -notin "`r", "`n") {
                $index++
            }
            if ($index -lt $length) {
                [void]$builder.Append($Text[$index])
            }
            continue
        }

        if ($char -eq '/' -and $next -eq '*') {
            $index += 2
            while ($index + 1 -lt $length -and -not ($Text[$index] -eq '*' -and $Text[$index + 1] -eq '/')) {
                $index++
            }
            $index++
            continue
        }

        [void]$builder.Append($char)
    }

    return $builder.ToString()
}

function Read-HudSettings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $defaults = [pscustomobject]@{
        panelX = 32
        panelY = 96
        recentPanelX = 464
        recentPanelY = 96
        panelWidth = 420
        panelHeight = 360
        fontFamily = 'Yu Gothic UI'
        titleFontSize = 15
        detailTitleFontSize = 15
        featureTitleFontSize = 15
        filterFontSize = 12
        listFontSize = 14
        detailFontSize = 12
        bitLabels = [pscustomobject]@{
            one = '1'
            zero = '0'
        }
        backgroundRgba = [pscustomobject]@{
            r = 255
            g = 255
            b = 255
            a = 1
        }
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($script:EmbeddedHudSettingsJsonc) {
            Write-HudTextFileIfMissing -Path $Path -Text $script:EmbeddedHudSettingsJsonc
        }
        else {
            return $defaults
        }
    }

    $settings = Remove-JsoncComments -Text (Get-Content -LiteralPath $Path -Raw -Encoding UTF8) | ConvertFrom-Json
    foreach ($name in @('panelX', 'panelY', 'recentPanelX', 'recentPanelY', 'panelWidth', 'panelHeight', 'fontFamily', 'titleFontSize', 'detailTitleFontSize', 'featureTitleFontSize', 'filterFontSize', 'listFontSize', 'detailFontSize')) {
        if ($null -eq $settings.$name) {
            $settings | Add-Member -NotePropertyName $name -NotePropertyValue $defaults.$name -Force
        }
    }
    if ($null -eq $settings.bitLabels) {
        $settings | Add-Member -NotePropertyName 'bitLabels' -NotePropertyValue $defaults.bitLabels -Force
    }
    foreach ($name in @('one', 'zero')) {
        if ($null -eq $settings.bitLabels.$name) {
            $settings.bitLabels | Add-Member -NotePropertyName $name -NotePropertyValue $defaults.bitLabels.$name -Force
        }
    }
    if ($null -eq $settings.backgroundRgba) {
        $settings | Add-Member -NotePropertyName 'backgroundRgba' -NotePropertyValue $defaults.backgroundRgba -Force
    }
    foreach ($name in @('r', 'g', 'b', 'a')) {
        if ($null -eq $settings.backgroundRgba.$name) {
            $settings.backgroundRgba | Add-Member -NotePropertyName $name -NotePropertyValue $defaults.backgroundRgba.$name -Force
        }
    }

    return $settings
}

function ConvertTo-WpfColorCode {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Rgba
    )

    $r = [Math]::Max(0, [Math]::Min(255, [int]$Rgba.r))
    $g = [Math]::Max(0, [Math]::Min(255, [int]$Rgba.g))
    $b = [Math]::Max(0, [Math]::Min(255, [int]$Rgba.b))
    $aValue = [double]$Rgba.a
    if ($aValue -le 1) {
        $a = [Math]::Round($aValue * 255)
    }
    else {
        $a = [Math]::Round($aValue)
    }
    $a = [Math]::Max(0, [Math]::Min(255, [int]$a))

    return ('#{0:X2}{1:X2}{2:X2}{3:X2}' -f $a, $r, $g, $b)
}

#endregion src/Infrastructure/JsonStore.ps1

#region src/Domain/HudModel.ps1
function New-HudState {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Items
    )

    [pscustomobject]@{
        Items = $Items
        Level = 'Root'
        SelectedCategory = $null
        SelectedGroup = $null
        SelectedFeature = $null
        TextFilter = ''
    }
}

function Get-HudCandidates {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$State
    )

    switch ($State.Level) {
        'Root' {
            $items = $State.Items
            if ($State.TextFilter) {
                $items = @($items | Where-Object { $_.name.StartsWith($State.TextFilter, [System.StringComparison]::OrdinalIgnoreCase) })
            }
            return @($items | ForEach-Object { [pscustomobject]@{ Label = $_.name; Value = $_ } })
        }
        'Group' {
            $items = @($State.SelectedCategory.groups)
            if ($State.TextFilter) {
                $items = @($items | Where-Object { $_.name.StartsWith($State.TextFilter, [System.StringComparison]::OrdinalIgnoreCase) })
            }
            return @($items | ForEach-Object { [pscustomobject]@{ Label = $_.name; Value = $_ } })
        }
        'Feature' {
            $items = @($State.SelectedGroup.features)
            if ($State.TextFilter) {
                $items = @($items | Where-Object { Test-HudInitialMatch -Text $_.title -Filter $State.TextFilter })
            }
            return @($items | ForEach-Object { [pscustomobject]@{ Label = $_.title; Value = $_ } })
        }
        'Detail' {
            return @([pscustomobject]@{ Label = $State.SelectedFeature.title; Value = $State.SelectedFeature })
        }
    }
}

function Test-HudInitialMatch {
    param(
        [AllowNull()]
        [string]$Text,

        [AllowNull()]
        [string]$Filter
    )

    if ([string]::IsNullOrEmpty($Filter)) {
        return $true
    }
    if ([string]::IsNullOrEmpty($Text)) {
        return $false
    }
    if ($Text.StartsWith($Filter, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    $initials = (([regex]::Matches($Text, '\b[0-9A-Za-z]') | ForEach-Object { $_.Value }) -join '')

    return $initials.StartsWith($Filter, [System.StringComparison]::OrdinalIgnoreCase)
}

function ConvertTo-HudBitDisplayText {
    param(
        [string]$BitText
    )

    if (-not $script:HudBitLabels) {
        return $BitText
    }

    $chars = foreach ($char in $BitText.ToCharArray()) {
        switch ($char) {
            '1' { $script:HudBitLabels.one }
            '0' { $script:HudBitLabels.zero }
            default { [string]$char }
        }
    }
    return ($chars -join '')
}

function Reset-HudFilter {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$State
    )

    $State.TextFilter = ''
}

#endregion src/Domain/HudModel.ps1

#region src/UI/MainWindow.ps1
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
    $editorWidth = 920
    $editorHeight = 620
    $editorLeft = [Math]::Max(0, [int](($screen.Width - $editorWidth) / 2))
    $editorTop = [Math]::Max(0, [int](($screen.Height - $editorHeight) / 2))
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
    $script:HudFavoritePanels = @()
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
                                            Height="20"
                                            Margin="0,0,0,0"
                                            Padding="6,0"
                                            BorderThickness="0"
                                            Background="Transparent"
                                            Foreground="#6B7280"
                                            FontFamily="$fontFamily"
                                            FontSize="$filterFontSize"
                                            VerticalAlignment="Top"/>
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
                Visibility="Visible">
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
                                    Height="20"
                                    Padding="6,0"
                                    BorderThickness="0"
                                    Background="Transparent"
                                    Foreground="#6B7280"
                                    FontFamily="$fontFamily"
                                    FontSize="$filterFontSize"
                                    VerticalAlignment="Top"/>
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
    $script:HudRoot = $root
    $panel = $window.FindName('Panel')
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
    $shortcutBox = $window.FindName('ShortcutBox')
    $shortcutText = $window.FindName('ShortcutText')
    $copyShortcutButton = $window.FindName('CopyShortcutButton')
    $descriptionText = $window.FindName('DescriptionText')
    $recentPanel = $window.FindName('RecentPanel')
    $recentPathText = $window.FindName('RecentPathText')
    $recentDragHandle = $window.FindName('RecentDragHandle')
    $recentFeatureTitleText = $window.FindName('RecentFeatureTitleText')
    $recentShortcutArea = $window.FindName('RecentShortcutArea')
    $recentShortcutText = $window.FindName('RecentShortcutText')
    $recentCopyShortcutButton = $window.FindName('RecentCopyShortcutButton')
    $recentDescriptionText = $window.FindName('RecentDescriptionText')
    $recentCloseButton = $window.FindName('RecentCloseButton')

    function Set-HudProperty {
        param(
            [Parameter(Mandatory = $true)]
            [object]$Target,
            [Parameter(Mandatory = $true)]
            [string]$Name,
            [object]$Value
        )

        if ($Target.PSObject.Properties.Name -contains $Name) {
            $Target.$Name = $Value
        }
        else {
            $Target | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
        }
    }

    function Set-EditorStatus {
        param([string]$Text)
        $editorStatusText.Text = $Text
    }

    function global:Set-HudPropertyFromEvent {
        param(
            [Parameter(Mandatory = $true)]
            [object]$Target,
            [Parameter(Mandatory = $true)]
            [string]$Name,
            [object]$Value
        )

        if ($Target.PSObject.Properties.Name -contains $Name) {
            $Target.$Name = $Value
        }
        else {
            $Target | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
        }
    }

    function global:Save-HudJsonFromEvent {
        param([Parameter(Mandatory = $true)][object[]]$Items)

        $directory = Split-Path -Parent $script:DefaultHudDataPath
        if ($directory -and -not (Test-Path -LiteralPath $directory)) {
            New-Item -ItemType Directory -Force -Path $directory | Out-Null
        }

        $json = @($Items) | ConvertTo-Json -Depth 20
        [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($script:DefaultHudDataPath), $json, [System.Text.UTF8Encoding]::new($true))
    }

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
        if ($Feature.PSObject.Properties.Name -contains 'favorite' -and [bool]$Feature.favorite) {
            $script:HudFavoriteButton.Content = '★'
            $script:HudFavoriteButton.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F59E0B')
        }
        else {
            $script:HudFavoriteButton.Content = '☆'
            $script:HudFavoriteButton.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6B7280')
        }
    }

    function global:Start-HudPanelDrag {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.FrameworkElement]$Target,
            [Parameter(Mandatory = $true)]
            [System.Windows.Input.MouseButtonEventArgs]$Event
        )

        $script:HudDragTarget = $Target
        $script:HudDragStartPoint = $Event.GetPosition($root)
        $script:HudDragStartMargin = $Target.Margin
        $Target.CaptureMouse() | Out-Null
        $Event.Handled = $true
    }

    function global:Move-HudPanelDrag {
        param([Parameter(Mandatory = $true)][System.Windows.Input.MouseEventArgs]$Event)

        if ($null -eq $script:HudDragTarget) {
            return
        }

        $point = $Event.GetPosition($root)
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
        Set-EditorLabelText -Label $editorTitleLabel -Text 'Title' -Dirty $false
        Set-EditorLabelText -Label $editorBitLabel -Text 'Bit' -Dirty $false
        Set-EditorLabelText -Label $editorShortcutLabel -Text 'Shortcut / Command / Template' -Dirty $false
        Set-EditorLabelText -Label $editorDescriptionLabel -Text 'Description' -Dirty $false
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
            $editorBitTagBox.Text = ''
            $editorShortcutBox.Text = ''
            $editorCopyableBox.IsChecked = $false
            $editorFavoriteBox.IsChecked = $false
            $editorDescriptionBox.Text = ''
            $script:HudEditorRefreshing = $false
            Clear-EditorDirtyMarkers
            return
        }

        $editorTitleBox.Text = [string]$feature.title
        $editorBitTagBox.Text = [string]$feature.bitTag
        $editorShortcutBox.Text = if ($feature.PSObject.Properties.Name -contains 'shortcut') { [string]$feature.shortcut } else { '' }
        $editorCopyableBox.IsChecked = ($feature.PSObject.Properties.Name -contains 'copyable' -and [bool]$feature.copyable)
        $editorFavoriteBox.IsChecked = ($feature.PSObject.Properties.Name -contains 'favorite' -and [bool]$feature.favorite)
        $editorDescriptionBox.Text = [string]$feature.description
        $script:HudEditorRefreshing = $false
        Clear-EditorDirtyMarkers
    }

    function Refresh-EditorFeatureList {
        $selected = Get-EditorSelectedFeature
        $script:HudEditorRefreshing = $true
        $editorFeatureList.Items.Clear()
        $group = Get-EditorSelectedGroup
        if ($null -ne $group) {
            foreach ($feature in @($group.features)) {
                [void]$editorFeatureList.Items.Add($feature)
            }
        }
        if ($null -ne $selected -and @($group.features) -contains $selected) {
            $editorFeatureList.SelectedItem = $selected
        }
        elseif ($editorFeatureList.Items.Count -gt 0) {
            $editorFeatureList.SelectedIndex = 0
        }
        $script:HudEditorRefreshing = $false
        Refresh-EditorFeatureFields
    }

    function Refresh-EditorGroupList {
        $selected = Get-EditorSelectedGroup
        $script:HudEditorRefreshing = $true
        $editorGroupList.Items.Clear()
        $category = Get-EditorSelectedCategory
        $editorCategoryNameBox.Text = if ($null -ne $category) { [string]$category.name } else { '' }
        if ($null -ne $category) {
            foreach ($group in @($category.groups)) {
                [void]$editorGroupList.Items.Add($group)
            }
        }
        if ($null -ne $selected -and @($category.groups) -contains $selected) {
            $editorGroupList.SelectedItem = $selected
        }
        elseif ($editorGroupList.Items.Count -gt 0) {
            $editorGroupList.SelectedIndex = 0
        }
        $group = Get-EditorSelectedGroup
        $editorGroupNameBox.Text = if ($null -ne $group) { [string]$group.name } else { '' }
        $script:HudEditorRefreshing = $false
        Refresh-EditorFeatureList
    }

    function Refresh-EditorCategoryList {
        $selected = Get-EditorSelectedCategory
        $script:HudEditorRefreshing = $true
        $editorCategoryList.Items.Clear()
        foreach ($category in @($State.Items)) {
            [void]$editorCategoryList.Items.Add($category)
        }
        if ($null -ne $selected -and @($State.Items) -contains $selected) {
            $editorCategoryList.SelectedItem = $selected
        }
        elseif ($editorCategoryList.Items.Count -gt 0) {
            $editorCategoryList.SelectedIndex = 0
        }
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
    }

    function Apply-EditorFeatureFields {
        param([string[]]$DirtyFields = @('Title', 'Bit', 'Shortcut', 'Description'))

        $feature = Get-EditorSelectedFeature
        if ($null -eq $feature) { return }
        Set-HudProperty -Target $feature -Name 'title' -Value $editorTitleBox.Text
        Set-HudProperty -Target $feature -Name 'bitTag' -Value $editorBitTagBox.Text
        Set-HudProperty -Target $feature -Name 'description' -Value $editorDescriptionBox.Text

        if ([string]::IsNullOrWhiteSpace($editorShortcutBox.Text)) {
            if ($feature.PSObject.Properties.Name -contains 'shortcut') { $feature.PSObject.Properties.Remove('shortcut') }
        }
        else {
            Set-HudProperty -Target $feature -Name 'shortcut' -Value $editorShortcutBox.Text
        }

        if ([bool]$editorCopyableBox.IsChecked) {
            Set-HudProperty -Target $feature -Name 'copyable' -Value $true
        }
        elseif ($feature.PSObject.Properties.Name -contains 'copyable') {
            $feature.PSObject.Properties.Remove('copyable')
        }
        if ([bool]$editorFavoriteBox.IsChecked) {
            Set-HudProperty -Target $feature -Name 'favorite' -Value $true
        }
        elseif ($feature.PSObject.Properties.Name -contains 'favorite') {
            $feature.PSObject.Properties.Remove('favorite')
        }
        if ($DirtyFields -contains 'Title') {
            Set-EditorLabelText -Label $editorTitleLabel -Text 'Title' -Dirty $false
        }
        if ($DirtyFields -contains 'Bit') {
            Set-EditorLabelText -Label $editorBitLabel -Text 'Bit' -Dirty $false
        }
        if ($DirtyFields -contains 'Shortcut') {
            Set-EditorLabelText -Label $editorShortcutLabel -Text 'Shortcut / Command / Template' -Dirty $false
        }
        if ($DirtyFields -contains 'Description') {
            Set-EditorLabelText -Label $editorDescriptionLabel -Text 'Description' -Dirty $false
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
        Set-HudProperty -Target $feature -Name 'bitTag' -Value $editorBitTagBox.Text
        Set-HudProperty -Target $feature -Name 'description' -Value $editorDescriptionBox.Text

        if ([string]::IsNullOrWhiteSpace($editorShortcutBox.Text)) {
            if ($feature.PSObject.Properties.Name -contains 'shortcut') { $feature.PSObject.Properties.Remove('shortcut') }
        }
        else {
            Set-HudProperty -Target $feature -Name 'shortcut' -Value $editorShortcutBox.Text
        }

        if ([bool]$editorCopyableBox.IsChecked) {
            Set-HudProperty -Target $feature -Name 'copyable' -Value $true
        }
        elseif ($feature.PSObject.Properties.Name -contains 'copyable') {
            $feature.PSObject.Properties.Remove('copyable')
        }
        if ([bool]$editorFavoriteBox.IsChecked) {
            Set-HudProperty -Target $feature -Name 'favorite' -Value $true
        }
        elseif ($feature.PSObject.Properties.Name -contains 'favorite') {
            $feature.PSObject.Properties.Remove('favorite')
        }
    }

    function New-EditorWindow {
        [xml]$editorXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="HUD Item Editor"
        Width="920"
        Height="620"
        WindowStartupLocation="Manual"
        Left="$editorLeft"
        Top="$editorTop"
        ResizeMode="NoResize"
        Background="#F6F8FA">
    <Border Background="#F6F8FA"
            BorderBrush="#B8C0CC"
            BorderThickness="1"
            Padding="12">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <Grid Grid.Row="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="190"/>
                    <ColumnDefinition Width="190"/>
                    <ColumnDefinition Width="260"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Grid Grid.Column="0" Margin="0,0,10,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBlock Name="EditorCategoryLabel" Grid.Row="0" Text="親分類" FontFamily="$fontFamily" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <ListBox Name="EditorCategoryList" Grid.Row="1" FontFamily="$fontFamily" DisplayMemberPath="name"/>
                    <Grid Grid.Row="2" Margin="0,8,0,0">
                        <TextBox Name="EditorCategoryNameBox" FontFamily="$fontFamily"/>
                        <TextBlock Name="EditorCategoryDirtyMark"
                                   Text="*"
                                   Foreground="#9CA3AF"
                                   FontFamily="$fontFamily"
                                   FontWeight="SemiBold"
                                   HorizontalAlignment="Right"
                                   VerticalAlignment="Bottom"
                                   Margin="0,0,4,-1"
                                   Visibility="Collapsed"/>
                    </Grid>
                    <StackPanel Grid.Row="3" Orientation="Horizontal" Margin="0,8,0,0">
                        <Button Name="EditorAddCategoryButton" Content="Add" Width="54" Margin="0,0,6,0"/>
                        <Button Name="EditorDeleteCategoryButton" Content="Delete" Width="64"/>
                    </StackPanel>
                </Grid>
                <Grid Grid.Column="1" Margin="0,0,10,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBlock Name="EditorGroupLabel" Grid.Row="0" Text="中分類" FontFamily="$fontFamily" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <ListBox Name="EditorGroupList" Grid.Row="1" FontFamily="$fontFamily" DisplayMemberPath="name"/>
                    <Grid Grid.Row="2" Margin="0,8,0,0">
                        <TextBox Name="EditorGroupNameBox" FontFamily="$fontFamily"/>
                        <TextBlock Name="EditorGroupDirtyMark"
                                   Text="*"
                                   Foreground="#9CA3AF"
                                   FontFamily="$fontFamily"
                                   FontWeight="SemiBold"
                                   HorizontalAlignment="Right"
                                   VerticalAlignment="Bottom"
                                   Margin="0,0,4,-1"
                                   Visibility="Collapsed"/>
                    </Grid>
                    <StackPanel Grid.Row="3" Orientation="Horizontal" Margin="0,8,0,0">
                        <Button Name="EditorAddGroupButton" Content="Add" Width="54" Margin="0,0,6,0"/>
                        <Button Name="EditorDeleteGroupButton" Content="Delete" Width="64"/>
                    </StackPanel>
                </Grid>
                <Grid Grid.Column="2" Margin="0,0,10,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBlock Grid.Row="0" Text="機能" FontFamily="$fontFamily" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <ListBox Name="EditorFeatureList" Grid.Row="1" FontFamily="$fontFamily" DisplayMemberPath="title"/>
                    <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,8,0,0">
                        <Button Name="EditorAddFeatureButton" Content="Add" Width="54" Margin="0,0,6,0"/>
                        <Button Name="EditorDeleteFeatureButton" Content="Delete" Width="64"/>
                    </StackPanel>
                </Grid>
                <Grid Grid.Column="3">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBlock Grid.Row="0" Text="編集" FontFamily="$fontFamily" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <TextBlock Name="EditorTitleLabel" Grid.Row="1" Text="Title" FontFamily="$fontFamily" Foreground="#6B7280"/>
                    <TextBox Name="EditorTitleBox" Grid.Row="2" FontFamily="$fontFamily" Margin="0,2,0,8"/>
                    <Grid Grid.Row="3" Margin="0,0,0,8">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="100"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <TextBlock Name="EditorBitLabel" Grid.Row="0" Grid.Column="0" Text="Bit" FontFamily="$fontFamily" Foreground="#6B7280"/>
                        <TextBox Name="EditorBitTagBox" Grid.Row="1" Grid.Column="0" FontFamily="$fontFamily" Margin="0,2,8,0"/>
                        <StackPanel Grid.Row="1" Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Margin="0,2,0,0">
                            <CheckBox Name="EditorCopyableBox" Content="copyable" FontFamily="$fontFamily" Margin="0,0,10,0"/>
                            <CheckBox Name="EditorFavoriteBox" Content="favorite" FontFamily="$fontFamily"/>
                        </StackPanel>
                    </Grid>
                    <TextBlock Name="EditorShortcutLabel" Grid.Row="4" Text="Shortcut / Command / Template" FontFamily="$fontFamily" Foreground="#6B7280"/>
                    <TextBox Name="EditorShortcutBox" Grid.Row="5" FontFamily="$fontFamily" Margin="0,2,0,8" AcceptsReturn="True" Height="88" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
                    <TextBlock Name="EditorDescriptionLabel" Grid.Row="6" Text="Description" FontFamily="$fontFamily" Foreground="#6B7280"/>
                    <TextBox Name="EditorDescriptionBox" Grid.Row="7" FontFamily="$fontFamily" Margin="0,2,0,0" AcceptsReturn="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
                    <StackPanel Grid.Row="8" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,8,0,0">
                        <Button Name="EditorSaveButton" Content="Save JSON" Width="92" Margin="0,0,8,0"/>
                        <Button Name="EditorCloseButton" Content="Close" Width="72"/>
                    </StackPanel>
                </Grid>
            </Grid>
            <Grid Grid.Row="1" Margin="0,12,0,0">
                <TextBlock Name="EditorStatusText" FontFamily="$fontFamily" VerticalAlignment="Center" Foreground="#374151"/>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

        $editorReader = [System.Xml.XmlNodeReader]::new($editorXaml)
        $editorWindow = [Windows.Markup.XamlReader]::Load($editorReader)
        if (Test-Path -LiteralPath $script:DefaultHudIconPath) {
            $editorWindow.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create([System.Uri]::new($script:DefaultHudIconPath))
        }
        return $editorWindow
    }

    function Use-EditorWindowControls {
        param([Parameter(Mandatory = $true)][System.Windows.Window]$EditorWindow)

        Set-Variable -Name editorCategoryList -Value $EditorWindow.FindName('EditorCategoryList') -Scope Script
        Set-Variable -Name editorGroupList -Value $EditorWindow.FindName('EditorGroupList') -Scope Script
        Set-Variable -Name editorFeatureList -Value $EditorWindow.FindName('EditorFeatureList') -Scope Script
        Set-Variable -Name editorCategoryLabel -Value $EditorWindow.FindName('EditorCategoryLabel') -Scope Script
        Set-Variable -Name editorGroupLabel -Value $EditorWindow.FindName('EditorGroupLabel') -Scope Script
        Set-Variable -Name editorCategoryDirtyMark -Value $EditorWindow.FindName('EditorCategoryDirtyMark') -Scope Script
        Set-Variable -Name editorGroupDirtyMark -Value $EditorWindow.FindName('EditorGroupDirtyMark') -Scope Script
        Set-Variable -Name editorTitleLabel -Value $EditorWindow.FindName('EditorTitleLabel') -Scope Script
        Set-Variable -Name editorBitLabel -Value $EditorWindow.FindName('EditorBitLabel') -Scope Script
        Set-Variable -Name editorShortcutLabel -Value $EditorWindow.FindName('EditorShortcutLabel') -Scope Script
        Set-Variable -Name editorDescriptionLabel -Value $EditorWindow.FindName('EditorDescriptionLabel') -Scope Script
        Set-Variable -Name editorCategoryNameBox -Value $EditorWindow.FindName('EditorCategoryNameBox') -Scope Script
        Set-Variable -Name editorGroupNameBox -Value $EditorWindow.FindName('EditorGroupNameBox') -Scope Script
        Set-Variable -Name editorAddCategoryButton -Value $EditorWindow.FindName('EditorAddCategoryButton') -Scope Script
        Set-Variable -Name editorDeleteCategoryButton -Value $EditorWindow.FindName('EditorDeleteCategoryButton') -Scope Script
        Set-Variable -Name editorAddGroupButton -Value $EditorWindow.FindName('EditorAddGroupButton') -Scope Script
        Set-Variable -Name editorDeleteGroupButton -Value $EditorWindow.FindName('EditorDeleteGroupButton') -Scope Script
        Set-Variable -Name editorAddFeatureButton -Value $EditorWindow.FindName('EditorAddFeatureButton') -Scope Script
        Set-Variable -Name editorDeleteFeatureButton -Value $EditorWindow.FindName('EditorDeleteFeatureButton') -Scope Script
        Set-Variable -Name editorTitleBox -Value $EditorWindow.FindName('EditorTitleBox') -Scope Script
        Set-Variable -Name editorBitTagBox -Value $EditorWindow.FindName('EditorBitTagBox') -Scope Script
        Set-Variable -Name editorShortcutBox -Value $EditorWindow.FindName('EditorShortcutBox') -Scope Script
        Set-Variable -Name editorCopyableBox -Value $EditorWindow.FindName('EditorCopyableBox') -Scope Script
        Set-Variable -Name editorFavoriteBox -Value $EditorWindow.FindName('EditorFavoriteBox') -Scope Script
        Set-Variable -Name editorDescriptionBox -Value $EditorWindow.FindName('EditorDescriptionBox') -Scope Script
        Set-Variable -Name editorSaveButton -Value $EditorWindow.FindName('EditorSaveButton') -Scope Script
        Set-Variable -Name editorCloseButton -Value $EditorWindow.FindName('EditorCloseButton') -Scope Script
        Set-Variable -Name editorStatusText -Value $EditorWindow.FindName('EditorStatusText') -Scope Script
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
        $editorBitTagBox.Add_LostFocus({ Apply-EditorFeatureFields -DirtyFields @('Bit') })
        $editorShortcutBox.Add_LostFocus({ Apply-EditorFeatureFields -DirtyFields @('Shortcut') })
        $editorDescriptionBox.Add_LostFocus({ Apply-EditorFeatureFields -DirtyFields @('Description') })
        $editorCopyableBox.Add_Click({
            Apply-EditorFeatureFields -DirtyFields @('Shortcut')
            Save-HudJson -Path $script:DefaultHudDataPath -Items @($State.Items)
            Set-EditorDirty $false
            Set-EditorStatus "Saved: $script:DefaultHudDataPath"
            Refresh-HudFavoritePanelsFromEvent
        })
        $editorFavoriteBox.Add_Click({
            Apply-EditorFeatureFields -DirtyFields @()
            Save-HudJson -Path $script:DefaultHudDataPath -Items @($State.Items)
            Set-EditorDirty $false
            Set-EditorStatus "Saved: $script:DefaultHudDataPath"
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
                Set-EditorLabelText -Label $editorTitleLabel -Text 'Title' -Dirty $true
            }
        })
        $editorBitTagBox.Add_TextChanged({
            if (-not $script:HudEditorRefreshing) {
                Set-EditorLabelText -Label $editorBitLabel -Text 'Bit' -Dirty $true
            }
        })
        $editorShortcutBox.Add_TextChanged({
            if (-not $script:HudEditorRefreshing) {
                Set-EditorLabelText -Label $editorShortcutLabel -Text 'Shortcut / Command / Template' -Dirty $true
            }
        })
        $editorDescriptionBox.Add_TextChanged({
            if (-not $script:HudEditorRefreshing) {
                Set-EditorLabelText -Label $editorDescriptionLabel -Text 'Description' -Dirty $true
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
                groups = @([pscustomobject]@{
                    name = 'NewGroup'
                    features = @([pscustomobject]@{
                        title = 'New feature（新しい機能）'
                        bitTag = '1'
                        description = '説明を入力してください。'
                    })
                })
            }
            $State.Items = @($State.Items) + $newCategory
            Refresh-EditorCategoryList
            $editorCategoryList.SelectedIndex = $editorCategoryList.Items.Count - 1
            Set-EditorDirty $true
            Set-EditorStatus 'Added category.'
        })
        $editorDeleteCategoryButton.Add_Click({
            if ($editorCategoryList.SelectedIndex -lt 0) { return }
            $category = Get-EditorSelectedCategory
            $State.Items = @($State.Items | Where-Object { $_ -ne $category })
            Refresh-EditorCategoryList
            Set-EditorDirty $true
            Set-EditorStatus 'Deleted category.'
        })
        $editorAddGroupButton.Add_Click({
            $category = Get-EditorSelectedCategory
            if ($null -eq $category) { return }
            $newGroup = [pscustomobject]@{
                name = 'NewGroup'
                features = @([pscustomobject]@{
                    title = 'New feature（新しい機能）'
                    bitTag = '1'
                    description = '説明を入力してください。'
                })
            }
            Set-HudProperty -Target $category -Name 'groups' -Value (@($category.groups) + $newGroup)
            Refresh-EditorGroupList
            $editorGroupList.SelectedIndex = $editorGroupList.Items.Count - 1
            Set-EditorDirty $true
            Set-EditorStatus 'Added group.'
        })
        $editorDeleteGroupButton.Add_Click({
            $category = Get-EditorSelectedCategory
            $group = Get-EditorSelectedGroup
            if ($null -eq $category -or $null -eq $group) { return }
            Set-HudProperty -Target $category -Name 'groups' -Value @(@($category.groups) | Where-Object { $_ -ne $group })
            Refresh-EditorGroupList
            Set-EditorDirty $true
            Set-EditorStatus 'Deleted group.'
        })
        $editorAddFeatureButton.Add_Click({
            $group = Get-EditorSelectedGroup
            if ($null -eq $group) { return }
            $newFeature = [pscustomobject]@{
                title = 'New feature（新しい機能）'
                bitTag = '1'
                description = '説明を入力してください。'
            }
            Set-HudProperty -Target $group -Name 'features' -Value (@($group.features) + $newFeature)
            Refresh-EditorFeatureList
            $editorFeatureList.SelectedIndex = $editorFeatureList.Items.Count - 1
            Set-EditorDirty $true
            Set-EditorStatus 'Added feature.'
        })
        $editorDeleteFeatureButton.Add_Click({
            $group = Get-EditorSelectedGroup
            $feature = Get-EditorSelectedFeature
            if ($null -eq $group -or $null -eq $feature) { return }
            Set-HudProperty -Target $group -Name 'features' -Value @(@($group.features) | Where-Object { $_ -ne $feature })
            Refresh-EditorFeatureList
            Set-EditorDirty $true
            Set-EditorStatus 'Deleted feature.'
        })
        $editorSaveButton.Add_Click({
            Save-EditorJson
        })
        $editorCloseButton.Add_Click({ Close-EditorPanel })
    }

    function Save-EditorJson {
        Save-EditorCurrentFields
        Save-HudJson -Path $script:DefaultHudDataPath -Items @($State.Items)
        Set-EditorDirty $false
        Set-EditorStatus "Saved: $script:DefaultHudDataPath"
    }

    function Ensure-EditorWindow {
        if ($null -ne $script:HudEditorWindow) {
            return
        }

        $script:HudEditorWindow = New-EditorWindow
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

    function Show-EmptyRecentDetailWindow {
        $recentPathText.Text = '直近 /'
        $recentFeatureTitleText.Text = 'まだ詳細を開いていません'
        $recentShortcutText.Text = ''
        $recentShortcutArea.Visibility = [System.Windows.Visibility]::Collapsed
        $recentCopyShortcutButton.Visibility = [System.Windows.Visibility]::Collapsed
        $recentDescriptionText.Text = '詳細画面を開くと、ここに直近の内容が残ります。'
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
            Show-EmptyRecentDetailWindow
            return
        }

        Update-RecentDetailWindow -Feature $script:HudRecentFeature -CategoryName $script:HudRecentCategoryName -GroupName $script:HudRecentGroupName
    }

    function Set-FavoriteButtonState {
        param([AllowNull()][object]$Feature)

        if ($null -eq $Feature) {
            $favoriteButton.Visibility = [System.Windows.Visibility]::Collapsed
            return
        }

        $favoriteButton.Visibility = [System.Windows.Visibility]::Visible
        if ($Feature.PSObject.Properties.Name -contains 'favorite' -and [bool]$Feature.favorite) {
            $favoriteButton.Content = '★'
            $favoriteButton.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F59E0B')
        }
        else {
            $favoriteButton.Content = '☆'
            $favoriteButton.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6B7280')
        }
    }

    function global:Get-HudFavoriteDefaultMarginFromEvent {
        param([Parameter(Mandatory = $true)][int]$Index)

        $gap = 12
        $stepX = $script:HudFavoritePanelWidth + $gap
        $stepY = $script:HudFavoritePanelHeight + $gap
        $baseX = $script:HudFavoritePanelX
        $baseY = $script:HudFavoritePanelY
        $slots = @()

        $rowOffsets = @(0, -1, 1, -2, 2, -3, 3)
        foreach ($rowOffset in $rowOffsets) {
            $top = $baseY + ($stepY * $rowOffset)
            if ($top -lt 0 -or ($top + $script:HudFavoritePanelHeight) -gt $script:HudFavoriteVisibleHeight) {
                continue
            }

            for ($column = 1; $column -le 20; $column++) {
                $left = $baseX - ($stepX * $column)
                if ($left -lt 0) {
                    break
                }
                $slots += [System.Windows.Thickness]::new($left, $top, 0, 0)
            }

            for ($column = 0; $column -lt 20; $column++) {
                $left = $baseX + $stepX + ($stepX * $column)
                if (($left + $script:HudFavoritePanelWidth) -gt $script:HudFavoriteVisibleWidth) {
                    break
                }
                $slots += [System.Windows.Thickness]::new($left, $top, 0, 0)
            }
        }

        if ($Index -lt $slots.Count) {
            return $slots[$Index]
        }

        $fallbackLeft = [Math]::Max(0, [Math]::Min(
            $script:HudFavoriteVisibleWidth - $script:HudFavoritePanelWidth,
            $baseX - ($stepX * (($Index % 3) + 1))
        ))
        $fallbackTop = [Math]::Max(0, [Math]::Min(
            $script:HudFavoriteVisibleHeight - $script:HudFavoritePanelHeight,
            $baseY + (24 * [Math]::Floor($Index / 3))
        ))
        return [System.Windows.Thickness]::new($fallbackLeft, $fallbackTop, 0, 0)
    }

    function global:Refresh-HudFavoritePanelsFromEvent {
        if ($null -eq $script:HudRoot) {
            $script:HudFavoritePanels = @()
            return
        }

        foreach ($favoritePanel in @($script:HudFavoritePanels)) {
            $featureId = [string]$favoritePanel.Tag
            if (-not [string]::IsNullOrWhiteSpace($featureId)) {
                $script:HudFavoritePanelPositions[$featureId] = $favoritePanel.Margin
            }
            [void]$script:HudRoot.Children.Remove($favoritePanel)
        }
        $script:HudFavoritePanels = @()

        if ($script:HudIsRetreated) {
            return
        }

        $entries = @()
        foreach ($category in @($script:HudState.Items)) {
            foreach ($group in @($category.groups)) {
                foreach ($feature in @($group.features)) {
                    if ($feature.PSObject.Properties.Name -contains 'favorite' -and [bool]$feature.favorite) {
                        $entries += [pscustomobject]@{
                            CategoryName = $category.name
                            GroupName = $group.name
                            Feature = $feature
                        }
                    }
                }
            }
        }

        $index = 0
        foreach ($entry in $entries) {
            $border = [System.Windows.Controls.Border]::new()
            $border.Width = $script:HudFavoritePanelWidth
            $border.Height = $script:HudFavoritePanelHeight
            $border.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
            $border.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
            $featureId = "$($entry.CategoryName)`n$($entry.GroupName)`n$($entry.Feature.title)"
            $border.Tag = $featureId
            if ($script:HudFavoritePanelPositions.ContainsKey($featureId)) {
                $border.Margin = $script:HudFavoritePanelPositions[$featureId]
            }
            else {
                $border.Margin = Get-HudFavoriteDefaultMarginFromEvent -Index $index
            }
            $border.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F6F8FA')
            $border.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#B8C0CC')
            $border.BorderThickness = [System.Windows.Thickness]::new(1)
            $border.Padding = [System.Windows.Thickness]::new(12, 10, 12, 8)

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
            $pathText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#1F2937')
            $pathText.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $border -Event $event }.GetNewClosure())
            [System.Windows.Controls.Grid]::SetRow($pathText, 0)
            [System.Windows.Controls.Grid]::SetColumn($pathText, 0)
            [void]$grid.Children.Add($pathText)

            $favoriteDragHandle = [System.Windows.Controls.TextBlock]::new()
            $favoriteDragHandle.Text = '・・・'
            $favoriteDragHandle.Width = 28
            $favoriteDragHandle.Height = 20
            $favoriteDragHandle.TextAlignment = [System.Windows.TextAlignment]::Center
            $favoriteDragHandle.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#9CA3AF')
            $favoriteDragHandle.FontFamily = $script:HudFavoriteFontFamily
            $favoriteDragHandle.FontSize = $script:HudFavoriteFilterFontSize
            $favoriteDragHandle.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $border -Event $event }.GetNewClosure())
            [System.Windows.Controls.Grid]::SetRow($favoriteDragHandle, 0)
            [System.Windows.Controls.Grid]::SetColumn($favoriteDragHandle, 1)
            [void]$grid.Children.Add($favoriteDragHandle)

            $unfavoriteButton = [System.Windows.Controls.Button]::new()
            $unfavoriteButton.Content = '★'
            $unfavoriteButton.Width = 24
            $unfavoriteButton.Height = 20
            $unfavoriteButton.Padding = [System.Windows.Thickness]::new(0)
            $unfavoriteButton.BorderThickness = [System.Windows.Thickness]::new(0)
            $unfavoriteButton.Background = [System.Windows.Media.Brushes]::Transparent
            $unfavoriteButton.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F59E0B')
            $unfavoriteButton.FontFamily = $script:HudFavoriteFontFamily
            $unfavoriteButton.FontSize = $script:HudFavoriteTitleFontSize
            $unfavoriteButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
            $unfavoriteButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
            $unfavoriteButton.Add_Click({
                param($sender, $event)
                $entry.Feature.PSObject.Properties.Remove('favorite')
                Save-HudJsonFromEvent -Items @($script:HudState.Items)
                if ($script:HudState.SelectedFeature -eq $entry.Feature) {
                    Set-FavoriteButtonStateFromEvent -Feature $entry.Feature
                }
                Refresh-HudFavoritePanelsFromEvent
                $event.Handled = $true
            }.GetNewClosure())
            [System.Windows.Controls.Grid]::SetRow($unfavoriteButton, 0)
            [System.Windows.Controls.Grid]::SetColumn($unfavoriteButton, 2)
            [void]$grid.Children.Add($unfavoriteButton)

            $titleText = [System.Windows.Controls.TextBlock]::new()
            $titleText.Text = [string]$entry.Feature.title
            $titleText.FontFamily = $script:HudFavoriteFontFamily
            $titleText.FontSize = $script:HudFavoriteFeatureTitleFontSize
            $titleText.FontWeight = [System.Windows.FontWeights]::SemiBold
            $titleText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#111827')
            $titleText.TextWrapping = [System.Windows.TextWrapping]::Wrap
            $titleText.Margin = [System.Windows.Thickness]::new(0, 4, 0, 8)
            $titleText.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $border -Event $event }.GetNewClosure())
            [System.Windows.Controls.Grid]::SetRow($titleText, 1)
            [System.Windows.Controls.Grid]::SetColumnSpan($titleText, 3)
            [void]$grid.Children.Add($titleText)

            $shortcutArea = [System.Windows.Controls.Grid]::new()
            $shortcutArea.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
            $shortcutArea.RowDefinitions[0].Height = [System.Windows.GridLength]::Auto
            $shortcutArea.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
            $shortcutArea.RowDefinitions[1].Height = [System.Windows.GridLength]::Auto
            [System.Windows.Controls.Grid]::SetRow($shortcutArea, 2)
            [System.Windows.Controls.Grid]::SetColumnSpan($shortcutArea, 3)

            $shortcutLabel = [System.Windows.Controls.TextBlock]::new()
            $shortcutLabel.Text = 'Shortcut:'
            $shortcutLabel.FontFamily = $script:HudFavoriteFontFamily
            $shortcutLabel.FontSize = $script:HudFavoriteFilterFontSize
            $shortcutLabel.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6B7280')
            $shortcutLabel.Margin = [System.Windows.Thickness]::new(0, 0, 0, 4)
            [System.Windows.Controls.Grid]::SetRow($shortcutLabel, 0)
            [void]$shortcutArea.Children.Add($shortcutLabel)

            $shortcutBorder = [System.Windows.Controls.Border]::new()
            $shortcutBorder.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#E5E7EB')
            $shortcutBorder.CornerRadius = [System.Windows.CornerRadius]::new(4)
            $shortcutBorder.Padding = [System.Windows.Thickness]::new(10, 5, 10, 5)
            $shortcutBorder.Margin = [System.Windows.Thickness]::new(0, 0, 0, 12)
            $shortcutBorder.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
            [System.Windows.Controls.Grid]::SetRow($shortcutBorder, 1)

            $shortcutGrid = [System.Windows.Controls.Grid]::new()
            $shortcutGrid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
            $shortcutGrid.ColumnDefinitions[0].Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
            $shortcutGrid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
            $shortcutGrid.ColumnDefinitions[1].Width = [System.Windows.GridLength]::Auto

            $shortcutTextBox = [System.Windows.Controls.TextBox]::new()
            $shortcutTextBox.Text = [string]$entry.Feature.shortcut
            $shortcutTextBox.FontFamily = $script:HudFavoriteFontFamily
            $shortcutTextBox.FontSize = $script:HudFavoriteTitleFontSize
            $shortcutTextBox.FontWeight = [System.Windows.FontWeights]::SemiBold
            $shortcutTextBox.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#111827')
            $shortcutTextBox.Background = [System.Windows.Media.Brushes]::Transparent
            $shortcutTextBox.BorderThickness = [System.Windows.Thickness]::new(0)
            $shortcutTextBox.Padding = [System.Windows.Thickness]::new(0, 1, 0, 1)
            $shortcutTextBox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
            $shortcutTextBox.IsReadOnly = $true
            $shortcutTextBox.IsReadOnlyCaretVisible = $false
            [System.Windows.Controls.Grid]::SetColumn($shortcutTextBox, 0)
            [void]$shortcutGrid.Children.Add($shortcutTextBox)

            $copyButton = [System.Windows.Controls.Button]::new()
            $copyButton.Content = 'Copy'
            $copyButton.Width = 40
            $copyButton.Height = 20
            $copyButton.Padding = [System.Windows.Thickness]::new(6, 0, 6, 0)
            $copyButton.BorderThickness = [System.Windows.Thickness]::new(0)
            $copyButton.Background = [System.Windows.Media.Brushes]::Transparent
            $copyButton.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6B7280')
            $copyButton.FontFamily = $script:HudFavoriteFontFamily
            $copyButton.FontSize = $script:HudFavoriteFilterFontSize
            $copyButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
            $copyButton.Add_Click({
                param($sender, $event)
                try {
                    [System.Windows.Clipboard]::SetText($shortcutTextBox.Text)
                    $sender.Content = 'OK'
                }
                catch {
                    $sender.Content = 'Failed'
                }
            }.GetNewClosure())
            [System.Windows.Controls.Grid]::SetColumn($copyButton, 1)
            [void]$shortcutGrid.Children.Add($copyButton)

            $shortcutBorder.Child = $shortcutGrid
            [void]$shortcutArea.Children.Add($shortcutBorder)
            if ([string]::IsNullOrWhiteSpace([string]$entry.Feature.shortcut)) {
                $shortcutArea.Visibility = [System.Windows.Visibility]::Collapsed
            }
            [void]$grid.Children.Add($shortcutArea)

            $descriptionGrid = [System.Windows.Controls.Grid]::new()
            $descriptionGrid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
            $descriptionGrid.RowDefinitions[0].Height = [System.Windows.GridLength]::Auto
            $descriptionGrid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
            $descriptionGrid.RowDefinitions[1].Height = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
            [System.Windows.Controls.Grid]::SetRow($descriptionGrid, 3)
            [System.Windows.Controls.Grid]::SetColumnSpan($descriptionGrid, 3)

            $descriptionLabel = [System.Windows.Controls.TextBlock]::new()
            $descriptionLabel.Text = 'Description:'
            $descriptionLabel.FontFamily = $script:HudFavoriteFontFamily
            $descriptionLabel.FontSize = $script:HudFavoriteFilterFontSize
            $descriptionLabel.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6B7280')
            $descriptionLabel.Margin = [System.Windows.Thickness]::new(0, 0, 0, 4)
            [System.Windows.Controls.Grid]::SetRow($descriptionLabel, 0)
            [void]$descriptionGrid.Children.Add($descriptionLabel)

            $descriptionTextBox = [System.Windows.Controls.TextBox]::new()
            $descriptionTextBox.Text = [string]$entry.Feature.description
            $descriptionTextBox.FontFamily = $script:HudFavoriteFontFamily
            $descriptionTextBox.FontSize = $script:HudFavoriteDetailFontSize
            $descriptionTextBox.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#374151')
            $descriptionTextBox.Background = [System.Windows.Media.Brushes]::Transparent
            $descriptionTextBox.BorderThickness = [System.Windows.Thickness]::new(0)
            $descriptionTextBox.Padding = [System.Windows.Thickness]::new(0)
            $descriptionTextBox.IsReadOnly = $true
            $descriptionTextBox.IsReadOnlyCaretVisible = $false
            $descriptionTextBox.TextWrapping = [System.Windows.TextWrapping]::Wrap
            $descriptionTextBox.AcceptsReturn = $true
            $descriptionTextBox.VerticalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Auto
            $descriptionTextBox.HorizontalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Disabled
            [System.Windows.Controls.Grid]::SetRow($descriptionTextBox, 1)
            [void]$descriptionGrid.Children.Add($descriptionTextBox)
            [void]$grid.Children.Add($descriptionGrid)

            $border.Child = $grid
            $border.Add_MouseMove({ param($sender, $event) Move-HudPanelDrag -Event $event }.GetNewClosure())
            $border.Add_MouseLeftButtonUp({ param($sender, $event) Stop-HudPanelDrag -Event $event }.GetNewClosure())
            [void]$script:HudRoot.Children.Add($border)
            $script:HudFavoritePanels += $border
            $index++
        }
    }

    function global:Toggle-HudFavoriteFromDetail {
        if ($script:HudState.Level -ne 'Detail' -or $null -eq $script:HudState.SelectedFeature) {
            return
        }

        $feature = $script:HudState.SelectedFeature
        if ($feature.PSObject.Properties.Name -contains 'favorite' -and [bool]$feature.favorite) {
            $feature.PSObject.Properties.Remove('favorite')
        }
        else {
            Set-HudPropertyFromEvent -Target $feature -Name 'favorite' -Value $true
        }

        Save-HudJsonFromEvent -Items @($script:HudState.Items)
        Set-FavoriteButtonStateFromEvent -Feature $feature
        Refresh-HudFavoritePanelsFromEvent
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
            Set-FavoriteButtonState -Feature $State.SelectedFeature
        }
        else {
            $filter.Text = "Text: $($State.TextFilter)"
            $filterRow.Height = [System.Windows.GridLength]::Auto
            $title.FontSize = $titleFontSize
            $featureTitle.Visibility = [System.Windows.Visibility]::Collapsed
            $featureTitle.Text = ''
            Set-FavoriteButtonState -Feature $null
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
        while ($null -ne $source) {
            if ($source -is [System.Windows.Controls.Button] -or $source -is [System.Windows.Controls.TextBox]) {
                return
            }
            if ($script:HudFavoritePanels -contains $source) {
                return
            }
            if ($source -is [System.Windows.FrameworkElement] -and $source.Name -in @('TitleMarkerText', 'TitleText', 'MainDragHandle', 'RecentPathText', 'RecentFeatureTitleText', 'RecentDragHandle')) {
                return
            }
            $source = [System.Windows.Media.VisualTreeHelper]::GetParent($source)
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

        if ($null -ne $script:HudEditorWindow -and $script:HudEditorWindow.IsVisible) {
            return
        }

        if ([System.Windows.Input.Keyboard]::Modifiers -band [System.Windows.Input.ModifierKeys]::Control) {
            return
        }

        $key = if ($Event.Key -eq [System.Windows.Input.Key]::System) { $Event.SystemKey } else { $Event.Key }

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
    $titleMarker.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $panel -Event $event }.GetNewClosure())
    $title.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $panel -Event $event }.GetNewClosure())
    $mainDragHandle.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $panel -Event $event }.GetNewClosure())
    $panel.Add_MouseMove({ param($sender, $event) Move-HudPanelDrag -Event $event }.GetNewClosure())
    $panel.Add_MouseLeftButtonUp({ param($sender, $event) Stop-HudPanelDrag -Event $event }.GetNewClosure())
    $recentPathText.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $recentPanel -Event $event }.GetNewClosure())
    $recentFeatureTitleText.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $recentPanel -Event $event }.GetNewClosure())
    $recentDragHandle.Add_MouseLeftButtonDown({ param($sender, $event) Start-HudPanelDrag -Target $recentPanel -Event $event }.GetNewClosure())
    $recentPanel.Add_MouseMove({ param($sender, $event) Move-HudPanelDrag -Event $event }.GetNewClosure())
    $recentPanel.Add_MouseLeftButtonUp({ param($sender, $event) Stop-HudPanelDrag -Event $event }.GetNewClosure())
    $minimizeButton.Add_Click({ Hide-HudSession })
    $editItemsButton.Add_Click({ Show-EditorPanel })
    $favoriteButton.Add_Click({ Toggle-HudFavoriteFromDetail })
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

#endregion src/UI/MainWindow.ps1

#region src/App/Run.ps1
$items = Read-HudJson -Path $script:DefaultHudDataPath
$settings = Read-HudSettings -Path $script:DefaultHudSettingsPath
$state = New-HudState -Items @($items)
Show-HudWindow -State $state -Settings $settings

#endregion src/App/Run.ps1

