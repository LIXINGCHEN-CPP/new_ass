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

  // Orders
  async createOrder(orderData) {
    const db = this.getDb();
    const result = await db.collection('orders').insertOne({
      ...orderData,
      createdAt: new Date(),
      confirmedAt: new Date() // Auto-confirm orders for now
    });
    return result.insertedId;
  }

  async getOrders(filters = {}) {
    const db = this.getDb();
    const query = {};
    
    if (filters.status !== undefined) {
      query.status = filters.status;
    }
    
    return await db.collection('orders').find(query).sort({ createdAt: -1 }).toArray();
  }

  async getOrderById(id) {
    const db = this.getDb();
    return await db.collection('orders').findOne({ _id: new require('mongodb').ObjectId(id) });
  }

  async getOrderByOrderId(orderId) {
    const db = this.getDb();
    return await db.collection('orders').findOne({ orderId: orderId });
  }

  async updateOrderStatus(id, status, timestamp = null) {
    const db = this.getDb();
    const updateData = { status };
    
    // Add timestamp based on status
    const now = timestamp || new Date();
    switch (status) {
      case 0: // confirmed
        updateData.confirmedAt = now;
        break;
      case 1: // processing
        updateData.processingAt = now;
        break;
      case 2: // shipped
        updateData.shippedAt = now;
        break;
      case 3: // delivery
        updateData.deliveredAt = now;
        break;
      case 4: // cancelled
        updateData.cancelledAt = now;
        break;
    }

    return await db.collection('orders').updateOne(
      { _id: new require('mongodb').ObjectId(id) },
      { $set: updateData }
    );
  }
}

module.exports = new Database(); 