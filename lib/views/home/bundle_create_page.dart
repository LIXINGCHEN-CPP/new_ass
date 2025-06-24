import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';
import 'components/bundle_create_bottom_action_bar.dart';
import 'components/bundle_create_food_categories.dart';
import 'components/product_grid_view.dart';
import '../../core/models/product_model.dart';
import '../../core/models/bundle_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/components/custom_toast.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';

class BundleCreatePage extends StatefulWidget {
  const BundleCreatePage({super.key});

  @override
  State<BundleCreatePage> createState() => _BundleCreatePageState();
}

class _BundleCreatePageState extends State<BundleCreatePage> {
  String? selectedCategoryId;
  final Map<ProductModel, int> selectedProductsWithQuantity = {};

  // Get total quantity of all selected items
  int get _totalItemCount => selectedProductsWithQuantity.values.fold(0, (sum, quantity) => sum + quantity);

  // Get list of products for display (flattened with quantities)
  List<ProductModel> get _selectedProductsList {
    List<ProductModel> result = [];
    selectedProductsWithQuantity.forEach((product, quantity) {
      for (int i = 0; i < quantity; i++) {
        result.add(product);
      }
    });
    return result;
  }

  double get _currentPrice =>
      selectedProductsWithQuantity.entries.fold(0, (sum, entry) => sum + (entry.key.originalPrice - 1) * entry.value);
  double get _originalPrice =>
      selectedProductsWithQuantity.entries.fold(0, (sum, entry) => sum + entry.key.originalPrice * entry.value);

  Future<void> _addToCart(BuildContext context) async {
    if (selectedProductsWithQuantity.isEmpty) return;

    // Create bundle items with correct quantities
    List<BundleItem> bundleItems = [];
    selectedProductsWithQuantity.forEach((product, quantity) {
      bundleItems.add(BundleItem(
        productId: product.id ?? '',
        quantity: quantity,
        productDetails: product,
      ));
    });

    final bundle = BundleModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Custom Pack',
      description: 'User created bundle',
      coverImage: selectedProductsWithQuantity.keys.first.coverImage,
      items: bundleItems,
      itemNames: selectedProductsWithQuantity.keys.map((e) => e.name).toList(),
      currentPrice: _currentPrice,
      originalPrice: _originalPrice,
      categoryId: '11',
      isActive: true,
      isPopular: false,
    );

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    await cartProvider.addBundle(bundle);

    if (context.mounted) {
      context.showSuccessToast('Added ${bundle.name} to cart');
      Navigator.pushNamed(context, AppRoutes.cartPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f3f5),
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Create My Pack'),
      ),
      body: Column(
        children: [
          FoodCategories(
            selectedCategoryId: selectedCategoryId,
            onCategorySelected: (id) {
              setState(() {
                selectedCategoryId = id;
              });
            },
          ),
          const SizedBox(height: AppDefaults.padding / 2),
          ProductGridView(
            categoryId: selectedCategoryId,
            selectedProducts: _selectedProductsList,
            selectedProductsWithQuantity: selectedProductsWithQuantity,
            onProductToggle: (product) {
              setState(() {
                if (selectedProductsWithQuantity.containsKey(product)) {
                  // If product is already selected, increase quantity
                  int currentQuantity = selectedProductsWithQuantity[product]!;
                  if (_totalItemCount >= 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You can select up to 4 items total')),
                    );
                  } else {
                    selectedProductsWithQuantity[product] = currentQuantity + 1;
                  }
                } else {
                  // If product is not selected, add it with quantity 1
                  if (_totalItemCount >= 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You can select up to 4 items total')),
                    );
                  } else {
                    selectedProductsWithQuantity[product] = 1;
                  }
                }
              });
            },
            onProductRemove: (product) {
              setState(() {
                if (selectedProductsWithQuantity.containsKey(product)) {
                  int currentQuantity = selectedProductsWithQuantity[product]!;
                  if (currentQuantity > 1) {
                    selectedProductsWithQuantity[product] = currentQuantity - 1;
                  } else {
                    selectedProductsWithQuantity.remove(product);
                  }
                }
              });
            },
          ),
          if (selectedProductsWithQuantity.isNotEmpty)
            BottomActionBar(
              products: _selectedProductsList,
              selectedProductsWithQuantity: selectedProductsWithQuantity,
              totalPrice: _currentPrice,
              onCheckout: () => _addToCart(context),
            ),
        ],
      ),
    );
  }
}