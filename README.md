# shun198-mac-setup

Apple Silicon (Mシリーズ) Mac 向けの初期セットアップキットです。

## このリポジトリで管理するもの

- Homebrew 経由の CLI ツールと GUI アプリ (`Brewfile`)
- 開発向けの主要 macOS 設定 (`scripts/macos.sh`)
- 移行用の現行 Mac スナップショット (`scripts/snapshot-current-mac.sh`)
- `~/.zshrc` の管理・移行 (`dotfiles/.zshrc`, `scripts/install-zshrc.sh`)
- セットアップ後の検証 (`scripts/verify.sh`)
- 自動化しない手作業の整理 (`manual-checklist.md`)

## 対応範囲

- 対応アーキテクチャ: `arm64` のみ（Mシリーズ）
- 非対応: Intel Mac

## ファイル構成

- `scripts/bootstrap.sh`: 新規 Mac セットアップのエントリーポイント
- `scripts/macos.sh`: 管理対象の macOS 設定を適用
- `scripts/snapshot-current-mac.sh`: 現在の Mac 状態を移行用データとして出力
- `scripts/update-brewfile-from-snapshot.sh`: スナップショットから Brewfile 更新候補を生成
- `scripts/install-zshrc.sh`: 管理対象の `~/.zshrc` を適用
- `scripts/verify.sh`: セットアップ後の状態を検証
- `Brewfile`: パッケージ/アプリの宣言的リスト
- `dotfiles/.zshrc`: 管理対象の zsh 設定ファイル
- `manual-checklist.md`: 手動で実施する項目

## 使い方

### 1) 現行 Mac のスナップショットを取得

現在使っている Mac で実行して、状態を出力します。

```bash
bash scripts/snapshot-current-mac.sh
```

出力は `snapshots/<timestamp>/` 配下に生成されます。

### 2) 管理対象の設定を見直して更新

- `bash scripts/update-brewfile-from-snapshot.sh` で更新候補を確認
- 残したいものを確認した上で `bash scripts/update-brewfile-from-snapshot.sh --apply` を実行
- `snapshots/<timestamp>/zshrc.current` を `dotfiles/.zshrc` に反映
- `scripts/macos.sh` の defaults 設定を調整

### 3) 新しい Mシリーズ Mac をセットアップ

新しい Mac 側で実行します。

```bash
bash scripts/bootstrap.sh
```

管理者権限が必要な処理で毎回パスワード入力したくない場合は、sudo セッション維持オプションを使えます（開始時に1回だけ認証）。

```bash
bash scripts/bootstrap.sh --with-sudo-session
```

### スナップショットを Brewfile に反映

スナップショットの最新ディレクトリを使って、Brewfile の更新差分を確認できます。Mac App Store アプリも `mas` エントリに変換されます。

```bash
bash scripts/update-brewfile-from-snapshot.sh
```

内容を確認して反映する場合は、`--apply` を付けます。実行時に確認が入り、更新前の Brewfile は `snapshots/` 配下へバックアップされます。

```bash
bash scripts/update-brewfile-from-snapshot.sh --apply
```

特定のスナップショットを指定することもできます。

```bash
bash scripts/update-brewfile-from-snapshot.sh --snapshot snapshots/<timestamp> --apply
```

Mac App Store アプリのインストールには、新 Mac 側で Apple ID にサインインしている必要があります。

> 注意: `brew` を root/sudo で直接実行する構成ではありません。`bootstrap.sh` 自体も sudo では実行しないでください。

### 4) 検証

```bash
bash scripts/verify.sh
```

### 5) 手動チェックリストを実施

`manual-checklist.md` に沿って残り作業を進めてください。

## 個別実行コマンド

必要な処理だけを個別に実行できます。

### Brewfile のインストールだけ実行

```bash
brew bundle --file ./Brewfile
```

### Brewfile の不足チェックだけ実行（インストールなし）

```bash
brew bundle check --file ./Brewfile
```

### `~/.zshrc` の適用だけ実行

```bash
bash scripts/install-zshrc.sh
```

### macOS 設定（defaults）だけ適用

```bash
bash scripts/macos.sh
```

### 検証だけ実行

```bash
bash scripts/verify.sh
```

### スナップショットだけ取得

```bash
bash scripts/snapshot-current-mac.sh
```
