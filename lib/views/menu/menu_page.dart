import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/app_provider.dart';
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
          const CategoriesGrid()
        ],
      ),
    );
  }
}

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appProvider.categories.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          return GridView.count(
            crossAxisCount: 3,
            children: appProvider.categories.map((category) {
              return CategoryTile(
                imageLink: category.imageUrl,
                label: category.name,
                backgroundColor: Color(int.parse(category.backgroundColor.replaceFirst('#', '0xff'))),
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.categoryDetails,
                    arguments: category.id, // 传递分类ID以便动态显示商品
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
