import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/network_image.dart';
import '../../../core/components/custom_toast.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/favorite_item_model.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/models/cart_item_model.dart';
import '../../../core/routes/app_routes.dart';

class FavoriteItemTile extends StatelessWidget {
  const FavoriteItemTile({
    super.key,
    required this.favoriteItem,
    required this.onRemove,
  });

  final FavoriteItemModel favoriteItem;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoriteProvider, CartProvider>(
      builder: (context, favoriteProvider, cartProvider, child) {
        // Check if item is in cart
        bool isInCart = false;
        int cartQuantity = 0;
        
        if (favoriteItem.type == FavoriteItemType.product) {
          isInCart = cartProvider.isInCart(favoriteItem.itemId, CartItemType.product);
          cartQuantity = cartProvider.getItemQuantity(favoriteItem.itemId, CartItemType.product);
        } else {
          isInCart = cartProvider.isInCart(favoriteItem.itemId, CartItemType.bundle);
          cartQuantity = cartProvider.getItemQuantity(favoriteItem.itemId, CartItemType.bundle);
        }

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDefaults.borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppDefaults.borderRadius,
              onTap: () {
                // Navigate to product/bundle details
                if (favoriteItem.type == FavoriteItemType.product) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.productDetails,
                    arguments: favoriteItem.productDetails,
                  );
                } else {
                  // Navigate to bundleProduct page for complete bundle details
                  Navigator.pushNamed(
                    context,
                    AppRoutes.bundleProduct,
                    arguments: favoriteItem.bundleDetails,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: Row(
                  children: [
                    // Product image
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: NetworkImageWithLoader(
                        favoriteItem.coverImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favoriteItem.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            favoriteItem.weight,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (favoriteItem.originalPrice > favoriteItem.currentPrice) ...[
                                Text(
                                  '\$${favoriteItem.originalPrice.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                '\$${favoriteItem.currentPrice.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (isInCart) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'In Cart (${cartQuantity}x)',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Action buttons
                    Column(
                      children: [
                        // Remove from favorites button
                        IconButton(
                          onPressed: onRemove,
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          tooltip: 'Remove from favorites',
                        ),
                        const SizedBox(height: 8),
                        // Add to cart button
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              if (favoriteItem.type == FavoriteItemType.product && 
                                  favoriteItem.productDetails != null) {
                                await cartProvider.addProduct(favoriteItem.productDetails!, quantity: 1);
                              } else if (favoriteItem.type == FavoriteItemType.bundle && 
                                         favoriteItem.bundleDetails != null) {
                                await cartProvider.addBundle(favoriteItem.bundleDetails!, quantity: 1);
                              }
                              
                              context.showSuccessToast(isInCart 
                                  ? 'Quantity increased' 
                                  : 'Added to cart');
                            },
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 