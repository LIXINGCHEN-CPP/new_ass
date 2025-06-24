import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/favorite_item_model.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../core/components/custom_toast.dart';

class SelectableProductTile extends StatelessWidget {
  const SelectableProductTile({
    super.key,
    required this.product,
    required this.selected,
    required this.onToggle,
    this.quantity = 0,
    this.onRemove,
  });

  final ProductModel product;
  final bool selected;
  final VoidCallback onToggle;
  final int quantity;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = product.id != null &&
            favoriteProvider.isFavorite(product.id!, FavoriteItemType.product);

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
                arguments: product,
              ),
              child: Container(
                width: 176,
                height: 280,
                padding: const EdgeInsets.all(AppDefaults.padding),
                decoration: BoxDecoration(
                  borderRadius: AppDefaults.borderRadius,
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppDefaults.padding / 2),
                          child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: NetworkImageWithLoader(
                              product.coverImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        if (quantity > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'x$quantity',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: () async {
                              if (product.id == null) return;
                              await favoriteProvider.toggleFavorite(
                                product.id!,
                                FavoriteItemType.product,
                                product: product,
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
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      product.weight,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${(product.originalPrice - 1).toInt()}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '\$${product.originalPrice.toInt()}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (quantity > 0 && onRemove != null) ...[
                          GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                        GestureDetector(
                          onTap: onToggle,
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