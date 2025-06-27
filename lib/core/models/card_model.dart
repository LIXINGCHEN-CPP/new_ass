// models/card_model.dart
class CardModel {
  final String? id;
  final String? userId;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final String backgroundImage;
  final bool isDefault;
  final DateTime? createdAt;

  CardModel({
    this.id,
    this.userId,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    this.backgroundImage = 'https://i.imgur.com/uUDkwQx.png',
    this.isDefault = false,
    this.createdAt,
  });

  // 转换为JSON用于存储
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (userId != null) 'userId': userId,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'cvvCode': cvvCode,
      'backgroundImage': backgroundImage,
      'isDefault': isDefault,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  // 从JSON创建对象
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['_id'],
      userId: json['userId'],
      cardNumber: json['cardNumber'],
      expiryDate: json['expiryDate'],
      cardHolderName: json['cardHolderName'],
      cvvCode: json['cvvCode'],
      backgroundImage: json['backgroundImage'] ?? 'https://i.imgur.com/uUDkwQx.png',
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  // 格式化卡号显示（隐藏中间数字）
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $lastFour';
  }
}