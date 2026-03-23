function resolveIndicativeAllocation(profileCode) {
  switch (String(profileCode || '').toUpperCase()) {
    case 'DYNAMIQUE':
      return {
        equities: 70,
        fixed_income: 20,
        liquidity: 10,
      };
    case 'EQUILIBRE':
      return {
        equities: 50,
        fixed_income: 35,
        liquidity: 15,
      };
    case 'PRUDENT':
      return {
        equities: 25,
        fixed_income: 55,
        liquidity: 20,
      };
    case 'DEFENSIF':
    default:
      return {
        equities: 10,
        fixed_income: 60,
        liquidity: 30,
      };
  }
}

function buildIntegratedAllocation(profile) {
  const allocation = resolveIndicativeAllocation(profile?.code);

  return {
    profile_code: profile?.code || 'DEFENSIF',
    profile_label: profile?.label || 'Profil défensif',
    indicative_allocation: allocation,
    notes: [
      'Cette allocation indicative est produite par le roboadvisor intégré du backend principal.',
      'Elle constitue une base de travail à affiner ensuite selon l univers OPCVM effectivement référencé dans la plateforme.',
      'Les futurs enrichissements pourront inclure des règles par objectifs, contraintes réglementaires et classes d actifs détaillées.',
    ],
  };
}

module.exports = {
  resolveIndicativeAllocation,
  buildIntegratedAllocation,
};
