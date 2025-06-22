import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/bundle_model.dart';
import '../models/user_model.dart';

class CartProvider with ChangeNotifier {
  static const String _cartKey = 'shopping_cart';
  
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _currentUserId;

  // Getters
  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  
  // Check if cart is empty
  bool get isEmpty => _cartItems.isEmpty;
  
  // Total items count in cart
  int get totalItemsCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  // Total cart price
  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  // Total original price
  double get totalOriginalPrice => _cartItems.fold(
    0.0, 
    (sum, item) => sum + (item.originalPrice * item.quantity)
  );
  
  // Total savings amount
  double get totalSavings => totalOriginalPrice - totalPrice;

  // Constructor
  CartProvider() {
    
  }

  
  Future<void> _loadCartFromStorage() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartKey = '${_cartKey}_$_currentUserId';
      final cartString = prefs.getString(cartKey);
      
      if (cartString != null) {
        final cartList = json.decode(cartString) as List;
        _cartItems = cartList.map((item) => CartItemModel.fromJson(item)).toList();
      } else {
        _cartItems = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load cart data: $e');
    }
  }

 
  Future<void> _saveCartToStorage() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartKey = '${_cartKey}_$_currentUserId';
      final cartString = json.encode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(cartKey, cartString);
    } catch (e) {
      debugPrint('Failed to save cart data: $e');
    }
  }


  Future<void> setCurrentUser(UserModel? user) async {
    _currentUserId = user?.id;
    _cartItems.clear();
    
    if (_currentUserId != null) {
      await _loadCartFromStorage();
    }
    notifyListeners();
  }

  // Clear user session (call when user logs out)
  Future<void> clearUserSession() async {
    _currentUserId = null;
    _cartItems.clear();
    notifyListeners();
  }

  // Check if item is in cart
  bool isInCart(String itemId, CartItemType type) {
    return _cartItems.any((item) => item.itemId == itemId && item.type == type);
  }

  // Get item quantity in cart
  int getItemQuantity(String itemId, CartItemType type) {
    final item = _cartItems.firstWhere(
      (item) => item.itemId == itemId && item.type == type,
      orElse: () => CartItemModel(
        id: '',
        type: type,
        itemId: itemId,
        name: '',
        weight: '',
        coverImage: '',
        currentPrice: 0,
        originalPrice: 0,
        quantity: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  // Add product to cart
  Future<void> addProduct(ProductModel product, {int quantity = 1}) async {
    if (product.id == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Check if already exists
      final existingIndex = _cartItems.indexWhere(
        (item) => item.itemId == product.id && item.type == CartItemType.product,
      );

      if (existingIndex >= 0) {
        // If exists, increase quantity
        _cartItems[existingIndex].quantity += quantity;
      } else {
        // If not exists, create new cart item
        final cartItem = CartItemModel.fromProduct(product, quantity: quantity);
        _cartItems.add(cartItem);
      }

      await _saveCartToStorage();
    } catch (e) {
      debugPrint('Failed to add product to cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add bundle to cart
  Future<void> addBundle(BundleModel bundle, {int quantity = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if already exists
      final existingIndex = _cartItems.indexWhere(
        (item) => item.itemId == bundle.id && item.type == CartItemType.bundle,
      );

      if (existingIndex >= 0) {
        // If exists, increase quantity
        _cartItems[existingIndex].quantity += quantity;
      } else {
        // If not exists, create new cart item
        final cartItem = CartItemModel.fromBundle(bundle, quantity: quantity);
        _cartItems.add(cartItem);
      }

      await _saveCartToStorage();
    } catch (e) {
      debugPrint('Failed to add bundle to cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update cart item quantity
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(cartItemId);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        _cartItems[index].quantity = newQuantity;
        await _saveCartToStorage();
      }
    } catch (e) {
      debugPrint('Failed to update cart quantity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Increase cart item quantity
  Future<void> increaseQuantity(String cartItemId) async {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      await updateQuantity(cartItemId, _cartItems[index].quantity + 1);
    }
  }

  // Decrease cart item quantity
  Future<void> decreaseQuantity(String cartItemId) async {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      await updateQuantity(cartItemId, _cartItems[index].quantity - 1);
    }
  }

  // Remove cart item
  Future<void> removeItem(String cartItemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems.removeWhere((item) => item.id == cartItemId);
      await _saveCartToStorage();
    } catch (e) {
      debugPrint('Failed to remove cart item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems.clear();
      await _saveCartToStorage();
    } catch (e) {
      debugPrint('Failed to clear cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 