#!/usr/bin/env bash
set -euo pipefail

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-fund_opcvm}"
DB_USER="${DB_USER:-root}"
DUMP_PATH="${1:-./database/dumps/fund_opcvm.sql}"

if [ ! -f "$DUMP_PATH" ]; then
  echo "Dump introuvable: $DUMP_PATH"
  echo "Place un fichier .sql dans ./database/dumps/ puis relance la commande."
  exit 1
fi

echo "Import de $DUMP_PATH vers ${DB_NAME} sur ${DB_HOST}:${DB_PORT}"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p "$DB_NAME" < "$DUMP_PATH"
echo "Import terminé."
