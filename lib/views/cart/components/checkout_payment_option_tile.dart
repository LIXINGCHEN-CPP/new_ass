import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';

class CheckoutPaymentOptionTile extends StatelessWidget {
  const CheckoutPaymentOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.accountName,
    required this.onTap,
    this.isActive = false,
  });

  final String icon; // Network image URL
  final String label;
  final String accountName;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 2,
      ),
      child: Material(
        color: isActive
            ? AppColors.coloredBackground
            : AppColors.textInputBackground,
        borderRadius: AppDefaults.borderRadius,
        child: InkWell(
          borderRadius: AppDefaults.borderRadius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              borderRadius: AppDefaults.borderRadius,
              border: Border.all(
                color: isActive ? AppColors.primary : Colors.grey,
                width: isActive ? 1 : 0.3,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithLoader(
                      icon,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accountName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 