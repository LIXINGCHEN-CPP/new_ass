import 'cart_item_model.dart';
import '../enums/dummy_order_status.dart';

class OrderModel {
  final String? id;
  final String orderId;
  final String? userId;  
  final OrderStatus status;
  final List<CartItemModel> items;
  final double totalAmount;
  final double originalAmount;
  final double savings;
  final String paymentMethod;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? processingAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  OrderModel({
    this.id,
    required this.orderId,
    this.userId, 
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.originalAmount,
    required this.savings,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.createdAt,
    this.confirmedAt,
    this.processingAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle different ID formats from MongoDB
    String? modelId;
    if (json['_id'] is Map) {
      modelId = json['_id']['\$oid'];
    } else {
      modelId = json['_id']?.toString() ?? json['id']?.toString();
    }

    // Handle status conversion - could be int or string
    int statusIndex;
    if (json['status'] is String) {
      statusIndex = int.parse(json['status']);
    } else {
      statusIndex = json['status'] as int;
    }

    return OrderModel(
      id: modelId,
      orderId: json['orderId']?.toString() ?? '',
      userId: json['userId']?.toString(),  
      status: OrderStatus.values[statusIndex],
      items: (json['items'] as List? ?? [])
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      originalAmount: (json['originalAmount'] as num? ?? 0).toDouble(),
      savings: (json['savings'] as num? ?? 0).toDouble(),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      confirmedAt: json['confirmedAt'] != null 
          ? DateTime.parse(json['confirmedAt']) 
          : null,
      processingAt: json['processingAt'] != null 
          ? DateTime.parse(json['processingAt']) 
          : null,
      shippedAt: json['shippedAt'] != null 
          ? DateTime.parse(json['shippedAt']) 
          : null,
      deliveredAt: json['deliveredAt'] != null 
          ? DateTime.parse(json['deliveredAt']) 
          : null,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'orderId': orderId,
      if (userId != null) 'userId': userId,  // Add user ID to JSON
      'status': status.index,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'originalAmount': originalAmount,
      'savings': savings,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'processingAt': processingAt?.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedOrderId => '#$orderId';
  
  String get statusDisplayName {
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
    }
  }

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderModel copyWith({
    String? id,
    String? orderId,
    String? userId,  // Add user ID parameter
    OrderStatus? status,
    List<CartItemModel>? items,
    double? totalAmount,
    double? originalAmount,
    double? savings,
    String? paymentMethod,
    String? deliveryAddress,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? processingAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,  // Add user ID to copyWith
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      originalAmount: originalAmount ?? this.originalAmount,
      savings: savings ?? this.savings,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      processingAt: processingAt ?? this.processingAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
} 