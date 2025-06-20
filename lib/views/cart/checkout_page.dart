import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/payment_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/notification_provider.dart';
import 'components/checkout_address_selector.dart';
import 'components/checkout_card_details.dart';
import 'components/checkout_payment_systems.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentType selectedPaymentType = PaymentType.masterCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AddressSelector(),
            PaymentSystem(
              selectedPaymentType: selectedPaymentType,
              onPaymentTypeChanged: (PaymentType type) {
                setState(() {
                  selectedPaymentType = type;
                });
              },
            ),
            if (selectedPaymentType == PaymentType.masterCard)
              const CardDetails(),
            PayNowButton(selectedPaymentType: selectedPaymentType),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class PayNowButton extends StatelessWidget {
  final PaymentType selectedPaymentType;
  
  const PayNowButton({
    super.key,
    required this.selectedPaymentType,
  });

  String _getPaymentMethodName(PaymentType paymentType) {
    switch (paymentType) {
      case PaymentType.masterCard:
        return 'Master Card';
      case PaymentType.paypal:
        return 'Paypal';
      case PaymentType.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentType.applePay:
        return 'Apple Pay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CartProvider, OrderProvider, NotificationProvider>(
      builder: (context, cartProvider, orderProvider, notificationProvider, child) {
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
                  paymentMethod: _getPaymentMethodName(selectedPaymentType),
                  deliveryAddress: '123 Main Street, City, State', // Could be made dynamic
                );

                if (success) {
                  // Add order success notification
                  if (orderProvider.currentOrder != null) {
                    await notificationProvider.addOrderSuccessNotification(orderProvider.currentOrder!);
                  }
                  
                  // Clear cart
                  await cartProvider.clearCart();
                  
                  // Refresh orders list
                  await orderProvider.loadOrders();
                  
                  // Navigate to success page
                  if (context.mounted) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.orderSuccessfull,
                      arguments: orderProvider.currentOrder?.orderId ?? orderProvider.currentOrder?.id,
                    );
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
