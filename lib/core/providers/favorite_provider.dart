import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/favorite_item_model.dart';
import '../models/product_model.dart';
import '../models/bundle_model.dart';

class FavoriteProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorites_list';
  
  List<FavoriteItemModel> _favoriteItems = [];
  bool _isLoading = false;

  // Getters
  List<FavoriteItemModel> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;
  
  // Check if favorites is empty
  bool get isEmpty => _favoriteItems.isEmpty;
  
  // Total favorites count
  int get totalFavoritesCount => _favoriteItems.length;

  // Constructor
  FavoriteProvider() {
    _loadFavoritesFromStorage();
  }

  // Load favorites from local storage
  Future<void> _loadFavoritesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString(_favoritesKey);
      
      if (favoritesString != null) {
        final favoritesList = json.decode(favoritesString) as List;
        _favoriteItems = favoritesList.map((item) => FavoriteItemModel.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load favorites data: $e');
    }
  }

  // Save favorites to local storage
  Future<void> _saveFavoritesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = json.encode(_favoriteItems.map((item) => item.toJson()).toList());
      await prefs.setString(_favoritesKey, favoritesString);
    } catch (e) {
      debugPrint('Failed to save favorites data: $e');
    }
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
      _favoriteItems.removeWhere((item) => item.itemId == itemId && item.type == type);
      await _saveFavoritesToStorage();
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