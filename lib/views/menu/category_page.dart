import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/app_provider.dart';

class CategoryProductPage extends StatefulWidget {
  const CategoryProductPage({super.key});

  @override
  State<CategoryProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  String? categoryId;
  String categoryName = 'Category Products';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get route parameters
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is String) {
      categoryId = args;
      
      // Get category name based on categoryId
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final category = appProvider.categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => appProvider.categories.first,
      );
      categoryName = category.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f3f5),
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              // Filter products by categoryId
              final products = categoryId != null 
                  ? appProvider.getProductsByCategory(categoryId)
                  : appProvider.products;
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        categoryId != null 
                            ? 'No products in this category'
                            : 'No products available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
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
