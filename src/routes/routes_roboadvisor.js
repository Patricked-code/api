const express = require('express');
const { buildIntegratedRoboadvisorResult } = require('../roboadvisor/profileEngine');

const router = express.Router();

router.post('/roboadvisor/profile', async (req, res) => {
  try {
    const payload = req.body || {};
    const result = buildIntegratedRoboadvisorResult(payload);
    return res.json(result);
  } catch (error) {
    return res.status(500).json({ error: error.message || 'Erreur roboadvisor intégré' });
  }
});

router.get('/roboadvisor/health', async (req, res) => {
  return res.json({
    module: 'roboadvisor',
    mode: 'integrated',
    status: 'available',
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
