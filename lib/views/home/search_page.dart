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
import '../../core/services/search_history_service.dart';
import 'dialogs/product_filters_dialog.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final SearchHistoryService _searchHistoryService = SearchHistoryService.instance;
  String _query = '';
  List<ProductModel> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchHistoryService.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
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
      
      // Add search term to history only if we get results
      if (results.isNotEmpty) {
        await _searchHistoryService.addSearchTerm(query);
        await _loadSearchHistory(); // Refresh history display
      }
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

  void _onTapHistoryItem(String searchTerm) {
    _controller.text = searchTerm;
    setState(() {
      _query = searchTerm;
    });
    _performSearch(searchTerm);
  }

  Future<void> _removeHistoryItem(String searchTerm) async {
    await _searchHistoryService.removeSearchTerm(searchTerm);
    await _loadSearchHistory();
  }

  Future<void> _clearAllHistory() async {
    await _searchHistoryService.clearSearchHistory();
    await _loadSearchHistory();
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
            // Perform search for any non-empty input
            if (v.isNotEmpty) {
              _performSearch(v);
            } else {
              setState(() {
                _searchResults = [];
                _isSearching = false;
              });
            }
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
          ? _RecentSearchList(
              searchHistory: _searchHistory,
              onTapHistoryItem: _onTapHistoryItem,
              onRemoveHistoryItem: _removeHistoryItem,
              onClearAllHistory: _clearAllHistory,
            )
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

/// Recent search history list
class _RecentSearchList extends StatelessWidget {
  final List<String> searchHistory;
  final Function(String) onTapHistoryItem;
  final Function(String) onRemoveHistoryItem;
  final VoidCallback onClearAllHistory;

  const _RecentSearchList({
    required this.searchHistory,
    required this.onTapHistoryItem,
    required this.onRemoveHistoryItem,
    required this.onClearAllHistory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (searchHistory.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(AppDefaults.padding),
              child: Text(
                'Start typing to search for products...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: onClearAllHistory,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            ...searchHistory.map((searchTerm) {
              return ListTile(
                title: Text(searchTerm),
                leading: const Icon(Icons.history, color: Colors.grey),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => onRemoveHistoryItem(searchTerm),
                ),
                onTap: () => onTapHistoryItem(searchTerm),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
