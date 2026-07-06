#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USE_SUDO_SESSION=false
SUDO_KEEPALIVE_PID=""

for arg in "$@"; do
  case "$arg" in
    --with-sudo-session)
      USE_SUDO_SESSION=true
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: bash scripts/bootstrap.sh [--with-sudo-session]"
      exit 1
      ;;
  esac
done

if [[ "${EUID}" -eq 0 ]]; then
  echo "Do not run this script with sudo/root."
  echo "Run as your normal user: bash scripts/bootstrap.sh"
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "This setup supports Apple Silicon (M-series) only."
  exit 1
fi

start_sudo_session() {
  if [[ "$USE_SUDO_SESSION" != "true" ]]; then
    return 0
  fi

  echo "[sudo] Requesting administrator authentication once..."
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
  SUDO_KEEPALIVE_PID="$!"
}

stop_sudo_session() {
  if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
    kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
  fi
}

trap stop_sudo_session EXIT
start_sudo_session

echo "[1/5] Checking Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are not installed."
  echo "Run: xcode-select --install"
  echo "Then re-run this script."
  exit 1
fi

echo "[2/5] Installing Homebrew if needed..."
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "[3/5] Installing formulae/casks from Brewfile..."
brew bundle --file "$ROOT_DIR/Brewfile"

echo "[4/5] Installing managed ~/.zshrc if available..."
bash "$ROOT_DIR/scripts/install-zshrc.sh"

echo "[5/5] Applying managed macOS defaults..."
bash "$ROOT_DIR/scripts/macos.sh"

echo "Bootstrap finished."
echo "Next: bash \"$ROOT_DIR/scripts/verify.sh\""
