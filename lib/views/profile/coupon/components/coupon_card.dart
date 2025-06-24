import 'package:flutter/material.dart';

import '../../../../core/components/dotted_divider.dart';
import '../../../../core/constants/constants.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    this.couponBackground,
    required this.discounts,
    this.color,
    required this.onTap,
    this.isSelectMode = false,
    this.isSelected = false,
  });

  final String? couponBackground;
  final String discounts;
  final Color? color;
  final void Function() onTap;
  final bool isSelectMode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 162,
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: AppDefaults.padding / 2,
              horizontal: AppDefaults.padding,
            ),
            decoration: BoxDecoration(
              color: color ?? Colors.blue,
              borderRadius: AppDefaults.borderRadius,
              image: DecorationImage(
                image: AssetImage(
                  couponBackground ?? AppImages.couponBackgrounds[1],
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: AppDefaults.borderRadius,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppDefaults.borderRadius,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              discounts,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            Text(
                              'Off',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 160,
                      child:
                          DottedDivider(isVertical: true, color: Colors.white),
                    ),
                    const Expanded(
                      flex: 11, // Keep the layout ratio
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            height: 32,
            width: 32,
            decoration: const BoxDecoration(
              color: AppColors.scaffoldBackground,
              shape: BoxShape.circle,
            ),
          ),
        )
      ],
    );
  }
}
