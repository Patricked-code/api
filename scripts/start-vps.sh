#!/usr/bin/env bash
set -e

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "[1/3] Bootstrap base transactionnelle depuis DATABASE_URL"
node scripts/bootstrap-mysql-from-database-url.js

echo "[2/3] Exécution des migrations"
npx sequelize-cli db:migrate

echo "[3/3] Démarrage de l'API"
node app.js
