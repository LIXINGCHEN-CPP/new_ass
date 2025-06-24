import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/buy_now_row_button.dart';
import '../../core/components/quantity_selector.dart';
import '../../core/components/product_images_slider.dart';
import '../../core/components/review_row_button.dart';
import '../../core/components/custom_toast.dart';
import '../../core/constants/constants.dart';
import '../../core/models/bundle_model.dart';
import '../../core/models/cart_item_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/database_service.dart';
import 'components/bundle_meta_data.dart';
import 'components/bundle_pack_details.dart';

class BundleProductDetailsPage extends StatefulWidget {
  const BundleProductDetailsPage({super.key});

  @override
  State<BundleProductDetailsPage> createState() => _BundleProductDetailsPageState();
}

class _BundleProductDetailsPageState extends State<BundleProductDetailsPage> {
  BundleModel? bundle;
  bool isLoading = true;
  int selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBundleDetails();
    });
  }

  void _loadBundleDetails() async {
    // Get bundle data from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is BundleModel) {
      // Try to get complete bundle details from API
      try {
        final detailedBundle = await DatabaseService.instance.getBundleDetails(args.id);
        setState(() {
          bundle = detailedBundle ?? args; // If failed, use original passed data
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          bundle = args; // If failed, use original passed data
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no bundle data passed, show error page
    if (bundle == null && !isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Bundle Details'),
        ),
        body: const Center(
          child: Text('Bundle not found'),
        ),
      );
    }

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Bundle Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(bundle!.id, CartItemType.bundle);
        final cartQuantity = cartProvider.getItemQuantity(bundle!.id, CartItemType.bundle);

        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(),
            title: const Text('Bundle Details'),
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProductImagesSlider(
                  images: bundle!.items.isNotEmpty
                    ? bundle!.items.map((item) => item.productDetails?.coverImage ?? bundle!.coverImage).toList()
                    : [bundle!.coverImage],
                  bundle: bundle,
                ),
                /* <---- Product Data -----> */
                Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          bundle!.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (isInCart) ...[
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
                        const SizedBox(height: 16),
                      ],

                      // Price and quantity selector
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (bundle!.originalPrice > bundle!.currentPrice) ...[
                                Text(
                                  '\$${bundle!.originalPrice.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                '\$${bundle!.currentPrice.toStringAsFixed(2)}',
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

                      const SizedBox(height: AppDefaults.padding / 2),

                      // Display bundle description
                      if (bundle!.description.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            bundle!.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ),
                        const SizedBox(height: AppDefaults.padding),
                      ],

                      // Display items included in bundle
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Items Included',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...bundle!.itemNames.map((itemName) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(itemName),
                          ],
                        ),
                      )).toList(),
                      const SizedBox(height: AppDefaults.padding),

                      // const BundleMetaData(),
                      PackDetails(bundle: bundle!),
                      // const ReviewRowButton(totalStars: 5),
                      const Divider(thickness: 0.1),
                      BuyNowRow(
                        quantity: selectedQuantity,
                        onAddToCart: () async {
                          await cartProvider.addBundle(bundle!, quantity: selectedQuantity);

                          // Show success message
                          context.showSuccessToast('Added ${selectedQuantity}x ${bundle!.name} to cart');
                        },
                        onCartButtonTap: () {
                          // Cart button opens cart page
                          Navigator.pushNamed(context, AppRoutes.cartPage);
                        },
                      ),
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
