const express = require('express');
const { buildIntegratedRoboadvisorResult } = require('../roboadvisor/profileEngine');
const { buildIntegratedAllocation } = require('../roboadvisor/allocationEngine');
const { buildIntegratedRecommendation } = require('../roboadvisor/recommendationEngine');

const router = express.Router();

router.post('/roboadvisor/recommendation', async (req, res) => {
  try {
    const payload = req.body || {};
    const result = buildIntegratedRoboadvisorResult(payload);
    const allocation = buildIntegratedAllocation(result.profile);
    const recommendation = buildIntegratedRecommendation(result.profile, allocation);

    return res.json({
      mode: 'integrated',
      score: result.score,
      profile: result.profile,
      allocation,
      recommendation,
    });
  } catch (error) {
    return res.status(500).json({ error: error.message || 'Erreur recommandation roboadvisor intégrée' });
  }
});

module.exports = router;
