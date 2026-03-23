# Base de données `fund_opcvm`

Ce dossier documente la bonne méthode d'intégration de la base du projet OPCVM dans le dépôt backend `api`.

## Principe

- Le dépôt `Front` reste le client web.
- Le dépôt `api` porte la connexion à la base et toute la logique serveur.
- Le dump SQL ne doit pas être versionné comme source de vérité principale dans le dépôt public.
- La base doit être restaurée dans un serveur MySQL ou MariaDB, puis reliée à l'API via les variables d'environnement.

## Dump attendu

Le dump analysé pour ce projet est un export MariaDB/MySQL de la base `fund_opcvm`.
Nom de fichier observé : `fund_opcvm_2026-03-21_16-34-38.sql.zip`

## Emplacement recommandé hors versionnement

Placer les fichiers volumineux de dump dans `database/dumps/` en local uniquement.
Le dépôt ignore les fichiers `.sql` et `.zip` pour éviter de publier la base en clair.

## Import manuel recommandé

### 1. Créer la base

```bash
mysql -u root -p -e "CREATE DATABASE fund_opcvm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 2. Importer le dump

```bash
mysql -u root -p fund_opcvm < ./database/dumps/fund_opcvm.sql
```

### 3. Démarrer l'API

```bash
npm install
npm run dev
```

## Import via script

Un script `scripts/import-db.sh` est fourni pour automatiser l'import si un dump `.sql` est présent dans `database/dumps/`.

## Import via Docker Compose

Le fichier `docker-compose.yml` permet de démarrer :

- un conteneur MariaDB
- l'API Node.js

Le chargement automatique du dump n'est volontairement pas forcé dans l'image publique pour ne pas committer la base dans Git.

## Variables de configuration à fournir côté API

L'API attend notamment :

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `DB_DIALECT`
- `API_BASE_URL`
- `SITE_BASE_URL`
- `FRONTEND_URL`

## Bonnes pratiques retenues

1. ne pas stocker le dump SQL massif dans le dépôt public ;
2. conserver les sauvegardes hors Git ou via stockage privé ;
3. faire de la base restaurée la cible d'exécution de l'API ;
4. laisser le front consommer uniquement l'API ;
5. auditer ensuite la correspondance entre les tables restaurées et les modèles Sequelize.
