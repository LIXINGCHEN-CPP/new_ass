import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../models/bundle_model.dart';
import '../models/favorite_item_model.dart';
import '../providers/favorite_provider.dart';
import '../routes/app_routes.dart';
import 'network_image.dart';

class BundleTileSquare extends StatelessWidget {
  const BundleTileSquare({
    super.key,
    required this.data,
  });

  final BundleModel data;

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(data.id, FavoriteItemType.bundle);

        return Material(
          color: AppColors.scaffoldBackground,
          borderRadius: AppDefaults.borderRadius,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.bundleProduct, arguments: data);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 176,
              padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
              decoration: BoxDecoration(
                // border: Border.all(width: 0.6, color: AppColors.placeholder),
                borderRadius: AppDefaults.borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image area with favorite button
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: NetworkImageWithLoader(
                            data.cover,
                            fit: BoxFit.contain,
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
                              data.id,
                              FavoriteItemType.bundle,
                              bundle: data,
                            );
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFavorite 
                                    ? 'Removed from favorites' 
                                    : 'Added to favorites'),
                                duration: const Duration(milliseconds: 800),
                                backgroundColor: isFavorite ? Colors.orange : Colors.green,
                              ),
                            );
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
                  const SizedBox(height: 8),

                  // Name and item list
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // —— 1. Name
                      Text(
                        data.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,                  // Title font size
                          // fontWeight: FontWeight.bold,   // Bold
                          color: Colors.black,           // Color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // —— 2. Item names
                      Text(
                        data.itemNames.join(', '),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,                  // Sub-text font size
                          fontWeight: FontWeight.w400,   // Regular weight
                          color: Colors.grey[700],       // Grey color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    children: [
                      // —— 3. Current Price
                      Text(
                        '\$${data.price.toInt()}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,                  // Current price font size
                          fontWeight: FontWeight.w600,   // Slightly bold
                          color: AppColors.primary,      // Primary color highlight
                        ),
                      ),
                      const SizedBox(width: 4),

                      // —— 4. Original Price
                      Text(
                        '\$${data.mainPrice}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,                  // Original price font size
                          color: Colors.grey,            // Grey color
                          decoration: TextDecoration.lineThrough, // Strike through
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
