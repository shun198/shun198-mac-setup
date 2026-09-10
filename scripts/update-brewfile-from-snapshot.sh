#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$ROOT_DIR/Brewfile"
SNAPSHOT_DIR=""
APPLY=false
GENERATED_FILE=""

usage() {
  echo "Usage: bash scripts/update-brewfile-from-snapshot.sh [--snapshot DIR] [--output FILE] [--apply]"
  echo
  echo "By default, prints a diff without changing the output file."
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --snapshot)
      if [[ "$#" -lt 2 ]]; then
        echo "--snapshot requires a directory" >&2
        exit 1
      fi
      shift
      SNAPSHOT_DIR="$1"
      ;;
    --output)
      if [[ "$#" -lt 2 ]]; then
        echo "--output requires a file" >&2
        exit 1
      fi
      shift
      OUTPUT_FILE="$1"
      ;;
    --apply)
      APPLY=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [[ "$1" == --snapshot=* ]]; then
        SNAPSHOT_DIR="${1#*=}"
      elif [[ "$1" == --output=* ]]; then
        OUTPUT_FILE="${1#*=}"
      else
        echo "Unknown option: $1" >&2
        usage >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -z "$SNAPSHOT_DIR" ]]; then
  SNAPSHOT_DIR="$(find "$ROOT_DIR/snapshots" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -n 1)"
fi

if [[ -z "$SNAPSHOT_DIR" || ! -d "$SNAPSHOT_DIR" ]]; then
  echo "No snapshot directory found. Run scripts/snapshot-current-mac.sh first." >&2
  exit 1
fi

CURRENT_BREWFILE="$SNAPSHOT_DIR/Brewfile.current"
MAS_LIST="$SNAPSHOT_DIR/mas.list"
if [[ ! -f "$CURRENT_BREWFILE" ]]; then
  echo "Snapshot is missing: $CURRENT_BREWFILE" >&2
  exit 1
fi
if [[ ! -f "$OUTPUT_FILE" ]]; then
  echo "Output Brewfile does not exist: $OUTPUT_FILE" >&2
  exit 1
fi

GENERATED_FILE="$(mktemp "${TMPDIR:-/tmp}/brewfile.XXXXXX")"
trap 'rm -f "$GENERATED_FILE"' EXIT
cp "$CURRENT_BREWFILE" "$GENERATED_FILE"

if [[ -f "$MAS_LIST" ]]; then
  MAS_ENTRIES="$(awk '
    NF >= 2 {
      app_id = $1
      $1 = ""
      sub(/^[[:space:]]+/, "", $0)
      gsub(/"/, "\\\"", $0)
      printf "mas \"%s\", id: %s\n", $0, app_id
    }
  ' "$MAS_LIST")"

  if [[ -n "$MAS_ENTRIES" ]]; then
    if ! grep -Eq '^[[:space:]]*brew "mas"([[:space:]]|$)' "$GENERATED_FILE"; then
      printf '\nbrew "mas"\n' >> "$GENERATED_FILE"
    fi
    while IFS= read -r entry; do
      app_id="${entry##*id: }"
      if ! grep -Eq "^[[:space:]]*mas .*id: ${app_id//./\\.}([[:space:]]|$)" "$GENERATED_FILE"; then
        if ! grep -q '^mas ' "$GENERATED_FILE"; then
          printf '\n# --- Mac App Store apps ---\n' >> "$GENERATED_FILE"
        fi
        printf '%s\n' "$entry" >> "$GENERATED_FILE"
      fi
    done <<< "$MAS_ENTRIES"
  fi
fi

echo "Snapshot: $SNAPSHOT_DIR"
echo "Output:   $OUTPUT_FILE"
if diff -u "$OUTPUT_FILE" "$GENERATED_FILE"; then
  echo "Brewfile is already synchronized."
  exit 0
fi

if [[ "$APPLY" != "true" ]]; then
  echo "Dry-run only. Re-run with --apply to update the Brewfile."
  exit 0
fi

read -r -p "Update $OUTPUT_FILE from this snapshot? [y/N] " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
  echo "Update cancelled."
  exit 0
fi

BACKUP_DIR="$ROOT_DIR/snapshots/$(date +%Y%m%d-%H%M%S)-before-brewfile-update"
mkdir -p "$BACKUP_DIR"
cp "$OUTPUT_FILE" "$BACKUP_DIR/Brewfile.before-update"
cp "$GENERATED_FILE" "$OUTPUT_FILE"
echo "Updated:  $OUTPUT_FILE"
echo "Backup:   $BACKUP_DIR/Brewfile.before-update"
