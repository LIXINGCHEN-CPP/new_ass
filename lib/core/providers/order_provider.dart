import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../enums/dummy_order_status.dart';
import '../services/database_service.dart';
import 'user_provider.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  OrderModel? _currentOrder;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderModel? get currentOrder => _currentOrder;

  // Filtered orders
  List<OrderModel> get allOrders => _orders;
  List<OrderModel> get runningOrders => _orders.where((order) =>
      order.status == OrderStatus.confirmed ||
      order.status == OrderStatus.processing ||
      order.status == OrderStatus.shipped).toList();
  List<OrderModel> get completedOrders => _orders.where((order) =>
      order.status == OrderStatus.delivery ||
      order.status == OrderStatus.cancelled).toList();

  // Orders older than 24 hours regardless of status
  List<OrderModel> get previousOrders => _orders.where((order) {
        final difference = DateTime.now().difference(order.createdAt);
        return difference.inHours >= 24;
      }).toList();

  int get previousOrdersCount => previousOrders.length;

  // Create new order
  Future<bool> createOrder({
    required List<CartItemModel> items,
    required double totalAmount,
    required double originalAmount,
    required double savings,
    required String paymentMethod,
    required String deliveryAddress,
    String? userId,  // Add optional user ID parameter
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await DatabaseService.instance.createOrder(
        items: items,
        totalAmount: totalAmount,
        originalAmount: originalAmount,
        savings: savings,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        userId: userId,  // Pass user ID to database service
      );

      if (success != null) {
        _currentOrder = success;
        // Add to local orders list
        _orders.insert(0, success);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create order';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load all orders
  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orders = await DatabaseService.instance.getOrders();
      _orders = orders;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load orders by user ID
  Future<void> loadOrdersByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orders = await DatabaseService.instance.getOrdersByUserId(userId);
      _orders = orders;
      _error = null;
      debugPrint('Loaded ${orders.length} orders for user $userId');
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load orders for user $userId: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load order by orderId (not database ID)
  Future<void> loadOrderById(String orderId) async {
    // If already loading this order, don't start another request
    if (_isLoading && _currentOrder?.orderId == orderId) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try to find in local orders
      try {
        final localOrder = _orders.firstWhere(
          (order) => order.orderId == orderId,
        );
        _currentOrder = localOrder;
        _error = null;
        debugPrint('Found order locally: ${localOrder.orderId}');
      } catch (e) {
        // If not found locally, try API
        debugPrint('Order not found locally, trying API for orderId: $orderId');
        final order = await DatabaseService.instance.getOrderByOrderId(orderId);
        if (order != null) {
          _currentOrder = order;
          _error = null;
          debugPrint('Found order via API: ${order.orderId}');
        } else {
          _error = 'Order not found';
          debugPrint('Order not found via API either');
        }
      }
    } catch (e) {
      _error = 'Failed to load order: $e';
      debugPrint('Error loading order: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final success = await DatabaseService.instance.updateOrderStatus(orderId, newStatus);
      
      if (success) {
        // Update local order
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index >= 0) {
          _orders[index] = _orders[index].copyWith(status: newStatus);
          notifyListeners();
        }
        
        // Update current order if it matches
        if (_currentOrder?.id == orderId) {
          _currentOrder = _currentOrder!.copyWith(status: newStatus);
          notifyListeners();
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to update order status: $e');
      notifyListeners();
      return false;
    }
  }

  // Clear current order
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get order count by status
  int getOrderCountByStatus(OrderStatus? status) {
    if (status == null) return _orders.length;
    return _orders.where((order) => order.status == status).length;
  }

  // Get running orders count
  int get runningOrdersCount => runningOrders.length;

  // Get completed orders count
  int get completedOrdersCount => completedOrders.length;
} 