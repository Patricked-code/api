# AfricaFunds — rapport de déploiement du socle data

**Date :** 29 juillet 2026  
**Cible :** Supabase PostgreSQL 17  
**Projet :** `ogpuidfkkqqnnvvkrouz`  
**Statut :** socle installé, historiques externes non encore chargés

## Résultat vérifié

Le déploiement a créé :

- 67 tables métier ;
- 10 schémas fonctionnels : `af_ref`, `af_org`, `af_fund`, `af_market`, `af_method`, `af_source`, `af_ops`, `af_calc`, `af_quality`, `af_publish` ;
- 4 devises ;
- 8 géographies ;
- 9 organismes Maroc/UEMOA ;
- 7 points d'entrée de sources ;
- 4 indices officiels ;
- 8 séries officielles de taux ;
- 18 catégories ;
- 14 définitions d'indices calculés ;
- 6 méthodologies versionnées.

## Migrations appliquées

| Version Supabase | Migration |
|---|---|
| `20260729021238` | `africafunds_core_schema` |
| `20260729021502` | `africafunds_seed_morocco_uemoa` |
| `20260729021801` | `africafunds_calculation_helpers` |
| `20260729021827` | `africafunds_money_market_engine` |
| `20260729021903` | `africafunds_security_hardening` |

## Chaîne métier couverte

```text
Fonds → sous-fonds → classe de parts
      → classification locale
      → catégorie nationale
      → conversion EUR/USD
      → catégorie régionale
      → catégorie Afrique
      → indices, benchmarks et classements
```

## Données récupérées versus calculées

### Récupérées

- VL, Unit Price, Bid Price, Offer Price et actif net ;
- indices officiels ;
- taux monétaires et taux souverains par maturité ;
- adjudications, prix, rendements, coupons, échéances et encours ;
- inflation ;
- taux de change.

### Calculées

- rendements ;
- courbes normalisées ;
- indices de marché ;
- indices de catégorie ;
- indices réels ;
- benchmarks plateforme ;
- conversions EUR/USD ;
- indices régionaux et Afrique ;
- classements ;
- scores de qualité et couverture.

## Indices monétaires initiaux

### Maroc

- `AF_MM_MAR_MARKET_MAD`
- `AF_MM_MAR_CATEGORY_MAD`
- `AF_MM_MAR_REAL_MAD`
- `AF_MM_MAR_PLATFORM_MAD`

### UEMOA

- `AF_MM_UEMOA_MARKET_XOF`
- `AF_MM_UEMOA_CATEGORY_XOF`
- `AF_MM_UEMOA_REAL_XOF`
- `AF_MM_UEMOA_PLATFORM_XOF`

### Régional et Afrique

- Afrique du Nord EUR/USD ;
- Afrique de l'Ouest EUR/USD ;
- Afrique EUR/USD.

## Sécurité

- `search_path` fixé sur les fonctions AfricaFunds ;
- moteur monétaire non accessible à `anon` et `authenticated` ;
- aucune clé API ni secret dans les migrations ;
- aucune modification des tables métier préexistantes, la base en étant dépourvue au moment de l'audit.

Une alerte indépendante subsiste sur `public.rls_auto_enable()`, fonction préexistante non modifiée dans ce lot.

## Travaux restant à réaliser

1. écrire les crawlers et parseurs par source ;
2. archiver les fichiers officiels ;
3. effectuer le backfill des historiques ;
4. charger les fonds, classes de parts, VL et actifs nets ;
5. ajouter les moteurs catégorie, réel, benchmark, FX, régional et Afrique ;
6. exposer les API de lecture et d'administration ;
7. connecter le front ;
8. créer les tests de non-régression et de réconciliation.

## Critère de vérité

Aucun indice réel ne doit être publié sans données sources suffisantes. Chaque valeur publiée doit rester reconstructible jusqu'au document, fichier, feuille/page et cellule ou champ d'origine.
