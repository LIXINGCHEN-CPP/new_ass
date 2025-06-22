import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/favorite_item_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../routes/app_routes.dart';
import 'network_image.dart';
import 'custom_toast.dart';

class ProductTileSquare extends StatelessWidget {
  const ProductTileSquare({
    super.key,
    required this.data,
  });

  final ProductModel data;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, FavoriteProvider>(
      builder: (context, cartProvider, favoriteProvider, child) {
        final isInCart = data.id != null && 
            cartProvider.isInCart(data.id!, CartItemType.product);
        final cartQuantity = data.id != null ? 
            cartProvider.getItemQuantity(data.id!, CartItemType.product) : 0;
        final isFavorite = data.id != null && 
            favoriteProvider.isFavorite(data.id!, FavoriteItemType.product);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding / 2),
          child: Material(
            borderRadius: AppDefaults.borderRadius,
            color: AppColors.scaffoldBackground,
            child: InkWell(
              borderRadius: AppDefaults.borderRadius,
              onTap: () => Navigator.pushNamed(
                context, 
                AppRoutes.productDetails, 
                arguments: data,
              ),
              child: Container(
                width: 176,
                height: 280,
                padding: const EdgeInsets.all(AppDefaults.padding),
                decoration: BoxDecoration(
                  // border: Border.all(width: 0.1, color: AppColors.placeholder),
                  borderRadius: AppDefaults.borderRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image area (including cart status indicator and favorite button)
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppDefaults.padding / 2),
                          child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: NetworkImageWithLoader(
                              data.coverImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Cart status indicator
                        if (isInCart)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${cartQuantity}x',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // Favorite button
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: () async {
                              await favoriteProvider.toggleFavorite(
                                data.id!,
                                FavoriteItemType.product,
                                product: data,
                              );
                              
                              if (isFavorite) {
                                context.showInfoToast('Removed from favorites');
                              } else {
                                context.showSuccessToast('Added to favorites');
                              }
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),

                    // —— 1. Product name
                    Text(
                      data.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,                  // Title font size
                        // fontWeight: FontWeight.bold,   // Bold
                        color: Colors.black,           // Color
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // —— 2. Weight / specification
                    Text(
                      data.weight,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,                  // Sub-text font size
                        fontWeight: FontWeight.w400,   // Regular weight
                        color: Colors.grey[700],       // Dark grey
                      ),
                    ),
                    const SizedBox(height: 4),

                    // —— 3. Price row and cart button
                    Row(
                      children: [
                        // Price section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${data.currentPrice.toInt()}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18,                  // Current price font size
                                  fontWeight: FontWeight.w600,   // Slightly bold
                                  color: AppColors.primary,      // Primary color
                                ),
                              ),
                              if (data.originalPrice > data.currentPrice) ...[
                                Text(
                                  '\$${data.originalPrice}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,                  // Original price font size
                                    color: Colors.grey,            // Grey color
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Quick add to cart button
                        GestureDetector(
                          onTap: () async {
                            // Always add one more item to cart
                            await cartProvider.addProduct(data, quantity: 1);
                            
                            // Show brief feedback
                            if (isInCart) {
                              context.showSuccessToast('Quantity increased');
                            } else {
                              context.showSuccessToast('Added to cart');
                            }
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
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
