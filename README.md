# Just-in-Time HUD

Just-in-Time HUD は、OS・アプリ・エディタが既に持っている標準機能のショートカット、操作手順、記法を、必要なタイミングで素早く参照するための PowerShell / .NET WinForms 製 HUD です。

独自の効率化機能を追加するのではなく、既存機能への到達時間を短縮することを目的にしています。

## 方針

- インストール不要で動作する
- 管理者権限を要求しない
- Windows 標準機能と PowerShell / .NET で構成する
- グローバルキーフックや常時入力監視に依存しない
- 開発時は `src/` 配下の分割ファイルで編集し、配布時は単一 `.ps1` にまとめる

## 開発起動

```powershell
.\run-dev.ps1
```

## 単一ファイル生成

```powershell
.\build.ps1
```

既定では `dist/JustInTimeHud.ps1` を生成します。

## 検証

```powershell
.\verify.ps1
```

## 設定

`settings.jsonc` でHUDパネルの表示座標と、全画面入力面の背景RGBAを変更できます。

```json
{
  "panelX": 32,
  "panelY": 96,
  "panelWidth": 420,
  "panelHeight": 360,
  "fontFamily": "Yu Gothic UI",
  "titleFontSize": 15,
  "detailTitleFontSize": 15,
  "featureTitleFontSize": 15,
  "filterFontSize": 12,
  "listFontSize": 14,
  "detailFontSize": 12,
  "bitLabels": {
    "one": "L",
    "zero": "R"
  },
  "backgroundRgba": {
    "r": 255,
    "g": 255,
    "b": 255,
    "a": 0.01
  }
}
```

`backgroundRgba.a` は `0.0` から `1.0`、または `0` から `255` で指定できます。
`bitLabels.one` は左クリック、`bitLabels.zero` は右クリックの表示文字です。内部の絞り込み値は `1` / `0` のまま扱います。

## 構成

- `src/App/`: 起動処理
- `src/Config/`: アプリ設定
- `src/Domain/`: HUDデータと遷移モデル
- `src/Infrastructure/`: JSON読み込み
- `src/UI/`: WinForms UI
- `data/`: HUD項目サンプル
