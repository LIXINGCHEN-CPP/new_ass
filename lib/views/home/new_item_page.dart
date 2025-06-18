import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/app_provider.dart';

class NewItemsPage extends StatelessWidget {
  const NewItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f3f5),
      appBar: AppBar(
        title: const Text('New Item'),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final products = appProvider.newProducts;
              
              if (products.isEmpty) {
                return const Center(
                  child: Text('暂无新品商品'),
                );
              }
              
              return GridView.builder(
                padding: const EdgeInsets.only(top: AppDefaults.padding),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.66,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductTileSquare(
                    data: products[index],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
