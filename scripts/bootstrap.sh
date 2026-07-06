#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "This setup supports Apple Silicon (M-series) only."
  exit 1
fi

echo "[1/4] Checking Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are not installed."
  echo "Run: xcode-select --install"
  echo "Then re-run this script."
  exit 1
fi

echo "[2/4] Installing Homebrew if needed..."
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "[3/4] Installing formulae/casks from Brewfile..."
brew bundle --file "$ROOT_DIR/Brewfile"

echo "[4/4] Applying managed macOS defaults..."
bash "$ROOT_DIR/scripts/macos.sh"

echo "Bootstrap finished."
echo "Next: bash \"$ROOT_DIR/scripts/verify.sh\""
