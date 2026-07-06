#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="$ROOT_DIR/snapshots/$TIMESTAMP"

mkdir -p "$OUT_DIR"

echo "Creating snapshot at: $OUT_DIR"

if command -v brew >/dev/null 2>&1; then
  brew bundle dump --file "$OUT_DIR/Brewfile.current" --force
else
  echo "Homebrew is not installed, skipping Brewfile export."
fi

if command -v mas >/dev/null 2>&1; then
  mas list > "$OUT_DIR/mas.list"
else
  echo "mas is not installed, skipping App Store app export."
fi

{
  echo "arch=$(uname -m)"
  echo "macos_version=$(sw_vers -productVersion)"
  echo "macos_build=$(sw_vers -buildVersion)"
} > "$OUT_DIR/system.txt"

defaults read -g > "$OUT_DIR/defaults-global.txt" 2>/dev/null || true
defaults read com.apple.finder > "$OUT_DIR/defaults-finder.txt" 2>/dev/null || true
defaults read com.apple.dock > "$OUT_DIR/defaults-dock.txt" 2>/dev/null || true

ls /Applications > "$OUT_DIR/applications.txt"

if [[ -f "$HOME/.zshrc" ]]; then
  cp "$HOME/.zshrc" "$OUT_DIR/zshrc.current"
else
  echo "~/.zshrc not found, skipping zshrc snapshot."
fi

echo "Snapshot completed."
echo "Review files under: $OUT_DIR"
