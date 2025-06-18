const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const config = require('./config');
const database = require('./database');
const apiRoutes = require('./routes/api');

const app = express();

// Security middleware
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests, please try again later'
  }
});
app.use('/api/', limiter);

// CORS configuration
app.use(cors({
  origin: config.corsOrigin,
  credentials: true
}));

// Logging middleware
app.use(morgan('combined'));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date(),
    uptime: process.uptime(),
    environment: config.nodeEnv
  });
});

// API routes
app.use('/api', apiRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Grocery Store Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      api: '/api',
      categories: '/api/categories',
      products: '/api/products',
      bundles: '/api/bundles'
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'API endpoint not found',
    path: req.originalUrl
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Server Error:', error);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: config.nodeEnv === 'development' ? error.message : 'Internal error'
  });
});

// Start server
async function startServer() {
  try {
    // Connect to database
    const connected = await database.connect();
    if (!connected) {
      console.error('Failed to connect to database, server startup failed');
      process.exit(1);
    }

    // Start HTTP server
    const server = app.listen(config.port, '0.0.0.0', () => {
      console.log(`Server started successfully`);
      console.log(`Port: ${config.port}`);
      console.log(`Environment: ${config.nodeEnv}`);
      console.log(`API URL: http://localhost:${config.port}/api`);
      console.log(`Android Emulator: http://10.0.2.2:${config.port}/api`);
      console.log(`Health Check: http://localhost:${config.port}/health`);
    });

    // Graceful shutdown
    process.on('SIGTERM', async () => {
      console.log('Shutting down server...');
      server.close(async () => {
        await database.disconnect();
        console.log('Server closed');
        process.exit(0);
      });
    });

    process.on('SIGINT', async () => {
      console.log('Shutting down server...');
      server.close(async () => {
        await database.disconnect();
        console.log('Server closed');
        process.exit(0);
      });
    });

  } catch (error) {
    console.error('Server startup failed:', error);
    process.exit(1);
  }
}

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled promise rejection:', reason);
  process.exit(1);
});

startServer(); 