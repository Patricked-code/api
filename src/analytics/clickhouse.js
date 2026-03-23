const { createClient } = require('@clickhouse/client');

function isClickHouseEnabled() {
  return String(process.env.CLICKHOUSE_ENABLED || '').toLowerCase() === 'true';
}

function getClickHouseClient() {
  if (!isClickHouseEnabled()) {
    return null;
  }

  const url = process.env.CLICKHOUSE_URL || 'http://localhost:8123';
  const username = process.env.CLICKHOUSE_USER || 'default';
  const password = process.env.CLICKHOUSE_PASSWORD || '';
  const database = process.env.CLICKHOUSE_DB || 'opcvm_analytics';

  return createClient({
    url,
    username,
    password,
    database,
  });
}

async function pingClickHouse() {
  const client = getClickHouseClient();
  if (!client) {
    return { enabled: false, ok: false };
  }

  try {
    await client.ping();
    return { enabled: true, ok: true };
  } catch (error) {
    return { enabled: true, ok: false, error: error.message };
  }
}

module.exports = {
  isClickHouseEnabled,
  getClickHouseClient,
  pingClickHouse,
};
