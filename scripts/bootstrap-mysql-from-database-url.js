require('dotenv').config();
const mysql = require('mysql2/promise');
const { URL } = require('url');

function parseMysqlDatabaseUrl(databaseUrl) {
  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required');
  }

  const url = new URL(databaseUrl);
  const protocol = String(url.protocol || '').replace(':', '');

  if (!['mysql', 'mysql2', 'mariadb'].includes(protocol)) {
    throw new Error(`Unsupported DATABASE_URL protocol for bootstrap: ${protocol}`);
  }

  const database = (url.pathname || '').replace(/^\//, '');
  if (!database) {
    throw new Error('DATABASE_URL must include a database name');
  }

  return {
    host: url.hostname,
    port: Number(url.port || 3306),
    user: decodeURIComponent(url.username || ''),
    password: decodeURIComponent(url.password || ''),
    database,
  };
}

async function ensureDatabaseExists() {
  const config = parseMysqlDatabaseUrl(process.env.DATABASE_URL);

  const connection = await mysql.createConnection({
    host: config.host,
    port: config.port,
    user: config.user,
    password: config.password,
    multipleStatements: false,
  });

  try {
    await connection.query(
      `CREATE DATABASE IF NOT EXISTS \`${config.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
    );
    console.log(`Database ensured: ${config.database}`);
  } finally {
    await connection.end();
  }
}

ensureDatabaseExists()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Database bootstrap failed:', error.message);
    process.exit(1);
  });
