const { MongoClient } = require('mongodb');
const config = require('./config');

class Database {
  constructor() {
    this.client = null;
    this.db = null;
  }

  async connect() {
    try {
      console.log('Connecting to MongoDB Atlas...');
      this.client = new MongoClient(config.mongodbUri);
      await this.client.connect();
      this.db = this.client.db(config.databaseName);
      // Ensure a text index on the product name field for efficient full-text search (runs only if not created)
      await this.db.collection('products').createIndex({ name: 'text' });
      console.log('Successfully connected to MongoDB Atlas');
      return true;
    } catch (error) {
      console.error('MongoDB connection failed:', error);
      return false;
    }
  }

  async disconnect() {
    if (this.client) {
      await this.client.close();
      console.log('MongoDB connection closed');
    }
  }

  getDb() {
    if (!this.db) {
      throw new Error('Database not connected');
    }
    return this.db;
  }

  // Categories
  async getCategories() {
    const db = this.getDb();
    return await db.collection('categories').find({}).sort({ sortOrder: 1 }).toArray();
  }

  async getCategoryById(id) {
    const db = this.getDb();
    return await db.collection('categories').findOne({ _id: new require('mongodb').ObjectId(id) });
  }

  // Products
  async getProducts(filters = {}) {
    const db = this.getDb();
    const query = {};
    
    if (filters.categoryId) {
      query.categoryId = filters.categoryId;
    }
    if (filters.isNew !== undefined) {
      query.isNew = filters.isNew;
    }
    if (filters.isPopular !== undefined) {
      query.isPopular = filters.isPopular;
    }
    if (filters.isActive !== undefined) {
      query.isActive = filters.isActive;
    }

    return await db.collection('products').find(query).toArray();
  }

  async getProductById(id) {
    const db = this.getDb();
    return await db.collection('products').findOne({ _id: new require('mongodb').ObjectId(id) });
  }

  async searchProducts(searchTerm) {
    const db = this.getDb();

    // 1. Try using MongoDB text search on the name field (requires the index ensured in connect())
    try {
      const textResults = await db.collection('products')
        .find(
          { $text: { $search: searchTerm } },
          { projection: { score: { $meta: 'textScore' } } }
        )
        .sort({ score: { $meta: 'textScore' } })
        .toArray();

      if (textResults.length) {
        return textResults;
      }
    } catch (err) {
      console.error('Text search failed, falling back to regex search:', err);
    }

    // 2. Fallback: case-insensitive regex that matches only the name field
    return await db.collection('products').find({
      name: { $regex: searchTerm, $options: 'i' }
    }).toArray();
  }

  // Bundles
  async getBundles(filters = {}) {
    const db = this.getDb();
    const query = {};
    
    if (filters.categoryId) {
      query.categoryId = filters.categoryId;
    }
    if (filters.isPopular !== undefined) {
      query.isPopular = filters.isPopular;
    }
    if (filters.isActive !== undefined) {
      query.isActive = filters.isActive;
    }

    return await db.collection('bundles').find(query).toArray();
  }

  async getBundleById(id) {
    const db = this.getDb();
    return await db.collection('bundles').findOne({ _id: new require('mongodb').ObjectId(id) });
  }
}

module.exports = new Database(); 