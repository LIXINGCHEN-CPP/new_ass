import 'product_model.dart';
import 'bundle_model.dart';

enum CartItemType { product, bundle }

class CartItemModel {
  final String id;
  final CartItemType type;
  final String itemId; // productId or bundleId
  final String name;
  final String weight;
  final String coverImage;
  final double currentPrice;
  final double originalPrice;
  int quantity;
  final DateTime addedAt;
  
  // Complete product or bundle information (optional)
  final ProductModel? productDetails;
  final BundleModel? bundleDetails;

  CartItemModel({
    required this.id,
    required this.type,
    required this.itemId,
    required this.name,
    required this.weight,
    required this.coverImage,
    required this.currentPrice,
    required this.originalPrice,
    required this.quantity,
    required this.addedAt,
    this.productDetails,
    this.bundleDetails,
  });

  // Create CartItem from Product
  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItemModel(
      id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: CartItemType.product,
      itemId: product.id!,
      name: product.name,
      weight: product.weight,
      coverImage: product.coverImage,
      currentPrice: product.currentPrice,
      originalPrice: product.originalPrice,
      quantity: quantity,
      addedAt: DateTime.now(),
      productDetails: product,
    );
  }

  // Create CartItem from Bundle
  factory CartItemModel.fromBundle(BundleModel bundle, {int quantity = 1}) {
    return CartItemModel(
      id: '${bundle.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: CartItemType.bundle,
      itemId: bundle.id,
      name: bundle.name,
      weight: 'Bundle',
      coverImage: bundle.coverImage,
      currentPrice: bundle.currentPrice,
      originalPrice: bundle.originalPrice,
      quantity: quantity,
      addedAt: DateTime.now(),
      bundleDetails: bundle,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      type: CartItemType.values[json['type'] as int],
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      weight: json['weight'] as String,
      coverImage: json['coverImage'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
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
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
      'productDetails': productDetails?.toJson(),
      'bundleDetails': bundleDetails?.toJson(),
    };
  }

  // Get total price
  double get totalPrice => currentPrice * quantity;

  // Get savings amount
  double get savingsAmount => (originalPrice - currentPrice) * quantity;

  // Copy method
  CartItemModel copyWith({
    String? id,
    CartItemType? type,
    String? itemId,
    String? name,
    String? weight,
    String? coverImage,
    double? currentPrice,
    double? originalPrice,
    int? quantity,
    DateTime? addedAt,
    ProductModel? productDetails,
    BundleModel? bundleDetails,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      coverImage: coverImage ?? this.coverImage,
      currentPrice: currentPrice ?? this.currentPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      productDetails: productDetails ?? this.productDetails,
      bundleDetails: bundleDetails ?? this.bundleDetails,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel && 
           other.itemId == itemId && 
           other.type == type;
  }

  @override
  int get hashCode => itemId.hashCode ^ type.hashCode;
} 