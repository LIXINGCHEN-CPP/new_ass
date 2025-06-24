import 'order_model.dart';

enum NotificationType {
  order,
  promotion,
  system,
  coupon,
  favorite, // Added for favorite notifications
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final String? imageLink;
  final DateTime createdAt;
  final bool isRead;
  final String? orderId; // For order-related notifications
  final Map<String, dynamic>? extraData; // For additional data

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageLink,
    required this.createdAt,
    this.isRead = false,
    this.orderId,
    this.extraData,
  });

  // Factory constructor for order success notification
  factory NotificationModel.orderSuccess({
    required OrderModel order,
  }) {
    return NotificationModel(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.order,
      title: 'Order Placed!',
      subtitle: 'Your order #${order.orderId} has been successfully placed. Total: \$${order.totalAmount.toStringAsFixed(2)}',
      imageLink: 'https://i.imgur.com/KKWqqrP.png',
      createdAt: DateTime.now(),
      orderId: order.orderId,
      extraData: {
        'totalAmount': order.totalAmount,
        'itemsCount': order.totalItemsCount,
        'paymentMethod': order.paymentMethod,
      },
    );
  }

  // Factory constructor for order status update
  factory NotificationModel.orderStatusUpdate({
    required OrderModel order,
  }) {
    String title;
    String subtitle;
    String imageLink;

    switch (order.status.index) {
      case 1: // processing
        title = 'Order Processing';
        subtitle = 'Your order #${order.orderId} is being processed.';
        imageLink = 'https://i.imgur.com/XYbd8Tj.png';
        break;
      case 2: // shipped
        title = 'Order Shipped';
        subtitle = 'Your order #${order.orderId} has been shipped and is on its way!';
        imageLink = 'https://i.imgur.com/hmUnrRE.png';
        break;
      case 3: // delivered
        title = 'Order Delivered';
        subtitle = 'Your order #${order.orderId} has been delivered successfully!';
        imageLink = 'https://i.imgur.com/VSwGkZg.png';
        break;
      case 4: // cancelled
        title = 'Order Cancelled';
        subtitle = 'Your order #${order.orderId} has been cancelled. Need help?';
        imageLink = 'https://i.imgur.com/jsDEdkz.png';
        break;
      default: // confirmed
        title = 'Order Placed';
        subtitle = 'Your order #${order.orderId} has been placed.';
        imageLink = 'https://i.imgur.com/KKWqqrP.png';
    }

    return NotificationModel(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.order,
      title: title,
      subtitle: subtitle,
      imageLink: imageLink,
      createdAt: DateTime.now(),
      orderId: order.orderId,
      extraData: {
        'status': order.status.index,
        'statusName': order.statusDisplayName,
      },
    );
  }

  // Factory constructor for favorite action notification
  factory NotificationModel.favoriteAdded({
    required String itemName,
    required String itemType, 
    String? itemImage,
    required String itemId,
  }) {
    return NotificationModel(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.favorite,
      title: '❤️ Added to Favorites',
      subtitle: '$itemName has been added to your favorites!',
      imageLink: itemImage ?? 'https://i.imgur.com/heart-icon.png',
      createdAt: DateTime.now(),
      extraData: {
        'itemId': itemId,
        'itemName': itemName,
        'itemType': itemType,
        'action': 'added',
      },
    );
  }

  // Factory constructor for favorite removed notification
  factory NotificationModel.favoriteRemoved({
    required String itemName,
    required String itemType, // 'product' or 'bundle'
    String? itemImage,
    required String itemId,
  }) {
    return NotificationModel(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.favorite,
      title: '💔 Removed from Favorites',
      subtitle: '$itemName has been removed from your favorites.',
      imageLink: itemImage ?? 'https://i.imgur.com/heart-broken-icon.png',
      createdAt: DateTime.now(),
      extraData: {
        'itemId': itemId,
        'itemName': itemName,
        'itemType': itemType,
        'action': 'removed',
      },
    );
  }

  // Get formatted time display
  String get timeDisplay {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'Minute' : 'Minutes'} Ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'Hour' : 'Hours'} Ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'Day' : 'Days'} Ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'subtitle': subtitle,
      'imageLink': imageLink,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'orderId': orderId,
      'extraData': extraData,
    };
  }

  // Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: NotificationType.values[json['type']],
      title: json['title'],
      subtitle: json['subtitle'],
      imageLink: json['imageLink'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      orderId: json['orderId'],
      extraData: json['extraData'] != null 
          ? Map<String, dynamic>.from(json['extraData'])
          : null,
    );
  }

  // Copy with method
  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? subtitle,
    String? imageLink,
    DateTime? createdAt,
    bool? isRead,
    String? orderId,
    Map<String, dynamic>? extraData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageLink: imageLink ?? this.imageLink,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      orderId: orderId ?? this.orderId,
      extraData: extraData ?? this.extraData,
    );
  }
} 