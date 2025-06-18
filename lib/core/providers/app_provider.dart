import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/bundle_model.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  // State variables
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<BundleModel> _bundles = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<BundleModel> get bundles => _bundles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get filtered products
  List<ProductModel> getProductsByCategory(String? categoryId) {
    if (categoryId == null) return _products;
    return _products.where((product) => product.categoryId == categoryId).toList();
  }
  
  List<ProductModel> get newProducts => _products;
  List<ProductModel> get popularProducts => _products.where((product) => product.isPopular).toList();
  
  // Get filtered bundles
  List<BundleModel> getBundlesByCategory(String? categoryId) {
    if (categoryId == null) return _bundles;
    return _bundles.where((bundle) => bundle.categoryId == categoryId).toList();
  }
  
  List<BundleModel> get popularBundles => _bundles.where((bundle) => bundle.isPopular).toList();
  
  // Initialize data
  Future<void> initializeData() async {
    _setLoading(true);
    _setError(null);
    
    try {
      await Future.wait([
        loadCategories(),
        loadProducts(),
        loadBundles(),
      ]);
    } catch (e) {
      _setError('Failed to load data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load categories
  Future<void> loadCategories() async {
    try {
      final categories = await _databaseService.getCategories();
      _categories = categories;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }
  
  // Load products
  Future<void> loadProducts() async {
    try {
      final products = await _databaseService.getProducts();
      _products = products;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: $e');
    }
  }
  
  // Load bundles
  Future<void> loadBundles() async {
    try {
      final bundles = await _databaseService.getBundles();
      _bundles = bundles;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load bundles: $e');
    }
  }
  
  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      return await _databaseService.searchProducts(query);
    } catch (e) {
      _setError('Search failed: $e');
      return [];
    }
  }
  
  // Get specific items by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      return await _databaseService.getProductById(id);
    } catch (e) {
      _setError('Failed to get product: $e');
      return null;
    }
  }
  
  Future<BundleModel?> getBundleById(String id) async {
    try {
      return await _databaseService.getBundleById(id);
    } catch (e) {
      _setError('Failed to get bundle: $e');
      return null;
    }
  }
  
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      return await _databaseService.getCategoryById(id);
    } catch (e) {
      _setError('Failed to get category: $e');
      return null;
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 