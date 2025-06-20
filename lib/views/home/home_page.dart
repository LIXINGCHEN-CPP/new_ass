import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/app_provider.dart';
import 'components/ad_space.dart';
import 'components/our_new_item.dart';
import 'components/popular_packs.dart';
import '../../core/components/title_and_action_button.dart';
import '../menu/components/category_tile.dart';
import '../menu/menu_page.dart';
import '../entrypoint/entrypoint_ui.dart';

// Import CategoryTile from Menu page
import '../menu/components/category_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f3f5),
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
                    ElevatedButton(
                      onPressed: () => appProvider.initializeData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                // Top AppBar
                SliverAppBar(
                  backgroundColor: const Color(0xFFf3f3f5),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.drawerPage),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        shape: const CircleBorder(),
                      ),
                      child: SvgPicture.asset(AppIcons.sidebarIcon),
                    ),
                  ),
                  floating: true,
                  title: SvgPicture.asset("assets/images/app_logo.svg", height: 32),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF),
                          shape: const CircleBorder(),
                        ),
                        child: SvgPicture.asset(AppIcons.search),
                      ),
                    ),
                  ],
                ),

                // Advertisement banner
                const SliverToBoxAdapter(child: AdSpace()),

                // Categories section - using dynamic data
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDefaults.padding),

                        TitleAndActionButton(
                          title: 'Categories',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EntryPointUI(initialIndex: 1),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDefaults.padding),

                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
                            scrollDirection: Axis.horizontal,
                            itemCount: appProvider.categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: AppDefaults.padding),
                            itemBuilder: (context, idx) {
                              final category = appProvider.categories[idx];
                              return SizedBox(
                                width: 90,
                                child: CategoryTile(
                                  imageLink: category.imageUrl,
                                  label: category.name,
                                  backgroundColor: Color(int.parse(category.backgroundColor.replaceFirst('#', '0xff'))),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.categoryDetails,
                                    arguments: category.id, // Pass category ID
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: AppDefaults.padding),
                      ],
                    ),
                  ),
                ),

                // Original popular packages, new items and other modules
                const SliverToBoxAdapter(child: PopularPacks()),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
                  sliver: SliverToBoxAdapter(child: OurNewItem()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}