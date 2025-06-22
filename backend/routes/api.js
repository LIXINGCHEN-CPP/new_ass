const express = require('express');
const router = express.Router();
const database = require('../database');
const emailService = require('../emailService');
const { ObjectId } = require('mongodb');

// Helper function to handle async routes
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Test endpoint
router.get('/test', (req, res) => {
  res.json({ message: 'Grocery Store API is working!', timestamp: new Date() });
});

// Categories endpoints
router.get('/categories', asyncHandler(async (req, res) => {
  try {
    const categories = await database.getCategories();
    res.json({
      success: true,
      data: categories,
      count: categories.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch categories',
      error: error.message
    });
  }
}));

router.get('/categories/:id', asyncHandler(async (req, res) => {
  try {
    const category = await database.getCategoryById(req.params.id);
    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }
    res.json({
      success: true,
      data: category
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch category',
      error: error.message
    });
  }
}));

// Products endpoints
router.get('/products', asyncHandler(async (req, res) => {
  try {
    const filters = {};
    
    // Parse query parameters
    if (req.query.categoryId) filters.categoryId = req.query.categoryId;
    if (req.query.isNew) filters.isNew = req.query.isNew === 'true';
    if (req.query.isPopular) filters.isPopular = req.query.isPopular === 'true';
    if (req.query.isActive) filters.isActive = req.query.isActive === 'true';
    
    const products = await database.getProducts(filters);
    res.json({
      success: true,
      data: products,
      count: products.length,
      filters: filters
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch products',
      error: error.message
    });
  }
}));

router.get('/products/:id', asyncHandler(async (req, res) => {
  try {
    const product = await database.getProductById(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    res.json({
      success: true,
      data: product
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch product',
      error: error.message
    });
  }
}));

// Search products
router.get('/products/search/:term', asyncHandler(async (req, res) => {
  try {
    const searchTerm = req.params.term;
    const products = await database.searchProducts(searchTerm);
    res.json({
      success: true,
      data: products,
      count: products.length,
      searchTerm: searchTerm
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to search products',
      error: error.message
    });
  }
}));

// Create product
router.post('/products', asyncHandler(async (req, res) => {
  try {
    const productData = req.body;
    
    // Validate required fields
    if (!productData.name || !productData.coverImage || !productData.currentPrice) {
      return res.status(400).json({
        success: false,
        message: 'Name, coverImage, and currentPrice are required'
      });
    }
    
    const insertedId = await database.createProduct(productData);
    
    res.status(201).json({
      success: true,
      message: 'Product created successfully',
      data: { id: insertedId.toString() }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create product',
      error: error.message
    });
  }
}));

// Update product
router.put('/products/:id', asyncHandler(async (req, res) => {
  try {
    const productId = req.params.id;
    const updateData = req.body;
    
    const updated = await database.updateProduct(productId, updateData);
    
    if (!updated) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Product updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update product',
      error: error.message
    });
  }
}));

// Bundles endpoints
router.get('/bundles', asyncHandler(async (req, res) => {
  try {
    const filters = {};
    
    // Parse query parameters
    if (req.query.categoryId) filters.categoryId = req.query.categoryId;
    if (req.query.isPopular) filters.isPopular = req.query.isPopular === 'true';
    if (req.query.isActive) filters.isActive = req.query.isActive === 'true';
    
    const bundles = await database.getBundles(filters);
    res.json({
      success: true,
      data: bundles,
      count: bundles.length,
      filters: filters
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch bundles',
      error: error.message
    });
  }
}));

// Get bundle details with populated products
router.get('/bundles/:id', async (req, res) => {
  try {
    const bundleId = req.params.id;
    const db = database.getDb();
    
    let query;
    // Check if it's a valid ObjectId format
    if (ObjectId.isValid(bundleId) && bundleId.length === 24) {
      query = { _id: new ObjectId(bundleId) };
    } else {
      // Treat as string ID (for mock data compatibility)
      query = { $or: [{ id: bundleId }, { name: bundleId }] };
    }
    
    // Add isActive filter
    query.isActive = true;
    
    // Get bundle by ID
    const bundle = await db.collection('bundles').findOne(query);
    
    if (!bundle) {
      return res.status(404).json({ 
        success: false, 
        message: 'Bundle not found' 
      });
    }
    
    // Populate products in bundle items
    if (bundle.items && bundle.items.length > 0) {
      const productIds = bundle.items.map(item => item.productId);
      const products = await db.collection('products').find({
        _id: { $in: productIds },
        isActive: true
      }).toArray();
      
      // Create a map for quick lookup
      const productMap = {};
      products.forEach(product => {
        productMap[product._id.toString()] = product;
      });
      
      // Add product details to bundle items
      bundle.items = bundle.items.map(item => ({
        ...item,
        productDetails: productMap[item.productId.toString()] || null
      }));
    }
    
    res.json({ success: true, data: bundle });
  } catch (error) {
    console.error('Error fetching bundle details:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch bundle details',
      error: error.message 
    });
  }
});

// Create bundle
router.post('/bundles', asyncHandler(async (req, res) => {
  try {
    const bundleData = req.body;
    
    // Validate required fields
    if (!bundleData.name || !bundleData.coverImage || !bundleData.currentPrice) {
      return res.status(400).json({
        success: false,
        message: 'Name, coverImage, and currentPrice are required'
      });
    }
    
    const insertedId = await database.createBundle(bundleData);
    
    res.status(201).json({
      success: true,
      message: 'Bundle created successfully',
      data: { id: insertedId.toString() }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create bundle',
      error: error.message
    });
  }
}));

// Update bundle
router.put('/bundles/:id', asyncHandler(async (req, res) => {
  try {
    const bundleId = req.params.id;
    const updateData = req.body;
    
    const updated = await database.updateBundle(bundleId, updateData);
    
    if (!updated) {
      return res.status(404).json({
        success: false,
        message: 'Bundle not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Bundle updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update bundle',
      error: error.message
    });
  }
}));

// Orders endpoints
router.post('/orders', asyncHandler(async (req, res) => {
  try {
    const { items, totalAmount, originalAmount, savings, paymentMethod, deliveryAddress, userId } = req.body;
    
    // Generate unique order ID
    const orderId = Math.floor(100000000 + Math.random() * 900000000).toString();
    
    const orderData = {
      orderId,
      userId,  // Include user ID in order data
      status: 0, // confirmed
      items,
      totalAmount,
      originalAmount,
      savings,
      paymentMethod,
      deliveryAddress,
      createdAt: new Date(),
      confirmedAt: new Date()
    };
    
    const insertedId = await database.createOrder(orderData);
    
    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: {
        _id: insertedId.toString(),
        orderId,
        ...orderData
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create order',
      error: error.message
    });
  }
}));

router.get('/orders', asyncHandler(async (req, res) => {
  try {
    const filters = {};
    
    // Parse query parameters
    if (req.query.status) filters.status = parseInt(req.query.status);
    
    const orders = await database.getOrders(filters);
    
    // Convert ObjectId to string for all orders
    const serializedOrders = orders.map(order => ({
      ...order,
      _id: order._id.toString(),
      // Convert any nested ObjectIds in items
      items: order.items ? order.items.map(item => ({
        ...item,
        // Convert ObjectIds in productDetails if present
        productDetails: item.productDetails ? {
          ...item.productDetails,
          _id: item.productDetails._id ? item.productDetails._id.toString() : item.productDetails._id
        } : item.productDetails,
        // Convert ObjectIds in bundleDetails if present
        bundleDetails: item.bundleDetails ? {
          ...item.bundleDetails,
          _id: item.bundleDetails._id ? item.bundleDetails._id.toString() : item.bundleDetails._id,
          // Convert ObjectIds in bundle items
          items: item.bundleDetails.items ? item.bundleDetails.items.map(bundleItem => ({
            ...bundleItem,
            productDetails: bundleItem.productDetails ? {
              ...bundleItem.productDetails,
              _id: bundleItem.productDetails._id ? bundleItem.productDetails._id.toString() : bundleItem.productDetails._id
            } : bundleItem.productDetails
          })) : item.bundleDetails.items
        } : item.bundleDetails
      })) : order.items
    }));
    
    res.json({
      success: true,
      data: serializedOrders,
      count: serializedOrders.length,
      filters: filters
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch orders',
      error: error.message
    });
  }
}));

router.get('/orders/:id', asyncHandler(async (req, res) => {
  try {
    const order = await database.getOrderById(req.params.id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    // Convert ObjectId to string
    const serializedOrder = {
      ...order,
      _id: order._id.toString(),
      items: order.items ? order.items.map(item => ({
        ...item,
        productDetails: item.productDetails ? {
          ...item.productDetails,
          _id: item.productDetails._id ? item.productDetails._id.toString() : item.productDetails._id
        } : item.productDetails,
        bundleDetails: item.bundleDetails ? {
          ...item.bundleDetails,
          _id: item.bundleDetails._id ? item.bundleDetails._id.toString() : item.bundleDetails._id,
          items: item.bundleDetails.items ? item.bundleDetails.items.map(bundleItem => ({
            ...bundleItem,
            productDetails: bundleItem.productDetails ? {
              ...bundleItem.productDetails,
              _id: bundleItem.productDetails._id ? bundleItem.productDetails._id.toString() : bundleItem.productDetails._id
            } : bundleItem.productDetails
          })) : item.bundleDetails.items
        } : item.bundleDetails
      })) : order.items
    };
    
    res.json({
      success: true,
      data: serializedOrder
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order',
      error: error.message
    });
  }
}));

router.get('/orders/by-order-id/:orderId', asyncHandler(async (req, res) => {
  try {
    const order = await database.getOrderByOrderId(req.params.orderId);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    // Convert ObjectId to string
    const serializedOrder = {
      ...order,
      _id: order._id.toString(),
      items: order.items ? order.items.map(item => ({
        ...item,
        productDetails: item.productDetails ? {
          ...item.productDetails,
          _id: item.productDetails._id ? item.productDetails._id.toString() : item.productDetails._id
        } : item.productDetails,
        bundleDetails: item.bundleDetails ? {
          ...item.bundleDetails,
          _id: item.bundleDetails._id ? item.bundleDetails._id.toString() : item.bundleDetails._id,
          items: item.bundleDetails.items ? item.bundleDetails.items.map(bundleItem => ({
            ...bundleItem,
            productDetails: bundleItem.productDetails ? {
              ...bundleItem.productDetails,
              _id: bundleItem.productDetails._id ? bundleItem.productDetails._id.toString() : bundleItem.productDetails._id
            } : bundleItem.productDetails
          })) : item.bundleDetails.items
        } : item.bundleDetails
      })) : order.items
    };
    
    res.json({
      success: true,
      data: serializedOrder
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order',
      error: error.message
    });
  }
}));

router.put('/orders/:id/status', asyncHandler(async (req, res) => {
  try {
    const { status } = req.body;
    const result = await database.updateOrderStatus(req.params.id, status);
    
    if (result.matchedCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Order status updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update order status',
      error: error.message
    });
  }
}));

// Get orders by user ID
router.get('/users/:userId/orders', asyncHandler(async (req, res) => {
  try {
    const orders = await database.getOrdersByUserId(req.params.userId);
    
    // Convert ObjectId to string for all orders
    const serializedOrders = orders.map(order => ({
      ...order,
      _id: order._id.toString(),
      items: order.items ? order.items.map(item => ({
        ...item,
        productDetails: item.productDetails ? {
          ...item.productDetails,
          _id: item.productDetails._id ? item.productDetails._id.toString() : item.productDetails._id
        } : item.productDetails,
        bundleDetails: item.bundleDetails ? {
          ...item.bundleDetails,
          _id: item.bundleDetails._id ? item.bundleDetails._id.toString() : item.bundleDetails._id,
          items: item.bundleDetails.items ? item.bundleDetails.items.map(bundleItem => ({
            ...bundleItem,
            productDetails: bundleItem.productDetails ? {
              ...bundleItem.productDetails,
              _id: bundleItem.productDetails._id ? bundleItem.productDetails._id.toString() : bundleItem.productDetails._id
            } : bundleItem.productDetails
          })) : item.bundleDetails.items
        } : item.bundleDetails
      })) : order.items
    }));
    
    res.json({
      success: true,
      data: serializedOrders,
      count: serializedOrders.length,
      userId: req.params.userId
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user orders',
      error: error.message
    });
  }
}));

// Users endpoints
router.post('/users/register', asyncHandler(async (req, res) => {
  try {
    const { name, phone, password, email } = req.body;
    
    // Validate required fields
    if (!name || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, phone, and password are required'
      });
    }
    
    // Check if user already exists
    const existingUser = await database.getUserByPhone(phone);
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'Phone number already registered'
      });
    }
    
    // Create user
    const insertedId = await database.createUser({
      name,
      phone,
      password,
      email
    });
    
    // Get created user (without password)
    const user = await database.getUserById(insertedId);
    
    if (!user) {
      return res.status(500).json({
        success: false,
        message: 'User created but could not retrieve user data'
      });
    }
    
    const { password: _, ...userWithoutPassword } = user;
    
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        ...userWithoutPassword,
        _id: insertedId.toString()
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Registration failed',
      error: error.message
    });
  }
}));

router.post('/users/login', asyncHandler(async (req, res) => {
  try {
    const { phone, password } = req.body;
    
    // Validate required fields
    if (!phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Phone and password are required'
      });
    }
    
    // Authenticate user
    const user = await database.loginUser(phone, password);
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password'
      });
    }
    
    res.json({
      success: true,
      message: 'Login successful',
      data: {
        ...user,
        _id: user._id.toString()
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Login failed',
      error: error.message
    });
  }
}));

router.get('/users/:id', asyncHandler(async (req, res) => {
  try {
    const user = await database.getUserById(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;
    
    res.json({
      success: true,
      data: {
        ...userWithoutPassword,
        _id: user._id.toString()
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user',
      error: error.message
    });
  }
}));

router.get('/users/phone/:phone', asyncHandler(async (req, res) => {
  try {
    const user = await database.getUserByPhone(req.params.phone);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;
    
    res.json({
      success: true,
      data: {
        ...userWithoutPassword,
        _id: user._id.toString()
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user',
      error: error.message
    });
  }
}));

router.put('/users/:id', asyncHandler(async (req, res) => {
  try {
    const { name, email, address, profileImage } = req.body;
    
    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (email !== undefined) updateData.email = email;
    if (address !== undefined) updateData.address = address;
    if (profileImage !== undefined) updateData.profileImage = profileImage;
    
    const updatedUser = await database.updateUser(req.params.id, updateData);
    
    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    // Remove password from response
    const { password: _, ...userWithoutPassword } = updatedUser;
    
    res.json({
      success: true,
      message: 'User updated successfully',
      data: {
        ...userWithoutPassword,
        _id: updatedUser._id.toString()
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update user',
      error: error.message
    });
  }
}));

// Password Reset endpoints
router.post('/auth/forgot-password', asyncHandler(async (req, res) => {
  try {
    const { email } = req.body;
    
    // Validate required fields
    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }
    
    // Check if user exists with this email
    const user = await database.getUserByEmail(email);
    
    if (!user) {
      // For security, don't reveal if email exists or not
      return res.json({
        success: true,
        message: 'If an account with this email exists, you will receive a password reset code.'
      });
    }
    
    // Generate 4-digit verification code
    const verificationCode = emailService.generateVerificationCode();
    
    // Store code in database
    try {
      await database.createPasswordResetCode(email, verificationCode);
    } catch (error) {
      if (error.message.includes('Please wait')) {
        return res.status(429).json({
          success: false,
          message: error.message
        });
      }
      throw error; // Re-throw if it's a different error
    }
    
    // Send email with verification code
    const emailResult = await emailService.sendPasswordResetCode(email, verificationCode);
    
    if (!emailResult.success) {
      return res.status(500).json({
        success: false,
        message: 'Failed to send verification email'
      });
    }
    
    res.json({
      success: true,
      message: 'Verification code sent to your email',
      debug: {
        code: verificationCode,
        previewUrl: emailResult.previewUrl || false
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to process password reset request',
      error: error.message
    });
  }
}));

router.post('/auth/verify-reset-code', asyncHandler(async (req, res) => {
  try {
    const { email, code } = req.body;
    
    // Validate required fields
    if (!email || !code) {
      return res.status(400).json({
        success: false,
        message: 'Email and verification code are required'
      });
    }
    
    // Verify the code
    const isValid = await database.verifyPasswordResetCode(email, code);
    
    if (isValid) {
      res.json({
        success: true,
        message: 'Verification code is valid'
      });
    } else {
      res.status(400).json({
        success: false,
        message: 'Invalid or expired verification code'
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to verify code',
      error: error.message
    });
  }
}));

router.post('/auth/reset-password', asyncHandler(async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;
    
    // Validate required fields
    if (!email || !code || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Email, verification code, and new password are required'
      });
    }
    
    // Validate password strength
    if (newPassword.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long'
      });
    }
    
    // Check for special characters
    const specialCharPattern = /[#?!@$%^&*-]/;
    if (!specialCharPattern.test(newPassword)) {
      return res.status(400).json({
        success: false,
        message: 'Password must contain at least one special character (#?!@$%^&*-)'
      });
    }
    
    // Verify the code again
    const isValid = await database.verifyPasswordResetCode(email, code);
    
    if (!isValid) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired verification code'
      });
    }
    
    // Update password
    const passwordUpdated = await database.updateUserPassword(email, newPassword);
    
    if (!passwordUpdated) {
      return res.status(500).json({
        success: false,
        message: 'Failed to update password'
      });
    }
    
    // Mark code as used
    await database.markPasswordResetCodeAsUsed(email, code);
    
    res.json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to reset password',
      error: error.message
    });
  }
}));

// Error handling middleware
router.use((error, req, res, next) => {
  console.error('API Error:', error);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: error.message
  });
});

module.exports = router; 