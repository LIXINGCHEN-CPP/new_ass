import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/dummy_bundle_model.dart';
import '../routes/app_routes.dart';
import 'network_image.dart';

class BundleTileSquare extends StatelessWidget {
  const BundleTileSquare({
    super.key,
    required this.data,
  });

  final BundleModel data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.scaffoldBackground,
      borderRadius: AppDefaults.borderRadius,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.bundleProduct);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 176,
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          decoration: BoxDecoration(
            // border: Border.all(width: 0.6, color: AppColors.placeholder),
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片区域
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: NetworkImageWithLoader(
                    data.cover,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 名称与条目列表
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // —— 1. 名称 Name
                  Text(
                    data.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,                  // 调整标题字号
                      // fontWeight: FontWeight.bold,   // 加粗
                      color: Colors.black,           // 颜色
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // —— 2. 子项列表 Item names
                  Text(
                    data.itemNames.join(', '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,                  // 调整副文本字号
                      fontWeight: FontWeight.w400,   // 常规粗细
                      color: Colors.grey[700],       // 灰色
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 价格行
              Row(
                children: [
                  // —— 3. 现价 Price
                  Text(
                    '\$${data.price.toInt()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,                  // 调整现价字号
                      fontWeight: FontWeight.w600,   // 略微加粗
                      color: AppColors.primary,      // 主色调高亮
                    ),
                  ),
                  const SizedBox(width: 4),

                  // —— 4. 原价 MainPrice
                  Text(
                    '\$${data.mainPrice}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,                  // 调整原价字号
                      color: Colors.grey,            // 灰色
                      decoration: TextDecoration.lineThrough, // 删除线
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
