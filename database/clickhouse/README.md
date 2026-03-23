# Schéma ClickHouse OPCVM

## Objet

Ce dossier contient les scripts SQL pour initialiser une couche analytique ClickHouse dédiée au projet OPCVM.

## Tables initiales

### `fund_navs_daily`

Table analytique journalière des VL par fonds.

Usages :

- historique de VL ;
- comparatifs ;
- dashboards ;
- exports ;
- séries longues.

### `portfolio_positions_daily`

Table analytique journalière des positions de portefeuille.

Usages :

- valorisation ;
- snapshots ;
- vues consolidées ;
- analytics par utilisateur et portefeuille.

### `fund_performance_monthly`

Table analytique mensuelle des performances.

Usages :

- reporting ;
- performances calendaires ;
- ratios ;
- comparaisons multi-fonds.

## Principe

Le schéma ClickHouse est complémentaire au schéma transactionnel.

- MySQL ou MariaDB : source de vérité applicative
- ClickHouse : moteur analytique orienté lecture

## Mise en œuvre recommandée

1. restaurer la base transactionnelle ;
2. stabiliser l'API existante ;
3. alimenter ClickHouse via ETL ;
4. exposer ensuite des endpoints de reporting lourds sur ClickHouse.
