class CouponModel {
  final String id;
  final String title;
  final String subtitle;
  final double discountAmount; // Fixed discount amount in dollars
  final String expireDate;
  final String color;
  final String? backgroundImage;
  final bool isActive;
  final bool isCollected;
  final bool isUsed;

  CouponModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.discountAmount,
    required this.expireDate,
    required this.color,
    this.backgroundImage,
    this.isActive = true,
    this.isCollected = true,
    this.isUsed = false,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      expireDate: json['expireDate'] ?? '',
      color: json['color'] ?? '',
      backgroundImage: json['backgroundImage'],
      isActive: json['isActive'] ?? true,
      isCollected: json['isCollected'] ?? true,
      isUsed: json['isUsed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'discountAmount': discountAmount,
      'expireDate': expireDate,
      'color': color,
      'backgroundImage': backgroundImage,
      'isActive': isActive,
      'isCollected': isCollected,
      'isUsed': isUsed,
    };
  }

  CouponModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? discountAmount,
    String? expireDate,
    String? color,
    String? backgroundImage,
    bool? isActive,
    bool? isCollected,
    bool? isUsed,
  }) {
    return CouponModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      discountAmount: discountAmount ?? this.discountAmount,
      expireDate: expireDate ?? this.expireDate,
      color: color ?? this.color,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      isActive: isActive ?? this.isActive,
      isCollected: isCollected ?? this.isCollected,
      isUsed: isUsed ?? this.isUsed,
    );
  }
} 