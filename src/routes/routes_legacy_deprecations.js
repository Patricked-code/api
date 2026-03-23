const express = require('express');

const router = express.Router();

router.get('/api/userlogin', async (req, res) => {
  return res.status(410).json({
    error: 'Route legacy retirée. Utiliser POST /auth/login ou POST /api/login-modern.',
    mode: 'stable',
  });
});

router.post('/api/generate-api-key', async (req, res) => {
  return res.status(410).json({
    error: 'Génération de clé API legacy désactivée.',
    mode: 'stable',
  });
});

router.post('/api/renew-api-key', async (req, res) => {
  return res.status(410).json({
    error: 'Renouvellement de clé API legacy désactivé.',
    mode: 'stable',
  });
});

router.get('/api/resource', async (req, res) => {
  return res.status(410).json({
    error: 'Ressource legacy sous x-api-key désactivée.',
    mode: 'stable',
  });
});

router.get('/api/api-keys', async (req, res) => {
  return res.status(410).json({
    error: 'Listing des clés API legacy désactivé.',
    mode: 'stable',
  });
});

module.exports = router;
