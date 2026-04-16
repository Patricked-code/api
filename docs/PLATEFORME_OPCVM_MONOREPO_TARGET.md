# Cible monorepo : Plateforme_Opcvm

## Objectif

Fusionner le frontend et le backend dans un seul repo afin de simplifier :

- le suivi du code ;
- le déploiement ;
- la cohérence des branches ;
- les scripts de build et de démarrage ;
- la maintenance de la base transactionnelle et de ClickHouse.

## Structure cible recommandée

```text
Plateforme_Opcvm/
  apps/
    frontend/        # ancien repo Front
    backend/         # ancien repo api
  database/
    mysql/
    clickhouse/
    dumps/
  scripts/
    start-vps.sh
    bootstrap-mysql-from-database-url.js
  infra/
    nginx/
    pm2/
    docker/
  docs/
    IONOS_VPS_DEPLOYMENT_BLUEPRINT.md
    CLICKHOUSE_DATA_MARTS.md
    DEPLOYMENT_TARGET_ARCHITECTURE.md
  package.json
  README.md
```

## Répartition recommandée

### `apps/frontend`

- App Router Next.js
- auth stable
- panels stables
- roboadvisor intégré côté UI
- proxies internes

### `apps/backend`

- API Express
- auth moderne
- routes roboadvisor intégrées
- analytics
- logique OPCVM
- bootstrap runtime

### `database`

- SQL transactionnel roboadvisor
- schémas ClickHouse
- dumps et scripts de restauration

### `infra`

- configuration Nginx
- configuration PM2
- artefacts Docker si nécessaires

## Ordre conseillé de migration vers le monorepo

1. créer le repo `Plateforme_Opcvm` ;
2. importer `Front` dans `apps/frontend` ;
3. importer `api` dans `apps/backend` ;
4. remonter `database/` et `scripts/` à la racine ;
5. adapter les chemins internes et scripts de démarrage ;
6. ajouter une orchestration de démarrage unique pour le VPS.

## Bénéfice

Cette cible réduit fortement la complexité opérationnelle pour un déploiement sur IONOS VPS avec base transactionnelle + ClickHouse + frontend + backend dans un cadre unique.
