# AfricaFunds — socle de données et indices

Ce répertoire contient le schéma PostgreSQL/Supabase du moteur AfricaFunds.

## Environnement cible obligatoire

Le développement, les migrations, les collecteurs, les backfills, les API et les tests doivent être exécutés sur l’environnement isolé :

```text
https://funds.chainsolutions.fr/
```

L’environnement historique ou de production `africafunds` ne doit pas être modifié directement.

Règles obligatoires :

1. aucune migration directe sur la base de production AfricaFunds ;
2. aucune modification du conteneur, du volume ou du fichier `.env` de production ;
3. base de données, stockage, Redis, files d’attente et tâches cron séparés pour `funds.chainsolutions.fr` ;
4. branche Git dédiée et PR en brouillon ;
5. sauvegarde et inventaire avant toute migration ;
6. exécution des migrations d’abord sur `funds.chainsolutions.fr` ;
7. tests de non-régression, réconciliation et performance ;
8. promotion vers AfricaFunds uniquement après validation humaine explicite.

Variables attendues pour l’environnement isolé :

```text
APP_ENV=funds_staging
APP_BASE_URL=https://funds.chainsolutions.fr
DATABASE_URL=<base séparée>
REDIS_URL=<instance ou namespace séparé>
STORAGE_PREFIX=funds-staging/
QUEUE_PREFIX=funds-staging
CRON_ENABLED=true
AFRICAFUNDS_PRODUCTION_WRITE_ENABLED=false
```

Toute tâche d’écriture doit refuser de démarrer lorsque `AFRICAFUNDS_PRODUCTION_WRITE_ENABLED` n’est pas explicitement autorisé.

## Préparer la migration cœur

La migration cœur est conservée sans perte dans `001_core_parts/` afin de rester facilement transportable par le connecteur GitHub.

```bash
bash database/africafunds/assemble_core_migration.sh
```

Le fichier reconstruit doit avoir le SHA-256 :

```text
e00154738ced3004e8e034a679570d281886111aea65a2b6832b083bf5f3cf0e
```

## Ordre d'application

1. `001_africafunds_core.sql`, après assemblage
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
