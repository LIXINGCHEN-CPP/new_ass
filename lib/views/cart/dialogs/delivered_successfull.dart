import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/routes/app_routes.dart';

class DeliverySuccessfullDialog extends StatelessWidget {
  final String? orderId;

  const DeliverySuccessfullDialog({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDefaults.padding * 3,
          horizontal: AppDefaults.padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AspectRatio(
              aspectRatio: 1 / 1,
              child: NetworkImageWithLoader(
                'https://i.imgur.com/DQqtvkL.png',
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              'Hurrah!!  we just deliverred your',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  orderId != null ? '#$orderId' : '#',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.black),
                ),
                const Text(' order Successfully.')
              ],
            ),
            const SizedBox(height: AppDefaults.padding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.entryPoint);
                },
                child: const Text('Browse Home'),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (orderId != null && orderId!.isNotEmpty) {
                    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
                      AppRoutes.orderDetails,
                      arguments: orderId,
                    );
                  } else {
                    // Fallback: navigate to My Orders page
                    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
                      AppRoutes.myOrder,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Rate The Product'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
