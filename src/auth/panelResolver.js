function normalizeRole(value) {
  return String(value || '')
    .trim()
    .toLowerCase()
    .replace(/\s+/g, '_');
}

function resolvePanelTarget(role) {
  const normalized = normalizeRole(role);

  if (!normalized) {
    return 'investisseurpanel';
  }

  if (normalized.includes('admin')) {
    return 'adminpanel';
  }

  if (normalized.includes('societe') || normalized.includes('gestion')) {
    return 'societegestionpanel';
  }

  if (normalized.includes('personnel') || normalized.includes('staff')) {
    return 'personnelpanel';
  }

  return 'investisseurpanel';
}

module.exports = {
  normalizeRole,
  resolvePanelTarget,
};
