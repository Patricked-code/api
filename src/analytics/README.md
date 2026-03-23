# Couche analytics ClickHouse

## Statut

Cette couche est optionnelle et non destructive.

Elle n'altère pas le fonctionnement actuel basé sur MySQL ou MariaDB.

## Objectif

Préparer une base analytique pour :

- historiques de VL ;
- agrégations ;
- tableaux de bord ;
- reporting ;
- séries de performances ;
- analyses multi-fonds.

## Fichier principal

- `src/analytics/clickhouse.js`

## Activation

Définir :

- `CLICKHOUSE_ENABLED=true`
- `CLICKHOUSE_URL`
- `CLICKHOUSE_USER`
- `CLICKHOUSE_PASSWORD`
- `CLICKHOUSE_DB`

## Principe recommandé

- MySQL ou MariaDB reste la base transactionnelle ;
- ClickHouse devient la base analytique ;
- un ETL ou export incrémental alimente ClickHouse ;
- les endpoints de reporting lourd peuvent ensuite lire ClickHouse.
