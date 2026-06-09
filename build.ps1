param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot 'build.manifest.psd1'),
    [string]$OutputPath = (Join-Path $PSScriptRoot 'dist\JustInTimeHud.ps1')
)

$ErrorActionPreference = 'Stop'
$manifest = Import-PowerShellDataFile -LiteralPath $ManifestPath
$repoRoot = Split-Path -Parent $ManifestPath

$builder = [System.Text.StringBuilder]::new()
[void]$builder.AppendLine('# Auto-generated from src/*.ps1 by build.ps1.')
[void]$builder.AppendLine('# Edit files under src/ instead of this generated file.')
try {
    $commit = git -C $repoRoot rev-parse --short HEAD 2>$null
    [void]$builder.AppendLine("# Source commit: $commit")
}
catch {
    [void]$builder.AppendLine('# Source commit: unknown')
}
[void]$builder.AppendLine()

$dataPath = Join-Path $repoRoot 'data\hud-items.sample.json'
if (-not (Test-Path -LiteralPath $dataPath)) {
    throw 'HUD data file not found: data\hud-items.sample.json'
}
[void]$builder.AppendLine('$script:EmbeddedHudDataJson = @''')
[void]$builder.Append((Get-Content -LiteralPath $dataPath -Raw -Encoding UTF8))
[void]$builder.AppendLine()
[void]$builder.AppendLine('''@')
[void]$builder.AppendLine()

$settingsPath = Join-Path $repoRoot 'settings.jsonc'
if (-not (Test-Path -LiteralPath $settingsPath)) {
    throw 'HUD settings file not found: settings.jsonc'
}
[void]$builder.AppendLine('$script:EmbeddedHudSettingsJsonc = @''')
[void]$builder.Append((Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8))
[void]$builder.AppendLine()
[void]$builder.AppendLine('''@')
[void]$builder.AppendLine()

foreach ($relativePath in $manifest.SourceFiles) {
    $path = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Source file not found: $relativePath"
    }
    [void]$builder.AppendLine("#region $relativePath")
    [void]$builder.Append((Get-Content -LiteralPath $path -Raw -Encoding UTF8))
    [void]$builder.AppendLine()
    [void]$builder.AppendLine("#endregion $relativePath")
    [void]$builder.AppendLine()
}

$outputDir = Split-Path -Parent $OutputPath
if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

$utf8Bom = [System.Text.UTF8Encoding]::new($true)
$fullOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
[System.IO.File]::WriteAllText($fullOutputPath, $builder.ToString(), $utf8Bom)
Write-Host "Built: $OutputPath"


