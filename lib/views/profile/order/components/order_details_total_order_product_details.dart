import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/models/product_model.dart';
import 'order_details_product_tile.dart';

class TotalOrderProductDetails extends StatelessWidget {
  const TotalOrderProductDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Temporary sample product data, should be fetched from order data in practice
    final List<ProductModel> orderProducts = [
      ProductModel(
        id: 'temp_1',
        name: 'Sample Product 1',
        description: 'Sample description',
        weight: '500g',
        coverImage: 'https://i.imgur.com/6unJlSL.png',
        images: ['https://i.imgur.com/6unJlSL.png'],
        currentPrice: 15,
        originalPrice: 18,
        categoryId: '1',
        stock: 10,
        tags: ['sample'],
      ),
      ProductModel(
        id: 'temp_2',
        name: 'Sample Product 2',
        description: 'Sample description',
        weight: '1kg',
        coverImage: 'https://i.imgur.com/oaCY49b.png',
        images: ['https://i.imgur.com/oaCY49b.png'],
        currentPrice: 12,
        originalPrice: 15,
        categoryId: '1',
        stock: 5,
        tags: ['sample'],
      ),
      ProductModel(
        id: 'temp_3',
        name: 'Sample Product 3',
        description: 'Sample description',
        weight: '750g',
        coverImage: 'https://i.imgur.com/5wghZji.png',
        images: ['https://i.imgur.com/5wghZji.png'],
        currentPrice: 20,
        originalPrice: 25,
        categoryId: '2',
        stock: 8,
        tags: ['sample'],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Product Details',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            itemBuilder: (context, index) {
              return OrderDetailsProductTile(data: orderProducts[index]);
            },
            separatorBuilder: (context, index) => const Divider(
              thickness: 0.2,
            ),
            itemCount: orderProducts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );
  }
}
