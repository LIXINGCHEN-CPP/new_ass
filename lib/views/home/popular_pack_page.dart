import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/bundle_tile_square.dart';
import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/app_provider.dart';

class PopularPackPage extends StatefulWidget {
  const PopularPackPage({super.key});

  @override
  State<PopularPackPage> createState() => _PopularPackPageState();
}

class _PopularPackPageState extends State<PopularPackPage> {
  @override
  void initState() {
    super.initState();
    // Load data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = context.read<AppProvider>();
      if (appProvider.bundles.isEmpty) {
        appProvider.loadBundles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f3f5),
      appBar: AppBar(
        title: const Text('Popular Packs'),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            if (appProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (appProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${appProvider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => appProvider.loadBundles(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final bundles = appProvider.bundles;
            if (bundles.isEmpty) {
              return const Center(child: Text('No bundles available'));
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: AppDefaults.padding),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: bundles.length,
                    itemBuilder: (context, index) {
                      return BundleTileSquare(
                        data: bundles[index],
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppDefaults.padding * 2),
                    decoration: const BoxDecoration(
                      color: Colors.white60,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.createMyPack);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AppIcons.shoppingBag),
                          const SizedBox(width: AppDefaults.padding),
                          const Text('Create Own Pack'),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
