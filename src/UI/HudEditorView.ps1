function global:New-HudEditorWindow {
    param(
        [Parameter(Mandatory = $true)][double]$Left,
        [Parameter(Mandatory = $true)][double]$Top,
        [Parameter(Mandatory = $true)][string]$FontFamily
    )

    [xml]$editorXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="HUD Item Editor"
        Width="920"
        Height="620"
        WindowStartupLocation="Manual"
        Left="$Left"
        Top="$Top"
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
                    <TextBlock Name="EditorCategoryLabel" Grid.Row="0" Text="親分類" FontFamily="$FontFamily" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <ListBox Name="EditorCategoryList" Grid.Row="1" FontFamily="$FontFamily" DisplayMemberPath="name"/>
                    <Grid Grid.Row="2" Margin="0,8,0,0">
                        <TextBox Name="EditorCategoryNameBox" FontFamily="$FontFamily"/>
                        <TextBlock Name="EditorCategoryDirtyMark"
                                   Text="*"
                                   Foreground="#9CA3AF"
                                   FontFamily="$FontFamily"
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
                    <TextBlock Name="EditorGroupLabel" Grid.Row="0" Text="中分類" FontFamily="$FontFamily" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <ListBox Name="EditorGroupList" Grid.Row="1" FontFamily="$FontFamily" DisplayMemberPath="name"/>
                    <Grid Grid.Row="2" Margin="0,8,0,0">
                        <TextBox Name="EditorGroupNameBox" FontFamily="$FontFamily"/>
                        <TextBlock Name="EditorGroupDirtyMark"
                                   Text="*"
                                   Foreground="#9CA3AF"
                                   FontFamily="$FontFamily"
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
                    <TextBlock Grid.Row="0" Text="機能" FontFamily="$FontFamily" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <ListBox Name="EditorFeatureList" Grid.Row="1" FontFamily="$FontFamily" DisplayMemberPath="title"/>
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
                    <TextBlock Grid.Row="0" Text="編集" FontFamily="$FontFamily" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <TextBlock Name="EditorTitleLabel" Grid.Row="1" Text="Title:" FontFamily="$FontFamily" Foreground="#6B7280"/>
                    <TextBox Name="EditorTitleBox" Grid.Row="2" FontFamily="$FontFamily" Margin="0,2,0,8"/>
                    <Grid Grid.Row="3" Margin="0,0,0,8">
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="0,2,0,0">
                            <CheckBox Name="EditorCopyableBox" Content="copyable" FontFamily="$FontFamily" Margin="0,0,10,0"/>
                            <CheckBox Name="EditorFavoriteBox" Content="favorite" FontFamily="$FontFamily"/>
                        </StackPanel>
                    </Grid>
                    <StackPanel Grid.Row="4" Orientation="Horizontal">
                        <TextBlock Name="EditorShortcutLabel" Text="Snippets:" FontFamily="$FontFamily" Foreground="#6B7280"/>
                        <TextBlock Text="※「---」で別Snippetとして追加"
                                   FontFamily="$FontFamily"
                                   Foreground="#9CA3AF"
                                   Margin="8,0,0,0"/>
                    </StackPanel>
                    <TextBox Name="EditorShortcutBox" Grid.Row="5" FontFamily="$FontFamily" Margin="0,2,0,8" AcceptsReturn="True" Height="88" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" ToolTip="複数に分ける場合は、区切り行として --- を入れる。本文中に --- だけの行を入れる場合は \--- と書く"/>
                    <TextBlock Name="EditorDescriptionLabel" Grid.Row="6" Text="Description:" FontFamily="$FontFamily" Foreground="#6B7280"/>
                    <TextBox Name="EditorDescriptionBox" Grid.Row="7" FontFamily="$FontFamily" Margin="0,2,0,0" AcceptsReturn="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
                    <StackPanel Grid.Row="8" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,8,0,0">
                        <Button Name="EditorSaveButton" Content="Save JSON" Width="92" Margin="0,0,8,0"/>
                        <Button Name="EditorCloseButton" Content="Close" Width="72"/>
                    </StackPanel>
                </Grid>
            </Grid>
            <Grid Grid.Row="1" Margin="0,12,0,0">
                <TextBlock Name="EditorStatusText" FontFamily="$FontFamily" VerticalAlignment="Center" Foreground="#374151"/>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

    $reader = [System.Xml.XmlNodeReader]::new($editorXaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    if (Test-Path -LiteralPath $script:DefaultHudIconPath) {
        $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create([System.Uri]::new($script:DefaultHudIconPath))
    }
    return $window
}

function global:New-EditorDefaultFeature {
    return [pscustomobject]@{
        title = 'New feature（新しい機能）'
        description = '説明を入力してください。'
    }
}

function global:New-EditorDefaultGroup {
    return [pscustomobject]@{
        name = 'NewGroup'
        features = @(New-EditorDefaultFeature)
    }
}

function global:Use-EditorWindowControls {
    param([Parameter(Mandatory = $true)][System.Windows.Window]$EditorWindow)

    Set-Variable -Name editorCategoryList -Value $EditorWindow.FindName('EditorCategoryList') -Scope Script
    Set-Variable -Name editorGroupList -Value $EditorWindow.FindName('EditorGroupList') -Scope Script
    Set-Variable -Name editorFeatureList -Value $EditorWindow.FindName('EditorFeatureList') -Scope Script
    Set-Variable -Name editorCategoryLabel -Value $EditorWindow.FindName('EditorCategoryLabel') -Scope Script
    Set-Variable -Name editorGroupLabel -Value $EditorWindow.FindName('EditorGroupLabel') -Scope Script
    Set-Variable -Name editorCategoryDirtyMark -Value $EditorWindow.FindName('EditorCategoryDirtyMark') -Scope Script
    Set-Variable -Name editorGroupDirtyMark -Value $EditorWindow.FindName('EditorGroupDirtyMark') -Scope Script
    Set-Variable -Name editorTitleLabel -Value $EditorWindow.FindName('EditorTitleLabel') -Scope Script
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
    Set-Variable -Name editorShortcutBox -Value $EditorWindow.FindName('EditorShortcutBox') -Scope Script
    Set-Variable -Name editorCopyableBox -Value $EditorWindow.FindName('EditorCopyableBox') -Scope Script
    Set-Variable -Name editorFavoriteBox -Value $EditorWindow.FindName('EditorFavoriteBox') -Scope Script
    Set-Variable -Name editorDescriptionBox -Value $EditorWindow.FindName('EditorDescriptionBox') -Scope Script
    Set-Variable -Name editorSaveButton -Value $EditorWindow.FindName('EditorSaveButton') -Scope Script
    Set-Variable -Name editorCloseButton -Value $EditorWindow.FindName('EditorCloseButton') -Scope Script
    Set-Variable -Name editorStatusText -Value $EditorWindow.FindName('EditorStatusText') -Scope Script
}
