# Patch exact pour activer le runtime stable

## Fichier concerné

- `app.js`

## Objectif

Monter les routes modernes et les dépréciations legacy avant `routes_vl`, afin de :

- sortir progressivement de Magic pour la connexion ;
- désactiver les anciens endpoints de clés API ;
- faire passer la connexion standard email/mot de passe + JWT en priorité ;
- garder le legacy applicatif en place sans refonte brutale.

## Remplacement recommandé dans `app.js`

### Bloc actuel

```js
// ---------------------
// Routes
// ---------------------
require('./src/routes/routes_vl')(app);
```

### Bloc cible

```js
// ---------------------
// Routes
// ---------------------
const { registerStableRoutes } = require('./src/bootstrap/registerStableRoutes');
registerStableRoutes(app);
```

## Effet attendu

L'ordre de chargement devient :

1. `routes_auth_modern`
2. `routes_legacy_deprecations`
3. `routes_analytics`
4. `routes_vl`

Ce point est essentiel car Express applique les routes dans l'ordre de montage.

## Option package.json

Si un second runtime doit être testé plus tard, on peut ajouter par exemple :

```json
{
  "scripts": {
    "start:stable": "node app.js"
  }
}
```

À ce stade, aucune duplication de runtime n'est nécessaire si `app.js` est patché comme ci-dessus.

## Vérifications à faire après patch

1. `POST /auth/login` retourne bien un JWT.
2. `POST /api/login-modern` fonctionne aussi.
3. `GET /api/userlogin` retourne 410.
4. `POST /api/generate-api-key` retourne 410.
5. Les routes legacy métier restent accessibles via `routes_vl`.

## Conséquence métier

Ce patch active réellement la transition :

- connexion simplifiée ;
- moins de blocages liés à Magic ;
- moins de confusion entre anciens et nouveaux flux ;
- meilleure base pour reconnecter proprement les panels front.
