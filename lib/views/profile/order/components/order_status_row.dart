import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/enums/dummy_order_status.dart';

class OrderStatusRow extends StatelessWidget {
  const OrderStatusRow({
    super.key,
    required this.status,
    required this.date,
    required this.time,
    this.isActive = false,
    this.isStart = false,
    this.isEnd = false,
  });

  final OrderStatus status;
  final String date;
  final String time;
  final bool isStart;
  final bool isActive;
  final bool isEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? _orderColor().withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? _orderColor().withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isActive ? _orderColor() : Colors.grey,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: SvgPicture.asset(
              _orderIcon(),
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _orderStatus(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
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

  String _orderStatus() {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Order Placed';
      case OrderStatus.processing:
        return 'Order Processing';
      case OrderStatus.shipped:
        return 'Order Shipped';
      case OrderStatus.delivery:
        return 'Order Delivered';
      case OrderStatus.cancelled:
        return 'Order Cancelled';

      default:
        return 'Order null';
    }
  }

  String _orderIcon() {
    switch (status) {
      case OrderStatus.confirmed:
        return AppIcons.orderConfirmed;
      case OrderStatus.processing:
        return AppIcons.orderProcessing;
      case OrderStatus.shipped:
        return AppIcons.orderShipped;
      case OrderStatus.delivery:
        return AppIcons.orderDelivered;
      case OrderStatus.cancelled:
        return AppIcons.delete;

      default:
        return AppIcons.delete;
    }
  }
}
