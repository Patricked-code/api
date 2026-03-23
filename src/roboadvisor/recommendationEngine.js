function buildRecommendationBlocks(profileCode) {
  const code = String(profileCode || 'DEFENSIF').toUpperCase();

  if (code === 'DYNAMIQUE') {
    return {
      summary: 'Orientation de long terme à dominante croissance avec acceptation élevée de la volatilité.',
      suitable_fund_styles: ['actions', 'diversifie dynamique', 'fonds croissance'],
      warnings: ['Prévoir une forte variabilité à court terme.', 'Nécessite un horizon long et une discipline élevée.'],
    };
  }

  if (code === 'EQUILIBRE') {
    return {
      summary: 'Orientation mixte entre croissance et stabilité avec diversification structurée.',
      suitable_fund_styles: ['diversifie equilibre', 'mixte prudent-dynamique', 'allocation flexible'],
      warnings: ['Le portefeuille peut connaître des phases de recul temporaires.', 'La diversification doit rester effective.'],
    };
  }

  if (code === 'PRUDENT') {
    return {
      summary: 'Orientation plus défensive recherchant un compromis entre rendement et stabilité.',
      suitable_fund_styles: ['obligataire', 'monetaire dynamique', 'diversifie prudent'],
      warnings: ['La performance potentielle peut être plus modérée.', 'La protection du capital reste relative et non garantie.'],
    };
  }

  return {
    summary: 'Orientation très prudente visant d abord la stabilité et la liquidité.',
    suitable_fund_styles: ['monetaire', 'tresorerie', 'obligataire court terme'],
    warnings: ['Le rendement attendu peut être limité.', 'Le risque n est pas nul même sur des supports défensifs.'],
  };
}

function buildIntegratedRecommendation(profile, allocation) {
  const blocks = buildRecommendationBlocks(profile?.code);

  return {
    profile_code: profile?.code || 'DEFENSIF',
    profile_label: profile?.label || 'Profil défensif',
    summary: blocks.summary,
    suitable_fund_styles: blocks.suitable_fund_styles,
    indicative_allocation: allocation?.indicative_allocation || null,
    warnings: blocks.warnings,
    next_steps: [
      'Valider la cohérence entre profil, horizon et besoin de liquidité.',
      'Cartographier ensuite les OPCVM réellement disponibles dans la plateforme.',
      'Produire une proposition d allocation détaillée par fonds et catégorie réglementaire.',
    ],
  };
}

module.exports = {
  buildIntegratedRecommendation,
};
