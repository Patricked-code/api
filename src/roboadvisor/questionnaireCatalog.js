const INTEGRATED_ROBOADVISOR_QUESTIONNAIRE = {
  code: 'INVESTOR_PROFILE_CORE',
  version: '1.0.0',
  label: 'Questionnaire profil investisseur intégré',
  questions: [
    {
      key: 'horizon_years',
      label: 'Quel est votre horizon d’investissement en années ?',
      type: 'number',
      min: 0,
      max: 50,
      required: true,
    },
    {
      key: 'max_drawdown_tolerance',
      label: 'Quelle baisse maximale temporaire pouvez-vous accepter ?',
      type: 'number',
      min: 0,
      max: 10,
      required: true,
    },
    {
      key: 'loss_reaction_score',
      label: 'Comment réagissez-vous face à une baisse de marché ?',
      type: 'number',
      min: 0,
      max: 10,
      required: true,
    },
    {
      key: 'income_stability_score',
      label: 'Quel est le niveau de stabilité de vos revenus ?',
      type: 'number',
      min: 0,
      max: 10,
      required: true,
    },
    {
      key: 'liquidity_need_score',
      label: 'À quel point avez-vous besoin de liquidité à court terme ?',
      type: 'number',
      min: 0,
      max: 10,
      required: true,
    },
    {
      key: 'investment_experience_score',
      label: 'Quel est votre niveau d’expérience en investissement ?',
      type: 'number',
      min: 0,
      max: 10,
      required: true,
    },
  ],
};

module.exports = {
  INTEGRATED_ROBOADVISOR_QUESTIONNAIRE,
};
