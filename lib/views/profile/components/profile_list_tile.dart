import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  final void Function() onTap;
  final String icon;
  final String title;
  final bool showBadge;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDefaults.borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SvgPicture.asset(icon),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.black),
                ),
              ),
              // Notification badge
              if (showBadge && badgeCount > 0) ...[
                Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (showBadge) ...[
                // Show only red dot without number
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              SvgPicture.asset(AppIcons.right),
            ],
          ),
        ),
      ),
    );
  }
}
