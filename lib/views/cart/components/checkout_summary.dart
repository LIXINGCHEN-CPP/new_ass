import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/dotted_divider.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/providers/cart_provider.dart';
import 'item_row.dart';

class CheckoutSummary extends StatelessWidget {
  const CheckoutSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          margin: const EdgeInsets.all(AppDefaults.padding),
          padding: const EdgeInsets.all(AppDefaults.padding),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: AppDefaults.borderRadius,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 16),
              
              ItemRow(
                title: 'Items (${cartProvider.totalItemsCount})',
                value: '\$${cartProvider.totalOriginalPrice.toStringAsFixed(2)}',
              ),
              
              if (cartProvider.productSavings > 0) ...[
                ItemRow(
                  title: 'Product Savings',
                  value: '-\$${cartProvider.productSavings.toStringAsFixed(2)}',
                  valueColor: Colors.green,
                ),
                ItemRow(
                  title: 'Subtotal',
                  value: '\$${cartProvider.subtotalPrice.toStringAsFixed(2)}',
                ),
              ],
              
              if (cartProvider.couponDiscount > 0) ...[
                ItemRow(
                  title: 'Coupon Discount',
                  value: '-\$${cartProvider.couponDiscount.toStringAsFixed(2)}',
                  valueColor: Colors.green,
                ),
              ],
              
              const DottedDivider(),
              
              ItemRow(
                title: 'Total',
                value: '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                titleStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 