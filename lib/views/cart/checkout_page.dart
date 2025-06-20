import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import 'components/checkout_address_selector.dart';
import 'components/checkout_card_details.dart';
import 'components/checkout_payment_systems.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Checkout'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            AddressSelector(),
            PaymentSystem(),
            CardDetails(),
            PayNowButton(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class PayNowButton extends StatelessWidget {
  const PayNowButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, OrderProvider>(
      builder: (context, cartProvider, orderProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: ElevatedButton(
              onPressed: orderProvider.isLoading ? null : () async {
                if (cartProvider.cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cart is empty')),
                  );
                  return;
                }

                // Create order
                final success = await orderProvider.createOrder(
                  items: cartProvider.cartItems,
                  totalAmount: cartProvider.totalPrice,
                  originalAmount: cartProvider.totalOriginalPrice,
                  savings: cartProvider.totalSavings,
                  paymentMethod: 'Credit Card', // Could be made dynamic
                  deliveryAddress: '123 Main Street, City, State', // Could be made dynamic
                );

                if (success) {
                  // Clear cart
                  await cartProvider.clearCart();
                  
                  // Refresh orders list
                  await orderProvider.loadOrders();
                  
                  // Navigate to success page
                  if (context.mounted) {
                    Navigator.pushNamed(context, AppRoutes.orderSuccessfull);
                  }
                } else {
                  // Show error
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(orderProvider.error ?? 'Failed to create order'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: orderProvider.isLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Pay Now'),
            ),
          ),
        );
      },
    );
  }
}
