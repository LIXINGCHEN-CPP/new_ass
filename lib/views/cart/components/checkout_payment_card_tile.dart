import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';

class PaymentCardTile extends StatelessWidget {
  const PaymentCardTile({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    required this.isActive,
  });

  final String icon;
  final String label;
  final void Function() onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: isActive
            ? AppColors.coloredBackground
            : AppColors.scaffoldBackground,
        borderRadius: AppDefaults.borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDefaults.borderRadius,
                      child: Container(
              height: 78,
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: AppDefaults.borderRadius,
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.placeholder,
                  width: isActive ? 1 : 0.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon.startsWith('http'))
                    Image.network(
                      icon,
                      width: 24,
                      height: 24,
                    )
                  else
                    SvgPicture.asset(icon),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }
}
