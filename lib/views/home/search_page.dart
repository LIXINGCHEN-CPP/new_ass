import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_icons.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/ui_util.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/product_model.dart';
import 'dialogs/product_filters_dialog.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final results = await appProvider.searchProducts(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  void _onTapProduct(ProductModel product) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetails,
      arguments: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search products',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          textInputAction: TextInputAction.search,
          onChanged: (v) {
            setState(() => _query = v);
            _performSearch(v);
          },
          onSubmitted: (v) {
            FocusScope.of(context).unfocus();
            _performSearch(v);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              UiUtil.openBottomSheet(
                context: context,
                widget: const ProductFiltersDialog(),
              );
            },
          )
        ],
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: _query.isEmpty
          ? const _RecentSearchList()
          : _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppDefaults.padding),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, idx) {
                        final product = _searchResults[idx];
                        return ListTile(
                          leading: Image.network(
                            product.coverImage,
                            width: 48,
                            height: 48,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                          title: Text(product.name),
                          subtitle: Text(product.weight),
                          trailing: Text('\$${product.currentPrice}'),
                          onTap: () => _onTapProduct(product),
                        );
                      },
                    ),
    );
  }
}

/// 历史搜索列表
class _RecentSearchList extends StatelessWidget {
  const _RecentSearchList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppDefaults.padding),
            child: Text(
              'Start typing to search for products...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          ...List.generate(6, (i) {
            return ListTile(
              title: Text('Recent: Item ${i+1}'),
              leading: const Icon(Icons.history),
              onTap: () {
                // 可直接填充到搜索框
              },
            );
          }),
        ],
      ),
    );
  }
}
