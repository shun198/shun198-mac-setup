#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/mac-setup-test.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/snapshot"
cat > "$TEST_DIR/snapshot/Brewfile.current" <<'EOF'
brew "git"
cask "raycast"
EOF
cat > "$TEST_DIR/snapshot/mas.list" <<'EOF'
497799835 Xcode
1295203466 Microsoft Remote Desktop
EOF
cat > "$TEST_DIR/Brewfile" <<'EOF'
brew "old-package"
EOF

output="$(bash "$ROOT_DIR/scripts/update-brewfile-from-snapshot.sh" \
  --snapshot "$TEST_DIR/snapshot" \
  --output "$TEST_DIR/Brewfile")"

grep -q 'mas "Xcode", id: 497799835' <<< "$output"
grep -q 'mas "Microsoft Remote Desktop", id: 1295203466' <<< "$output"
grep -q 'brew "mas"' <<< "$output"
grep -q 'Dry-run only' <<< "$output"
grep -q 'brew "old-package"' "$TEST_DIR/Brewfile"

printf 'update-brewfile-from-snapshot test passed\n'
