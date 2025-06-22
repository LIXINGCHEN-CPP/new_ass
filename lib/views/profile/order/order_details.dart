import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/enums/dummy_order_status.dart';
import 'components/order_details_statuses.dart';
import 'components/order_details_total_amount_and_paid.dart';
import 'components/order_details_total_order_product_details.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String? orderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get order ID from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    debugPrint('Order details route arguments: $args');
    if (args is String) {
      orderId = args;
      debugPrint('Loading order details for orderId: $orderId');
      // Load order details after the current build is complete
      if (orderId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<OrderProvider>(context, listen: false).loadOrderById(orderId!);
        });
      }
    } else {
      debugPrint('Invalid arguments type: ${args.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Order Details'),
      ),
      body: Consumer<OrderProvider>(
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
                    onPressed: () {
                      if (orderId != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          orderProvider.loadOrderById(orderId!);
                        });
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = orderProvider.currentOrder;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(AppDefaults.margin),
              padding: const EdgeInsets.all(AppDefaults.padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDefaults.borderRadius,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Order id ${order.formattedOrderId}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  const OrderStatusColumn(),
                  const TotalOrderProductDetails(),
                  const TotalAmountAndPaidData(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: kDebugMode ? Consumer2<OrderProvider, NotificationProvider>(
        builder: (context, orderProvider, notificationProvider, child) {
          final order = orderProvider.currentOrder;
          if (order == null) return const SizedBox.shrink();
          
          return FloatingActionButton(
            onPressed: () {
              _showStatusUpdateDialog(context, order, notificationProvider);
            },
            child: const Icon(Icons.notification_add),
          );
        },
      ) : null,
    );
  }

  void _showStatusUpdateDialog(BuildContext context, order, NotificationProvider notificationProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Notification'),
        content: const Text('Add a status update notification for this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Create a copy of the order with next status
              final currentStatus = order.status;
              OrderStatus? nextStatus;
              
              switch (currentStatus) {
                case OrderStatus.confirmed:
                  nextStatus = OrderStatus.processing;
                  break;
                case OrderStatus.processing:
                  nextStatus = OrderStatus.shipped;
                  break;
                case OrderStatus.shipped:
                  nextStatus = OrderStatus.delivery;
                  break;
                default:
                  nextStatus = OrderStatus.confirmed;
              }
              
              final updatedOrder = order.copyWith(status: nextStatus);
              await notificationProvider.addOrderStatusNotification(updatedOrder);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status notification added!')),
              );
            },
            child: const Text('Add Notification'),
          ),
        ],
      ),
    );
  }
}
