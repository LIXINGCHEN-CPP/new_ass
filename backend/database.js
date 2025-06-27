const { MongoClient, ObjectId } = require('mongodb');
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
    return await db.collection('categories').findOne({ _id: new ObjectId(id) });
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
    return await db.collection('products').findOne({ _id: new ObjectId(id) });
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
    return await db.collection('bundles').findOne({ _id: new ObjectId(id) });
  }

  // Products CRUD operations
  async createProduct(productData) {
    const db = this.getDb();
    const result = await db.collection('products').insertOne({
      ...productData,
      createdAt: new Date(),
      updatedAt: new Date(),
      isActive: true
    });
    return result.insertedId;
  }

  async updateProduct(id, updateData) {
    const db = this.getDb();
    const result = await db.collection('products').updateOne(
      { _id: new ObjectId(id) },
      {
        $set: {
          ...updateData,
          updatedAt: new Date()
        }
      }
    );
    return result.matchedCount > 0;
  }

  // Bundles CRUD operations
  async createBundle(bundleData) {
    const db = this.getDb();
    const result = await db.collection('bundles').insertOne({
      ...bundleData,
      createdAt: new Date(),
      updatedAt: new Date(),
      isActive: true
    });
    return result.insertedId;
  }

  async updateBundle(id, updateData) {
    const db = this.getDb();
    const result = await db.collection('bundles').updateOne(
      { _id: new ObjectId(id) },
      {
        $set: {
          ...updateData,
          updatedAt: new Date()
        }
      }
    );
    return result.matchedCount > 0;
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
    if (filters.userId) {
      query.userId = filters.userId;
    }

    return await db.collection('orders').find(query).sort({ createdAt: -1 }).toArray();
  }

  async getOrdersByUserId(userId) {
    const db = this.getDb();
    return await db.collection('orders').find({ userId: userId }).sort({ createdAt: -1 }).toArray();
  }

  async getOrderById(id) {
    const db = this.getDb();
    return await db.collection('orders').findOne({ _id: new ObjectId(id) });
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
      { _id: new ObjectId(id) },
      { $set: updateData }
    );
  }

  // Users
  async createUser(userData) {
    const db = this.getDb();
    const bcrypt = require('bcrypt');

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(userData.password, saltRounds);

    const result = await db.collection('users').insertOne({
      name: userData.name,
      phone: userData.phone,
      email: userData.email,
      gender: userData.gender,
      birthday: userData.birthday,
      password: hashedPassword,
      createdAt: new Date(),
      updatedAt: new Date(),
      isActive: true
    });

    return result.insertedId;
  }

  async getUserById(id) {
    const db = this.getDb();
    return await db.collection('users').findOne({
      _id: new ObjectId(id),
      isActive: true
    });
  }

  async getUserByPhone(phone) {
    const db = this.getDb();
    return await db.collection('users').findOne({
      phone: phone,
      isActive: true
    });
  }

  async loginUser(phone, password) {
    const db = this.getDb();
    const bcrypt = require('bcrypt');

    const user = await db.collection('users').findOne({
      phone: phone,
      isActive: true
    });

    if (!user) {
      return null;
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return null;
    }

    // Remove password from returned user object
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  async updateUser(id, updateData) {
    const db = this.getDb();

    const result = await db.collection('users').updateOne(
      { _id: new ObjectId(id) },
      {
        $set: {
          ...updateData,
          updatedAt: new Date()
        }
      }
    );

    if (result.matchedCount === 0) {
      return null;
    }

    return await this.getUserById(id);
  }

  // Password Reset Methods
  async getUserByEmail(email) {
    const db = this.getDb();
    return await db.collection('users').findOne({
      email: email,
      isActive: true
    });
  }

  async getUsersByEmail(email) {
    const db = this.getDb();
    return await db.collection('users').find({
      email: email,
      isActive: true
    }).toArray();
  }

  async getUserByEmailAndPhone(email, phone) {
    const db = this.getDb();
    return await db.collection('users').findOne({
      email: email,
      phone: phone,
      isActive: true
    });
  }

  async createPasswordResetCode(email, code) {
    const db = this.getDb();
    const expiryTime = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes from now

    // Check if there's a recent request (within 1 minute) to prevent spam
    const recentRequest = await db.collection('password_reset_codes').findOne({
      email: email,
      createdAt: { $gt: new Date(Date.now() - 60 * 1000) } // Within last minute
    });

    if (recentRequest) {
      throw new Error('Please wait before requesting another verification code');
    }

    // Remove any existing codes for this email
    await db.collection('password_reset_codes').deleteMany({ email: email });

    const result = await db.collection('password_reset_codes').insertOne({
      email: email,
      code: code,
      createdAt: new Date(),
      expiresAt: expiryTime,
      isUsed: false,
      attemptCount: 0 // Track verification attempts
    });

    return result.insertedId;
  }

  async verifyPasswordResetCode(email, code) {
    const db = this.getDb();

    // Find the reset record first
    const resetRecord = await db.collection('password_reset_codes').findOne({
      email: email,
      isUsed: false,
      expiresAt: { $gt: new Date() }
    });

    if (!resetRecord) {
      return false;
    }

    // Check if too many attempts have been made
    if (resetRecord.attemptCount >= 5) {
      // Mark as used to prevent further attempts
      await db.collection('password_reset_codes').updateOne(
        { _id: resetRecord._id },
        { $set: { isUsed: true, usedAt: new Date() } }
      );
      return false;
    }


    const codeMatches = String(resetRecord.code) === String(code);

    if (codeMatches) {

      await db.collection('password_reset_codes').updateOne(
        { _id: resetRecord._id },
        { $inc: { attemptCount: 1 } }
      );
      return true;
    } else {

      await db.collection('password_reset_codes').updateOne(
        { _id: resetRecord._id },
        { $inc: { attemptCount: 1 } }
      );
      return false;
    }
  }

  async markPasswordResetCodeAsUsed(email, code) {
    const db = this.getDb();
    await db.collection('password_reset_codes').updateOne(
      { email: email, code: code },
      { $set: { isUsed: true, usedAt: new Date() } }
    );
  }

  async updateUserPassword(email, newPassword, phone = null) {
    const db = this.getDb();
    const bcrypt = require('bcrypt');

    // Hash new password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

    // If phone is provided, use both email and phone to identify user
    const query = phone ?
      { email: email, phone: phone, isActive: true } :
      { email: email, isActive: true };

    const result = await db.collection('users').updateOne(
      query,
      {
        $set: {
          password: hashedPassword,
          updatedAt: new Date()
        }
      }
    );

    return result.matchedCount > 0;
  }

  // Clean up expired password reset codes (should be called periodically)
  async cleanupExpiredPasswordResetCodes() {
    const db = this.getDb();
    await db.collection('password_reset_codes').deleteMany({
      expiresAt: { $lt: new Date() }
    });
  }

  // Change user password with current password verification
  async changeUserPassword(userId, currentPassword, newPassword) {
    const db = this.getDb();
    const bcrypt = require('bcrypt');

    // Get user
    const user = await db.collection('users').findOne({
      _id: new ObjectId(userId),
      isActive: true
    });

    if (!user) {
      return false;
    }

    // Verify current password
    const passwordMatch = await bcrypt.compare(currentPassword, user.password);
    if (!passwordMatch) {
      return false;
    }

    // Hash new password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    const result = await db.collection('users').updateOne(
      { _id: new ObjectId(userId) },
      {
        $set: {
          password: hashedPassword,
          updatedAt: new Date()
        }
      }
    );

    return result.matchedCount > 0;
  }

  // Delete user account permanently
  async deleteUser(userId, currentPassword) {
    const db = this.getDb();
    const bcrypt = require('bcrypt');

    try {
     
      const user = await db.collection('users').findOne({
        _id: new ObjectId(userId),
        isActive: true
      });

      if (!user) {
        return { success: false, message: 'User not found' };
      }

     
      const passwordMatch = await bcrypt.compare(currentPassword, user.password);
      if (!passwordMatch) {
        return { success: false, message: 'Invalid password' };
      }

      // Start transaction for data integrity
      const session = this.client.startSession();
      
      try {
        await session.withTransaction(async () => {
          
          await db.collection('orders').deleteMany({ userId: userId }, { session });
          
          
          await db.collection('password_reset_codes').deleteMany({ 
            email: user.email 
          }, { session });
          
          
          await db.collection('orders').deleteMany({ userId: userId }, { session });
          
          
          await db.collection('password_reset_codes').deleteMany({ 
            email: user.email 
          }, { session });
          
          // Delete user's cards
          await db.collection('user_cards').deleteMany({ userId: userId }, { session });
          
          
          await db.collection('users').deleteOne({ 
            _id: new ObjectId(userId) 
          }, { session });
        });
        
        return { success: true, message: 'Account deleted successfully' };
      } catch (error) {
        console.error('Error during user deletion transaction:', error);
        return { success: false, message: 'Failed to delete account' };
      } finally {
        await session.endSession();
      }
    } catch (error) {
      console.error('Error deleting user:', error);
      return { success: false, message: 'Failed to delete account' };
    }
  }

  // Card Management Methods
  async createCard(cardData) {
    const db = this.getDb();
    
    try {
      // If this is set as default, unset all other default cards for this user
      if (cardData.isDefault) {
        await db.collection('user_cards').updateMany(
          { userId: cardData.userId },
          { $set: { isDefault: false } }
        );
      }

      const result = await db.collection('user_cards').insertOne({
        ...cardData,
        createdAt: new Date(),
        updatedAt: new Date()
      });

      return result.insertedId;
    } catch (error) {
      console.error('Error creating card:', error);
      throw error;
    }
  }

  async getUserCards(userId) {
    const db = this.getDb();
    
    try {
      const cards = await db.collection('user_cards').find({
        userId: userId
      }).sort({ createdAt: -1 }).toArray();

      return cards;
    } catch (error) {
      console.error('Error fetching user cards:', error);
      throw error;
    }
  }

  async updateCard(cardId, updateData) {
    const db = this.getDb();
    
    try {
      // If setting as default, unset all other default cards for this user
      if (updateData.isDefault) {
        const card = await db.collection('user_cards').findOne({ _id: new ObjectId(cardId) });
        if (card) {
          await db.collection('user_cards').updateMany(
            { userId: card.userId, _id: { $ne: new ObjectId(cardId) } },
            { $set: { isDefault: false } }
          );
        }
      }

      const result = await db.collection('user_cards').updateOne(
        { _id: new ObjectId(cardId) },
        { 
          $set: {
            ...updateData,
            updatedAt: new Date()
          }
        }
      );

      return result.matchedCount > 0;
    } catch (error) {
      console.error('Error updating card:', error);
      throw error;
    }
  }

  async deleteCard(cardId, userId) {
    const db = this.getDb();
    
    try {
      const result = await db.collection('user_cards').deleteOne({
        _id: new ObjectId(cardId),
        userId: userId
      });

      return result.deletedCount > 0;
    } catch (error) {
      console.error('Error deleting card:', error);
      throw error;
    }
  }

  async getCardById(cardId) {
    const db = this.getDb();
    
    try {
      const card = await db.collection('user_cards').findOne({
        _id: new ObjectId(cardId)
      });

      return card;
    } catch (error) {
      console.error('Error fetching card by ID:', error);
      throw error;
    }
  }
}

module.exports = new Database(); 