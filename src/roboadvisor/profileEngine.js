function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function computeRiskScore(answers = {}) {
  const horizon = Number(answers.horizon_years || 0);
  const drawdownTolerance = Number(answers.max_drawdown_tolerance || 0);
  const lossReaction = Number(answers.loss_reaction_score || 0);
  const incomeStability = Number(answers.income_stability_score || 0);
  const liquidityNeed = Number(answers.liquidity_need_score || 0);
  const experience = Number(answers.investment_experience_score || 0);

  const rawScore =
    horizon * 8 +
    drawdownTolerance * 10 +
    lossReaction * 12 +
    incomeStability * 6 +
    experience * 10 -
    liquidityNeed * 10;

  return clamp(Math.round(rawScore), 0, 100);
}

function resolveInvestorProfile(score) {
  if (score >= 75) {
    return {
      code: 'DYNAMIQUE',
      label: 'Profil dynamique',
      target_equity_range: '60-85%',
      target_fixed_income_range: '10-30%',
      target_liquidity_range: '5-15%',
    };
  }

  if (score >= 50) {
    return {
      code: 'EQUILIBRE',
      label: 'Profil équilibré',
      target_equity_range: '35-60%',
      target_fixed_income_range: '25-45%',
      target_liquidity_range: '10-20%',
    };
  }

  if (score >= 25) {
    return {
      code: 'PRUDENT',
      label: 'Profil prudent',
      target_equity_range: '10-35%',
      target_fixed_income_range: '45-70%',
      target_liquidity_range: '10-25%',
    };
  }

  return {
    code: 'DEFENSIF',
    label: 'Profil défensif',
    target_equity_range: '0-15%',
    target_fixed_income_range: '50-80%',
    target_liquidity_range: '15-35%',
  };
}

function buildIntegratedRoboadvisorResult(payload = {}) {
  const score = computeRiskScore(payload.answers || {});
  const profile = resolveInvestorProfile(score);

  return {
    mode: 'integrated',
    score,
    profile,
    recommendation_summary: {
      investment_horizon_years: Number(payload?.answers?.horizon_years || 0),
      notes: [
        'Ce moteur intégré remplace progressivement le roboadvisor Python externe.',
        'La logique actuelle constitue une base stable de scoring profil investisseur.',
        'Les recommandations détaillées et allocations fines pourront être enrichies ensuite par classe d actifs et univers OPCVM.',
      ],
    },
  };
}

module.exports = {
  computeRiskScore,
  resolveInvestorProfile,
  buildIntegratedRoboadvisorResult,
};
