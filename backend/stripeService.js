const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY || 'sk_test_51234567890abcdef');

class StripeService {
  constructor() {
    this.stripe = stripe;
  }

  /**
   * Create Stripe checkout session for payment link
   * Only function actually used by frontend for this presentation
   * Because the android studio is too limited, no need to create real request session
   */
  async createCheckoutSession(paymentData) {
    try {
      const { items, amount, currency = 'usd', userId, locale = 'en' } = paymentData;
      
      console.log('Creating Stripe session with locale:', locale);
      
      const description = items.length > 0 ? 
        `${items[0].productName}${items.length > 1 ? ` and ${items.length - 1} more items` : ''}` : 
        'Grocery order';

      const lineItems = [{
        price_data: {
          currency: currency,
          product_data: {
            name: 'Grocery Order',
            description: description,
          },
          unit_amount: Math.round(amount),
        },
        quantity: 1,
      }];

      const session = await this.stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        line_items: lineItems,
        mode: 'payment',
        locale: 'en',
        success_url: 'https://example.com/success',
        cancel_url: 'https://example.com/cancel',
      });

      return {
        success: true,
        data: {
          id: session.id,
          url: session.url,
          status: session.status,
          amount_total: session.amount_total,
          currency: session.currency,
        }
      };
    } catch (error) {
      console.error('Stripe create checkout session error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  async createPaymentIntent(paymentData) {
    try {
      const { items, amount, currency = 'usd', userId } = paymentData;
      

      const description = items.length > 0 ? 
        `${items[0].productName}${items.length > 1 ? ` and ${items.length - 1} more items` : ''}` : 
        'Grocery order';


      const paymentIntent = await this.stripe.paymentIntents.create({
        amount: Math.round(amount), 
        currency: currency,
        description: description,
        metadata: {
          userId: userId || 'guest',
          itemCount: items.length.toString(),
          orderId: `ORDER_${Date.now()}`,
        },
        automatic_payment_methods: {
          enabled: true,
        },
      });

      return {
        success: true,
        data: {
          clientSecret: paymentIntent.client_secret,
          paymentIntentId: paymentIntent.id,
          amount: paymentIntent.amount,
          currency: paymentIntent.currency,
        }
      };
    } catch (error) {
      console.error('Stripe create payment intent error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }


  async confirmPayment(confirmData) {
    try {
      const { paymentIntentId } = confirmData;
      
      // Get payment intent details
      const paymentIntent = await this.stripe.paymentIntents.retrieve(paymentIntentId);
      
      return {
        success: true,
        data: {
          isConfirmed: paymentIntent.status === 'succeeded',
          status: paymentIntent.status,
          paymentIntentId: paymentIntent.id,
          amount: paymentIntent.amount,
          currency: paymentIntent.currency,
        }
      };
    } catch (error) {
      console.error('Stripe confirm payment error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Handle Stripe webhook events
   * @param {Object} event - Stripe event
   * @returns {Object} Processing result
   */
  async handleWebhook(event) {
    try {
      switch (event.type) {
        case 'payment_intent.succeeded':
          const paymentIntent = event.data.object;
          console.log(`Payment succeeded: ${paymentIntent.id}`);
          return {
            success: true,
            data: {
              type: 'payment_succeeded',
              paymentIntentId: paymentIntent.id,
              amount: paymentIntent.amount,
              currency: paymentIntent.currency,
            }
          };

        case 'payment_intent.payment_failed':
          const failedPayment = event.data.object;
          console.log(`Payment failed: ${failedPayment.id}`);
          return {
            success: true,
            data: {
              type: 'payment_failed',
              paymentIntentId: failedPayment.id,
              error: failedPayment.last_payment_error?.message,
            }
          };

        default:
          console.log(`Unhandled event type: ${event.type}`);
          return {
            success: true,
            data: {
              type: 'unhandled',
              eventType: event.type,
            }
          };
      }
    } catch (error) {
      console.error('Stripe webhook handling error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Create refund for payment
   * @param {Object} refundData - Refund data
   * @returns {Object} Refund result
   */
  async createRefund(refundData) {
    try {
      const { paymentIntentId, amount, reason = 'requested_by_customer' } = refundData;
      
      const refund = await this.stripe.refunds.create({
        payment_intent: paymentIntentId,
        amount: amount ? Math.round(amount) : undefined, 
        reason: reason,
      });

      return {
        success: true,
        data: {
          refundId: refund.id,
          amount: refund.amount,
          currency: refund.currency,
          status: refund.status,
        }
      };
    } catch (error) {
      console.error('Stripe create refund error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Get payment intent details
   * @param {string} paymentIntentId - Payment intent ID
   * @returns {Object} Payment intent details
   */
  async getPaymentIntent(paymentIntentId) {
    try {
      const paymentIntent = await this.stripe.paymentIntents.retrieve(paymentIntentId);
      
      return {
        success: true,
        data: {
          id: paymentIntent.id,
          amount: paymentIntent.amount,
          currency: paymentIntent.currency,
          status: paymentIntent.status,
          created: paymentIntent.created,
          metadata: paymentIntent.metadata,
        }
      };
    } catch (error) {
      console.error('Stripe get payment intent error:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

// No need for presentation
  verifyWebhookSignature(payload, signature, endpointSecret) {
    try {
      const event = this.stripe.webhooks.constructEvent(payload, signature, endpointSecret);
      return {
        success: true,
        event: event
      };
    } catch (error) {
      console.error('Stripe signature verification failed:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

module.exports = new StripeService(); 