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
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e31aa3b93e.png',
            label: 'Vegetables',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e33389bd4e.png',
            label: 'Meat And Fish',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e3384800c0.png',
            label: 'Medicine',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e363d08edc.png',
            label: 'Baby Care',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e369e11457.png',
            label: 'Office Supplies',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e371a5a7b8.png',
            label: 'Beauty',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e37b1d2f8f.png',
            label: 'Gym Equipment',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e381ea2c5c.png',
            label: 'Gardening Tools',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e386b565e0.png',
            label: 'Pet Care',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e38be18d3c.png',
            label: 'Eye Wears',
            backgroundColor: const Color(0xFFccefdc),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.categoryDetails);
            },
          ),
          CategoryTile(
            imageLink: 'https://img.picui.cn/free/2025/05/22/682e392e5afb3.png',
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
