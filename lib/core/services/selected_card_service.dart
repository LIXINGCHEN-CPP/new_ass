import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class SelectedCardService {
  static const String _selectedCardKey = 'selected_card';


  static Future<void> setSelectedCard(CardModel card) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCardKey, json.encode(card.toJson()));
  }

  static Future<CardModel?> getSelectedCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardString = prefs.getString(_selectedCardKey);
      
      if (cardString != null) {
        final cardJson = json.decode(cardString);
        return CardModel.fromJson(cardJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearSelectedCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedCardKey);
  }

  static Future<bool> hasSelectedCard() async {
    final card = await getSelectedCard();
    return card != null;
  }
} 