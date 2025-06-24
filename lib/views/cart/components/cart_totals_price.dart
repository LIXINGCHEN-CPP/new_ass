import 'package:flutter/material.dart';

import '../../../core/components/dotted_divider.dart';
import '../../../core/constants/app_defaults.dart';
import 'item_row.dart';

class CartTotalsAndPrice extends StatelessWidget {
  const CartTotalsAndPrice({
    super.key,
    required this.totalItems,
    required this.totalOriginalPrice,
    required this.totalSavings,
    required this.totalPrice,
    this.subtotalPrice,
    this.productSavings,
    this.couponDiscount,
  });

  final int totalItems;
  final double totalOriginalPrice;
  final double totalSavings;
  final double totalPrice;
  final double? subtotalPrice;
  final double? productSavings;
  final double? couponDiscount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          ItemRow(
            title: 'Total Items',
            value: '$totalItems items',
          ),
          ItemRow(
            title: 'Original Price',
            value: '\$${totalOriginalPrice.toStringAsFixed(2)}',
          ),
          if (productSavings != null && productSavings! > 0) ...[
            ItemRow(
              title: 'Product Savings',
              value: '-\$${productSavings!.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          ],
          if (subtotalPrice != null) ...[
            ItemRow(
              title: 'Subtotal',
              value: '\$${subtotalPrice!.toStringAsFixed(2)}',
            ),
          ],
          if (couponDiscount != null && couponDiscount! > 0) ...[
            ItemRow(
              title: 'Coupon Discount',
              value: '-\$${couponDiscount!.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          ],
          const DottedDivider(),
          ItemRow(
            title: 'Total',
            value: '\$${totalPrice.toStringAsFixed(2)}',
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            valueStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
} 