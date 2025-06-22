import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/custom_toast.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/cart_provider.dart';
import 'components/coupon_code_field.dart';
import 'components/cart_item_tile.dart';
import 'components/cart_totals_price.dart';
import 'empty_cart_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({
    super.key,
    this.isHomePage = false,
  });

  final bool isHomePage;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          appBar: isHomePage
              ? null
              : AppBar(
                  leading: const AppBackButton(),
                  title: Text('Shopping Cart (${cartProvider.totalItemsCount})'),
                  actions: [
                    if (!cartProvider.isEmpty)
                      TextButton(
                        onPressed: () async {
                          // Show confirmation dialog
                          final shouldClear = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear Cart'),
                              content: const Text('Are you sure you want to clear your cart?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldClear == true) {
                            await cartProvider.clearCart();
                            context.showInfoToast('Cart cleared');
                          }
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
          body: SafeArea(
            child: cartProvider.isEmpty
                ? const EmptyCartPage()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Cart items list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartProvider.cartItems.length,
                          separatorBuilder: (context, index) => const Divider(thickness: 0.1),
                          itemBuilder: (context, index) {
                            final cartItem = cartProvider.cartItems[index];
                            return CartItemTile(
                              cartItem: cartItem,
                              onQuantityChanged: (newQuantity) async {
                                await cartProvider.updateQuantity(cartItem.id, newQuantity);
                              },
                              onRemove: () async {
                                await cartProvider.removeItem(cartItem.id);
                                context.showInfoToast('Removed ${cartItem.name}');
                              },
                            );
                          },
                        ),
                        
                        // Coupon input
                        const CouponCodeField(),
                        
                        // Price totals
                        CartTotalsAndPrice(
                          totalItems: cartProvider.totalItemsCount,
                          totalOriginalPrice: cartProvider.totalOriginalPrice,
                          totalSavings: cartProvider.totalSavings,
                          totalPrice: cartProvider.totalPrice,
                        ),
                        
                        // Checkout button
                        SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(AppDefaults.padding),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.checkoutPage);
                              },
                              child: Text('Checkout (\$${cartProvider.totalPrice.toStringAsFixed(2)})'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
