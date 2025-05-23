import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import 'components/category_tile.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Choose a category',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          const CateogoriesGrid()
        ],
      ),
    );
  }
}

class CateogoriesGrid extends StatelessWidget {
  const CateogoriesGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        children: [
          CategoryTile(
            imageLink: 'https://i.imgur.com/Gbf50lM.png',
            label: 'Vegetables',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e33389bd4e.png',
            label: 'Meat&Fish',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/yHdeMr7.png',
            label: 'Medicine',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/uGEmzyU.png',
            label: 'Baby Care',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/ShO7Pdz.png',
            label: 'Office Supplies',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/zyXxqa5.png',
            label: 'Beauty',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/VRSBMt5.png',
            label: 'Gym Equipment',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/rpN3TSz.png',
            label: 'Gardening Tools',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/vwJBZ6M.png',
            label: 'Pet Care',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/Kjwt5ve.png',
            label: 'Eye Wears',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/okTi0ck.png',
            label: 'Pack',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/m65fusg.png',
            label: 'Others',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
        ],
      ),
    );
  }
}
