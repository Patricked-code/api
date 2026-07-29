# AfricaFunds — règles d’environnement S1

## Cibles obligatoires

Tous les développements AfricaFunds de ce lot doivent être réalisés sur le serveur **S1** avec les domaines suivants :

- **API** : `https://apiv3.liquidity.wealthtechinnovations.com`
- **Front** : `https://liquidity.wealthtechinnovations.com`

Ces deux domaines constituent l’environnement isolé de développement, d’intégration, de backfill, de calcul et de validation.

## Interdictions

Il est interdit de :

- déployer directement sur AfricaFunds production ;
- modifier ses conteneurs, volumes, bases, fichiers `.env`, Redis, queues ou tâches cron ;
- partager les identifiants de base ou les secrets entre S1 et AfricaFunds production ;
- pointer le front S1 vers une API ou une base de production ;
- exécuter un backfill ou une migration sur AfricaFunds sans validation humaine explicite.

## Isolation technique requise

L’environnement S1 doit disposer de ressources distinctes :

```text
Front        liquidity.wealthtechinnovations.com
API          apiv3.liquidity.wealthtechinnovations.com
Database     dédiée à S1
Storage      dédié à S1
Redis        dédié à S1
Queues       dédiées à S1
Crons        dédiés à S1
Logs         dédiés à S1
Secrets      dédiés à S1
```

## Variables d’environnement minimales

```env
APP_ENV=s1_development
FRONTEND_URL=https://liquidity.wealthtechinnovations.com
API_BASE_URL=https://apiv3.liquidity.wealthtechinnovations.com
SITE_BASE_URL=https://liquidity.wealthtechinnovations.com
AFRICAFUNDS_PRODUCTION_WRITE_ENABLED=false
```

Aucun secret réel ne doit être versionné dans Git.

## Procédure de promotion

Toute future promotion vers AfricaFunds production nécessite :

1. inventaire complet de l’existant ;
2. sauvegarde vérifiée de la base et des volumes ;
3. migration testée sur S1 ;
4. tests de non-régression et de réconciliation réussis ;
5. contrôle des performances et de la sécurité ;
6. plan de retour arrière documenté ;
7. validation humaine explicite ;
8. fenêtre de déploiement identifiée ;
9. contrôle post-déploiement.

## Règle de vérité

```text
Développement et collecte
→ S1
→ apiv3.liquidity.wealthtechinnovations.com
→ liquidity.wealthtechinnovations.com
→ validation
→ promotion contrôlée éventuelle
```

Tant que cette procédure n’est pas achevée, aucune écriture vers AfricaFunds production n’est autorisée.
