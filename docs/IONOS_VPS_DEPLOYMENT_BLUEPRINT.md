# Blueprint de déploiement IONOS VPS

## Objectif

Déployer la plateforme OPCVM sur un VPS IONOS avec une architecture plus unifiée, plus robuste et moins dépendante de variables publiques front ou de services externes séparés.

## Cible recommandée

### Frontend

- Next.js servi sur le VPS
- routes internes et proxies privilégiés
- variables publiques minimales

### Backend

- API Node.js / Express sur le même VPS
- runtime principal pour auth, panels, roboadvisor, logique OPCVM et coordination analytics

### Base transactionnelle

- MySQL ou MariaDB sur le VPS
- initialisation à partir de `DATABASE_URL`
- migrations exécutées avant démarrage complet

### Base analytique

- ClickHouse sur le VPS ou dans un conteneur dédié sur le même hôte
- activable progressivement
- alimenté par ETL depuis la base transactionnelle

## Variables serveur minimales

- `DATABASE_URL`
- `ADMIN_EMAIL`
- `RESEND_API_KEY`

## Variables optionnelles

- `CLICKHOUSE_ENABLED`
- `CLICKHOUSE_URL`
- `CLICKHOUSE_DB`
- `API_BASE_URL`
- `SITE_BASE_URL`
- `FRONTEND_URL`

## Variables publiques front à réduire

Cible minimale :

- `NEXT_PUBLIC_API_URL` optionnelle
- `NEXT_PUBLIC_SITE_URL` optionnelle

Les autres variables publiques historiques doivent devenir inutiles ou désactivées.

## Services explicitement non prioritaires

- Magic
- service stablecoin externe
- roboadvisor Python externe

## Séquence cible de démarrage

1. démarrer MySQL ou MariaDB ;
2. créer la base si absente depuis `DATABASE_URL` ;
3. exécuter les migrations ;
4. démarrer l'API Node.js ;
5. démarrer le frontend Next.js ;
6. activer ClickHouse si la couche analytique est prête.

## Exposition réseau recommandée

- Nginx en frontal
- reverse proxy vers frontend et backend
- TLS via Let's Encrypt ou certificat géré séparément

## Gestion de processus recommandée

- PM2 ou systemd pour Node.js
- services système ou Docker pour MySQL/MariaDB et ClickHouse

## Direction d'architecture

Le backend principal doit devenir le point unique de vérité pour :

- auth ;
- roboadvisor ;
- logique OPCVM ;
- DB transactionnelle ;
- exposition API ;
- coordination analytics.
