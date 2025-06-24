import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/bundle_model.dart';
import '../models/user_model.dart';
import '../models/coupon_model.dart';

class CartProvider with ChangeNotifier {
  static const String _cartKey = 'shopping_cart';
  static const String _usedCouponsKey = 'used_coupons';
  static List<String> _usedCouponIds = [];
  static bool _usedCouponsLoaded = false;
  
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _currentUserId;
  CouponModel? _selectedCoupon;

  // Getters
  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  CouponModel? get selectedCoupon => _selectedCoupon;
  
  // Check if cart is empty
  bool get isEmpty => _cartItems.isEmpty;
  
  // Total items count in cart
  int get totalItemsCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  // Total cart price before coupon discount
  double get subtotalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  // Total original price
  double get totalOriginalPrice => _cartItems.fold(
    0.0, 
    (sum, item) => sum + (item.originalPrice * item.quantity)
  );
  
  // Total savings amount from products
  double get productSavings => totalOriginalPrice - subtotalPrice;
  
  // Coupon discount amount
  double get couponDiscount => _selectedCoupon?.discountAmount ?? 0.0;
  
  // Total savings including coupon
  double get totalSavings => productSavings + couponDiscount;
  
  // Final total price after all discounts
  double get totalPrice {
    final subtotal = subtotalPrice;
    final discount = couponDiscount;
    final finalPrice = subtotal - discount;
    return finalPrice < 0 ? 0 : finalPrice; // Ensure price doesn't go negative
  }

  // Constructor
  CartProvider() {
    _loadUsedCoupons();
  }

  // Load used coupons from storage
  Future<void> _loadUsedCoupons() async {
    if (_usedCouponsLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final usedCouponsJson = prefs.getStringList(_usedCouponsKey);
      
      if (usedCouponsJson != null) {
        _usedCouponIds = usedCouponsJson;
      }
      
      _usedCouponsLoaded = true;
    } catch (e) {
      debugPrint('Failed to load used coupons: $e');
    }
  }

  // Save used coupons to storage
  Future<void> _saveUsedCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_usedCouponsKey, _usedCouponIds);
    } catch (e) {
      debugPrint('Failed to save used coupons: $e');
    }
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
      _selectedCoupon = null; // Clear selected coupon when clearing cart
      await _saveCartToStorage();
    } catch (e) {
      debugPrint('Failed to clear cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply coupon
  void applyCoupon(CouponModel coupon) {
    _selectedCoupon = coupon;
    notifyListeners();
  }

  // Remove coupon
  void removeCoupon() {
    _selectedCoupon = null;
    notifyListeners();
  }

  // Get all available coupons (static data for now)
  List<CouponModel> getAvailableCoupons() {
    final List<CouponModel> allCoupons = [
      CouponModel(
        id: '1',
        title: 'Black Coffee',
        subtitle: 'Save on your coffee order',
        discountAmount: 5.0,
        expireDate: 'Exp-28/12/2025',
        color: '0xFFA3D6CA',
      ),
      CouponModel(
        id: '2',
        title: 'Ice Cream',
        subtitle: 'Cool summer discount',
        discountAmount: 8.0,
        expireDate: 'Exp-25/10/2025',
        color: '0xFF96C2E2',
      ),
      CouponModel(
        id: '3',
        title: 'Oreo Biscuit',
        subtitle: 'Sweet savings deal',
        discountAmount: 12.0,
        expireDate: 'Exp-13/11/2025',
        color: '0xFFF4B3C5',
      ),
      CouponModel(
        id: '4',
        title: 'Tuna Fish',
        subtitle: 'Fresh seafood discount',
        discountAmount: 3.5,
        expireDate: 'Exp-28/12/2025',
        color: '0xFFF4AA8D',
      ),
    ];

    // Filter out used coupons
    return allCoupons.where((coupon) => !_usedCouponIds.contains(coupon.id)).toList();
  }

  // Mark a coupon as used
  Future<void> markCouponAsUsed() async {
    if (_selectedCoupon == null) return;
    
    try {
      // Add current coupon ID if not already in the list
      if (!_usedCouponIds.contains(_selectedCoupon!.id)) {
        _usedCouponIds.add(_selectedCoupon!.id);
        await _saveUsedCoupons();
      }
      
      // Clear selected coupon
      _selectedCoupon = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark coupon as used: $e');
    }
  }
} 