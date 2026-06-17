# Auto-generated from src/*.ps1 by build.ps1.
# Edit files under src/ instead of this generated file.
# Source commit: da6ddeb

$script:HudSingleFile = $true

$script:EmbeddedHudDataJson = @'
[
  {
    "name": "JustInTimeHUD",
    "groups": [
      {
        "name": "Prompt",
        "features": [
          {
            "title": "Format memo prompt（メモ整理プロンプト）",
            "snippets": [
              "以下のユーザ記載情報を、次の出力形式・ルールを元に、認知負荷が少ない情報として整理してください。\n\n## 作業情報(ユーザ記載)\n\n<内容>\n\n## 出力形式\n\n- 親分類: 作業領域や用途の大きなまとまり。\n- 中分類: 親分類の中で、具体的な作業種類や場面を分ける分類。\n- 機能名: 後から探すときの項目名。「English title（日本語説明）」形式にする。\n- 主要情報(Snippets): 実際にコピーして使うコマンド、定型文、手順、参照情報。複数ある場合は分けて書く。\n- 説明(Description): 主要情報の具体的な説明(何のために使うかなど)や補足情報などを説明する。\n\n## 出力例\n\n```\n- 親分類: `Terminal`\n- 中分類: `Git`\n- 機能名: `Status（変更状況の確認コマンド）`\n- 主要情報(Snippets):\n    ```\n    git status --short\n    ---\n    git diff --stat\n    ```\n- 説明(Description): \n    ```\n    コミット前に、作業ツリーの変更状況と差分の概要を確認するために使う。\n    ```\n```\n\n## ルール\n\n- 内容から用途を推測し、後から探しやすい分類名にする。\n- 親分類と中分類は、広すぎず細かすぎない粒度にする。\n- 機能名は「English title（日本語説明）」形式にする。\n- English title は、分類名ではなく、キー入力で探しやすい、機能を表す短い単語から始める。\n- English title は、親分類名や中分類名と同じ語で始めない。(例: `Git Status`ではなく`Status`)\n- 主要情報(Snippets)には、実際に再利用する本文だけを書く。\n- 主要情報(Snippets)が複数ある場合は、「---」だけの行で区切る。\n- 説明(Description)には、主要情報の目的、使う場面、注意点を簡潔に書く。\n- 不明な点がある場合は、足りない情報だけを質問する。"
            ],
            "description": "雑に書いた内容を、分類・機能名・主要情報・説明へ整理するためのプロンプト。",
            "copyable": true,
            "favorite": true
          }
        ]
      },
      {
        "name": "Instructions",
        "features": [
          {
            "title": "Overview（概要）",
            "description": "Just-In-Time HUDは、よく使うコマンド、定型文、手順、参照情報を、必要な瞬間に短い操作で呼び出すためのHUDです。\n\n情報は「親分類 / 中分類 / 機能」の3階層で整理します。親分類はサービス名や作業領域くらいの大きなまとまり、中分類はその中の用途、機能は実際に呼び出す項目です。\n\n機能名は「English title（日本語説明）」形式にすると、キー入力で探しやすくなります。English titleは分類名ではなく、機能を表す短い単語から始めると使いやすいです。"
          },
          {
            "title": "Navigate（基本操作）",
            "snippets": [
              "キー入力: 候補を絞り込み",
              "左クリック: 上へ移動\n右クリック: 下へ移動",
              "Tab: 選択中に遷移\n1/2/3: 上から選択",
              "Esc: 入力リセット / 前の画面へ戻る\nSpace: HUDを退避"
            ],
            "description": "親分類・中分類・機能リストで使う基本操作です。\n\nキー入力で候補を絞り込み、候補が1件になると自動で次へ進みます。`左クリック/右クリック`は選択位置の移動、`Tab`と`1/2/3`は選択中項目への遷移に使います。\n\n`Esc`は入力リセットや前の画面へ戻る操作です。`Space`はHUDを退避します。"
          },
          {
            "title": "Edit items（項目編集）",
            "description": "右上のEditから項目編集画面を開けます。各機能を追加・削除できます。\n\n- Title: 後から探すときの機能名です。「English title（日本語説明）」形式にすると、キー入力で探しやすくなります。\n- Snippets: 実際にコピーして使うコマンド、定型文、手順、参照情報です。「---」だけの行で区切ると、複数Snippetとして登録されます。\n- Description: Snippetsの目的、使う場面、注意点などの補足説明です。メモとして活用できます。\n- copyable: 有効にすると、各Snippetに`Copy`ボタンが表示されます。favoriteを有効にすると、お気に入りウィンドウとして常に表示されるようになります。"
          },
          {
            "title": "Read detail（詳細画面）",
            "snippets": [
              "Copy: 対象Snippetをクリップボードへコピー",
              "Ctrl+C: 選択中のテキストをコピー"
            ],
            "description": "詳細画面では、機能名、Snippets、Descriptionを確認できます。\n\nSnippetsは、コピーして使うコマンド、定型文、手順、参照情報です。`Copy`ボタンが表示されている場合は、押すとそのSnippetをクリップボードへコピーします。`Ctrl+C`で選択中のテキストをコピーすることもできます。\n\n長いSnippetsやDescriptionはスクロールして確認できます。Snippetごとの最大表示高さは`settings.jsonc`の`snippetMaxHeight`で調整できます。"
          },
          {
            "title": "Settings（設定）",
            "description": "`settings.jsonc`で、HUDの座標、サイズ、フォント、背景色、Snippet最大表示高さを調整できます。\n\n各項目の説明は、`settings.jsonc`内にコメントで記載されています。\n\n配布用の単一ファイルを使う場合、`hud-items.json`と`settings.jsonc`が同じフォルダに無ければ初回起動時に自動生成されます。"
          }
        ]
      }
    ]
  },
  {
    "name": "Git",
    "groups": [
      {
        "name": "Working tree",
        "features": [
          {
            "title": "Status（変更状況の確認コマンド）",
            "snippets": [
              "git status --short",
              "git diff --stat",
              "git diff"
            ],
            "description": "コミット前に、作業ツリーの変更状況や差分を確認するためのコマンド。",
            "copyable": true
          },
          {
            "title": "Restore（変更取り消しコマンド）",
            "snippets": [
              "git restore <file>",
              "git restore --staged <file>",
              "git clean -nd"
            ],
            "description": "作業ツリーやステージ済み変更を戻すときのコマンド。`git clean -nd`は削除対象の確認用。",
            "copyable": true
          }
        ]
      },
      {
        "name": "Commit",
        "features": [
          {
            "title": "Stage（ステージングコマンド）",
            "snippets": [
              "git add <file>",
              "git add .",
              "git reset <file>"
            ],
            "description": "コミット対象をステージへ追加・解除するためのコマンド。",
            "copyable": true
          },
          {
            "title": "Commit（コミット作成コマンド）",
            "snippets": [
              "git commit -m \"<message>\"",
              "git commit --amend"
            ],
            "description": "コミットを作成・修正するためのコマンド。",
            "copyable": true
          }
        ]
      }
    ]
  }
]
'@

$script:EmbeddedHudSettingsJsonc = @'
{
  // HUDを表示するモニター番号。0始まり。
  "displayMonitorIndex": 1,

  // HUDパネル左上の表示座標。
  "panelX": 1480,
  "panelY": 20,

  // 直近詳細HUDの左上の表示座標。
  "recentPanelX": 1480,
  "recentPanelY": 395,

  // メイン、直近、お気に入りの各HUDパネル共通サイズ。
  "panelWidth": 420,
  "panelHeight": 360,

  // 直近詳細HUDを表示するか。
  "showRecentPanel": true,

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

  // Snippets 1件あたりの最大表示高さ。超えた分はバー非表示でスクロール可能。
  "snippetMaxHeight": 80,

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
    public const int MDT_EFFECTIVE_DPI = 0;
    public const int MONITOR_DEFAULTTONEAREST = 2;

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT
    {
        public int x;
        public int y;
    }

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern IntPtr MonitorFromPoint(POINT pt, uint dwFlags);

    [DllImport("shcore.dll")]
    public static extern int GetDpiForMonitor(IntPtr hmonitor, int dpiType, out uint dpiX, out uint dpiY);

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
        if ($script:HudSingleFile -and $script:EmbeddedHudDataJson) {
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
        displayMonitorIndex = 0
        panelX = 32
        panelY = 96
        recentPanelX = 464
        recentPanelY = 96
        panelWidth = 420
        panelHeight = 360
        showRecentPanel = $true
        fontFamily = 'Yu Gothic UI'
        titleFontSize = 15
        detailTitleFontSize = 15
        featureTitleFontSize = 15
        filterFontSize = 12
        listFontSize = 14
        detailFontSize = 12
        snippetMaxHeight = 80
        backgroundRgba = [pscustomobject]@{
            r = 255
            g = 255
            b = 255
            a = 1
        }
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($script:HudSingleFile -and $script:EmbeddedHudSettingsJsonc) {
            Write-HudTextFileIfMissing -Path $Path -Text $script:EmbeddedHudSettingsJsonc
        }
        else {
            return $defaults
        }
    }

    $settings = Remove-JsoncComments -Text (Get-Content -LiteralPath $Path -Raw -Encoding UTF8) | ConvertFrom-Json
    foreach ($name in @('displayMonitorIndex', 'panelX', 'panelY', 'recentPanelX', 'recentPanelY', 'panelWidth', 'panelHeight', 'showRecentPanel', 'fontFamily', 'titleFontSize', 'detailTitleFontSize', 'featureTitleFontSize', 'filterFontSize', 'listFontSize', 'detailFontSize', 'snippetMaxHeight')) {
        if ($null -eq $settings.$name) {
            $settings | Add-Member -NotePropertyName $name -NotePropertyValue $defaults.$name -Force
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

    $candidates = [System.Collections.Generic.List[object]]::new()
    $filter = [string]$State.TextFilter

    switch ($State.Level) {
        'Root' {
            foreach ($item in @($State.Items)) {
                $name = [string]$item.name
                if ($filter -and -not $name.StartsWith($filter, [System.StringComparison]::OrdinalIgnoreCase)) {
                    continue
                }
                $candidates.Add([pscustomobject]@{ Label = $name; Value = $item })
            }
        }
        'Group' {
            foreach ($item in @($State.SelectedCategory.groups)) {
                $name = [string]$item.name
                if ($filter -and -not $name.StartsWith($filter, [System.StringComparison]::OrdinalIgnoreCase)) {
                    continue
                }
                $candidates.Add([pscustomobject]@{ Label = $name; Value = $item })
            }
        }
        'Feature' {
            foreach ($item in @($State.SelectedGroup.features)) {
                $title = [string]$item.title
                if ($filter -and -not (Test-HudInitialMatch -Text $title -Filter $filter)) {
                    continue
                }
                $candidates.Add([pscustomobject]@{ Label = $title; Value = $item })
            }
        }
        'Detail' {
            return @([pscustomobject]@{ Label = $State.SelectedFeature.title; Value = $State.SelectedFeature })
        }
    }

    return $candidates.ToArray()
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

    $initials = [System.Text.StringBuilder]::new()
    $previousIsAsciiWord = $false
    foreach ($char in $Text.ToCharArray()) {
        $code = [int][char]$char
        $isAsciiWord = (
            ($code -ge 48 -and $code -le 57) -or
            ($code -ge 65 -and $code -le 90) -or
            ($code -ge 97 -and $code -le 122)
        )

        if ($isAsciiWord -and -not $previousIsAsciiWord) {
            [void]$initials.Append($char)
        }
        $previousIsAsciiWord = $isAsciiWord
    }

    return $initials.ToString().StartsWith($Filter, [System.StringComparison]::OrdinalIgnoreCase)
}

function Reset-HudFilter {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$State
    )

    $State.TextFilter = ''
}

#endregion src/Domain/HudModel.ps1

#region src/UI/HudControls.ps1
function New-HudReadOnlyTextBox {
    param(
        [AllowNull()][string]$Text,
        [Parameter(Mandatory = $true)][string]$FontFamily,
        [Parameter(Mandatory = $true)][double]$FontSize,
        [Parameter(Mandatory = $true)][System.Windows.Media.Brush]$Foreground,
        [System.Windows.FontWeight]$FontWeight = [System.Windows.FontWeights]::Normal,
        [System.Windows.Thickness]$Padding = [System.Windows.Thickness]::new(0),
        [double]$MaxHeight = -1,
        [System.Windows.Controls.ScrollBarVisibility]$VerticalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Disabled
    )

    $textBox = [System.Windows.Controls.TextBox]::new()
    $textBox.Text = [string]$Text
    $textBox.FontFamily = $FontFamily
    $textBox.FontSize = $FontSize
    $textBox.FontWeight = $FontWeight
    $textBox.Foreground = $Foreground
    $textBox.Background = [System.Windows.Media.Brushes]::Transparent
    $textBox.BorderThickness = [System.Windows.Thickness]::new(0)
    $textBox.Padding = $Padding
    $textBox.IsReadOnly = $true
    $textBox.IsReadOnlyCaretVisible = $false
    $textBox.AcceptsReturn = $true
    $textBox.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $textBox.VerticalScrollBarVisibility = $VerticalScrollBarVisibility
    $textBox.HorizontalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Disabled

    if ($MaxHeight -ge 0) {
        $textBox.MaxHeight = $MaxHeight
    }

    return $textBox
}

function New-HudFlatButton {
    param(
        [Parameter(Mandatory = $true)][object]$Content,
        [double]$Width = -1,
        [double]$Height = -1,
        [double]$MinHeight = -1,
        [Parameter(Mandatory = $true)][string]$FontFamily,
        [Parameter(Mandatory = $true)][double]$FontSize,
        [Parameter(Mandatory = $true)][System.Windows.Media.Brush]$Foreground,
        [System.Windows.Media.Brush]$Background = [System.Windows.Media.Brushes]::Transparent,
        [System.Windows.Thickness]$Padding = [System.Windows.Thickness]::new(0)
    )

    $button = [System.Windows.Controls.Button]::new()
    $button.Content = $Content
    if ($Width -ge 0) { $button.Width = $Width }
    if ($Height -ge 0) { $button.Height = $Height }
    if ($MinHeight -ge 0) { $button.MinHeight = $MinHeight }
    $button.Padding = $Padding
    $button.BorderThickness = [System.Windows.Thickness]::new(0)
    $button.Background = $Background
    $button.Foreground = $Foreground
    $button.FontFamily = $FontFamily
    $button.FontSize = $FontSize
    return $button
}

function Test-HudProperty {
    param(
        [AllowNull()][object]$Target,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return ($null -ne $Target -and $null -ne $Target.PSObject.Properties[$Name])
}

function Remove-HudProperty {
    param(
        [AllowNull()][object]$Target,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if (Test-HudProperty -Target $Target -Name $Name) {
        $Target.PSObject.Properties.Remove($Name)
    }
}

function Remove-HudArrayItem {
    param(
        [AllowNull()][object[]]$Items,
        [AllowNull()][object]$RemoveItem
    )

    $remaining = [System.Collections.Generic.List[object]]::new()
    foreach ($item in @($Items)) {
        if ($item -ne $RemoveItem) {
            $remaining.Add($item)
        }
    }
    return $remaining.ToArray()
}

function Get-HudTextLineCount {
    param([AllowNull()][string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return 1
    }

    $count = 1
    $index = 0
    while ($index -lt $Text.Length) {
        $char = $Text[$index]
        if ($char -eq "`r") {
            $count++
            if (($index + 1) -lt $Text.Length -and $Text[$index + 1] -eq "`n") {
                $index++
            }
        }
        elseif ($char -eq "`n") {
            $count++
        }
        $index++
    }
    return $count
}

function Set-HudListBoxItems {
    param(
        [Parameter(Mandatory = $true)][System.Windows.Controls.ListBox]$ListBox,
        [AllowNull()][object[]]$Items,
        [AllowNull()][object]$Selected
    )

    $ListBox.Items.Clear()
    foreach ($item in @($Items)) {
        [void]$ListBox.Items.Add($item)
    }

    if ($null -ne $Selected -and @($Items) -contains $Selected) {
        $ListBox.SelectedItem = $Selected
    }
    elseif ($ListBox.Items.Count -gt 0) {
        $ListBox.SelectedIndex = 0
    }
}

function Get-HudScreenDipBounds {
    param([Parameter(Mandatory = $true)][System.Drawing.Rectangle]$Bounds)

    $dpiX = [uint32]96
    $dpiY = [uint32]96
    try {
        $point = [HudNativeMethods+POINT]::new()
        $point.x = $Bounds.Left
        $point.y = $Bounds.Top
        $monitor = [HudNativeMethods]::MonitorFromPoint($point, [HudNativeMethods]::MONITOR_DEFAULTTONEAREST)
        if ($monitor -ne [IntPtr]::Zero) {
            [void][HudNativeMethods]::GetDpiForMonitor($monitor, [HudNativeMethods]::MDT_EFFECTIVE_DPI, [ref]$dpiX, [ref]$dpiY)
        }
    }
    catch {
        $dpiX = [uint32]96
        $dpiY = [uint32]96
    }

    $scaleX = [Math]::Max(0.1, [double]$dpiX / 96.0)
    $scaleY = [Math]::Max(0.1, [double]$dpiY / 96.0)

    return [pscustomobject]@{
        Left = [double]$Bounds.Left / $scaleX
        Top = [double]$Bounds.Top / $scaleY
        Width = [double]$Bounds.Width / $scaleX
        Height = [double]$Bounds.Height / $scaleY
        ScaleX = $scaleX
        ScaleY = $scaleY
    }
}

#endregion src/UI/HudControls.ps1

#region src/UI/MainWindow.ps1
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
    $panelX = [Math]::Max(0, [Math]::Min($visibleWidth - $panelWidth, $panelX))
    $panelY = [Math]::Max(0, [Math]::Min($visibleHeight - $panelHeight, $panelY))
    $recentPanelX = [Math]::Max(0, [Math]::Min($visibleWidth - $panelWidth, $recentPanelX))
    $recentPanelY = [Math]::Max(0, [Math]::Min($visibleHeight - $panelHeight, $recentPanelY))
    $showRecentPanel = [bool]$Settings.showRecentPanel
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

    function Set-HudProperty {
        param(
            [Parameter(Mandatory = $true)]
            [object]$Target,
            [Parameter(Mandatory = $true)]
            [string]$Name,
            [object]$Value
        )

        if (Test-HudProperty -Target $Target -Name $Name) {
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

        Set-HudProperty -Target $Target -Name $Name -Value $Value
    }

    function global:Get-HudFeatureSnippets {
        param([AllowNull()][object]$Feature)

        if ($null -eq $Feature) {
            return @()
        }

        $snippets = [System.Collections.Generic.List[object]]::new()
        $featureCopyable = (Test-HudProperty -Target $Feature -Name 'copyable') -and [bool]$Feature.copyable
        if ((Test-HudProperty -Target $Feature -Name 'snippets') -and $null -ne $Feature.snippets) {
            foreach ($snippet in @($Feature.snippets)) {
                $text = if ($snippet -is [string]) { [string]$snippet } else { [string]$snippet.text }
                if ([string]::IsNullOrWhiteSpace($text)) { continue }
                $snippets.Add([pscustomobject]@{
                    text = $text
                    copyable = $featureCopyable
                })
            }
            return $snippets.ToArray()
        }

        if ((Test-HudProperty -Target $Feature -Name 'shortcut') -and -not [string]::IsNullOrWhiteSpace([string]$Feature.shortcut)) {
            return @([pscustomobject]@{
                text = [string]$Feature.shortcut
                copyable = $featureCopyable
            })
        }

        return @()
    }

    function Set-HudFeatureSnippetsFromText {
        param(
            [Parameter(Mandatory = $true)][object]$Feature,
            [AllowNull()][string]$Text,
            [bool]$Copyable
        )

        Remove-HudProperty -Target $Feature -Name 'shortcut'

        if ([string]::IsNullOrWhiteSpace($Text)) {
            Remove-HudProperty -Target $Feature -Name 'snippets'
            Remove-HudProperty -Target $Feature -Name 'copyable'
            return
        }

        $splitText = [regex]::Replace($Text.Trim(), "(?m)^(\s*)\\---(\s*)$", '$1__HUD_ESCAPED_SNIPPET_DELIMITER__$2')
        $parts = [regex]::Split($splitText, "(?m)^\s*---\s*$")
        $snippets = [System.Collections.Generic.List[string]]::new()
        foreach ($part in $parts) {
            $snippetText = $part.Trim().Replace('__HUD_ESCAPED_SNIPPET_DELIMITER__', '---')
            if ([string]::IsNullOrWhiteSpace($snippetText)) { continue }
            $snippets.Add($snippetText)
        }

        if ($snippets.Count -gt 0) {
            Set-HudProperty -Target $Feature -Name 'snippets' -Value @($snippets.ToArray())
            if ($Copyable) {
                Set-HudProperty -Target $Feature -Name 'copyable' -Value $true
            }
            else { Remove-HudProperty -Target $Feature -Name 'copyable' }
        }
        else { Remove-HudProperty -Target $Feature -Name 'snippets' }
    }

    function Format-HudSnippetTextForEditor {
        param([AllowNull()][string]$Text)

        if ($null -eq $Text) { return '' }
        return [regex]::Replace([string]$Text, "(?m)^(\s*)---(\s*)$", '$1\---$2')
    }

    function Join-HudSnippetTextsForEditor {
        param([AllowNull()][object[]]$Snippets)

        $texts = [System.Collections.Generic.List[string]]::new()
        foreach ($snippet in @($Snippets)) {
            $texts.Add((Format-HudSnippetTextForEditor -Text ([string]$snippet.text)))
        }
        return [string]::Join("`r`n---`r`n", $texts.ToArray())
    }

    function global:Add-HudSnippetRows {
        param(
            [Parameter(Mandatory = $true)][System.Windows.Controls.Panel]$Target,
            [Parameter(Mandatory = $true)][object[]]$Snippets
        )

        $Target.Children.Clear()
        $snippetIndex = 0
        foreach ($snippet in $Snippets) {
            $snippetBorder = [System.Windows.Controls.Border]::new()
            $snippetBorder.Background = $script:HudBrushSnippetBackground
            $snippetBorder.CornerRadius = [System.Windows.CornerRadius]::new(4)
            $snippetBorder.Padding = [System.Windows.Thickness]::new(10, 5, 10, 5)
            $bottomMargin = if ($snippetIndex -lt ($Snippets.Count - 1)) { 8 } else { 0 }
            $snippetBorder.Margin = [System.Windows.Thickness]::new(0, 0, 0, $bottomMargin)
            $snippetBorder.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left

            $snippetGrid = [System.Windows.Controls.Grid]::new()
            $snippetGrid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
            $snippetGrid.ColumnDefinitions[0].Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
            $snippetGrid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]::new())
            $snippetGrid.ColumnDefinitions[1].Width = [System.Windows.GridLength]::Auto

            $snippetTextBox = New-HudReadOnlyTextBox `
                -Text ([string]$snippet.text) `
                -FontFamily $script:HudFavoriteFontFamily `
                -FontSize $script:HudFavoriteTitleFontSize `
                -Foreground $script:HudBrushTextStrong `
                -FontWeight ([System.Windows.FontWeights]::SemiBold) `
                -Padding ([System.Windows.Thickness]::new(0, 1, 0, 1)) `
                -MaxHeight $script:HudSnippetMaxHeight `
                -VerticalScrollBarVisibility ([System.Windows.Controls.ScrollBarVisibility]::Hidden)
            $snippetTextBox.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
            [System.Windows.Controls.Grid]::SetColumn($snippetTextBox, 0)
            [void]$snippetGrid.Children.Add($snippetTextBox)

            $lineCount = Get-HudTextLineCount -Text ([string]$snippet.text)
            $copyLabel = if ($lineCount -le 3) {
                'cp'
            }
            else {
                "c`no`np`ny"
            }
            $copyOkLabel = if ($lineCount -le 3) {
                'ok'
            }
            else {
                "o`nk"
            }
            $copyNgLabel = if ($lineCount -le 3) {
                'ng'
            }
            else {
                "n`ng"
            }
            $snippetCopyButton = New-HudFlatButton `
                -Content $copyLabel `
                -Width 22 `
                -MinHeight 20 `
                -FontFamily $script:HudFavoriteFontFamily `
                -FontSize $script:HudFavoriteFilterFontSize `
                -Foreground $script:HudBrushTextNormal `
                -Background $script:HudBrushSnippetCopyBackground
            $snippetCopyButton.Tag = [pscustomobject]@{
                Copy = $copyLabel
                Ok = $copyOkLabel
                Ng = $copyNgLabel
            }
            $snippetCopyButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
            $snippetCopyButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
            $snippetCopyButton.Margin = [System.Windows.Thickness]::new(8, -5, -10, -5)
            if (-not [bool]$snippet.copyable) {
                $snippetCopyButton.Visibility = [System.Windows.Visibility]::Collapsed
            }
            $snippetCopyButton.Add_Click({
                param($sender, $event)
                $copyLabels = $sender.Tag
                try {
                    [System.Windows.Clipboard]::SetText($snippetTextBox.Text)
                    $sender.Content = $copyLabels.Ok
                }
                catch {
                    $sender.Content = $copyLabels.Ng
                }
                $copyResetTimer = [System.Windows.Threading.DispatcherTimer]::new()
                $copyResetTimer.Interval = [TimeSpan]::FromMilliseconds(900)
                $copyResetTimer.Add_Tick({
                    param($timerSender, $timerEvent)
                    $timerSender.Stop()
                    $sender.Content = $sender.Tag.Copy
                }.GetNewClosure())
                $copyResetTimer.Start()
                $event.Handled = $true
            }.GetNewClosure())
            [System.Windows.Controls.Grid]::SetColumn($snippetCopyButton, 1)
            [void]$snippetGrid.Children.Add($snippetCopyButton)

            $snippetBorder.Child = $snippetGrid
            [void]$Target.Children.Add($snippetBorder)
            $snippetIndex++
        }
    }

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
        if ((Test-HudProperty -Target $Feature -Name 'favorite') -and [bool]$Feature.favorite) {
            $script:HudFavoriteButton.Content = '★'
            $script:HudFavoriteButton.Foreground = $script:HudBrushFavoriteStar
        }
        else {
            $script:HudFavoriteButton.Content = '☆'
            $script:HudFavoriteButton.Foreground = $script:HudBrushTextMuted
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

    function Get-HudClampedPanelMargin {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.FrameworkElement]$Target,

            [Parameter(Mandatory = $true)]
            [double]$Left,

            [Parameter(Mandatory = $true)]
            [double]$Top
        )

        $targetWidth = if ($Target.ActualWidth -gt 0) { $Target.ActualWidth } else { $Target.Width }
        $targetHeight = if ($Target.ActualHeight -gt 0) { $Target.ActualHeight } else { $Target.Height }
        if ([double]::IsNaN($targetWidth) -or $targetWidth -le 0) { $targetWidth = $script:HudFavoritePanelWidth }
        if ([double]::IsNaN($targetHeight) -or $targetHeight -le 0) { $targetHeight = $script:HudFavoritePanelHeight }

        $maxLeft = [Math]::Max(0, $script:HudFavoriteVisibleWidth - $targetWidth)
        $maxTop = [Math]::Max(0, $script:HudFavoriteVisibleHeight - $targetHeight)
        $clampedLeft = [Math]::Max(0, [Math]::Min($maxLeft, $Left))
        $clampedTop = [Math]::Max(0, [Math]::Min($maxTop, $Top))
        return [System.Windows.Thickness]::new($clampedLeft, $clampedTop, 0, 0)
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

    function New-EditorDefaultFeature {
        return [pscustomobject]@{
            title = 'New feature（新しい機能）'
            description = '説明を入力してください。'
        }
    }

    function New-EditorDefaultGroup {
        return [pscustomobject]@{
            name = 'NewGroup'
            features = @(New-EditorDefaultFeature)
        }
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
                    <TextBlock Name="EditorTitleLabel" Grid.Row="1" Text="Title:" FontFamily="$fontFamily" Foreground="#6B7280"/>
                    <TextBox Name="EditorTitleBox" Grid.Row="2" FontFamily="$fontFamily" Margin="0,2,0,8"/>
                    <Grid Grid.Row="3" Margin="0,0,0,8">
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="0,2,0,0">
                            <CheckBox Name="EditorCopyableBox" Content="copyable" FontFamily="$fontFamily" Margin="0,0,10,0"/>
                            <CheckBox Name="EditorFavoriteBox" Content="favorite" FontFamily="$fontFamily"/>
                        </StackPanel>
                    </Grid>
                    <StackPanel Grid.Row="4" Orientation="Horizontal">
                        <TextBlock Name="EditorShortcutLabel" Text="Snippets:" FontFamily="$fontFamily" Foreground="#6B7280"/>
                        <TextBlock Text="※「---」で別Snippetとして追加"
                                   FontFamily="$fontFamily"
                                   Foreground="#9CA3AF"
                                   Margin="8,0,0,0"/>
                    </StackPanel>
                    <TextBox Name="EditorShortcutBox" Grid.Row="5" FontFamily="$fontFamily" Margin="0,2,0,8" AcceptsReturn="True" Height="88" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" ToolTip="複数に分ける場合は、区切り行として --- を入れる。本文中に --- だけの行を入れる場合は \--- と書く"/>
                    <TextBlock Name="EditorDescriptionLabel" Grid.Row="6" Text="Description:" FontFamily="$fontFamily" Foreground="#6B7280"/>
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

    function Set-RecentPanelVisibility {
        param([bool]$Visible)

        if (-not $script:HudShowRecentPanel -or -not $Visible -or $script:HudIsRetreated) {
            $recentPanel.Visibility = [System.Windows.Visibility]::Collapsed
            return
        }

        $recentPanel.Visibility = [System.Windows.Visibility]::Visible
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

        $snippets = @(Get-HudFeatureSnippets -Feature $Feature)
        if ($snippets.Count -gt 0) {
            Add-HudSnippetRows -Target $recentSnippetList -Snippets $snippets
            $recentShortcutArea.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $recentSnippetList.Children.Clear()
            $recentShortcutArea.Visibility = [System.Windows.Visibility]::Collapsed
        }

        Set-RecentPanelVisibility -Visible $true
    }

    function Update-RecentHistoryNav {
        $count = @($script:HudRecentHistory).Count
        if ($count -le 0) {
            $recentHistoryText.Text = '0/0'
            $recentPrevButton.IsEnabled = $false
            $recentNextButton.IsEnabled = $false
            return
        }

        $recentHistoryText.Text = "$($script:HudRecentHistoryIndex + 1)/$count"
        $recentPrevButton.IsEnabled = ($count -gt 1)
        $recentNextButton.IsEnabled = ($count -gt 1)
    }

    function Show-EmptyRecentDetailWindow {
        $recentPathText.Text = '直近 /'
        $recentFeatureTitleText.Text = 'まだ詳細を開いていません'
        $recentSnippetList.Children.Clear()
        $recentShortcutArea.Visibility = [System.Windows.Visibility]::Collapsed
        $recentDescriptionText.Text = '詳細画面を開くと、ここに直近の内容が残ります。'
        Update-RecentHistoryNav
        Set-RecentPanelVisibility -Visible $true
    }

    function Show-RecentHistoryEntry {
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

    function Set-RecentDetail {
        param(
            [Parameter(Mandatory = $true)]
            [object]$Feature
        )

        $entry = [pscustomobject]@{
            Feature = $Feature
            CategoryName = $State.SelectedCategory.name
            GroupName = $State.SelectedGroup.name
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

    function Show-RecentDetailIfAvailable {
        if (@($script:HudRecentHistory).Count -le 0) {
            Show-EmptyRecentDetailWindow
            return
        }

        Show-RecentHistoryEntry
    }

    function Move-RecentHistory {
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

    function Set-FavoriteButtonState {
        param([AllowNull()][object]$Feature)

        if ($null -eq $Feature) {
            $favoriteButton.Visibility = [System.Windows.Visibility]::Collapsed
            return
        }

        $favoriteButton.Visibility = [System.Windows.Visibility]::Visible
        if ((Test-HudProperty -Target $Feature -Name 'favorite') -and [bool]$Feature.favorite) {
            $favoriteButton.Content = '★'
            $favoriteButton.Foreground = $script:HudBrushFavoriteStar
        }
        else {
            $favoriteButton.Content = '☆'
            $favoriteButton.Foreground = $script:HudBrushTextMuted
        }
    }

    function global:Get-HudFavoriteDefaultMarginFromEvent {
        param([Parameter(Mandatory = $true)][int]$Index)

        $gap = 12
        $stepX = $script:HudFavoritePanelWidth + $gap
        $stepY = $script:HudFavoritePanelHeight + $gap
        $baseX = $script:HudFavoritePanelX
        $baseY = $script:HudFavoritePanelY
        $slots = [System.Collections.Generic.List[object]]::new()

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
                $slots.Add([System.Windows.Thickness]::new($left, $top, 0, 0))
            }

            for ($column = 0; $column -lt 20; $column++) {
                $left = $baseX + $stepX + ($stepX * $column)
                if (($left + $script:HudFavoritePanelWidth) -gt $script:HudFavoriteVisibleWidth) {
                    break
                }
                $slots.Add([System.Windows.Thickness]::new($left, $top, 0, 0))
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
            $script:HudFavoritePanels = [System.Collections.Generic.List[object]]::new()
            return
        }

        if ($script:HudIsRetreated) {
            foreach ($favoritePanel in @($script:HudFavoritePanels)) {
                $favoritePanel.Visibility = [System.Windows.Visibility]::Collapsed
            }
            return
        }

        foreach ($favoritePanel in @($script:HudFavoritePanels)) {
            $featureId = [string]$favoritePanel.Tag
            if (-not [string]::IsNullOrWhiteSpace($featureId)) {
                $script:HudFavoritePanelPositions[$featureId] = $favoritePanel.Margin
            }
            [void]$script:HudRoot.Children.Remove($favoritePanel)
        }
        $script:HudFavoritePanels = [System.Collections.Generic.List[object]]::new()

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
                $savedMargin = $script:HudFavoritePanelPositions[$featureId]
                $border.Margin = $savedMargin
            }
            else {
                $defaultMargin = Get-HudFavoriteDefaultMarginFromEvent -Index $index
                $border.Margin = Get-HudClampedPanelMargin -Target $border -Left $defaultMargin.Left -Top $defaultMargin.Top
            }
            $border.Background = $script:HudBrushPanelBackground
            $border.BorderBrush = $script:HudBrushPanelBorder
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
                Refresh-HudFavoritePanelsFromEvent
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
            $index++
        }
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
            Set-HudPropertyFromEvent -Target $feature -Name 'favorite' -Value $true
        }

        Save-HudJsonFromEvent
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
            if ($source -is [System.Windows.FrameworkElement] -and $source.Name -in @('MainHeaderDragArea', 'TitleMarkerText', 'TitleText', 'MainDragHandle', 'RecentPathText', 'RecentFeatureTitleDragArea', 'RecentFeatureTitleText', 'RecentDragHandle')) {
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
    $minimizeButton.Add_Click({ Hide-HudSession })
    $editItemsButton.Add_Click({ Show-EditorPanel })
    $favoriteButton.Add_Click({ Toggle-HudFavoriteFromDetail })
    $closeButton.Add_Click({ $window.Close() })
    $recentCloseButton.Add_Click({ $recentPanel.Visibility = [System.Windows.Visibility]::Collapsed })
    $recentPrevButton.Add_Click({ Move-RecentHistory -Delta 1 })
    $recentNextButton.Add_Click({ Move-RecentHistory -Delta -1 })
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

