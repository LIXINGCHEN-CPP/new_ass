import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/routes/app_routes.dart';

class AddNewCardRow extends StatelessWidget {
  final VoidCallback? onCardAdded;

  const AddNewCardRow({
    super.key,
    this.onCardAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: Row(
        children: [
          Text(
            'My Card',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, AppRoutes.paymentCardAdd);
              // 如果添加了新卡片，刷新列表
              if (result == true) {
                onCardAdded?.call();
              }
            },
            icon: SvgPicture.asset(AppIcons.cardAdd),
          )
        ],
      ),
    );
  }
}