import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/favorite_item_model.dart';
import '../models/product_model.dart';
import '../models/bundle_model.dart';
import '../models/user_model.dart';
import 'notification_provider.dart';

class FavoriteProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorites_list';
  
  List<FavoriteItemModel> _favoriteItems = [];
  bool _isLoading = false;
  String? _currentUserId;
  NotificationProvider? _notificationProvider;

  // Getters
  List<FavoriteItemModel> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;
  
  bool get isEmpty => _favoriteItems.isEmpty;
  
  int get totalFavoritesCount => _favoriteItems.length;

  FavoriteProvider() {
  }

  Future<void> _loadFavoritesFromStorage() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = '${_favoritesKey}_$_currentUserId';
      final favoritesString = prefs.getString(favoritesKey);
      
      if (favoritesString != null) {
        final favoritesList = json.decode(favoritesString) as List;
        _favoriteItems = favoritesList.map((item) => FavoriteItemModel.fromJson(item)).toList();
      } else {
        _favoriteItems = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load favorites data: $e');
    }
  }

  // Save favorites to local storage for current user
  Future<void> _saveFavoritesToStorage() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = '${_favoritesKey}_$_currentUserId';
      final favoritesString = json.encode(_favoriteItems.map((item) => item.toJson()).toList());
      await prefs.setString(favoritesKey, favoritesString);
    } catch (e) {
      debugPrint('Failed to save favorites data: $e');
    }
  }

  // Set current user (call when user logs in)
  Future<void> setCurrentUser(UserModel? user) async {
    _currentUserId = user?.id;
    _favoriteItems.clear();
    
    if (_currentUserId != null) {
      await _loadFavoritesFromStorage();
    }
    notifyListeners();
  }

  // Clear user session (call when user logs out)
  Future<void> clearUserSession() async {
    _currentUserId = null;
    _favoriteItems.clear();
    notifyListeners();
  }

  // Set notification provider for triggering notifications
  void setNotificationProvider(NotificationProvider? notificationProvider) {
    _notificationProvider = notificationProvider;
  }

  // Check if item is in favorites
  bool isFavorite(String itemId, FavoriteItemType type) {
    return _favoriteItems.any((item) => item.itemId == itemId && item.type == type);
  }

  // Add product to favorites
  Future<void> addProductToFavorites(ProductModel product) async {
    if (product.id == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Check if already exists
      final existingIndex = _favoriteItems.indexWhere(
        (item) => item.itemId == product.id && item.type == FavoriteItemType.product,
      );

      if (existingIndex < 0) {
        // If not exists, create new favorite item
        final favoriteItem = FavoriteItemModel.fromProduct(product);
        _favoriteItems.add(favoriteItem);
        await _saveFavoritesToStorage();
        
        // Trigger notification
        if (_notificationProvider != null) {
          await _notificationProvider!.addFavoriteAddedNotification(
            itemName: product.name,
            itemType: 'product',
            itemImage: product.coverImage,
            itemId: product.id!,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to add product to favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add bundle to favorites
  Future<void> addBundleToFavorites(BundleModel bundle) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if already exists
      final existingIndex = _favoriteItems.indexWhere(
        (item) => item.itemId == bundle.id && item.type == FavoriteItemType.bundle,
      );

      if (existingIndex < 0) {
        // If not exists, create new favorite item
        final favoriteItem = FavoriteItemModel.fromBundle(bundle);
        _favoriteItems.add(favoriteItem);
        await _saveFavoritesToStorage();
        
        // Trigger notification
        if (_notificationProvider != null) {
          await _notificationProvider!.addFavoriteAddedNotification(
            itemName: bundle.name,
            itemType: 'bundle',
            itemImage: bundle.coverImage,
            itemId: bundle.id,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to add bundle to favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String itemId, FavoriteItemType type) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find the item before removing it (for notification)
      final itemToRemove = _favoriteItems.firstWhere(
        (item) => item.itemId == itemId && item.type == type,
        orElse: () => throw StateError('Item not found'),
      );
      
      _favoriteItems.removeWhere((item) => item.itemId == itemId && item.type == type);
      await _saveFavoritesToStorage();
      
      // Trigger notification
      if (_notificationProvider != null) {
        await _notificationProvider!.addFavoriteRemovedNotification(
          itemName: itemToRemove.name,
          itemType: type == FavoriteItemType.product ? 'product' : 'bundle',
          itemImage: itemToRemove.coverImage,
          itemId: itemId,
        );
      }
    } catch (e) {
      debugPrint('Failed to remove from favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String itemId, FavoriteItemType type, {ProductModel? product, BundleModel? bundle}) async {
    if (isFavorite(itemId, type)) {
      await removeFromFavorites(itemId, type);
    } else {
      if (type == FavoriteItemType.product && product != null) {
        await addProductToFavorites(product);
      } else if (type == FavoriteItemType.bundle && bundle != null) {
        await addBundleToFavorites(bundle);
      }
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteItems.clear();
      await _saveFavoritesToStorage();
    } catch (e) {
      debugPrint('Failed to clear favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get favorites by type
  List<FavoriteItemModel> getFavoritesByType(FavoriteItemType type) {
    return _favoriteItems.where((item) => item.type == type).toList();
  }

  // Get product favorites
  List<FavoriteItemModel> get favoriteProducts => getFavoritesByType(FavoriteItemType.product);

  // Get bundle favorites
  List<FavoriteItemModel> get favoriteBundles => getFavoritesByType(FavoriteItemType.bundle);
} 