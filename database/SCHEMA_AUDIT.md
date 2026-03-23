# Audit initial du schéma `fund_opcvm`

## Périmètre

Audit initial réalisé à partir du dump SQL fourni et de la structure actuelle du backend Sequelize.

## Résultat global

Le dump SQL analysé contient **62 tables**.

Une partie importante des tables cœur du produit correspond déjà aux modèles Sequelize du backend. Cela confirme que la bonne méthode consiste bien à restaurer la base côté backend `api`, puis à fiabiliser progressivement la compatibilité fine.

## Correspondances confirmées

Correspondances confirmées entre le dump et les modèles du backend :

- `actualites`
- `api_keys`
- `documents`
- `favorisfonds`
- `fond_investissements`
- `portefeuilles`
- `transactions`
- `users`
- `valorisations`

Ces correspondances sont cohérentes avec les définitions de modèles déjà présentes dans `src/models/`.

## Observations importantes

### 1. La base est plus large que le backend actuellement audité

Le dump contient davantage de tables que celles confirmées à ce stade dans le backend. Cela veut dire :

- soit le backend n'utilise qu'une partie du schéma ;
- soit certaines tables existent pour des fonctionnalités futures, anciennes ou annexes ;
- soit certaines tables sont consommées indirectement via des routes non encore auditées fichier par fichier.

### 2. Présence de tables atypiques

Le dump contient aussi des noms de tables atypiques, notamment :

- `Feuil1`
- `USD_MAD_-_Données_Historiques_(`

Ces tables ressemblent à des artefacts d'import ou de reprise de données depuis Excel / CSV. Elles devront être traitées avec prudence avant toute industrialisation.

### 3. La priorité reste la non-régression

Aucun changement destructif n'a été apporté aux modèles ni aux routes métier. L'audit sert uniquement à préparer une stabilisation progressive de l'intégration base <-> backend.

## Tables du dump nécessitant une revue ciblée ensuite

Exemples de tables à revoir dans l'étape suivante :

- `benchmark`
- `cashs`
- `classementfonds`
- `classementfonds_eurs`
- `classementfonds_usds`
- `devisedechanges`
- `devises`
- `fiscalites`
- `performences`
- `performences_eurs`
- `performences_usds`
- `portefeuille_valorises`
- `portefeuille_vls`
- `tsr`
- `tsrhisto`
- `taux_changes`

## Conclusion opérationnelle

L'intégration est techniquement bien orientée :

- le backend est déjà configuré pour MySQL / MariaDB ;
- le dump SQL appartient bien au périmètre de ce backend ;
- la base doit être restaurée côté `api` et non côté `Front` ;
- l'étape suivante recommandée est un audit détaillé **modèle par modèle** et **table par table**, avec contrôle des colonnes, clés et index.
