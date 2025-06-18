import 'product_model.dart';
import 'bundle_model.dart';

enum FavoriteItemType { product, bundle }

class FavoriteItemModel {
  final String id;
  final FavoriteItemType type;
  final String itemId; // productId or bundleId
  final String name;
  final String weight;
  final String coverImage;
  final double currentPrice;
  final double originalPrice;
  final DateTime addedAt;
  
  // Complete product or bundle information (optional)
  final ProductModel? productDetails;
  final BundleModel? bundleDetails;

  FavoriteItemModel({
    required this.id,
    required this.type,
    required this.itemId,
    required this.name,
    required this.weight,
    required this.coverImage,
    required this.currentPrice,
    required this.originalPrice,
    required this.addedAt,
    this.productDetails,
    this.bundleDetails,
  });

  // Create FavoriteItem from Product
  factory FavoriteItemModel.fromProduct(ProductModel product) {
    return FavoriteItemModel(
      id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: FavoriteItemType.product,
      itemId: product.id!,
      name: product.name,
      weight: product.weight,
      coverImage: product.coverImage,
      currentPrice: product.currentPrice,
      originalPrice: product.originalPrice,
      addedAt: DateTime.now(),
      productDetails: product,
    );
  }

  // Create FavoriteItem from Bundle
  factory FavoriteItemModel.fromBundle(BundleModel bundle) {
    return FavoriteItemModel(
      id: '${bundle.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: FavoriteItemType.bundle,
      itemId: bundle.id,
      name: bundle.name,
      weight: 'Bundle',
      coverImage: bundle.coverImage,
      currentPrice: bundle.currentPrice,
      originalPrice: bundle.originalPrice,
      addedAt: DateTime.now(),
      bundleDetails: bundle,
    );
  }

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      id: json['id'] as String,
      type: FavoriteItemType.values[json['type'] as int],
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      weight: json['weight'] as String,
      coverImage: json['coverImage'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      addedAt: DateTime.parse(json['addedAt']),
      productDetails: json['productDetails'] != null 
          ? ProductModel.fromJson(json['productDetails'])
          : null,
      bundleDetails: json['bundleDetails'] != null 
          ? BundleModel.fromJson(json['bundleDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'itemId': itemId,
      'name': name,
      'weight': weight,
      'coverImage': coverImage,
      'currentPrice': currentPrice,
      'originalPrice': originalPrice,
      'addedAt': addedAt.toIso8601String(),
      'productDetails': productDetails?.toJson(),
      'bundleDetails': bundleDetails?.toJson(),
    };
  }

  // Get savings amount
  double get savingsAmount => originalPrice - currentPrice;

  // Copy method
  FavoriteItemModel copyWith({
    String? id,
    FavoriteItemType? type,
    String? itemId,
    String? name,
    String? weight,
    String? coverImage,
    double? currentPrice,
    double? originalPrice,
    DateTime? addedAt,
    ProductModel? productDetails,
    BundleModel? bundleDetails,
  }) {
    return FavoriteItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      coverImage: coverImage ?? this.coverImage,
      currentPrice: currentPrice ?? this.currentPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      addedAt: addedAt ?? this.addedAt,
      productDetails: productDetails ?? this.productDetails,
      bundleDetails: bundleDetails ?? this.bundleDetails,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteItemModel && 
           other.itemId == itemId && 
           other.type == type;
  }

  @override
  int get hashCode => itemId.hashCode ^ type.hashCode;
} 