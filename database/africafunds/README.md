# AfricaFunds — socle de données et indices

Ce répertoire contient le schéma PostgreSQL/Supabase du moteur AfricaFunds.

## Environnement obligatoire : S1

Tous les développements, migrations, collecteurs, backfills, calculs, API et tests doivent être exécutés sur le serveur **S1** avec les domaines suivants :

```text
API   https://apiv3.liquidity.wealthtechinnovations.com
Front https://liquidity.wealthtechinnovations.com
```

L’environnement historique ou de production AfricaFunds ne doit pas être modifié directement.

Règles obligatoires :

1. aucune migration directe sur la base de production AfricaFunds ;
2. aucune modification de ses conteneurs, volumes ou fichiers `.env` ;
3. base, stockage, Redis, files d’attente et tâches cron séparés sur S1 ;
4. branche Git dédiée et PR en brouillon ;
5. sauvegarde et inventaire avant toute promotion ;
6. exécution des migrations d’abord sur S1 ;
7. tests de non-régression, réconciliation, sécurité et performance ;
8. promotion vers AfricaFunds uniquement après validation humaine explicite.

Variables attendues :

```env
APP_ENV=s1_development
FRONTEND_URL=https://liquidity.wealthtechinnovations.com
API_BASE_URL=https://apiv3.liquidity.wealthtechinnovations.com
SITE_BASE_URL=https://liquidity.wealthtechinnovations.com
DATABASE_URL=<base S1 séparée>
REDIS_URL=<instance ou namespace S1 séparé>
STORAGE_PREFIX=s1-liquidity/
QUEUE_PREFIX=s1-liquidity
CRON_ENABLED=true
AFRICAFUNDS_PRODUCTION_WRITE_ENABLED=false
```

Toute tâche d’écriture doit refuser de démarrer si elle détecte une cible AfricaFunds production ou si `AFRICAFUNDS_PRODUCTION_WRITE_ENABLED` n’est pas explicitement autorisé.

Les garde-fous complets sont documentés dans :

```text
docs/africafunds/ENVIRONMENT_GUARDRAILS.md
```

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

Aucun secret réel ne doit être versionné.

## Limite actuelle

Les collecteurs HTTP, parseurs par source et historiques officiels ne sont pas inclus dans ce lot. Le schéma est prêt à les recevoir exclusivement sur S1.
