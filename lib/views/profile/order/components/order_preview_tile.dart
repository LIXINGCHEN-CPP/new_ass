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
                    const SizedBox(width: 4),
                    const _BouncingArrow(),
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
                  const SizedBox(height: 16),
                ],
                // Simplified status display without progress bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _orderColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _orderColor(),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusDisplayText(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: _orderColor(),
                              fontWeight: FontWeight.w600,
                            ),
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

  String _getStatusDisplayText() {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Order Placed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivery:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';

      default:
        return 'Unknown';
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

// Animated bouncing arrow indicator
class _BouncingArrow extends StatefulWidget {
  const _BouncingArrow({Key? key}) : super(key: key);

  @override
  State<_BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<_BouncingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _offsetAnim = Tween<double>(begin: 0, end: -3)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnim.value),
          child: child,
        );
      },
      child: const Icon(
        Icons.chevron_right_rounded,
        size: 24,
        color: Colors.grey,
      ),
    );
  }
}
