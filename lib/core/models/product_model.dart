class ProductModel {
  final String? id;
  final String name;
  final String? description;
  final String weight;
  final String coverImage;
  final List<String> images;
  final double currentPrice;
  final double originalPrice;
  final String? categoryId;
  final int stock;
  final bool isActive;
  final bool isNew;
  final bool isPopular;
  final List<String> tags;
  final Map<String, dynamic>? nutritionInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    required this.name,
    this.description,
    required this.weight,
    required this.coverImage,
    required this.images,
    required this.currentPrice,
    required this.originalPrice,
    this.categoryId,
    this.stock = 0,
    this.isActive = true,
    this.isNew = false,
    this.isPopular = false,
    this.tags = const [],
    this.nutritionInfo,
    this.createdAt,
    this.updatedAt,
  });

  // 保持兼容性的getter，映射到新的字段名
  String get cover => coverImage;
  double get price => currentPrice;
  double get mainPrice => originalPrice;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id']?.toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      weight: json['weight'] as String,
      coverImage: json['coverImage'] as String? ?? json['cover'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? (json['mainPrice'] as num).toDouble(),
      categoryId: json['categoryId']?.toString(),
      stock: json['stock'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isNew: json['isNew'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
      nutritionInfo: json['nutritionInfo'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (description != null) 'description': description,
      'weight': weight,
      'coverImage': coverImage,
      'images': images,
      'currentPrice': currentPrice,
      'originalPrice': originalPrice,
      if (categoryId != null) 'categoryId': categoryId,
      'stock': stock,
      'isActive': isActive,
      'isNew': isNew,
      'isPopular': isPopular,
      'tags': tags,
      if (nutritionInfo != null) 'nutritionInfo': nutritionInfo,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? weight,
    String? coverImage,
    List<String>? images,
    double? currentPrice,
    double? originalPrice,
    String? categoryId,
    int? stock,
    bool? isActive,
    bool? isNew,
    bool? isPopular,
    List<String>? tags,
    Map<String, dynamic>? nutritionInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      coverImage: coverImage ?? this.coverImage,
      images: images ?? this.images,
      currentPrice: currentPrice ?? this.currentPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      isNew: isNew ?? this.isNew,
      isPopular: isPopular ?? this.isPopular,
      tags: tags ?? this.tags,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 