import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/providers/cart_provider.dart';
import '../../profile/coupon/coupon_page.dart';

class CouponSelector extends StatelessWidget {
  const CouponSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final selectedCoupon = cartProvider.selectedCoupon;

        return Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coupon Discount',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 16),
              
              if (selectedCoupon != null) ...[
                // Show selected coupon
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: AppDefaults.borderRadius,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color(int.parse(selectedCoupon.color)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${selectedCoupon.discountAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Save \$${selectedCoupon.discountAmount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          cartProvider.removeCoupon();
                        },
                        icon: const Icon(Icons.close),
                        color: Colors.grey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CouponAndOffersPage(isSelectMode: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Change Coupon'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ] else ...[
                // Show coupon selection button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CouponAndOffersPage(isSelectMode: true),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: AppDefaults.borderRadius,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select Coupon',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
} 