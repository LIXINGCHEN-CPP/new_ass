import 'product_model.dart';

class BundleItem {
  final String productId;
  final int quantity;
  final String? note;
  final ProductModel? productDetails;

  BundleItem({
    required this.productId,
    required this.quantity,
    this.note,
    this.productDetails,
  });

  factory BundleItem.fromJson(Map<String, dynamic> json) {
    return BundleItem(
      productId: json['productId']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      note: json['note'],
      productDetails: json['productDetails'] != null 
          ? ProductModel.fromJson(json['productDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'note': note,
      'productDetails': productDetails?.toJson(),
    };
  }
}

class BundleModel {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final List<BundleItem> items;
  final List<String> itemNames;
  final double currentPrice;
  final double originalPrice;
  final String? categoryId;
  final bool isActive;
  final bool isPopular;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BundleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.items,
    required this.itemNames,
    required this.currentPrice,
    required this.originalPrice,
    this.categoryId,
    required this.isActive,
    required this.isPopular,
    this.createdAt,
    this.updatedAt,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) {
    return BundleModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['coverImage'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => BundleItem.fromJson(item))
          .toList() ?? [],
      itemNames: (json['itemNames'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      categoryId: json['categoryId']?.toString(),
      isActive: json['isActive'] ?? true,
      isPopular: json['isPopular'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'items': items.map((item) => item.toJson()).toList(),
      'itemNames': itemNames,
      'currentPrice': currentPrice,
      'originalPrice': originalPrice,
      'categoryId': categoryId,
      'isActive': isActive,
      'isPopular': isPopular,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  BundleModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImage,
    List<BundleItem>? items,
    List<String>? itemNames,
    double? currentPrice,
    double? originalPrice,
    String? categoryId,
    bool? isActive,
    bool? isPopular,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BundleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      items: items ?? this.items,
      itemNames: itemNames ?? this.itemNames,
      currentPrice: currentPrice ?? this.currentPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get cover => coverImage;
  double get price => currentPrice;
  double get mainPrice => originalPrice;
} 