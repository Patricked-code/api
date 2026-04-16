const express = require('express');

module.exports = (app) => {
  const router = express.Router();

  const demarches = [
    { id: 'naissance', titre: 'Declaration de naissance', domaine: 'Etat civil', frais: 1500, statut: 'active' },
    { id: 'deces', titre: 'Declaration de deces', domaine: 'Etat civil', frais: 1500, statut: 'active' },
    { id: 'copie-acte', titre: 'Demande de copie d acte', domaine: 'Etat civil', frais: 1000, statut: 'active' },
    { id: 'mariage', titre: 'Organisation de mariage', domaine: 'Etat civil', frais: 5000, statut: 'preview' },
  ];

  router.get('/health', (req, res) => {
    res.json({ module: 'commune-saas', status: 'ok', timestamp: new Date().toISOString() });
  });

  router.get('/portal-config', (req, res) => {
    res.json({
      commune: { nom: 'Niakaramadougou', pays: 'Cote d Ivoire', mode: 'mvp' },
      espaces: ['public', 'citoyen', 'admin'],
      modules: ['catalogue-demarches', 'etat-civil', 'ged', 'workflow', 'paiement'],
    });
  });

  router.get('/demarches', (req, res) => {
    res.json({ data: demarches, total: demarches.length });
  });

  router.get('/statistiques', (req, res) => {
    res.json({ demandes_en_attente: 18, demandes_a_completer: 7, actes_prets_au_retrait: 12, paiements_du_jour: 9 });
  });

  router.get('/dossiers-demo', (req, res) => {
    res.json({
      data: [
        { reference: 'NIC-2026-00021', type: 'Declaration de naissance', statut: 'En verification', progression: 60, service: 'Etat civil' },
        { reference: 'NIC-2026-00017', type: 'Copie d acte de naissance', statut: 'Pret au retrait', progression: 100, service: 'Etat civil' },
        { reference: 'NIC-2026-00009', type: 'Declaration de deces', statut: 'Pieces complementaires attendues', progression: 35, service: 'Etat civil' },
      ],
      total: 3,
    });
  });

  app.use('/api/commune', router);
};
