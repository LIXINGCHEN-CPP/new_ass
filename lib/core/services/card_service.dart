// services/card_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class CardService {
  static const String _cardsKey = 'saved_cards';

  // 保存卡片
  static Future<void> saveCard(CardModel card) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await getCards();
    cards.add(card);

    final cardsJson = cards.map((card) => card.toJson()).toList();
    await prefs.setString(_cardsKey, jsonEncode(cardsJson));
  }

  // 获取所有卡片
  static Future<List<CardModel>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsString = prefs.getString(_cardsKey);

    if (cardsString == null || cardsString.isEmpty) {
      // 返回默认卡片
      return [
        CardModel(
          cardNumber: '1464654654565',
          expiryDate: '10/28',
          cardHolderName: 'Shirley Hart',
          cvvCode: '542',
          backgroundImage: 'https://i.imgur.com/uUDkwQx.png',
        ),
      ];
    }

    final cardsList = jsonDecode(cardsString) as List;
    return cardsList.map((json) => CardModel.fromJson(json)).toList();
  }

  // 删除卡片
  static Future<void> deleteCard(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await getCards();

    if (index >= 0 && index < cards.length) {
      cards.removeAt(index);
      final cardsJson = cards.map((card) => card.toJson()).toList();
      await prefs.setString(_cardsKey, jsonEncode(cardsJson));
    }
  }
}