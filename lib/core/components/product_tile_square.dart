import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/dummy_product_model.dart';
import '../routes/app_routes.dart';
import 'network_image.dart';

class ProductTileSquare extends StatelessWidget {
  const ProductTileSquare({
    super.key,
    required this.data,
  });

  final ProductModel data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding / 2),
      child: Material(
        borderRadius: AppDefaults.borderRadius,
        color: AppColors.scaffoldBackground,
        child: InkWell(
          borderRadius: AppDefaults.borderRadius,
          onTap: () => Navigator.pushNamed(context, AppRoutes.productDetails),
          child: Container(
            width: 176,
            height: 280,
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              // border: Border.all(width: 0.1, color: AppColors.placeholder),
              borderRadius: AppDefaults.borderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片
                Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding / 2),
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: NetworkImageWithLoader(
                      data.cover,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 7),

                // —— 1. 商品名称
                Text(
                  data.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,                  // 标题字号
                    // fontWeight: FontWeight.bold,   // 加粗
                    color: Colors.black,           // 颜色
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),

                // —— 2. 重量 / 规格
                Text(
                  data.weight,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,                  // 副文本字号
                    fontWeight: FontWeight.w400,   // 常规粗细
                    color: Colors.grey[700],       // 深灰色
                  ),
                ),
                const SizedBox(height: 4),

                // —— 3. 价格行
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 现价
                    Text(
                      '\$${data.price.toInt()}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,                  // 现价字号
                        fontWeight: FontWeight.w600,   // 略微加粗
                        color: AppColors.primary,      // 主色调
                      ),
                    ),
                    const SizedBox(width: 4),
                    // 原价（删除线）
                    Text(
                      '\$${data.mainPrice}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,                  // 原价字号
                        color: Colors.grey,            // 灰色
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
