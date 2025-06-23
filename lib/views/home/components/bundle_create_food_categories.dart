import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/models/category_model.dart';
import '../../../core/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'app_chip.dart';

class FoodCategories extends StatelessWidget {
  const FoodCategories({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
      ),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final List<CategoryModel> categories = appProvider.categories;
          return Row(
            children: [
              AppChip(
                isActive: selectedCategoryId == null,
                label: 'All',
                onPressed: () => onCategorySelected(null),
              ),
              ...categories.map(
                    (category) => AppChip(
                  isActive: selectedCategoryId == category.id,
                  label: category.name,
                  onPressed: () => onCategorySelected(category.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}