require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const helmet = require('helmet');
const sequelize = require('./src/db/sequelize');
const swaggerUI = require('swagger-ui-express');
const swaggerJsDoc = require('swagger-jsdoc');
const { pingClickHouse, isClickHouseEnabled } = require('./src/analytics/clickhouse');

sequelize.initDb();

const app = express();
const port = process.env.PORT || 3005;

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "blob:"],
    },
  },
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));

const allowedOrigins = [
  process.env.FRONTEND_URL || 'http://localhost:3000',
  process.env.SITE_BASE_URL || 'http://localhost:3000',
];

app.use(cors({
  origin: function (origin, callback) {
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin)) return callback(null, true);
    return callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Origin', 'Authorization', 'X-Requested-With', 'Content-Type', 'Accept', 'x-api-key'],
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

const { sanitizeStrings, rateLimit } = require('./src/middleware/validate');
app.use(sanitizeStrings);
app.set('trust proxy', 1);
app.use(rateLimit(200, 15 * 60 * 1000));

if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

const swaggerOptions = {
  failOnErrors: true,
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API OPCVM - Documentation',
      version: '1.1.0',
      description: 'API pour la gestion, l analyse et l extension analytics OPCVM',
    },
    servers: [
      {
        url: process.env.API_BASE_URL || `http://localhost:${port}`,
      },
    ],
  },
  apis: ['./src/routes/*.js'],
};

const specs = swaggerJsDoc(swaggerOptions);
app.use('/api-docs', swaggerUI.serve, swaggerUI.setup(specs));

require('./src/routes/routes_vl')(app);
require('./src/routes/routes_analytics')(app);

app.get('/health', async (req, res) => {
  const clickhouse = await pingClickHouse();

  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {
      mysql: 'configured',
      clickhouse_enabled: isClickHouseEnabled(),
      clickhouse,
    },
  });
});

app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

app.use((err, req, res, next) => {
  console.error(`[${new Date().toISOString()}] Error:`, err.message);

  if (err.message === 'Not allowed by CORS') {
    return res.status(403).json({ error: 'CORS: Origine non autorisée' });
  }

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    error: process.env.NODE_ENV === 'production' ? 'Erreur interne du serveur' : err.message,
  });
});

const server = app.listen(port, async () => {
  const clickhouse = await pingClickHouse();
  console.log(`Serveur analytics démarré sur le port ${port} [${process.env.NODE_ENV || 'development'}]`);
  console.log('Statut ClickHouse au démarrage:', clickhouse);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM reçu. Arrêt gracieux...');
  server.close(() => {
    console.log('Serveur arrêté.');
    process.exit(0);
  });
});
