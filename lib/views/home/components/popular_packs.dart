import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/bundle_tile_square.dart';
import '../../../core/components/title_and_action_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/providers/app_provider.dart';

class PopularPacks extends StatelessWidget {
  const PopularPacks({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final popularBundles = appProvider.popularBundles;
        
        if (popularBundles.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          children: [
            TitleAndActionButton(
              title: 'Popular Packs',
              actionLabel: 'View All or Create Your Pack',
              onTap: () => Navigator.pushNamed(context, AppRoutes.popularItems),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: AppDefaults.padding),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  popularBundles.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: AppDefaults.padding),
                    child: BundleTileSquare(data: popularBundles[index]),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
