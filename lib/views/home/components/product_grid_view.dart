import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/product_tile_square.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/app_provider.dart';

class ProductGridView extends StatelessWidget {
  const ProductGridView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final products = appProvider.products;
          
          if (products.isEmpty) {
            return const Center(
              child: Text('No products available'),
            );
          }
          
          return GridView.builder(
            padding: const EdgeInsets.only(top: AppDefaults.padding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductTileSquare(data: products[index]);
            },
          );
        },
      ),
    );
  }
}
