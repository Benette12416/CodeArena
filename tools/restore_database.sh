#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 /path/to/backup.sql [new_restore_database_name]" >&2
  echo "This script restores into a NEW database and refuses to overwrite an existing one." >&2
  exit 2
fi
BACKUP_FILE="$1"
if [[ ! -f "$BACKUP_FILE" || ! -r "$BACKUP_FILE" ]]; then echo "Backup file does not exist or is not readable: $BACKUP_FILE" >&2; exit 2; fi
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
MYSQL_BIN="${MYSQL_BIN:-/Applications/XAMPP/xamppfiles/bin/mysql}"
if [[ ! -x "$MYSQL_BIN" ]]; then MYSQL_BIN="$(command -v mysql || true)"; fi
if [[ -z "$MYSQL_BIN" || ! -x "$MYSQL_BIN" ]]; then echo "mysql client not found. Set MYSQL_BIN to your XAMPP mysql path." >&2; exit 2; fi
STAMP="$(date +%Y%m%d_%H%M%S)"
TARGET_DB="${2:-codearena_restore_${STAMP}}"
if [[ ! "$TARGET_DB" =~ ^[A-Za-z0-9_]{1,64}$ ]]; then echo "Target DB name must contain 1-64 letters, numbers, and underscores." >&2; exit 2; fi
TMP_CNF="$(mktemp "${TMPDIR:-/tmp}/codearena-mysql-XXXXXX")"
trap 'rm -f "$TMP_CNF"' EXIT
chmod 600 "$TMP_CNF"
escape_option() { local value="$1"; value="${value//\\/\\\\}"; value="${value//\"/\\\"}"; printf '%s' "$value"; }
printf '[client]\nhost="%s"\nport=%s\nuser="%s"\n' "$(escape_option "$DB_HOST")" "$DB_PORT" "$(escape_option "$DB_USER")" > "$TMP_CNF"
read -r -s -p "MySQL password for ${DB_USER} (blank for default XAMPP root): " DB_PASS
printf '\n'
printf 'password="%s"\n' "$(escape_option "$DB_PASS")" >> "$TMP_CNF"
unset DB_PASS
EXISTS="$($MYSQL_BIN --defaults-extra-file="$TMP_CNF" -Nse "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${TARGET_DB}'" 2>/dev/null || true)"
if [[ -n "$EXISTS" ]]; then echo "Refusing to overwrite existing database '$TARGET_DB'. Choose another target name." >&2; exit 1; fi
echo "Target database: $TARGET_DB"
echo "Source backup: $BACKUP_FILE"
echo "This will create a new database; it will not change your current codearena database."
read -r -p "Type RESTORE to continue: " CONFIRM
if [[ "$CONFIRM" != "RESTORE" ]]; then echo "Restore cancelled."; exit 1; fi
"$MYSQL_BIN" --defaults-extra-file="$TMP_CNF" -e "CREATE DATABASE \`$TARGET_DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
if "$MYSQL_BIN" --defaults-extra-file="$TMP_CNF" "$TARGET_DB" < "$BACKUP_FILE"; then
  echo "Restore completed into '$TARGET_DB'. Validate it before changing config/config.php."
else
  echo "Restore failed. A partial database named '$TARGET_DB' may remain; inspect it in phpMyAdmin before removing it." >&2
  exit 1
fi
