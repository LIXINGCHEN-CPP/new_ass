import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/enums/dummy_order_status.dart';

class OrderPreviewTile extends StatelessWidget {
  const OrderPreviewTile({
    super.key,
    required this.orderID,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.onTap,
  });

  final String orderID;
  final String date;
  final OrderStatus status;
  final double totalAmount;
  final List<dynamic> items; // Can be CartItemModel or similar
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 2,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: AppDefaults.borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDefaults.borderRadius,
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              borderRadius: AppDefaults.borderRadius,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      date,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.black),
                    ),
                    const Spacer(),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Product items preview
                if (items.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _buildProductPreview(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    const Text('Status'),
                    Expanded(
                      child: RangeSlider(
                        values: RangeValues(0, _orderSliderValue()),
                        max: 3,
                        divisions: 3,
                        onChanged: (v) {},
                        activeColor: _orderColor(),
                        inactiveColor: AppColors.placeholder.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                            opacity: status == OrderStatus.confirmed ? 1 : 0,
                            child: Text(
                              'Confirmed',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: _orderColor()),
                            ),
                          ),
                          Opacity(
                            opacity: status == OrderStatus.processing ? 1 : 0,
                            child: Text(
                              'Processing',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: _orderColor()),
                            ),
                          ),
                          Opacity(
                            opacity: status == OrderStatus.shipped ? 1 : 0,
                            child: Text(
                              'Shipped',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: _orderColor()),
                            ),
                          ),
                          Opacity(
                            opacity: status == OrderStatus.delivery ||
                                    status == OrderStatus.cancelled
                                ? 1
                                : 0,
                            child: Text(
                              status == OrderStatus.delivery
                                  ? 'Delivery'
                                  : 'Cancelled',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: _orderColor()),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _orderSliderValue() {
    switch (status) {
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.processing:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivery:
        return 3;
      case OrderStatus.cancelled:
        return 3;

      default:
        return 0;
    }
  }

  Color _orderColor() {
    switch (status) {
      case OrderStatus.confirmed:
        return const Color(0xFF7375D4);
      case OrderStatus.processing:
        return const Color(0xFFFFA731);
      case OrderStatus.shipped:
        return const Color(0xFF61A2F9);
      case OrderStatus.delivery:
        return const Color(0xFF76BB78);
      case OrderStatus.cancelled:
        return const Color(0xFFDD4031);

      default:
        return Colors.red;
    }
  }

  List<Widget> _buildProductPreview() {
    // Show only the first 3 unique products
    final uniqueProducts = <String, dynamic>{};
    
    for (final item in items) {
      final name = item.name ?? item['name'] ?? 'Unknown Product';
      if (uniqueProducts.length < 3 && !uniqueProducts.containsKey(name)) {
        uniqueProducts[name] = item;
      }
    }
    
    final widgets = <Widget>[];
    
    for (final entry in uniqueProducts.entries) {
      final item = entry.value;
      final name = entry.key;
      final quantity = item.quantity ?? item['quantity'] ?? 1;
      
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$name×$quantity',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }
    
    // Add "..." if there are more items
    if (items.length > uniqueProducts.length) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }
}
