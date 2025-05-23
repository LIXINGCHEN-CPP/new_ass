import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';

class CategoryProductPage extends StatelessWidget {
  const CategoryProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = DummyCategory.products;
    return Scaffold(
      backgroundColor: const Color(0xFFf3f3f5),
      appBar: AppBar(
        title: const Text('Vegetables'),
        leading: const AppBackButton(),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.only(top: AppDefaults.padding),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          childAspectRatio: 0.64,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductTileSquare(
            data: products[index],
          );
        },
      ),
    );
  }
}
