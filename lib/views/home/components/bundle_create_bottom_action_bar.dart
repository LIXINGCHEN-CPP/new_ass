import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/models/product_model.dart';
import 'product_avatar_with_quantity.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.products,
    required this.totalPrice,
    required this.onCheckout,
    this.selectedProductsWithQuantity,
  });

  final List<ProductModel> products;
  final double totalPrice;
  final VoidCallback onCheckout;
  final Map<ProductModel, int>? selectedProductsWithQuantity;

  @override
  Widget build(BuildContext context) {
    // Get unique products with their quantities
    List<MapEntry<ProductModel, int>> uniqueProductsWithQuantity = [];
    if (selectedProductsWithQuantity != null) {
      uniqueProductsWithQuantity = selectedProductsWithQuantity!.entries.toList();
    } else {
      // Fallback: group products by counting occurrences
      Map<ProductModel, int> productCounts = {};
      for (ProductModel product in products) {
        productCounts[product] = (productCounts[product] ?? 0) + 1;
      }
      uniqueProductsWithQuantity = productCounts.entries.toList();
    }

    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppDefaults.bottomSheetRadius,
      ),
      child: Row(
        children: [
          // Show up to 4 unique products with their quantities
          ...uniqueProductsWithQuantity.take(4).map((entry) => Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: ProductAvatarWithQuanitty(
              productImage: entry.key.coverImage,
              quantity: entry.value,
            ),
          )),
          const Spacer(),
          Text(
            '\$${totalPrice.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onCheckout,
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.arrowForward,
                width: 30,
                height: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}