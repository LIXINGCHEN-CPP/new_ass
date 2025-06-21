import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_icons.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/routes/app_routes.dart';
import 'components/favorite_item_tile.dart';
import 'empty_save_page.dart';

class SavePage extends StatelessWidget {
  const SavePage({
    super.key,
    this.isHomePage = false,
  });

  final bool isHomePage;

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFf3f3f5),
          appBar: isHomePage
              ? null
              : AppBar(
                  leading: IconButton(
                    onPressed: () {
                      // Always return to home (entrypoint with home tab)
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.entryPoint,
                        (route) => false,
                      );
                    },
                    icon: SvgPicture.asset(AppIcons.arrowBackward),
                  ),
                  title: Text('Favorites (${favoriteProvider.totalFavoritesCount})'),
                  actions: [
                    if (!favoriteProvider.isEmpty)
                      TextButton(
                        onPressed: () async {
                          // Show confirmation dialog
                          final shouldClear = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear Favorites'),
                              content: const Text('Are you sure you want to clear all favorites?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldClear == true) {
                            await favoriteProvider.clearFavorites();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Favorites cleared'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: const Text('Clear All'),
                      ),
                  ],
                ),
          body: SafeArea(
            child: favoriteProvider.isEmpty
                ? const EmptySavePage()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Favorites list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: favoriteProvider.favoriteItems.length,
                          itemBuilder: (context, index) {
                            final favoriteItem = favoriteProvider.favoriteItems[index];
                            return FavoriteItemTile(
                              favoriteItem: favoriteItem,
                              onRemove: () async {
                                await favoriteProvider.removeFromFavorites(
                                  favoriteItem.itemId,
                                  favoriteItem.type,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Removed ${favoriteItem.name} from favorites'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: AppDefaults.padding),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
