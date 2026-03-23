const express = require('express');
const { buildIntegratedAllocation } = require('../roboadvisor/allocationEngine');
const { buildIntegratedRoboadvisorResult } = require('../roboadvisor/profileEngine');

const router = express.Router();

router.post('/roboadvisor/allocation', async (req, res) => {
  try {
    const payload = req.body || {};
    const result = buildIntegratedRoboadvisorResult(payload);
    const allocation = buildIntegratedAllocation(result.profile);

    return res.json({
      mode: 'integrated',
      profile: result.profile,
      score: result.score,
      allocation,
    });
  } catch (error) {
    return res.status(500).json({ error: error.message || 'Erreur allocation roboadvisor intégrée' });
  }
});

module.exports = router;
