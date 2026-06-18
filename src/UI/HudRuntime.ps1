function global:Save-HudJsonFromEvent {
    param([AllowNull()][object[]]$Items)

    if ($null -eq $Items) {
        if ($null -eq $script:HudState -or $null -eq $script:HudState.Items) {
            return
        }
        $Items = @($script:HudState.Items)
    }

    $directory = Split-Path -Parent $script:DefaultHudDataPath
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    $json = @($Items) | ConvertTo-Json -Depth 20
    $path = [System.IO.Path]::GetFullPath($script:DefaultHudDataPath)
    [System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($true))
}
