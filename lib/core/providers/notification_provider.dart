import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/notification_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class NotificationProvider with ChangeNotifier {
  static const String _notificationsKey = 'notifications_list';
  static const String _defaultNotificationsKey = 'default_notifications_initialized';

  // Current user notifications (specific to logged in user)
  List<NotificationModel> _userNotifications = [];
  bool _isLoading = false;
  String? _currentUserId;

  // Notification settings
  bool _appNotification = true;
  bool _phoneNumberNotification = true;
  bool _offerNotification = false;

  // Getters
  List<NotificationModel> get userNotifications => _userNotifications;
  bool get isLoading => _isLoading;
  bool get appNotification => _appNotification;
  bool get phoneNumberNotification => _phoneNumberNotification;
  bool get offerNotification => _offerNotification;

  // Default promotional notifications 
  List<NotificationModel> _getDefaultNotifications(String userId) => [
    NotificationModel(
      id: '${userId}_default_1',
      type: NotificationType.promotion,
      title: 'Welcome to E-Grocery!',
      subtitle: 'Thank you for joining us! Enjoy your shopping experience.',
      imageLink: 'https://i.imgur.com/MFO1R5K.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      isRead: true, 
    ),
    NotificationModel(
      id: '${userId}_default_2',
      type: NotificationType.coupon,
      title: 'First Order Discount',
      subtitle: 'Get 10% off on your first order! Use code: WELCOME10',
      imageLink: 'https://i.imgur.com/cl19m4w.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: true, 
    ),
    NotificationModel(
      id: '${userId}_default_3',
      type: NotificationType.promotion,
      title: 'Fresh Vegetables Daily',
      subtitle: 'Get fresh vegetables delivered to your doorstep every day!',
      imageLink: 'https://i.imgur.com/VSwGkZg.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      isRead: true, 
    ),
  ];

  // All notifications for current user (sorted by time)
  List<NotificationModel> get allNotifications {
    final notifications = [..._userNotifications];
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
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

  // Load notifications for current user from storage
  Future<void> _loadNotificationsFromStorage() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = '${_notificationsKey}_$_currentUserId';
      final notificationsString = prefs.getString(notificationsKey);
      
      if (notificationsString != null) {
        final notificationsList = json.decode(notificationsString) as List;
        _userNotifications = notificationsList
            .map((item) => NotificationModel.fromJson(item))
            .toList();
       
        await _migrateDefaultNotifications();
      } else {
        // First time loading for this user - add default notifications
        await _initializeDefaultNotifications();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    }
  }

  // Save notifications for current user to storage
  Future<void> _saveNotificationsToStorage() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = '${_notificationsKey}_$_currentUserId';
      final notificationsString = json.encode(
        _userNotifications.map((item) => item.toJson()).toList()
      );
      await prefs.setString(notificationsKey, notificationsString);
    } catch (e) {
      debugPrint('Failed to save notifications: $e');
    }
  }

  // Initialize default notifications for new user
  Future<void> _initializeDefaultNotifications() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultKey = '${_defaultNotificationsKey}_$_currentUserId';
      final hasInitialized = prefs.getBool(defaultKey) ?? false;
      
      if (!hasInitialized) {
        _userNotifications.addAll(_getDefaultNotifications(_currentUserId!));
        await prefs.setBool(defaultKey, true);
        await _saveNotificationsToStorage();
        debugPrint('Initialized default notifications for user: $_currentUserId');
      }
    } catch (e) {
      debugPrint('Failed to initialize default notifications: $e');
    }
  }

  // Migrate existing default notifications to mark them as read
  Future<void> _migrateDefaultNotifications() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final migrationKey = 'default_notifications_migrated_$_currentUserId';
      final hasMigrated = prefs.getBool(migrationKey) ?? false;
      
      if (!hasMigrated) {
        bool hasChanges = false;
        

        for (int i = 0; i < _userNotifications.length; i++) {
          final notification = _userNotifications[i];
          
          if (notification.id.contains('_default_') && !notification.isRead) {
            _userNotifications[i] = notification.copyWith(isRead: true);
            hasChanges = true;
            debugPrint('Migrated default notification to read: ${notification.id}');
          }
        }
        
        if (hasChanges) {
          await _saveNotificationsToStorage();
          debugPrint('Migration completed for user: $_currentUserId');
        }
        
        await prefs.setBool(migrationKey, true);
      }
    } catch (e) {
      debugPrint('Failed to migrate default notifications: $e');
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

  // Set current user (call when user logs in)
  Future<void> setCurrentUser(UserModel? user) async {
    _currentUserId = user?.id;
    _userNotifications.clear();
    
    if (_currentUserId != null) {
      await _loadNotificationsFromStorage();
    }
    notifyListeners();
  }

  // Clear user session (call when user logs out)
  Future<void> clearUserSession() async {
    _currentUserId = null;
    _userNotifications.clear();
    notifyListeners();
  }

  // Add order success notification
  Future<void> addOrderSuccessNotification(OrderModel order) async {
    if (!_appNotification || _currentUserId == null) return; // Respect user settings

    final notification = NotificationModel.orderSuccess(order: order);
    _userNotifications.insert(0, notification);
    await _saveNotificationsToStorage();
    notifyListeners();
    
    debugPrint('Added order success notification for order: ${order.orderId}');
  }

  // Add order status update notification
  Future<void> addOrderStatusNotification(OrderModel order) async {
    if (!_appNotification || _currentUserId == null) return; // Respect user settings

    final notification = NotificationModel.orderStatusUpdate(order: order);
    _userNotifications.insert(0, notification);
    await _saveNotificationsToStorage();
    notifyListeners();
    
    debugPrint('Added order status notification for order: ${order.orderId}');
  }

  // Add favorite added notification
  Future<void> addFavoriteAddedNotification({
    required String itemName,
    required String itemType,
    String? itemImage,
    required String itemId,
  }) async {
    if (!_appNotification || _currentUserId == null) return; // Respect user settings

    final notification = NotificationModel.favoriteAdded(
      itemName: itemName,
      itemType: itemType,
      itemImage: itemImage,
      itemId: itemId,
    );
    _userNotifications.insert(0, notification);
    await _saveNotificationsToStorage();
    notifyListeners();
    
    debugPrint('Added favorite notification for $itemType: $itemName');
  }

  // Add favorite removed notification
  Future<void> addFavoriteRemovedNotification({
    required String itemName,
    required String itemType,
    String? itemImage,
    required String itemId,
  }) async {
    if (!_appNotification || _currentUserId == null) return; // Respect user settings

    final notification = NotificationModel.favoriteRemoved(
      itemName: itemName,
      itemType: itemType,
      itemImage: itemImage,
      itemId: itemId,
    );
    _userNotifications.insert(0, notification);
    await _saveNotificationsToStorage();
    notifyListeners();
    
    debugPrint('Added favorite removed notification for $itemType: $itemName');
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
    if (_currentUserId == null) return;
    
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

    _userNotifications.insert(0, notification);
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _userNotifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _userNotifications[index] = _userNotifications[index].copyWith(isRead: true);
      await _saveNotificationsToStorage();
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _userNotifications.length; i++) {
      _userNotifications[i] = _userNotifications[i].copyWith(isRead: true);
    }
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _userNotifications.removeWhere((n) => n.id == notificationId);
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  // Clear all user notifications
  Future<void> clearAllNotifications() async {
    _userNotifications.clear();
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

  // Get favorite notifications
  List<NotificationModel> get favoriteNotifications => 
      getNotificationsByType(NotificationType.favorite);
} 