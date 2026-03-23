const { pingClickHouse, isClickHouseEnabled } = require('../analytics/clickhouse');

module.exports = function (app) {
  app.get('/analytics/health', async (req, res) => {
    const clickhouse = await pingClickHouse();

    res.json({
      module: 'analytics',
      clickhouse_enabled: isClickHouseEnabled(),
      clickhouse,
      timestamp: new Date().toISOString(),
    });
  });

  app.get('/analytics/capabilities', async (req, res) => {
    res.json({
      module: 'analytics',
      status: 'available',
      features: [
        'clickhouse_optional',
        'fund_navs_daily',
        'portfolio_positions_daily',
        'fund_performance_monthly',
        'mysql_to_clickhouse_sync_ready'
      ],
      timestamp: new Date().toISOString(),
    });
  });
};
