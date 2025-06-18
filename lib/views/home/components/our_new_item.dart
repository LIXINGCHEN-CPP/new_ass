import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/product_tile_square.dart';
import '../../../core/components/title_and_action_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/providers/app_provider.dart';

class OurNewItem extends StatelessWidget {
  const OurNewItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final newProducts = appProvider.newProducts;
        
        if (newProducts.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          children: [
            TitleAndActionButton(
              title: 'Our New Item',
              onTap: () => Navigator.pushNamed(context, AppRoutes.newItems),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: AppDefaults.padding),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  newProducts.length,
                  (index) => ProductTileSquare(data: newProducts[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
