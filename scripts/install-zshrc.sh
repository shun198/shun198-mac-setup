#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ZSHRC="$ROOT_DIR/dotfiles/.zshrc"
TARGET_ZSHRC="$HOME/.zshrc"

if [[ ! -f "$SOURCE_ZSHRC" ]]; then
  echo "No managed zshrc found at: $SOURCE_ZSHRC"
  echo "Skip installing ~/.zshrc"
  exit 0
fi

if [[ -f "$TARGET_ZSHRC" ]] && cmp -s "$SOURCE_ZSHRC" "$TARGET_ZSHRC"; then
  echo "~/.zshrc is already up-to-date."
  exit 0
fi

if [[ -f "$TARGET_ZSHRC" ]]; then
  BACKUP_PATH="$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
  cp "$TARGET_ZSHRC" "$BACKUP_PATH"
  echo "Existing ~/.zshrc was backed up to: $BACKUP_PATH"
fi

cp "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
echo "Installed ~/.zshrc from $SOURCE_ZSHRC"
