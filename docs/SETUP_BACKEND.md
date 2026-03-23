# Installation du backend OPCVM

## Positionnement

Ce dépôt `api` porte la logique serveur et la connexion à la base.
Le dépôt `Front` reste le client web.

## Architecture

Front -> API -> MySQL/MariaDB

## Mise en route locale

### Avec Docker

- placer un dump SQL local dans `database/dumps/`
- lancer `docker compose up`

### Sans Docker

- restaurer la base sur un serveur MySQL ou MariaDB
- fournir les variables d'environnement attendues par l'application
- lancer `npm install` puis `npm run dev`

## Points utiles

- `database/README.md` : import et restauration
- `database/SCHEMA_AUDIT.md` : audit du schéma
- `scripts/import-db.sh` : helper d'import
- `GET /health` : test simple de disponibilité
