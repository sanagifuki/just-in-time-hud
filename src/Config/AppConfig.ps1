$script:AppName = 'Just-in-Time HUD'
$script:DefaultHudSampleDataPath = Join-Path $script:AppRoot 'data\hud-items.sample.json'
$script:DefaultHudDataPath = if ($script:HudDevelopmentMode) {
    $script:DefaultHudSampleDataPath
}
else {
    Join-Path $script:AppRoot 'hud-items.json'
}
$script:DefaultHudSettingsPath = Join-Path $script:AppRoot 'settings.jsonc'
$script:DefaultHudStatePath = Join-Path $script:AppRoot 'hud-state.json'
$script:DefaultHudIconPath = Join-Path $script:AppRoot 'assets\icon.ico'
