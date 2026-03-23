const express = require('express');
const { INTEGRATED_ROBOADVISOR_QUESTIONNAIRE } = require('../roboadvisor/questionnaireCatalog');

const router = express.Router();

router.get('/roboadvisor/questionnaire', async (req, res) => {
  return res.json({
    mode: 'integrated',
    questionnaire: INTEGRATED_ROBOADVISOR_QUESTIONNAIRE,
  });
});

module.exports = router;
