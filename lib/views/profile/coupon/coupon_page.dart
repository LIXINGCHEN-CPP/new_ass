import 'package:flutter/material.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import 'components/coupon_card.dart';

class CouponAndOffersPage extends StatelessWidget {
  const CouponAndOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Offer And Promos',
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Text(
                'You Have 4 Coupons to use',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
          ),
          const Expanded(child: CouponLists()),
        ],
      ),
    );
  }
}

class CouponLists extends StatelessWidget {
  const CouponLists({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CouponCard(
          title: 'Black\nCoffee',
          discounts: '40%',
          couponBackground: AppImages.couponBackgrounds[2],
          expire: 'Exp-28/12/2025',
          color: const Color(0xFFA3D6CA),
          onTap: () => Navigator.pushNamed(context, AppRoutes.couponDetails),
        ),
        CouponCard(
          title: 'Ice\nCream',
          discounts: '30%',
          couponBackground: AppImages.couponBackgrounds[2],
          expire: 'Exp-25/10/2025',
          color: const Color(0xFF96C2E2),
          onTap: () => Navigator.pushNamed(context, AppRoutes.couponDetails),
        ),
        CouponCard(
          title: 'Oreo\nBiscuit',
          discounts: '50%',
          couponBackground: AppImages.couponBackgrounds[2],
          expire: 'Exp-13/11/2025',
          color: const Color(0xFFF4B3C5),
          onTap: () => Navigator.pushNamed(context, AppRoutes.couponDetails),
        ),
        CouponCard(
          title: 'Tuna\nFish',
          discounts: '18%',
          couponBackground: AppImages.couponBackgrounds[2],
          expire: 'Exp-28/12/2025',
          color: const Color(0xFFF4AA8D),
          onTap: () => Navigator.pushNamed(context, AppRoutes.couponDetails),
        ),
      ],
    );
  }
}
