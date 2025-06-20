import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/dummy_order_status.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/providers/order_provider.dart';
import 'order_preview_tile.dart';

class CompletedTab extends StatelessWidget {
  const CompletedTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${orderProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => orderProvider.loadOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final completedOrders = orderProvider.completedOrders;
        
        if (completedOrders.isEmpty) {
          return const Center(child: Text('No completed orders'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: completedOrders.length,
          itemBuilder: (context, index) {
            final order = completedOrders[index];
            return OrderPreviewTile(
              orderID: order.orderId,
              date: _formatDate(order.createdAt),
              status: order.status,
              totalAmount: order.totalAmount,
              items: order.items,
              onTap: () {
                debugPrint('Navigating to order details with orderId: ${order.orderId}');
                Navigator.pushNamed(
                  context, 
                  AppRoutes.orderDetails,
                  arguments: order.orderId,
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month]}';
  }
}
