require('dotenv').config();

const { vl } = require('../src/db/sequelize');
const { getClickHouseClient, isClickHouseEnabled } = require('../src/analytics/clickhouse');

async function run() {
  if (!isClickHouseEnabled()) {
    console.log('ClickHouse non activé. Définir CLICKHOUSE_ENABLED=true pour lancer la synchronisation.');
    process.exit(0);
  }

  const client = getClickHouseClient();
  if (!client) {
    throw new Error('Client ClickHouse indisponible');
  }

  const rows = await vl.findAll({
    raw: true,
    limit: parseInt(process.env.CLICKHOUSE_SYNC_LIMIT || '5000', 10),
    order: [['date', 'DESC']],
  });

  const payload = rows.map((row) => ({
    fund_id: Number(row.fund_id || 0),
    fund_name: String(row.fund_name || ''),
    valuation_date: row.date,
    nav_local: Number(row.value || 0),
    nav_usd: Number(row.value_USD || 0),
    nav_eur: Number(row.value_EUR || 0),
    adjusted_nav_local: Number(row.vl_ajuste || 0),
    adjusted_nav_usd: Number(row.vl_ajuste_USD || 0),
    adjusted_nav_eur: Number(row.vl_ajuste_EUR || 0),
    dividend_local: Number(row.dividende || 0),
    dividend_usd: Number(row.dividende_USD || 0),
    dividend_eur: Number(row.dividende_EUR || 0),
    benchmark_name: String(row.indice_name || ''),
    benchmark_value_local: Number(row.indRef || 0),
    benchmark_value_usd: Number(row.indRef_USD || 0),
    benchmark_value_eur: Number(row.indRef_EUR || 0),
    aum_local: Number(row.actif_net || 0),
    aum_usd: Number(row.actif_net_USD || 0),
    aum_eur: Number(row.actif_net_EUR || 0),
    subscription_price: Number(row.souscription || 0),
    redemption_price: Number(row.rachat || 0),
  }));

  if (!payload.length) {
    console.log('Aucune ligne de valorisation à synchroniser.');
    process.exit(0);
  }

  await client.insert({
    table: 'fund_navs_daily',
    values: payload,
    format: 'JSONEachRow',
  });

  console.log(`${payload.length} lignes synchronisées vers ClickHouse.`);
}

run()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Erreur de synchronisation ClickHouse:', error.message);
    process.exit(1);
  });
