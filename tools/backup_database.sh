#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-codearena}"
DB_USER="${DB_USER:-root}"
MYSQLDUMP_BIN="${MYSQLDUMP_BIN:-/Applications/XAMPP/xamppfiles/bin/mysqldump}"

if [[ ! "$DB_NAME" =~ ^[A-Za-z0-9_]+$ ]]; then echo "DB_NAME must contain only letters, numbers, and underscores." >&2; exit 2; fi
if [[ ! -x "$MYSQLDUMP_BIN" ]]; then MYSQLDUMP_BIN="$(command -v mysqldump || true)"; fi
if [[ -z "$MYSQLDUMP_BIN" || ! -x "$MYSQLDUMP_BIN" ]]; then echo "mysqldump not found. Set MYSQLDUMP_BIN to your XAMPP mysqldump path." >&2; exit 2; fi

OUT_DIR="${BACKUP_DIR:-$HOME/CodeArenaBackups}"
mkdir -p "$OUT_DIR"
chmod 700 "$OUT_DIR"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_FILE="$OUT_DIR/${DB_NAME}_${STAMP}.sql"
TMP_CNF="$(mktemp "${TMPDIR:-/tmp}/codearena-mysql-XXXXXX")"
trap 'rm -f "$TMP_CNF"' EXIT
chmod 600 "$TMP_CNF"

escape_option() { local value="$1"; value="${value//\\/\\\\}"; value="${value//\"/\\\"}"; printf '%s' "$value"; }
printf '[client]\nhost="%s"\nport=%s\nuser="%s"\n' "$(escape_option "$DB_HOST")" "$DB_PORT" "$(escape_option "$DB_USER")" > "$TMP_CNF"
read -r -s -p "MySQL password for ${DB_USER} (blank for default XAMPP root): " DB_PASS
printf '\n'
printf 'password="%s"\n' "$(escape_option "$DB_PASS")" >> "$TMP_CNF"
unset DB_PASS

echo "Creating a consistent logical backup of database '$DB_NAME'..."
TEMP_OUT="${OUT_FILE}.partial"
if "$MYSQLDUMP_BIN" --defaults-extra-file="$TMP_CNF" --single-transaction --routines --triggers --events --hex-blob "$DB_NAME" > "$TEMP_OUT"; then
  mv "$TEMP_OUT" "$OUT_FILE"
  chmod 600 "$OUT_FILE"
  echo "Backup completed: $OUT_FILE"
  echo "This file is outside the web root. Store a second copy somewhere safe."
else
  rm -f "$TEMP_OUT"
  echo "Backup failed. Confirm MySQL is running and the account can read database '$DB_NAME'." >&2
  exit 1
fi
