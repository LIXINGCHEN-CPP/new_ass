import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/notification_model.dart';
import '../models/order_model.dart';

class NotificationProvider with ChangeNotifier {
  static const String _notificationsKey = 'notifications_list';

  // Notifications list (dynamic notifications will be added here)
  List<NotificationModel> _dynamicNotifications = [];
  bool _isLoading = false;

  // Notification settings
  bool _appNotification = true;
  bool _phoneNumberNotification = true;
  bool _offerNotification = false;

  // Getters
  List<NotificationModel> get dynamicNotifications => _dynamicNotifications;
  bool get isLoading => _isLoading;
  bool get appNotification => _appNotification;
  bool get phoneNumberNotification => _phoneNumberNotification;
  bool get offerNotification => _offerNotification;

  // Hard-coded notifications (preserved as requested)
  List<NotificationModel> get hardCodedNotifications => [
    NotificationModel(
      id: 'hardcoded_1',
      type: NotificationType.order,
      title: 'E-Grocery Message',
      subtitle: 'Your order #232425627 Beef is out of stock. You can request a refund.',
      imageLink: 'https://i.imgur.com/XYbd8Tj.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      orderId: '232425627',
    ),
    NotificationModel(
      id: 'hardcoded_2',
      type: NotificationType.promotion,
      title: 'Gifts Offer',
      subtitle: 'Buy one gift and get one free! Limited time deal...',
      imageLink: 'https://i.imgur.com/MFO1R5K.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    NotificationModel(
      id: 'hardcoded_3',
      type: NotificationType.coupon,
      title: 'Coupon Offer',
      subtitle: 'Apply this coupon at checkout to save more...',
      imageLink: 'https://i.imgur.com/cl19m4w.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    NotificationModel(
      id: 'hardcoded_4',
      type: NotificationType.order,
      title: 'Congratulations',
      subtitle: 'Your order has been successfully placed！',
      imageLink: 'https://i.imgur.com/KKWqqrP.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: 'hardcoded_5',
      type: NotificationType.order,
      title: 'Your Order Cancelled',
      subtitle: 'Your recent order has been cancelled. Need help?',
      imageLink: 'https://i.imgur.com/jsDEdkz.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: 'hardcoded_6',
      type: NotificationType.promotion,
      title: 'Great Winter Discounts',
      subtitle: 'Enjoy special winter savings on selected items...',
      imageLink: 'https://i.imgur.com/hmUnrRE.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: 'hardcoded_7',
      type: NotificationType.promotion,
      title: '20% off Vegetables',
      subtitle: 'Get fresh vegetables at 20% off today only!',
      imageLink: 'https://i.imgur.com/VSwGkZg.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  // Combined notifications list (dynamic + hardcoded, sorted by time)
  List<NotificationModel> get allNotifications {
    final combined = [..._dynamicNotifications, ...hardCodedNotifications];
    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return combined;
  }

  // Unread notifications count
  int get unreadCount => allNotifications.where((n) => !n.isRead).length;

  // Constructor
  NotificationProvider() {
    _loadFromStorage();
  }

  // Load data from storage
  Future<void> _loadFromStorage() async {
    await Future.wait([
      _loadNotificationsFromStorage(),
      _loadSettingsFromStorage(),
    ]);
  }

  // Load notifications from storage
  Future<void> _loadNotificationsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString(_notificationsKey);
      
      if (notificationsString != null) {
        final notificationsList = json.decode(notificationsString) as List;
        _dynamicNotifications = notificationsList
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    }
  }

  // Save notifications to storage
  Future<void> _saveNotificationsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = json.encode(
        _dynamicNotifications.map((item) => item.toJson()).toList()
      );
      await prefs.setString(_notificationsKey, notificationsString);
    } catch (e) {
      debugPrint('Failed to save notifications: $e');
    }
  }

  // Load settings from storage
  Future<void> _loadSettingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _appNotification = prefs.getBool('app_notification') ?? true;
      _phoneNumberNotification = prefs.getBool('phone_notification') ?? true;
      _offerNotification = prefs.getBool('offer_notification') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load notification settings: $e');
    }
  }

  // Save settings to storage
  Future<void> _saveSettingsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_notification', _appNotification);
      await prefs.setBool('phone_notification', _phoneNumberNotification);
      await prefs.setBool('offer_notification', _offerNotification);
    } catch (e) {
      debugPrint('Failed to save notification settings: $e');
    }
  }

  // Add order success notification
  Future<void> addOrderSuccessNotification(OrderModel order) async {
    if (!_appNotification) return; // Respect user settings

    final notification = NotificationModel.orderSuccess(order: order);
    _dynamicNotifications.insert(0, notification);
    await _saveNotificationsToStorage();
    notifyListeners();
    
    debugPrint('Added order success notification for order: ${order.orderId}');
  }

  // Add order status update notification
  Future<void> addOrderStatusNotification(OrderModel order) async {
    if (!_appNotification) return; // Respect user settings

    final notification = NotificationModel.orderStatusUpdate(order: order);
    _dynamicNotifications.insert(0, notification);
    await _saveNotificationsToStorage();
    notifyListeners();
    
    debugPrint('Added order status notification for order: ${order.orderId}');
  }

  // Add custom notification
  Future<void> addCustomNotification({
    required NotificationType type,
    required String title,
    required String subtitle,
    String? imageLink,
    String? orderId,
    Map<String, dynamic>? extraData,
  }) async {
    final notification = NotificationModel(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      subtitle: subtitle,
      imageLink: imageLink,
      createdAt: DateTime.now(),
      orderId: orderId,
      extraData: extraData,
    );

    _dynamicNotifications.insert(0, notification);
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _dynamicNotifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _dynamicNotifications[index] = _dynamicNotifications[index].copyWith(isRead: true);
      await _saveNotificationsToStorage();
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _dynamicNotifications.length; i++) {
      _dynamicNotifications[i] = _dynamicNotifications[i].copyWith(isRead: true);
    }
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _dynamicNotifications.removeWhere((n) => n.id == notificationId);
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  // Clear all dynamic notifications
  Future<void> clearAllNotifications() async {
    _dynamicNotifications.clear();
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  // Update notification settings
  Future<void> updateAppNotification(bool value) async {
    _appNotification = value;
    await _saveSettingsToStorage();
    notifyListeners();
  }

  Future<void> updatePhoneNumberNotification(bool value) async {
    _phoneNumberNotification = value;
    await _saveSettingsToStorage();
    notifyListeners();
  }

  Future<void> updateOfferNotification(bool value) async {
    _offerNotification = value;
    await _saveSettingsToStorage();
    notifyListeners();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return allNotifications.where((n) => n.type == type).toList();
  }

  // Get order notifications
  List<NotificationModel> get orderNotifications => 
      getNotificationsByType(NotificationType.order);

  // Get promotion notifications
  List<NotificationModel> get promotionNotifications => 
      getNotificationsByType(NotificationType.promotion);
} 