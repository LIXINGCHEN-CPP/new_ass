import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/buy_now_row_button.dart';
import '../../core/components/quantity_selector.dart';
import '../../core/components/product_images_slider.dart';
import '../../core/components/review_row_button.dart';
import '../../core/components/custom_toast.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/constants.dart';
import '../../core/models/product_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/models/cart_item_model.dart';
import '../../core/routes/app_routes.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    // Get product data from route arguments
    final ProductModel? product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
    
    // If no product data passed, show error page
    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Product Details'),
        ),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = product.id != null && 
            cartProvider.isInCart(product.id!, CartItemType.product);
        final cartQuantity = product.id != null ? 
            cartProvider.getItemQuantity(product.id!, CartItemType.product) : 0;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const AppBackButton(),
            title: const Text('Product Details'),
            actions: [
              // Cart icon displays current total quantity
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.cartPage);
                    },
                  ),
                  if (cartProvider.totalItemsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.totalItemsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
              child: BuyNowRow(
                onBuyButtonTap: () async {
                  // Buy Now always adds the selected quantity to cart
                  await cartProvider.addProduct(product, quantity: selectedQuantity);
                  
                  // Show success message
                  context.showSuccessToast('Added ${selectedQuantity}x ${product.name} to cart');
                },
                onCartButtonTap: () {
                  // Cart button opens cart page
                  Navigator.pushNamed(context, AppRoutes.cartPage);
                },
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProductImagesSlider(
                  images: product.images.isNotEmpty ? product.images : [product.coverImage],
                  product: product,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text('Weight: ${product.weight}'),
                        if (isInCart) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              'In Cart (${cartQuantity}x)',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (product.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            product.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Price and quantity selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Price display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.originalPrice > product.currentPrice) ...[
                            Text(
                              '\$${product.originalPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            '\$${product.currentPrice.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.primary, 
                                  fontWeight: FontWeight.bold
                                ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      
                      // Quantity selector
                      QuantitySelector(
                        quantity: selectedQuantity,
                        onQuantityChanged: (newQuantity) {
                          setState(() {
                            selectedQuantity = newQuantity;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                /// Product Details
                Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Details',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description ?? 'No description available for this product.',
                      ),
                      if (product.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: product.tags.map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey[200],
                          )).toList(),
                        ),
                      ],
                      if (product.nutritionInfo != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Nutrition Information',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...product.nutritionInfo!.entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${entry.key}:'),
                              Text('${entry.value}'),
                            ],
                          ),
                        )).toList(),
                      ],
                    ],
                  ),
                ),

                /// Review Row
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDefaults.padding,
                    // vertical: AppDefaults.padding,
                  ),
                  child: Column(
                    children: [
                      Divider(thickness: 0.1),
                      ReviewRowButton(totalStars: 5),
                      Divider(thickness: 0.1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
