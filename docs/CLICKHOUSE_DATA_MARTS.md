# Data marts ClickHouse cibles pour la plateforme OPCVM

## Principe général

La base relationnelle reste la source transactionnelle.
ClickHouse devient le moteur analytique pour les usages lourds de lecture, reporting et séries historiques.

## Répartition cible

### Transactionnel MySQL / MariaDB / Cloud SQL

À conserver dans le transactionnel :

- utilisateurs
- authentification
- rôles et panels
- fonds et référentiels
- transactions
- portefeuilles
- documents
- paramètres applicatifs
- questionnaires roboadvisor
- réponses utilisateurs

### Analytique ClickHouse

À projeter dans ClickHouse :

- historiques journaliers de VL
- séries base 100 publiées
- séries base 100 total return
- performances calendaires
- drawdowns
- volatilités glissantes
- allocations agrégées par profil
- snapshots journaliers de portefeuilles
- métriques dashboard multi-fonds

## Data marts cibles

### 1. `fund_navs_daily`

Table analytique centrale des VL quotidiennes.

### 2. `fund_total_return_daily`

Table analytique dérivée des VL ajustées dividendes.

Colonnes cibles recommandées :

- `fund_id`
- `valuation_date`
- `nav_published`
- `dividend`
- `nav_total_return`
- `base_100_published`
- `base_100_total_return`

### 3. `fund_performance_periodic`

Table des métriques de performance par période.

Périodes cibles :

- daily
- weekly
- monthly
- ytd
- since_inception

### 4. `portfolio_snapshots_daily`

Snapshots quotidiens des portefeuilles.

### 5. `roboadvisor_profile_events`

Événements analytiques liés aux profils investisseur calculés par le roboadvisor intégré.

## Bénéfice métier

Cette architecture permet :

- des dashboards beaucoup plus rapides ;
- des comparatifs multi-fonds robustes ;
- une meilleure séparation entre opérationnel et analytique ;
- une représentation plus saine des performances ajustées dividendes.
