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
  });

  final List<ProductModel> products;
  final double totalPrice;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppDefaults.bottomSheetRadius,
      ),
      child: Row(
        children: [
          ...products.take(4).map(
                (e) => ProductAvatarWithQuanitty(
              productImage: e.coverImage,
              quantity: 1,
            ),
          ),
          const Spacer(),
          Text(
            '\$${totalPrice.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCheckout,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: SvgPicture.asset(AppIcons.arrowForward),
            ),
          ),
        ],
      ),
    );
  }
}