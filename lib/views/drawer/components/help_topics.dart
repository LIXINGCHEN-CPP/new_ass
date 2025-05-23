import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/components/app_settings_tile.dart';
import '../../../core/constants/constants.dart';

class HelpTopics extends StatelessWidget {
  const HelpTopics({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDefaults.padding),
        Text(
          'Topics',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDefaults.padding / 2),
        AppSettingsListTile(
          label: 'My account',
          trailing: SvgPicture.asset(AppIcons.right),
        ),
        AppSettingsListTile(
          label: 'Payment method and Wallet',
          trailing: SvgPicture.asset(AppIcons.right),
        ),
        AppSettingsListTile(
          label: 'Shipping and Delivery',
          trailing: SvgPicture.asset(AppIcons.right),
        ),
        AppSettingsListTile(
          label: 'Vouchers and Promotion',
          trailing: SvgPicture.asset(AppIcons.right),
        ),
        AppSettingsListTile(
          label: 'Order tracking',
          trailing: SvgPicture.asset(AppIcons.right),
        ),
      ],
    );
  }
}
