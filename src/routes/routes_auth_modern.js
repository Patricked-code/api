const express = require('express');
const bcrypt = require('bcrypt');
const { users } = require('../db/sequelize');
const { generateToken } = require('../middleware/auth');
const { resolvePanelTarget } = require('../auth/panelResolver');

const router = express.Router();

function sanitizeUser(user) {
  if (!user) return null;
  return {
    id: user.id,
    email: user.email,
    nom: user.nom || null,
    prenoms: user.prenoms || null,
    denomination: user.denomination || null,
    pays: user.pays || null,
    typeusers: user.typeusers || 'investisseur',
    typeusers_id: user.typeusers_id || null,
    active: user.active,
    panel: resolvePanelTarget(user.typeusers),
  };
}

async function findUserByEmail(email) {
  return users.findOne({ where: { email } });
}

router.post('/auth/register', async (req, res) => {
  try {
    const {
      email,
      password,
      nom,
      prenoms,
      denomination,
      pays,
      typeusers,
      typeusers_id,
    } = req.body || {};

    if (!email || !password) {
      return res.status(400).json({ error: 'Email et mot de passe requis' });
    }

    if (String(password).length < 8) {
      return res.status(400).json({ error: 'Le mot de passe doit contenir au moins 8 caractères' });
    }

    const existing = await findUserByEmail(email);
    if (existing) {
      return res.status(409).json({ error: 'Un compte existe déjà pour cet email' });
    }

    const hashedPassword = await bcrypt.hash(String(password), 10);

    const created = await users.create({
      email: String(email).trim().toLowerCase(),
      password: hashedPassword,
      nom: nom || null,
      prenoms: prenoms || null,
      denomination: denomination || null,
      pays: pays || null,
      typeusers: typeusers || 'investisseur',
      typeusers_id: typeusers_id || null,
      active: 1,
    });

    const token = generateToken(created);

    return res.status(201).json({
      message: 'Compte créé avec succès',
      token,
      user: sanitizeUser(created),
    });
  } catch (error) {
    return res.status(500).json({ error: error.message || 'Erreur lors de la création du compte' });
  }
});

router.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body || {};

    if (!email || !password) {
      return res.status(400).json({ error: 'Email et mot de passe requis' });
    }

    const user = await findUserByEmail(String(email).trim().toLowerCase());
    if (!user) {
      return res.status(401).json({ error: 'Identifiants invalides' });
    }

    if (user.active === 0) {
      return res.status(403).json({ error: 'Compte désactivé' });
    }

    const ok = await bcrypt.compare(String(password), String(user.password || ''));
    if (!ok) {
      return res.status(401).json({ error: 'Identifiants invalides' });
    }

    const token = generateToken(user);

    return res.json({
      message: 'Connexion réussie',
      token,
      user: sanitizeUser(user),
    });
  } catch (error) {
    return res.status(500).json({ error: error.message || 'Erreur de connexion' });
  }
});

router.get('/auth/panels', async (req, res) => {
  return res.json({
    panels: [
      'investisseurpanel',
      'societegestionpanel',
      'personnelpanel',
      'adminpanel',
    ],
  });
});

router.post('/api/login-modern', async (req, res) => {
  req.url = '/auth/login';
  return router.handle(req, res);
});

router.post('/api/register-modern', async (req, res) => {
  req.url = '/auth/register';
  return router.handle(req, res);
});

router.get('/api/userlogin-modern', async (req, res) => {
  return res.status(410).json({
    error: 'Route legacy retirée pour raisons de sécurité. Utiliser POST /auth/login',
  });
});

module.exports = router;
