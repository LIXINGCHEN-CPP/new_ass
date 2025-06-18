const express = require('express');
const router = express.Router();
const database = require('../database');
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