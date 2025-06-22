// Backend Configuration
const config = {
  // MongoDB Atlas Connection
  mongodbUri: process.env.MONGODB_URI,
  databaseName: 'grocery_store',
  
  // Server Configuration
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  
  // CORS Configuration
  corsOrigin: process.env.CORS_ORIGIN || '*'
};

module.exports = config; 