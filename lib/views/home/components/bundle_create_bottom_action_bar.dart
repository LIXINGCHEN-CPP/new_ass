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
          ...products.take(4).map((e) => Padding(
            padding: const EdgeInsets.only(right: 2.0),  // 8 像素间隔
            child: ProductAvatarWithQuanitty(
              productImage: e.coverImage,
              quantity: 1,
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
              // ① 指定固定宽高
              width: 40,
              height: 40,
              // ② 调整内边距（图标会在 padding 区域居中）
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              // ③ 也可以给 SvgPicture 本身指定宽高
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