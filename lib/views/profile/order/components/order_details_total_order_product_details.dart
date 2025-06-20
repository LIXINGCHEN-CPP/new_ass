import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/providers/order_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/models/cart_item_model.dart';
import 'order_details_product_tile.dart';

class TotalOrderProductDetails extends StatelessWidget {
  const TotalOrderProductDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final order = orderProvider.currentOrder;
        if (order == null || order.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppDefaults.padding),
            child: Text('No products found'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Product Details',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                itemBuilder: (context, index) {
                  final cartItem = order.items[index];
                  return InkWell(
                    onTap: () => _navigateToItemDetails(context, cartItem),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: cartItem.coverImage.isNotEmpty
                                ? Image.network(
                                    cartItem.coverImage,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.shopping_basket,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                          ),
                        ),
                        title: Text(cartItem.name),
                        subtitle: Text('${cartItem.weight} • ${cartItem.quantity}x'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${cartItem.totalPrice.toStringAsFixed(2)}'),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  thickness: 0.2,
                ),
                itemCount: order.items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToItemDetails(BuildContext context, dynamic cartItem) {
    // Determine if it's a bundle or product and navigate accordingly
    if (cartItem.type == CartItemType.bundle) {
      // Navigate to bundle product details page (more detailed than bundleDetailsPage)
      if (cartItem.bundleDetails != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.bundleProduct,
          arguments: cartItem.bundleDetails, // Pass full bundle model
        );
      } else {
        // If no bundle details, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bundle details not available')),
        );
      }
    } else if (cartItem.type == CartItemType.product) {
      // Navigate to product details
      if (cartItem.productDetails != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: cartItem.productDetails, // Pass full product model
        );
      } else {
        // If no product details, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product details not available')),
        );
      }
    }
  }
}
