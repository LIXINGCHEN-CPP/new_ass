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
  final List<ProductModel> selectedProducts = [];

  double get _currentPrice =>
      selectedProducts.fold(0, (sum, p) => sum + (p.originalPrice - 1));
  double get _originalPrice =>
      selectedProducts.fold(0, (sum, p) => sum + p.originalPrice);

  Future<void> _addToCart(BuildContext context) async {
    if (selectedProducts.isEmpty) return;

    final bundle = BundleModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Custom Pack',
      description: 'User created bundle',
      coverImage: selectedProducts.first.coverImage,
      items: selectedProducts
          .map((p) => BundleItem(
        productId: p.id ?? '',
        quantity: 1,
        productDetails: p,
      ))
          .toList(),
      itemNames: selectedProducts.map((e) => e.name).toList(),
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
            selectedProducts: selectedProducts,
            onProductToggle: (product) {
              setState(() {
                if (selectedProducts.contains(product)) {
                  selectedProducts.remove(product);
                } else {
                  if (selectedProducts.length >= 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You can select up to 4 items')),
                    );
                  } else {
                    selectedProducts.add(product);
                  }
                }
              });
            },
          ),
          if (selectedProducts.isNotEmpty)
            BottomActionBar(
              products: selectedProducts,
              totalPrice: _currentPrice,
              onCheckout: () => _addToCart(context),
            ),
        ],
      ),
    );
  }
}