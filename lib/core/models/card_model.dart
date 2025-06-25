// models/card_model.dart
class CardModel {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final String backgroundImage;

  CardModel({
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    this.backgroundImage = 'https://i.imgur.com/uUDkwQx.png',
  });

  // 转换为JSON用于存储
  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'cvvCode': cvvCode,
      'backgroundImage': backgroundImage,
    };
  }

  // 从JSON创建对象
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cardNumber: json['cardNumber'],
      expiryDate: json['expiryDate'],
      cardHolderName: json['cardHolderName'],
      cvvCode: json['cvvCode'],
      backgroundImage: json['backgroundImage'] ?? 'https://i.imgur.com/uUDkwQx.png',
    );
  }

  // 格式化卡号显示（隐藏中间数字）
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $lastFour';
  }
}