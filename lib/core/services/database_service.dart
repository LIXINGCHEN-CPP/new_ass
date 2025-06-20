import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/bundle_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../enums/dummy_order_status.dart';
import 'dart:math' as math;

/// Product search data structure
class ProductSearchData {
  final String name;

  ProductSearchData({
    required this.name,
  });
}

/// Keyword scoring result
class _KeywordScoreResult {
  final double score;
  final String matchType;

  _KeywordScoreResult({required this.score, required this.matchType});
}

/// Field scoring result
class _FieldScoreResult {
  final double score;
  final String matchType;

  _FieldScoreResult({required this.score, required this.matchType});
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  DatabaseService._internal();

  bool _isConnected = false;
  bool _useLocalData = false;

  // Backend API configuration - using 10.0.2.2 to access localhost (for Android emulator)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String healthUrl = 'http://10.0.2.2:3000/health';
  static const Duration timeoutDuration = Duration(seconds: 10);
  
  // Test backend connection
  Future<bool> connect() async {
    try {
      debugPrint('Testing backend API connection to: $healthUrl');
      final response = await http.get(
        Uri.parse(healthUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);
      
      debugPrint('Health check response: ${response.statusCode}');
      debugPrint('Health check body: ${response.body}');
      
      if (response.statusCode == 200) {
        _isConnected = true;
        _useLocalData = false;
        debugPrint('Backend API connection successful');
        return true;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Backend API connection failed: $e');
      debugPrint('Using local mock data');
      _isConnected = false;
      _useLocalData = true;
      return false;
    }
  }

  // Helper method for making HTTP requests
  Future<Map<String, dynamic>> _makeRequest(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('API request failed ($endpoint): $e');
      throw e;
    }
  }

  // Categories CRUD operations
  Future<List<CategoryModel>> getCategories() async {
    if (_useLocalData) {
      debugPrint('Using local category data');
      return _getMockCategories();
    }
    
    try {
      final responseData = await _makeRequest('/categories');
      
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        debugPrint('Successfully fetched ${data.length} categories from API');
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      debugPrint('Failed to fetch category data: $e, using local data');
      _useLocalData = true;
      return _getMockCategories();
    }
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    if (_useLocalData) {
      try {
        return _getMockCategories().firstWhere((cat) => cat.id == id);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final responseData = await _makeRequest('/categories/$id');
      
      if (responseData['success'] == true) {
        return CategoryModel.fromJson(responseData['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch category: $e');
      return null;
    }
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    throw UnimplementedError('Create operations not implemented');
  }

  // Products CRUD operations
  Future<List<ProductModel>> getProducts({String? categoryId, bool? isNew, bool? isPopular}) async {
    if (_useLocalData) {
      debugPrint('Using local product data');
      return _getMockProducts().where((product) {
        if (categoryId != null && product.categoryId != categoryId) return false;
        if (isNew != null && product.isNew != isNew) return false;
        if (isPopular != null && product.isPopular != isPopular) return false;
        return true;
      }).toList();
    }
    
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isNew != null) queryParams['isNew'] = isNew.toString();
      if (isPopular != null) queryParams['isPopular'] = isPopular.toString();
      
      final queryString = queryParams.isNotEmpty 
          ? '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '';
      
      final responseData = await _makeRequest('/products$queryString');
      
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        debugPrint('Successfully fetched ${data.length} products from API');
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch products');
      }
    } catch (e) {
      debugPrint('Failed to fetch product data: $e, using local data');
      _useLocalData = true;
      return _getMockProducts().where((product) {
        if (categoryId != null && product.categoryId != categoryId) return false;
        if (isNew != null && product.isNew != isNew) return false;
        if (isPopular != null && product.isPopular != isPopular) return false;
        return true;
      }).toList();
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    if (_useLocalData) {
      try {
        return _getMockProducts().firstWhere((product) => product.id == id);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final responseData = await _makeRequest('/products/$id');
      
      if (responseData['success'] == true) {
        return ProductModel.fromJson(responseData['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch product: $e');
      return null;
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    throw UnimplementedError('Create operations not implemented');
  }

  // Bundles CRUD operations
  Future<List<BundleModel>> getBundles({String? categoryId, bool? isPopular}) async {
    if (_useLocalData) {
      debugPrint('Using local bundle data');
      return _getMockBundles().where((bundle) {
        if (categoryId != null && bundle.categoryId != categoryId) return false;
        if (isPopular != null && bundle.isPopular != isPopular) return false;
        return true;
      }).toList();
    }
    
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isPopular != null) queryParams['isPopular'] = isPopular.toString();
      
      final queryString = queryParams.isNotEmpty 
          ? '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '';
      
      final responseData = await _makeRequest('/bundles$queryString');
      
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        debugPrint('Successfully fetched ${data.length} bundles from API');
        return data.map((json) => BundleModel.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch bundles');
      }
    } catch (e) {
      debugPrint('Failed to fetch bundle data: $e, using local data');
      _useLocalData = true;
      return _getMockBundles().where((bundle) {
        if (categoryId != null && bundle.categoryId != categoryId) return false;
        if (isPopular != null && bundle.isPopular != isPopular) return false;
        return true;
      }).toList();
    }
  }

  Future<BundleModel?> getBundleById(String id) async {
    if (_useLocalData) {
      try {
        return _getMockBundles().firstWhere((bundle) => bundle.id == id);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final responseData = await _makeRequest('/bundles/$id');
      
      if (responseData['success'] == true) {
        return BundleModel.fromJson(responseData['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch bundle: $e');
      return null;
    }
  }

  Future<BundleModel> createBundle(BundleModel bundle) async {
    throw UnimplementedError('Create operations not implemented');
  }

    // Get bundle details with product information
  Future<BundleModel?> getBundleDetails(String bundleId) async {
    if (_useLocalData) {
      try {
        return _getMockBundles().firstWhere((bundle) => bundle.id == bundleId);
      } catch (e) {
        return null;
      }
    }

    try {
      debugPrint('Fetching bundle details: $bundleId');
      
      final responseData = await _makeRequest('/bundles/$bundleId');

      if (responseData['success'] == true && responseData['data'] != null) {
        final bundle = BundleModel.fromJson(responseData['data']);
        debugPrint('Successfully fetched bundle details: ${bundle.name}');
        return bundle;
      } else if (responseData['success'] == false) {
        debugPrint('Bundle not found: $bundleId');
        return null;
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to fetch bundle details: $e');
      // If API fails, try to get from local data
      try {
        return _getMockBundles().firstWhere((bundle) => bundle.id == bundleId);
      } catch (e) {
        return null;
      }
    }
  }

  // Search operations
  Future<List<ProductModel>> searchProducts(String query) async {
    if (_useLocalData) {
      final products = _getMockProducts();
      return _searchProductsWithScoring(products, query);
    }
    
    try {
      final responseData = await _makeRequest('/products/search/${Uri.encodeComponent(query)}');
      
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        final products = data.map((json) => ProductModel.fromJson(json)).toList();
        // Re-rank using local scoring algorithm to ensure frontend rule compliance
        return _searchProductsWithScoring(products, query);
      } else {
        throw Exception(responseData['message'] ?? 'Search failed');
      }
    } catch (e) {
      debugPrint('Product search failed: $e, using local search');
      final products = await getProducts();
      return _searchProductsWithScoring(products, query);
    }
  }

  /// Smart multi-keyword search algorithm: supports space-separated keywords, searches product name only
  List<ProductModel> _searchProductsWithScoring(List<ProductModel> products, String query) {
    if (query.isEmpty) return [];
    
    final originalQuery = query.trim();
    final keywords = _splitQuery(originalQuery);
    final List<MapEntry<ProductModel, double>> scoredResults = [];
    
    debugPrint('🔍 Search query: "$originalQuery"');
    debugPrint('📝 Split keywords: ${keywords.join(", ")}');
    
    for (final product in products) {
      final ProductSearchData searchData = ProductSearchData(
        name: product.name.toLowerCase(),
      );
      
      double totalScore = 0;
      List<String> matchDetails = [];
      int matchedKeywords = 0;
      
      // Calculate score for each keyword
      for (final keyword in keywords) {
        final keywordScore = _calculateKeywordScore(searchData, keyword);
        if (keywordScore.score > 0) {
          totalScore += keywordScore.score;
          matchedKeywords++;
          matchDetails.add('${keyword}(${keywordScore.score.toStringAsFixed(0)}${keywordScore.matchType})');
        }
      }
      
      // Only products matching all keywords are included in results
      if (matchedKeywords == keywords.length) {
        // Multi-keyword bonus: more keywords matched, higher reward
        double multiKeywordBonus = keywords.length > 1 ? (keywords.length - 1) * 100 : 0;
        totalScore += multiKeywordBonus;
        
        // Length weight: shorter product names get higher scores
        double lengthBonus = math.max(0, (30 - searchData.name.length) * 3);
        totalScore += lengthBonus;
        
        // Completeness bonus: more complete matches get higher scores
        double completenessBonus = (matchedKeywords / keywords.length) * 200;
        totalScore += completenessBonus;
        
        debugPrint('  ✅ ${product.name} -> Score: ${totalScore.toStringAsFixed(1)} (${matchDetails.join(", ")})');
        scoredResults.add(MapEntry(product, totalScore));
      } else {
        debugPrint('  ❌ ${product.name} -> Partial match ($matchedKeywords/${keywords.length} keywords)');
      }
    }
    
    // Sort by score in descending order
    scoredResults.sort((a, b) => b.value.compareTo(a.value));
    
    debugPrint('🏆 Search results sorted (total ${scoredResults.length}):');
    for (int i = 0; i < math.min(5, scoredResults.length); i++) {
      final entry = scoredResults[i];
      debugPrint('  ${i + 1}. ${entry.key.name} (${entry.value.toStringAsFixed(1)})');
    }
    
    return scoredResults.map((entry) => entry.key).toList();
  }
  
  /// Split query into multiple keywords
  List<String> _splitQuery(String query) {
    return query.toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .where((keyword) => keyword.isNotEmpty)
        .toList();
  }

  /// Calculate score of a single keyword in product name
  _KeywordScoreResult _calculateKeywordScore(ProductSearchData searchData, String keyword) {
    // Search only in product name
    final nameScore = _calculateFieldScore(searchData.name, keyword, 1.0);
    return _KeywordScoreResult(
      score: nameScore.score, 
      matchType: nameScore.matchType,
    );
  }

  /// Calculate field matching score
  _FieldScoreResult _calculateFieldScore(String field, String keyword, double fieldWeight) {
    if (field.isEmpty || keyword.isEmpty) {
      return _FieldScoreResult(score: 0, matchType: '');
    }
    
    double baseScore = 0;
    String matchType = '';
    
    // 1. Exact match (highest score)
    if (field == keyword) {
      baseScore = 1000;
      matchType = '=';
    }
    // 2. Starts with keyword (high score)
    else if (field.startsWith(keyword)) {
      baseScore = 900;
      matchType = '^';
    }
    // 3. Word starts match (medium-high score)
    else if (_wordStartsMatch(field, keyword)) {
      baseScore = 700;
      matchType = 'W';
    }
    // 4. Contains match (medium score)
    else if (field.contains(keyword)) {
      // Base score determined by keyword length, single character gets lower score
      baseScore = keyword.length == 1 ? 300 : 500;
      matchType = '~';
      // Position weight: earlier position gets higher weight
      int position = field.indexOf(keyword);
      baseScore = baseScore - (position * 5);
      // Ensure the score never drops below zero to avoid negative keyword impact
      baseScore = math.max(0, baseScore);
    }
    
    // Apply field weight
    double finalScore = baseScore * fieldWeight;
    
    return _FieldScoreResult(score: finalScore, matchType: matchType);
  }

  /// Check if any word starts with the keyword
  bool _wordStartsMatch(String text, String keyword) {
    final words = text.split(RegExp(r'[^a-zA-Z0-9]+'));
    return words.any((word) => word.startsWith(keyword) && word.isNotEmpty);
  }

  // Mock data methods
  List<CategoryModel> _getMockCategories() {
    return [
      CategoryModel(
        id: '1',
        name: 'Vegetables',
        imageUrl: 'https://i.imgur.com/Gbf50lM.png',
        backgroundColor: '#ccefdc',
        description: 'Fresh vegetables and greens',
        sortOrder: 1,
      ),
      CategoryModel(
        id: '2',
        name: 'Meat&Fish',
        imageUrl: 'https://img.picui.cn/free/2025/05/22/682e33389bd4e.png',
        backgroundColor: '#ccefdc',
        description: 'Fresh meat and fish',
        sortOrder: 2,
      ),
      CategoryModel(
        id: '3',
        name: 'Medicine',
        imageUrl: 'https://i.imgur.com/yHdeMr7.png',
        backgroundColor: '#ccefdc',
        description: 'Health and medicine products',
        sortOrder: 3,
      ),
      CategoryModel(
        id: '4',
        name: 'Baby Care',
        imageUrl: 'https://i.imgur.com/uGEmzyU.png',
        backgroundColor: '#ccefdc',
        description: 'Baby care essentials',
        sortOrder: 4,
      ),
      CategoryModel(
        id: '5',
        name: 'Office Supplies',
        imageUrl: 'https://i.imgur.com/ShO7Pdz.png',
        backgroundColor: '#ccefdc',
        description: 'Office and stationery items',
        sortOrder: 5,
      ),
      CategoryModel(
        id: '6',
        name: 'Beauty',
        imageUrl: 'https://i.imgur.com/zyXxqa5.png',
        backgroundColor: '#ccefdc',
        description: 'Beauty and cosmetic products',
        sortOrder: 6,
      ),
      CategoryModel(
        id: '7',
        name: 'Gym Equipment',
        imageUrl: 'https://i.imgur.com/VRSBMt5.png',
        backgroundColor: '#ccefdc',
        description: 'Fitness and gym equipment',
        sortOrder: 7,
      ),
      CategoryModel(
        id: '8',
        name: 'Gardening Tools',
        imageUrl: 'https://i.imgur.com/rpN3TSz.png',
        backgroundColor: '#ccefdc',
        description: 'Gardening tools and supplies',
        sortOrder: 8,
      ),
      CategoryModel(
        id: '9',
        name: 'Pet Care',
        imageUrl: 'https://i.imgur.com/vwJBZ6M.png',
        backgroundColor: '#ccefdc',
        description: 'Pet care products',
        sortOrder: 9,
      ),
      CategoryModel(
        id: '10',
        name: 'Eye Wears',
        imageUrl: 'https://i.imgur.com/Kjwt5ve.png',
        backgroundColor: '#ccefdc',
        description: 'Glasses and eye wear',
        sortOrder: 10,
      ),
      CategoryModel(
        id: '11',
        name: 'Pack',
        imageUrl: 'https://i.imgur.com/okTi0ck.png',
        backgroundColor: '#ccefdc',
        description: 'Various packs and bundles',
        sortOrder: 11,
      ),
      CategoryModel(
        id: '12',
        name: 'Others',
        imageUrl: 'https://i.imgur.com/m65fusg.png',
        backgroundColor: '#ccefdc',
        description: 'Other miscellaneous items',
        sortOrder: 12,
      ),
    ];
  }

  List<ProductModel> _getMockProducts() {
    return [
      ProductModel(
        id: 'prod_1',
        name: 'Perry\'s Ice Cream Banana',
        description: 'Delicious banana flavored ice cream from Perry\'s',
        weight: '800 gm',
        coverImage: 'https://i.imgur.com/6unJlSL.png',
        images: ['https://i.imgur.com/6unJlSL.png'],
        currentPrice: 13,
        originalPrice: 15,
        categoryId: '12', // Others category (corrected from Beauty to Others)
        stock: 50,
        isNew: true,
        tags: ['ice cream', 'dessert', 'banana'],
      ),
      ProductModel(
        id: 'prod_2',
        name: 'Vanilla Ice Cream Banana',
        description: 'Creamy vanilla ice cream with banana flavor',
        weight: '500 gm',
        coverImage: 'https://i.imgur.com/oaCY49b.png',
        images: ['https://i.imgur.com/oaCY49b.png'],
        currentPrice: 12,
        originalPrice: 15,
        categoryId: '12', // Others category (corrected from Beauty to Others)
        stock: 30,
        isNew: true,
        tags: ['ice cream', 'dessert', 'vanilla'],
      ),
      ProductModel(
        id: 'prod_3',
        name: 'Beef',
        description: 'Fresh high-quality beef',
        weight: '1 Kg',
        coverImage: 'https://i.imgur.com/5wghZji.png',
        images: ['https://i.imgur.com/5wghZji.png'],
        currentPrice: 15,
        originalPrice: 18,
        categoryId: '2', // Meat&Fish category
        stock: 25,
        isPopular: true,
        tags: ['meat', 'beef', 'protein'],
      ),
      ProductModel(
        id: 'prod_4',
        name: 'Mushroom',
        description: 'Fresh organic mushrooms',
        weight: '500 gm',
        coverImage: 'https://i.imgur.com/XyAQYNX.jpeg',
        images: ['https://i.imgur.com/XyAQYNX.jpeg'],
        currentPrice: 15,
        originalPrice: 20,
        categoryId: '1', // Vegetables category
        stock: 40,
        tags: ['mushroom', 'vegetables', 'organic'],
      ),
      ProductModel(
        id: 'prod_5',
        name: 'Fresh Milk',
        description: 'Pure fresh milk from local farms',
        weight: '1 Kg',
        coverImage: 'https://i.imgur.com/9GqopLf.png',
        images: ['https://i.imgur.com/9GqopLf.png'],
        currentPrice: 15,
        originalPrice: 18,
        categoryId: '12', // Others category
        stock: 60,
        tags: ['milk', 'dairy', 'fresh'],
      ),
      ProductModel(
        id: 'prod_6',
        name: 'Pencil Case',
        description: 'Durable pencil case for office use',
        weight: '1 Pair',
        coverImage: 'https://i.imgur.com/k7MfSmE.jpeg',
        images: ['https://i.imgur.com/k7MfSmE.jpeg'],
        currentPrice: 15,
        originalPrice: 17,
        categoryId: '5', // Office Supplies category
        stock: 100,
        tags: ['stationery', 'office', 'pencil case'],
      ),
      ProductModel(
        id: 'prod_7',
        name: 'Tray of Eggs',
        description: 'Fresh farm eggs, 12 pieces',
        weight: '1 Kg',
        coverImage: 'https://i.imgur.com/FFnxmbr.png',
        images: ['https://i.imgur.com/FFnxmbr.png'],
        currentPrice: 15,
        originalPrice: 18,
        categoryId: '12', // Others category
        stock: 35,
        tags: ['eggs', 'protein', 'fresh'],
      ),
      ProductModel(
        id: 'prod_8',
        name: 'Green Vegetables',
        description: 'Mixed fresh green vegetables',
        weight: '500 gm',
        coverImage: 'https://i.imgur.com/gdCzhXW.jpeg',
        images: ['https://i.imgur.com/gdCzhXW.jpeg'],
        currentPrice: 12,
        originalPrice: 15,
        categoryId: '1', // Vegetables category
        stock: 45,
        tags: ['vegetables', 'green', 'healthy'],
      ),
      ProductModel(
        id: 'prod_9',
        name: 'Broccoli',
        description: 'Fresh broccoli, rich in vitamin C and dietary fiber',
        weight: '600 gm',
        coverImage: 'https://i.imgur.com/3o6ons9.png',
        images: ['https://i.imgur.com/3o6ons9.png'],
        currentPrice: 13,
        originalPrice: 15,
        categoryId: '1', // Vegetables category
        stock: 20,
        tags: ['broccoli', 'vegetables', 'vitamin c'],
      ),
      ProductModel(
        id: 'prod_10',
        name: 'Carrot',
        description: 'Fresh orange carrots, great for cooking',
        weight: '1 Kg',
        coverImage: 'https://i.imgur.com/upadTSW.jpeg',
        images: ['https://i.imgur.com/upadTSW.jpeg'],
        currentPrice: 15,
        originalPrice: 18,
        categoryId: '1', // Vegetables category
        stock: 55,
        tags: ['carrot', 'vegetables', 'orange'],
      ),
    ];
  }

  List<BundleModel> _getMockBundles() {
    return [
      BundleModel(
        id: 'bundle_1',
        name: 'Vegetables Pack',
        description: 'Fresh mixed vegetables bundle for healthy cooking',
        coverImage: 'https://i.imgur.com/Y0IFT2g.png',
        items: [
          BundleItem(
            productId: 'prod_4',
            quantity: 2,
            productDetails: ProductModel(
              id: 'prod_4',
              name: 'Mushroom',
              weight: '500 gm',
              coverImage: 'https://i.imgur.com/XyAQYNX.jpeg',
              images: ['https://i.imgur.com/XyAQYNX.jpeg'],
              currentPrice: 15,
              originalPrice: 20,
              categoryId: '1',
              stock: 40,
              tags: ['mushroom', 'vegetables', 'organic'],
            ),
          ),
          BundleItem(
            productId: 'prod_10',
            quantity: 1,
            productDetails: ProductModel(
              id: 'prod_10',
              name: 'Carrot',
              weight: '1 Kg',
              coverImage: 'https://i.imgur.com/upadTSW.jpeg',
              images: ['https://i.imgur.com/upadTSW.jpeg'],
              currentPrice: 15,
              originalPrice: 18,
              categoryId: '1',
              stock: 55,
              tags: ['carrot', 'vegetables', 'orange'],
            ),
          ),
        ],
        itemNames: ['Mushroom x2', 'Carrot x1'],
        currentPrice: 35,
        originalPrice: 50.32,
        categoryId: '1', // Vegetables category
        isActive: true,
        isPopular: true,
      ),
      BundleModel(
        id: 'bundle_2',
        name: 'Gardening Pack',
        description: 'Essential gardening tools for your garden',
        coverImage: 'https://i.imgur.com/RQ3gtlc.png',
        items: [
          BundleItem(
            productId: 'prod_6',
            quantity: 2,
            productDetails: ProductModel(
              id: 'prod_6',
              name: 'Gardening Tools',
              weight: '1 Set',
              coverImage: 'https://i.imgur.com/rpN3TSz.png',
              images: ['https://i.imgur.com/rpN3TSz.png'],
              currentPrice: 25,
              originalPrice: 30,
              categoryId: '8',
              stock: 15,
              tags: ['garden', 'tools', 'outdoor'],
            ),
          ),
        ],
        itemNames: ['Hoe x1', 'Scissors x1'],
        currentPrice: 35,
        originalPrice: 45,
        categoryId: '8', // Gardening Tools category
        isActive: true,
        isPopular: true,
      ),
      BundleModel(
        id: 'bundle_3',
        name: 'Medium Spices Pack',
        description: 'Essential spices for cooking',
        coverImage: 'https://i.postimg.cc/qtM4zj1K/packs-2.png',
        items: [
          BundleItem(
            productId: 'spice_1',
            quantity: 3,
            productDetails: ProductModel(
              id: 'spice_1',
              name: 'Mixed Spices',
              weight: '200 gm',
              coverImage: 'https://i.imgur.com/fI1BtZZ.jpeg',
              images: ['https://i.imgur.com/fI1BtZZ.jpeg'],
              currentPrice: 50,
              originalPrice: 65,
              categoryId: '12',
              stock: 30,
              tags: ['spices', 'cooking', 'flavor'],
            ),
          ),
        ],
        itemNames: ['Onion Powder', 'Cooking Oil', 'Sea Salt'],
        currentPrice: 150,
        originalPrice: 200,
        categoryId: '12', // Others category
        isActive: true,
        isPopular: false,
      ),
      BundleModel(
        id: 'bundle_4',
        name: 'Daily Essentials',
        description: 'Daily necessities bundle',
        coverImage: 'https://i.postimg.cc/MnwW8WRd/pack-1.png',
        items: [
          BundleItem(
            productId: 'prod_8',
            quantity: 1,
            productDetails: ProductModel(
              id: 'prod_8',
              name: 'Green Vegetables',
              weight: '500 gm',
              coverImage: 'https://i.imgur.com/gdCzhXW.jpeg',
              images: ['https://i.imgur.com/gdCzhXW.jpeg'],
              currentPrice: 12,
              originalPrice: 15,
              categoryId: '1',
              stock: 45,
              tags: ['vegetables', 'green', 'healthy'],
            ),
          ),
          BundleItem(
            productId: 'prod_5',
            quantity: 1,
            productDetails: ProductModel(
              id: 'prod_5',
              name: 'Fresh Milk',
              weight: '1 L',
              coverImage: 'https://i.imgur.com/9GqopLf.png',
              images: ['https://i.imgur.com/9GqopLf.png'],
              currentPrice: 15,
              originalPrice: 18,
              categoryId: '12',
              stock: 60,
              tags: ['milk', 'dairy', 'fresh'],
            ),
          ),
        ],
        itemNames: ['Green Vegetables x1', 'Fresh Milk x1'],
        currentPrice: 29,
        originalPrice: 37,
        categoryId: '12', // Others category
        isActive: true,
        isPopular: true,
      ),
      BundleModel(
        id: 'bundle_5',
        name: 'Spice Pack',
        description: 'Premium spice collection',
        coverImage: 'https://i.imgur.com/fI1BtZZ.jpeg',
        items: [
          BundleItem(
            productId: 'spice_2',
            quantity: 4,
            productDetails: ProductModel(
              id: 'spice_2',
              name: 'Black Pepper',
              weight: '100 gm',
              coverImage: 'https://i.imgur.com/fI1BtZZ.jpeg',
              images: ['https://i.imgur.com/fI1BtZZ.jpeg'],
              currentPrice: 8,
              originalPrice: 12,
              categoryId: '12',
              stock: 25,
              tags: ['spices', 'pepper', 'seasoning'],
            ),
          ),
        ],
        itemNames: ['Black Pepper', 'Cinnamon', 'Cardamom', 'Cloves'],
        currentPrice: 11.5,
        originalPrice: 20,
        categoryId: '12', // Others category
        isActive: true,
        isPopular: false,
      ),
      BundleModel(
        id: 'bundle_6',
        name: 'Stationery Pack',
        description: 'Complete stationery set for office',
        coverImage: 'https://i.imgur.com/tk4JddK.jpeg',
        items: [
          BundleItem(
            productId: 'prod_6',
            quantity: 1,
            productDetails: ProductModel(
              id: 'prod_6',
              name: 'Pencil Case',
              weight: '1 Pair',
              coverImage: 'https://i.imgur.com/k7MfSmE.jpeg',
              images: ['https://i.imgur.com/k7MfSmE.jpeg'],
              currentPrice: 15,
              originalPrice: 17,
              categoryId: '5',
              stock: 100,
              tags: ['stationery', 'office', 'pencil case'],
            ),
          ),
        ],
        itemNames: ['Pencil Case x1', 'Ruler x1', 'Eraser x2'],
        currentPrice: 35,
        originalPrice: 50.32,
        categoryId: '5', // Office Supplies category
        isActive: true,
        isPopular: false,
      ),
      BundleModel(
        id: 'bundle_7',
        name: 'Cosmetic Pack',
        description: 'Beauty essentials collection',
        coverImage: 'https://i.imgur.com/zyXxqa5.png',
        items: [
          BundleItem(
            productId: 'cosmetic_1',
            quantity: 3,
            productDetails: ProductModel(
              id: 'cosmetic_1',
              name: 'Beauty Essentials',
              weight: '1 Set',
              coverImage: 'https://i.imgur.com/zyXxqa5.png',
              images: ['https://i.imgur.com/zyXxqa5.png'],
              currentPrice: 450,
              originalPrice: 500,
              categoryId: '6',
              stock: 20,
              tags: ['beauty', 'cosmetics', 'makeup'],
            ),
          ),
        ],
        itemNames: ['Lipstick x1', 'Foundation x1', 'Mascara x1'],
        currentPrice: 500,
        originalPrice: 550,
        categoryId: '6', // Beauty category
        isActive: true,
        isPopular: false,
      ),
      BundleModel(
        id: 'bundle_8',
        name: 'First Aid Kit',
        description: 'Emergency medical supplies',
        coverImage: 'https://i.imgur.com/HmoQQIz.jpeg',
        items: [
          BundleItem(
            productId: 'medicine_1',
            quantity: 1,
            productDetails: ProductModel(
              id: 'medicine_1',
              name: 'Medical Supplies',
              weight: '1 Kit',
              coverImage: 'https://i.imgur.com/yHdeMr7.png',
              images: ['https://i.imgur.com/yHdeMr7.png'],
              currentPrice: 30,
              originalPrice: 40,
              categoryId: '3',
              stock: 15,
              tags: ['medicine', 'first aid', 'emergency'],
            ),
          ),
        ],
        itemNames: ['Gauze x5', 'Medicine Bottle x2', 'Bandages x10'],
        currentPrice: 35,
        originalPrice: 50.32,
        categoryId: '3', // Medicine category
        isActive: true,
        isPopular: false,
      ),
    ];
  }

  // Orders CRUD operations
  Future<OrderModel?> createOrder({
    required List<CartItemModel> items,
    required double totalAmount,
    required double originalAmount,
    required double savings,
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    // Try to reconnect if we're using local data
    if (_useLocalData) {
      debugPrint('Attempting to reconnect to backend before creating order...');
      final connected = await connect();
      if (!connected) {
        debugPrint('Creating order with local mock data');
        return _createMockOrder(
          items: items,
          totalAmount: totalAmount,
          originalAmount: originalAmount,
          savings: savings,
          paymentMethod: paymentMethod,
          deliveryAddress: deliveryAddress,
        );
      }
    }

    try {
      final requestBody = {
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'originalAmount': originalAmount,
        'savings': savings,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
      };

      debugPrint('Sending order request to: $baseUrl/orders');
      debugPrint('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(timeoutDuration);

      debugPrint('Order response status: ${response.statusCode}');
      debugPrint('Order response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          debugPrint('Order created successfully via API');
          debugPrint('Parsing order data: ${responseData['data']}');
          return OrderModel.fromJson(responseData['data']);
        }
      }
      
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('Failed to create order via API: $e, using local data');
      _useLocalData = true;
      return _createMockOrder(
        items: items,
        totalAmount: totalAmount,
        originalAmount: originalAmount,
        savings: savings,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
      );
    }
  }

  Future<List<OrderModel>> getOrders({OrderStatus? status}) async {
    if (_useLocalData) {
      debugPrint('Using local order data');
      return _getMockOrders().where((order) {
        if (status != null && order.status != status) return false;
        return true;
      }).toList();
    }

    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status.index.toString();
      
      final queryString = queryParams.isNotEmpty 
          ? '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '';

      final responseData = await _makeRequest('/orders$queryString');
      
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        debugPrint('Successfully fetched ${data.length} orders from API');
        
        // For now, only show the last 3 most recent orders to simulate user filtering
        final allOrders = data.map((json) => OrderModel.fromJson(json)).toList();
        allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
        final recentOrders = allOrders.take(3).toList(); // Take only the 3 most recent
        debugPrint('Showing ${recentOrders.length} recent orders');
        
        return recentOrders;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      debugPrint('Failed to fetch orders: $e, using local data');
      _useLocalData = true;
      return _getMockOrders().where((order) {
        if (status != null && order.status != status) return false;
        return true;
      }).toList();
    }
  }

  Future<OrderModel?> getOrderById(String id) async {
    if (_useLocalData) {
      try {
        return _getMockOrders().firstWhere((order) => order.id == id);
      } catch (e) {
        return null;
      }
    }

    try {
      final responseData = await _makeRequest('/orders/$id');
      
      if (responseData['success'] == true) {
        return OrderModel.fromJson(responseData['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch order: $e');
      return null;
    }
  }

  Future<OrderModel?> getOrderByOrderId(String orderId) async {
    if (_useLocalData) {
      try {
        return _getMockOrders().firstWhere((order) => order.orderId == orderId);
      } catch (e) {
        return null;
      }
    }

    try {
      final responseData = await _makeRequest('/orders/by-order-id/$orderId');
      
      if (responseData['success'] == true) {
        return OrderModel.fromJson(responseData['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch order by order ID: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    if (_useLocalData) {
      debugPrint('Mock order status update for order: $orderId to ${newStatus.name}');
      return true; // Mock success
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus.index}),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to update order status: $e');
      return false;
    }
  }

  // Mock order creation
  OrderModel _createMockOrder({
    required List<CartItemModel> items,
    required double totalAmount,
    required double originalAmount,
    required double savings,
    required String paymentMethod,
    required String deliveryAddress,
  }) {
    final orderId = (math.Random().nextInt(900000000) + 100000000).toString();
    final now = DateTime.now();
    
    return OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      status: OrderStatus.confirmed,
      items: items,
      totalAmount: totalAmount,
      originalAmount: originalAmount,
      savings: savings,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      createdAt: now,
      confirmedAt: now,
    );
  }

  // Mock orders data
  List<OrderModel> _getMockOrders() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    
    return [
      OrderModel(
        id: 'order_1',
        orderId: '232425627',
        status: OrderStatus.delivery,
        items: [
          CartItemModel(
            id: 'cart_1',
            type: CartItemType.product,
            itemId: 'prod_1',
            name: 'Sample Product 1',
            weight: '500g',
            coverImage: 'https://example.com/product1.jpg',
            currentPrice: 15.0,
            originalPrice: 18.0,
            quantity: 3,
            addedAt: twoDaysAgo,
          ),
          CartItemModel(
            id: 'cart_2',
            type: CartItemType.product,
            itemId: 'prod_2',
            name: 'Sample Product 2',
            weight: '1kg',
            coverImage: 'https://example.com/product2.jpg',
            currentPrice: 12.0,
            originalPrice: 15.0,
            quantity: 3,
            addedAt: twoDaysAgo,
          ),
          CartItemModel(
            id: 'cart_3',
            type: CartItemType.product,
            itemId: 'prod_3',
            name: 'Sample Product 3',
            weight: '750g',
            coverImage: 'https://example.com/product3.jpg',
            currentPrice: 20.0,
            originalPrice: 25.0,
            quantity: 3,
            addedAt: twoDaysAgo,
          ),
        ],
        totalAmount: 120.0,
        originalAmount: 141.0,
        savings: 21.0,
        paymentMethod: 'Credit Card',
        deliveryAddress: '123 Main Street, City, State',
        createdAt: twoDaysAgo,
        confirmedAt: twoDaysAgo,
        processingAt: twoDaysAgo.add(const Duration(hours: 2)),
        shippedAt: yesterday,
        deliveredAt: now.subtract(const Duration(hours: 1)),
      ),
      OrderModel(
        id: 'order_2',
        orderId: '232425628',
        status: OrderStatus.shipped,
        items: [
          CartItemModel(
            id: 'cart_4',
            type: CartItemType.product,
            itemId: 'prod_4',
            name: 'Fresh Vegetables',
            weight: '1kg',
            coverImage: 'https://example.com/vegetables.jpg',
            currentPrice: 8.0,
            originalPrice: 10.0,
            quantity: 2,
            addedAt: yesterday,
          ),
        ],
        totalAmount: 16.0,
        originalAmount: 20.0,
        savings: 4.0,
        paymentMethod: 'PayPal',
        deliveryAddress: '456 Oak Avenue, City, State',
        createdAt: yesterday,
        confirmedAt: yesterday,
        processingAt: yesterday.add(const Duration(hours: 1)),
        shippedAt: now.subtract(const Duration(hours: 3)),
      ),
      OrderModel(
        id: 'order_3',
        orderId: '232425629',
        status: OrderStatus.processing,
        items: [
          CartItemModel(
            id: 'cart_5',
            type: CartItemType.bundle,
            itemId: 'bundle_1',
            name: 'Grocery Bundle',
            weight: 'Bundle',
            coverImage: 'https://example.com/bundle.jpg',
            currentPrice: 45.0,
            originalPrice: 60.0,
            quantity: 1,
            addedAt: now.subtract(const Duration(hours: 4)),
          ),
        ],
        totalAmount: 45.0,
        originalAmount: 60.0,
        savings: 15.0,
        paymentMethod: 'Cash on Delivery',
        deliveryAddress: '789 Pine Street, City, State',
        createdAt: now.subtract(const Duration(hours: 4)),
        confirmedAt: now.subtract(const Duration(hours: 4)),
        processingAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }
} 