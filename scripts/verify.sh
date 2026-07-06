#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "Expected Apple Silicon (arm64), got: $(uname -m)"
  exit 1
fi

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  echo "Homebrew not found at /opt/homebrew/bin/brew"
  exit 1
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Checking Homebrew bundle state..."
if brew bundle check --file "$ROOT_DIR/Brewfile"; then
  echo "Brewfile requirements are satisfied."
else
  echo "Some Brewfile dependencies are missing."
  echo "Run: brew bundle --file \"$ROOT_DIR/Brewfile\""
fi

echo "Checking managed macOS defaults..."
echo "InitialKeyRepeat=$(defaults read -g InitialKeyRepeat 2>/dev/null || echo unset)"
echo "KeyRepeat=$(defaults read -g KeyRepeat 2>/dev/null || echo unset)"
echo "Finder.ShowPathbar=$(defaults read com.apple.finder ShowPathbar 2>/dev/null || echo unset)"
echo "Finder.ShowStatusBar=$(defaults read com.apple.finder ShowStatusBar 2>/dev/null || echo unset)"
echo "Dock.autohide=$(defaults read com.apple.dock autohide 2>/dev/null || echo unset)"

echo "Verification finished."
