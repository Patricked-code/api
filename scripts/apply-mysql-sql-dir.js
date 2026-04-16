require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { URL } = require('url');

function parseMysqlDatabaseUrl(databaseUrl) {
  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required');
  }

  const url = new URL(databaseUrl);
  const protocol = String(url.protocol || '').replace(':', '');
  if (!['mysql', 'mysql2', 'mariadb'].includes(protocol)) {
    throw new Error(`Unsupported DATABASE_URL protocol: ${protocol}`);
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

async function run() {
  const config = parseMysqlDatabaseUrl(process.env.DATABASE_URL);
  const sqlDir = path.join(process.cwd(), 'database', 'mysql');

  if (!fs.existsSync(sqlDir)) {
    console.log('No MySQL SQL directory found, skipping.');
    return;
  }

  const files = fs
    .readdirSync(sqlDir)
    .filter((file) => file.endsWith('.sql'))
    .sort();

  if (!files.length) {
    console.log('No MySQL SQL files to apply.');
    return;
  }

  const connection = await mysql.createConnection({
    host: config.host,
    port: config.port,
    user: config.user,
    password: config.password,
    database: config.database,
    multipleStatements: true,
  });

  try {
    for (const file of files) {
      const fullPath = path.join(sqlDir, file);
      const sql = fs.readFileSync(fullPath, 'utf8');
      console.log(`Applying MySQL SQL file: ${file}`);
      await connection.query(sql);
    }
  } finally {
    await connection.end();
  }
}

run()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Failed to apply MySQL SQL files:', error.message);
    process.exit(1);
  });
