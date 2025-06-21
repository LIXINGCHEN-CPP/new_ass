// Backend Configuration
const config = {
  // MongoDB Atlas Connection
  mongodbUri: process.env.MONGODB_URI || 'mongodb+srv://xli503441:lxc159357%40GOD@cluster0.isy9cqv.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0',
  databaseName: 'grocery_store',
  
  // Server Configuration
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  
  // CORS Configuration
  corsOrigin: process.env.CORS_ORIGIN || '*'
};

module.exports = config; 