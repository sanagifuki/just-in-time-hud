function global:Test-HudMemoSource {
    param([AllowNull()][object]$Source)

    if ($null -eq $script:HudMemoTextBox -or $null -eq $Source) {
        return $false
    }
    if ($Source -eq $script:HudMemoTextBox) {
        return $true
    }
    if ($Source -isnot [System.Windows.DependencyObject]) {
        return $false
    }

    return $script:HudMemoTextBox.IsAncestorOf($Source)
}

function global:Move-HudMemoFocusToRoot {
    if ($null -eq $script:HudMemoTextBox -or $null -eq $script:HudRoot) {
        return
    }

    $focusScope = [System.Windows.Input.FocusManager]::GetFocusScope($script:HudMemoTextBox)
    [System.Windows.Input.FocusManager]::SetFocusedElement($focusScope, $null)
    [System.Windows.Input.Keyboard]::ClearFocus()
    $script:HudRoot.Focus() | Out-Null
    [System.Windows.Input.Keyboard]::Focus($script:HudRoot) | Out-Null
}

function global:Bring-HudMemoPanelToFront {
    if ($null -ne $script:HudMemoPanel) {
        Bring-HudPanelToFront -Panel $script:HudMemoPanel
    }
}

function global:Focus-HudMemo {
    if ($null -eq $script:HudMemoPanel -or $null -eq $script:HudMemoTextBox) {
        return
    }

    $script:HudMemoPanel.Visibility = [System.Windows.Visibility]::Visible
    Bring-HudMemoPanelToFront
    $script:HudMemoTextBox.Focus() | Out-Null
    [System.Windows.Input.Keyboard]::Focus($script:HudMemoTextBox) | Out-Null
    $script:HudMemoTextBox.CaretIndex = $script:HudMemoTextBox.Text.Length
}

function global:Add-HudMemoPanelContextMenu {
    if ($null -eq $script:HudMemoPanel) {
        return
    }

    $menu = [System.Windows.Controls.ContextMenu]::new()
    $bringToFrontItem = [System.Windows.Controls.MenuItem]::new()
    $bringToFrontItem.Header = '最前面に表示'
    $bringToFrontItem.Add_Click({
        param($sender, $event)
        Bring-HudMemoPanelToFront
        $event.Handled = $true
    })
    [void]$menu.Items.Add($bringToFrontItem)
    $script:HudMemoPanel.ContextMenu = $menu
}
