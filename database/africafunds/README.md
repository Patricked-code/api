# AfricaFunds — socle de données et indices

Ce répertoire contient le schéma PostgreSQL/Supabase du moteur AfricaFunds.

## Ordre d'application

1. `001_africafunds_core.sql`
2. `002_africafunds_seed_morocco_uemoa.sql`
3. `003_africafunds_calculation_helpers.sql`
4. `004_africafunds_money_market_engine.sql`
5. `005_africafunds_security_hardening.sql`

Les scripts sont idempotents autant que possible et utilisent des codes métier plutôt que des UUID générés.

## Périmètre installé

- domaines fonds, organisations, marchés, sources, méthodes, calculs, qualité, opérations et publication ;
- référentiels Maroc et UEMOA ;
- catégories Actions, Obligations et Monétaire ;
- séries de taux initiales ;
- indices officiels initiaux ;
- définitions d'indices monétaires nationaux, régionaux et Afrique ;
- moteur SQL d'indice monétaire ;
- traçabilité document → fichier → feuille/page/cellule → observation → calcul → publication.

## Exemple de calcul

```sql
select af_calc.calculate_money_market_index(
  'AF_MM_MAR_MARKET_MAD',
  '2026-01-01',
  current_date
);
```

La fonction ne produit des niveaux que lorsque des observations officielles existent dans `af_market.official_rate_observations`.

## Sécurité

Les fonctions de calcul ne sont pas exécutables par `anon`. Le moteur d'indice monétaire reste réservé au rôle propriétaire/service.

## Limite actuelle

Les collecteurs HTTP, parseurs par source et historiques officiels ne sont pas inclus dans ce lot. Le schéma est prêt à les recevoir.
