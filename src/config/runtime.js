function toBool(value, fallback = false) {
  if (value === undefined || value === null || value === '') return fallback;
  return ['1', 'true', 'yes', 'on'].includes(String(value).toLowerCase());
}

function normalizeUrl(value, fallback = '') {
  return String(value || fallback || '').replace(/\/$/, '');
}

function getRuntimeConfig() {
  return {
    nodeEnv: process.env.NODE_ENV || 'development',
    port: Number(process.env.PORT || 3005),
    apiBaseUrl: normalizeUrl(process.env.API_BASE_URL, ''),
    siteBaseUrl: normalizeUrl(process.env.SITE_BASE_URL, ''),
    frontendUrl: normalizeUrl(process.env.FRONTEND_URL, ''),
    databaseUrl: process.env.DATABASE_URL || '',
    adminEmail: process.env.ADMIN_EMAIL || '',
    resendApiKey: process.env.RESEND_API_KEY || '',
    clickhouseEnabled: toBool(process.env.CLICKHOUSE_ENABLED, false),
    clickhouseUrl: normalizeUrl(process.env.CLICKHOUSE_URL, 'http://localhost:8123'),
    clickhouseDb: process.env.CLICKHOUSE_DB || 'opcvm_analytics',
    stablecoinEnabled: false,
    magicEnabled: false,
    roboadvisorMode: 'integrated',
  };
}

const runtimeConfig = getRuntimeConfig();

module.exports = {
  getRuntimeConfig,
  runtimeConfig,
};
