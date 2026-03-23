function registerStableRoutes(app) {
  if (!app || typeof app.use !== 'function') {
    throw new Error('Express app instance required');
  }

  app.use(require('../routes/routes_auth_modern'));
  app.use(require('../routes/routes_legacy_deprecations'));

  if (typeof require('../routes/routes_analytics') === 'function') {
    require('../routes/routes_analytics')(app);
  }

  if (typeof require('../routes/routes_vl') === 'function') {
    require('../routes/routes_vl')(app);
  }
}

module.exports = {
  registerStableRoutes,
};
