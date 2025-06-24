import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/custom_toast.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/payment_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/stripe_service.dart';
import 'components/checkout_address_selector.dart';
import 'components/checkout_card_details.dart';
import 'components/checkout_payment_systems.dart';
import 'components/coupon_selector.dart';
import 'components/checkout_summary.dart';



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
            const CouponSelector(),
            const CheckoutSummary(),
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
      case PaymentType.stripe:
        return 'Stripe';
      case PaymentType.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<CartProvider, OrderProvider, NotificationProvider, UserProvider>(
      builder: (context, cartProvider, orderProvider, notificationProvider, userProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: ElevatedButton(
              onPressed: orderProvider.isLoading ? null : () async {
                if (cartProvider.cartItems.isEmpty) {
                  context.showWarningToast('Cart is empty');
                  return;
                }

                // Check if user is logged in
                if (!userProvider.isLoggedIn) {
                  context.showWarningToast('Please log in to place an order');
                  Navigator.pushNamed(context, AppRoutes.login);
                  return;
                }

                // Handle Stripe payment
                if (selectedPaymentType == PaymentType.stripe) {
                  // Show confirmation dialog first
                  final shouldProceed = await StripeService.instance.showPaymentDialog(
                    context, 
                    cartProvider.totalPrice
                  );
                  
                  if (!shouldProceed) return;
                  
                  context.showInfoToast('Creating payment link...');
                  
                  // Create payment link
                  final stripeResponse = await StripeService.instance.createPaymentLink(
                    items: cartProvider.cartItems.map((item) => {
                      'name': item.name,
                      'quantity': item.quantity,
                      'price': (item.currentPrice * 100).round(),
                    }).toList(),
                    totalAmount: cartProvider.totalPrice,
                    userId: userProvider.currentUser?.id,
                  );
                  
                  if (stripeResponse != null && stripeResponse.paymentUrl.isNotEmpty) {
                    // Successfully got payment URL from backend
                    context.showInfoToast('Redirecting to Stripe...');
                    
                    // Launch payment URL - user must complete payment in browser
                    final launched = await StripeService.instance.launchPaymentUrl(stripeResponse.paymentUrl);
                    
                    if (launched) {
                      
                      context.showInfoToast('Please complete payment in browser...');
                      
                      // Wait 5 seconds to ensure user has time to complete payment
                      await Future.delayed(const Duration(seconds: 5));
                      
                     
                      final success = await orderProvider.createOrder(
                        items: cartProvider.cartItems,
                        totalAmount: cartProvider.totalPrice,
                        originalAmount: cartProvider.totalOriginalPrice,
                        savings: cartProvider.totalSavings,
                        paymentMethod: _getPaymentMethodName(selectedPaymentType),
                        deliveryAddress: userProvider.currentUser?.address ?? '123 Main Street, City, State',
                        userId: userProvider.currentUser?.id,
                      );

                      if (success && context.mounted) {
                        context.showSuccessToast('Order placed successfully!');
                        
                        // Add order success notification
                        if (orderProvider.currentOrder != null) {
                          await notificationProvider.addOrderSuccessNotification(orderProvider.currentOrder!);
                        }
                        
                        // Mark coupon as used if one was applied
                        if (cartProvider.selectedCoupon != null) {
                          await cartProvider.markCouponAsUsed();
                        }
                        
                        // Clear cart
                        await cartProvider.clearCart();
                        
                        // Refresh orders list
                        if (userProvider.isLoggedIn && userProvider.currentUser?.id != null) {
                          await orderProvider.loadOrdersByUserId(userProvider.currentUser!.id!);
                        } else {
                          await orderProvider.loadOrders();
                        }
                        
                        // Navigate to success page after delay
                        Navigator.pushNamed(
                          context,
                          AppRoutes.orderSuccessfull,
                          arguments: orderProvider.currentOrder?.orderId ?? orderProvider.currentOrder?.id,
                        );
                      }
                    } else {
                      if (context.mounted) {
                        context.showErrorToast('Failed to open payment page');
                      }
                    }
                  } else {
                    if (context.mounted) {
                      context.showErrorToast('Failed to create payment link from backend');
                    }
                  }
                  return;
                }

                // Handle other payment methods (MasterCard, Cash on Delivery)
                final success = await orderProvider.createOrder(
                  items: cartProvider.cartItems,
                  totalAmount: cartProvider.totalPrice,
                  originalAmount: cartProvider.totalOriginalPrice,
                  savings: cartProvider.totalSavings,
                  paymentMethod: _getPaymentMethodName(selectedPaymentType),
                  deliveryAddress: userProvider.currentUser?.address ?? '123 Main Street, City, State',
                  userId: userProvider.currentUser?.id,
                );

                if (success) {
                  // Show immediate success feedback
                  context.showSuccessToast('Order placed successfully!');
                  
                  // Add order success notification
                  if (orderProvider.currentOrder != null) {
                    await notificationProvider.addOrderSuccessNotification(orderProvider.currentOrder!);
                  }
                  
                  // Mark coupon as used if one was applied
                  if (cartProvider.selectedCoupon != null) {
                    await cartProvider.markCouponAsUsed();
                  }
                  
                  // Clear cart
                  await cartProvider.clearCart();
                  
                  // Refresh orders list - load user's orders if logged in
                  if (userProvider.isLoggedIn && userProvider.currentUser?.id != null) {
                    await orderProvider.loadOrdersByUserId(userProvider.currentUser!.id!);
                  } else {
                    await orderProvider.loadOrders();
                  }
                  
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
                    context.showErrorToast(orderProvider.error ?? 'Failed to create order');
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
