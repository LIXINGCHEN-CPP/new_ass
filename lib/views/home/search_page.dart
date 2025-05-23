import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_icons.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/ui_util.dart';
import 'dialogs/product_filters_dialog.dart';

// 引入假数据模型
import '../../core/constants/dummy_data.dart';
import '../../core/constants/dummy_data_category.dart';
import '../../core/models/dummy_product_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  /// 所有商品列表（合并两份假数据）
  late final List<ProductModel> _allProducts = [
    ...Dummy.products,
    ...DummyCategory.products,
  ];

  /// 根据 _query 动态过滤后的商品
  List<ProductModel> get _filtered {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _allProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.weight.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          onChanged: (v) => setState(() => _query = v),
          onSubmitted: (v) {
            // 可选：提交时焦点收起
            FocusScope.of(context).unfocus();
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
          ? const _RecentSearchList()    // 可以保留历史或提示
          : ListView.separated(
        padding: const EdgeInsets.all(AppDefaults.padding),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, idx) {
          final product = _filtered[idx];
          return ListTile(
            leading: Image.network(product.cover, width: 48, height: 48),
            title: Text(product.name),
            subtitle: Text(product.weight),
            trailing: Text('\$${product.price}'),
            onTap: () => _onTapProduct(product),
          );
        },
      ),
    );
  }
}

/// 原先的历史搜索列表，可选保留或删除
class _RecentSearchList extends StatelessWidget {
  const _RecentSearchList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(6, (i) {
          return ListTile(
            title: Text('Recent: Item ${i+1}'),
            leading: const Icon(Icons.history),
            onTap: () {
              // 可直接填充到搜索框
            },
          );
        }),
      ),
    );
  }
}
