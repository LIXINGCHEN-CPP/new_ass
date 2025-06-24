import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/models/coupon_model.dart';
import 'components/coupon_card.dart';

class CouponAndOffersPage extends StatelessWidget {
  const CouponAndOffersPage({super.key, this.isSelectMode = false});

  final bool isSelectMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(
          isSelectMode ? 'Select Coupon' : 'Offer And Promos',
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Text(
                isSelectMode 
                  ? 'Choose a coupon to apply discount'
                  : 'You Have 4 Coupons to use',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
          ),
          Expanded(child: CouponLists(isSelectMode: isSelectMode)),
        ],
      ),
    );
  }
}

class CouponLists extends StatelessWidget {
  const CouponLists({
    super.key,
    this.isSelectMode = false,
  });

  final bool isSelectMode;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final coupons = cartProvider.getAvailableCoupons();
        
        return ListView.builder(
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            final coupon = coupons[index];
            final isSelected = cartProvider.selectedCoupon?.id == coupon.id;
            
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
                vertical: AppDefaults.padding / 2,
              ),
              decoration: BoxDecoration(
                borderRadius: AppDefaults.borderRadius,
                border: isSelectMode && isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: CouponCard(
                discounts: '\$${coupon.discountAmount.toStringAsFixed(0)}',
                couponBackground: AppImages.couponBackgrounds[2],
                color: Color(int.parse(coupon.color)),
                isSelectMode: isSelectMode,
                isSelected: isSelected,
                onTap: () {
                  if (isSelectMode) {
                    if (isSelected) {
                      cartProvider.removeCoupon();
                      Navigator.pop(context);
                    } else {
                      cartProvider.applyCoupon(coupon);
                      Navigator.pop(context);
                    }
                  } else {
                    Navigator.pushNamed(context, AppRoutes.couponDetails);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
