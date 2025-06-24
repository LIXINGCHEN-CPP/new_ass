const express = require('express');
const router = express.Router();
const stripeService = require('../stripeService');

// Async handler wrapper
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Create payment link - the only route actually used
router.post('/create-payment-link', asyncHandler(async (req, res) => {
  try {
    const { items, amount, currency, userId, locale } = req.body;
    
    // Validate required fields
    if (!items || !amount || !Array.isArray(items)) {
      return res.status(400).json({
        success: false,
        message: 'Items and amount are required'
      });
    }
    
    // Create Stripe checkout session
    const stripeResult = await stripeService.createCheckoutSession({
      items,
      amount,
      currency,
      userId,
      locale
    });
    
    if (stripeResult.success) {
      res.json({
        success: true,
        message: 'Payment link created successfully',
        data: {
          paymentUrl: stripeResult.data.url,
          sessionId: stripeResult.data.id,
          status: stripeResult.data.status || 'open'
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to create payment link',
        error: stripeResult.error
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Payment link creation failed',
      error: error.message
    });
  }
}));

module.exports = router; 