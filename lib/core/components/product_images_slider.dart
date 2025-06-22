import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../views/home/components/animated_dots.dart';
import '../constants/constants.dart';
import '../providers/favorite_provider.dart';
import '../models/favorite_item_model.dart';
import '../models/product_model.dart';
import '../models/bundle_model.dart';
import 'network_image.dart';
import 'custom_toast.dart';

class ProductImagesSlider extends StatefulWidget {
  const ProductImagesSlider({
    super.key,
    required this.images,
    this.product,
    this.bundle,
  });

  final List<String> images;
  final ProductModel? product;
  final BundleModel? bundle;

  @override
  State<ProductImagesSlider> createState() => _ProductImagesSliderState();
}

class _ProductImagesSliderState extends State<ProductImagesSlider> {
  late PageController controller;
  int currentIndex = 0;

  List<String> images = [];

  @override
  void initState() {
    super.initState();
    images = widget.images;
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        bool isFavorite = false;
        
        // Check favorite status based on product or bundle
        if (widget.product != null) {
          isFavorite = favoriteProvider.isFavorite(
            widget.product!.id!,
            FavoriteItemType.product,
          );
        } else if (widget.bundle != null) {
          isFavorite = favoriteProvider.isFavorite(
            widget.bundle!.id,
            FavoriteItemType.bundle,
          );
        }

        return Stack(
          children: [
            /// Image Slider
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: controller,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) => Container(
                  padding: const EdgeInsets.all(AppDefaults.padding * 2),
                  child: NetworkImageWithLoader(images[index]),
                ),
              ),
            ),

            /// Indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: AnimatedDots(
                currentIndex: currentIndex,
                totalItems: images.length,
              ),
            ),

            /// Heart Button
            Positioned(
              right: 0,
              child: Material(
                color: Colors.transparent,
                borderRadius: AppDefaults.borderRadius,
                child: IconButton(
                  onPressed: () async {
                    // Toggle favorite status
                    if (widget.product != null) {
                      await favoriteProvider.toggleFavorite(
                        widget.product!.id!,
                        FavoriteItemType.product,
                        product: widget.product,
                      );
                    } else if (widget.bundle != null) {
                      await favoriteProvider.toggleFavorite(
                        widget.bundle!.id,
                        FavoriteItemType.bundle,
                        bundle: widget.bundle,
                      );
                    }
                    
                    // Show feedback
                    if (isFavorite) {
                      context.showWarningToast('Removed from favorites');
                    } else {
                      context.showSuccessToast('Added to favorites');
                    }
                  },
                  iconSize: 56,
                  constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
                  icon: Container(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    decoration: const BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      shape: BoxShape.circle,
                    ),
                    child: isFavorite
                        ? const Icon(
                            Icons.favorite, // Filled heart
                            color: Colors.red,
                            size: 24,
                          )
                        : SvgPicture.asset(AppIcons.heart), // Empty heart
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}