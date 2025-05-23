import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/constants/app_icons.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import 'components/ad_space.dart';
import 'components/our_new_item.dart';
import 'components/popular_packs.dart';
import '../../core/components/title_and_action_button.dart';
import '../menu/components/category_tile.dart';
import '../menu/menu_page.dart';
import '../entrypoint/entrypoint_ui.dart';

// 引入 Menu 页面里的 CategoryTile
import '../menu/components/category_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 用同 MenuPage 定义的分类列表
    final categories = <Map<String, String>>[
      {
        'imageLink': 'https://i.imgur.com/Gbf50lM.png',
        'label': 'Vegetables',
      },
      {
        'imageLink': 'https://img.picui.cn/free/2025/05/22/682e33389bd4e.png',
        'label': 'Meat&Fish',
      },
      {
        'imageLink': 'https://i.imgur.com/yHdeMr7.png',
        'label': 'Medicine',
      },
      {
        'imageLink': 'https://i.imgur.com/uGEmzyU.png',
        'label': 'Baby Care',
      },
      {
        'imageLink': 'https://i.imgur.com/ShO7Pdz.png',
        'label': 'Office Supplies',
      },
      {
        'imageLink': 'https://i.imgur.com/zyXxqa5.png',
        'label': 'Beauty',
      },
      {
        'imageLink': 'https://i.imgur.com/VRSBMt5.png',
        'label': 'Gym Equipment',
      },
      {
        'imageLink': 'https://i.imgur.com/rpN3TSz.png',
        'label': 'Gardening Tools',
      },
      {
        'imageLink': 'https://i.imgur.com/vwJBZ6M.png',
        'label': 'Pet Care',
      },
      {
        'imageLink': 'https://i.imgur.com/Kjwt5ve.png',
        'label': 'Eye Wears',
      },
      {
        'imageLink': 'https://i.imgur.com/okTi0ck.png',
        'label': 'Pack',
      },
      {
        'imageLink': 'https://i.imgur.com/m65fusg.png',
        'label': 'Others',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFf3f3f5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部 AppBar
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

            // 广告横幅
            const SliverToBoxAdapter(child: AdSpace()),

            // —— 插入 Categories 区块 ——
            SliverToBoxAdapter(
              child: Container(
                color: Colors.transparent,  // ← 在这里设置背景色
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
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppDefaults.padding),
                        itemBuilder: (context, idx) {
                          final cat = categories[idx];
                          return SizedBox(
                            width: 90,
                            child: CategoryTile(
                              imageLink: cat['imageLink']!,
                              label: cat['label']!,
                              backgroundColor: const Color(0xFFccefdc),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.categoryDetails,
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


            // 原有热门套餐、新品等模块
            const SliverToBoxAdapter(child: PopularPacks()),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
              sliver: SliverToBoxAdapter(child: OurNewItem()),
            ),
          ],
        ),
      ),
    );
  }
}