# Blueprint de déploiement Google Cloud

## Objectif

Déployer la plateforme OPCVM sur Google Cloud avec une architecture plus simple, plus robuste et moins dépendante de variables publiques front.

## Cible recommandée

### Frontend

- Next.js déployé sur Cloud Run ou autre cible web compatible
- consommation prioritaire de routes internes et proxies
- variables publiques minimales

### Backend

- API Node.js déployée sur Cloud Run
- lecture des secrets runtime via variables d'environnement ou Secret Manager
- logique roboadvisor intégrée directement dans ce backend

### Base transactionnelle

- Cloud SQL
- connexion via `DATABASE_URL`
- migrations exécutées au déploiement
- tables transactionnelles OPCVM et roboadvisor stockées ici

### Base analytique

- ClickHouse séparé et optionnel dans un premier temps
- activé via `CLICKHOUSE_ENABLED=true`
- alimenté par ETL incrémental depuis la base transactionnelle

## Variables serveur minimales cibles

### Requises

- `DATABASE_URL`
- `ADMIN_EMAIL`
- `RESEND_API_KEY`

### Optionnelles

- `CLICKHOUSE_ENABLED`
- `CLICKHOUSE_URL`
- `CLICKHOUSE_DB`

## Variables publiques front cibles minimales

### Optionnelles

- `NEXT_PUBLIC_API_URL`
- `NEXT_PUBLIC_SITE_URL`

Toutes les autres variables publiques historiques doivent être supprimées, remplacées ou désactivées.

## Séquence cible au déploiement

1. déployer l'image backend sur Cloud Run ;
2. injecter `DATABASE_URL`, `ADMIN_EMAIL`, `RESEND_API_KEY` ;
3. exécuter les migrations transactionnelles ;
4. initialiser les tables roboadvisor ;
5. démarrer le service ;
6. activer ClickHouse seulement si le service analytics est prêt.

## Composants explicitement non prioritaires

- Magic
- service stablecoin externe
- roboadvisor Python externe

## Direction d'architecture

Le backend principal devient le point unique de vérité pour :

- auth ;
- roboadvisor ;
- logique OPCVM ;
- DB transactionnelle ;
- exposition d'API métier ;
- coordination analytics.
