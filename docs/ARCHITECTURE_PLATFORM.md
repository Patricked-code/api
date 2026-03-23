# Architecture plateforme OPCVM

## Couches

- Front : dépôt `Front`
- API : dépôt `api`
- Base transactionnelle : MySQL ou MariaDB
- Base analytique optionnelle : ClickHouse

## Rôle de MySQL ou MariaDB

La base transactionnelle reste la source de vérité pour les utilisateurs, fonds, valorisations, portefeuilles, transactions et documents.

## Rôle de ClickHouse

ClickHouse est recommandé pour les historiques de VL, les comparatifs, les agrégations, les dashboards et les calculs analytiques volumineux.

## Flux recommandé

1. l'API écrit dans MySQL ou MariaDB ;
2. un flux ETL pousse les données analytiques vers ClickHouse ;
3. les endpoints de reporting lourd lisent ClickHouse ;
4. les endpoints transactionnels restent sur MySQL ou MariaDB.

## Principe de sécurité

Aucune table existante n'est renommée brutalement dans l'application actuelle. La professionnalisation passe d'abord par une couche documentaire et analytique non destructive.
