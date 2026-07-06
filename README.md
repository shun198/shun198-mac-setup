# shun198-mac-setup

Apple Silicon (Mシリーズ) Mac 向けの初期セットアップキットです。

## このリポジトリで管理するもの

- Homebrew 経由の CLI ツールと GUI アプリ (`Brewfile`)
- 開発向けの主要 macOS 設定 (`scripts/macos.sh`)
- 移行用の現行 Mac スナップショット (`scripts/snapshot-current-mac.sh`)
- セットアップ後の検証 (`scripts/verify.sh`)
- 自動化しない手作業の整理 (`manual-checklist.md`)

## 対応範囲

- 対応アーキテクチャ: `arm64` のみ（Mシリーズ）
- 非対応: Intel Mac

## ファイル構成

- `scripts/bootstrap.sh`: 新規 Mac セットアップのエントリーポイント
- `scripts/macos.sh`: 管理対象の macOS 設定を適用
- `scripts/snapshot-current-mac.sh`: 現在の Mac 状態を移行用データとして出力
- `scripts/verify.sh`: セットアップ後の状態を検証
- `Brewfile`: パッケージ/アプリの宣言的リスト
- `manual-checklist.md`: 手動で実施する項目

## 使い方

### 1) 現行 Mac のスナップショットを取得

現在使っている Mac で実行して、状態を出力します。

```bash
bash scripts/snapshot-current-mac.sh
```

出力は `snapshots/<timestamp>/` 配下に生成されます。

### 2) 管理対象の設定を見直して更新

- `snapshots/<timestamp>/Brewfile.current` を確認
- 残したいものだけ `Brewfile` に反映
- `scripts/macos.sh` の defaults 設定を調整

### 3) 新しい Mシリーズ Mac をセットアップ

新しい Mac 側で実行します。

```bash
bash scripts/bootstrap.sh
```

### 4) 検証

```bash
bash scripts/verify.sh
```

### 5) 手動チェックリストを実施

`manual-checklist.md` に沿って残り作業を進めてください。