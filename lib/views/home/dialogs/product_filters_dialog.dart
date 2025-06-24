import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/models/category_model.dart';
import '../../../core/providers/app_provider.dart';
import '../components/categories_chip.dart';
import 'filter_options.dart';

class ProductFiltersDialog extends StatefulWidget {
  final FilterOptions options;

  const ProductFiltersDialog({Key? key, required this.options}) : super(key: key);

  @override
  State<ProductFiltersDialog> createState() => _ProductFiltersDialogState();
}

class _ProductFiltersDialogState extends State<ProductFiltersDialog> {
  late String _sortBy;
  late RangeValues _range;
  late Set<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.options.sortBy;
    _range = widget.options.priceRange;
    _selectedCategories = Set.from(widget.options.categories);
  }

  void _reset() {
    setState(() {
      _sortBy = 'Popularity';
      _range = const RangeValues(0, 100);
      _selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.read<AppProvider>().categories;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: AppDefaults.borderRadius,
              ),
              margin: const EdgeInsets.all(8),
            ),
            _FilterHeader(onReset: _reset),
            _SortBy(current: _sortBy, onChanged: (v) {
              if (v != null) setState(() => _sortBy = v);
            }),
            _PriceRange(
              range: _range,
              onChanged: (v) => setState(() => _range = v),
            ),
            _CategoriesSelector(
              categories: categories,
              selected: _selectedCategories,
              onToggle: (id) {
                setState(() {
                  if (_selectedCategories.contains(id)) {
                    _selectedCategories.remove(id);
                  } else {
                    _selectedCategories.add(id);
                  }
                });
              },
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      FilterOptions(
                        sortBy: _sortBy,
                        priceRange: _range,
                        categories: _selectedCategories,
                      ),
                    );
                  },
                  child: const Text('Apply Filter'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CategoriesSelector extends StatelessWidget {
  final List<CategoryModel> categories;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _CategoriesSelector({
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 16,
              runSpacing: 16,
              children: categories
                  .map(
                    (c) => CategoriesChip(
                  isActive: selected.contains(c.id),
                  label: c.name,
                  onPressed: () => onToggle(c.id ?? ''),
                ),
              )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _PriceRange extends StatelessWidget {
  final RangeValues range;
  final ValueChanged<RangeValues> onChanged;

  const _PriceRange({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Price Range',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          RangeSlider(
            max: 100,
            min: 0,
            labels: RangeLabels(
              range.start.round().toString(),
              range.end.round().toString(),
            ),
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.gray,
            values: range,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$0'),
                Text('\$50'),
                Text('\$100'),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SortBy extends StatelessWidget {
  final String current;
  final ValueChanged<String?> onChanged;

  const _SortBy({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          DropdownButton(
            value: current,
            underline: const SizedBox(),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.primary,
            ),
            items: const [
              DropdownMenuItem(
                value: 'Popularity',
                child: Text('Popularity'),
              ),
              DropdownMenuItem(
                value: 'Price',
                child: Text('Price'),
              ),
            ],
            onChanged: onChanged,
          )
        ],
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  final VoidCallback onReset;
  const _FilterHeader({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 56,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.scaffoldWithBoxBackground,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Text(
          'Filter',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(
          width: 70,
          child: TextButton(
            onPressed: onReset,
            child: Text(
              'Reset',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black,
              ),
            ),
          ),
        )
      ],
    );
  }
}