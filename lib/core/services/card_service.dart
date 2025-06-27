// services/card_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';
import '../constants/api_constants.dart';

class CardService {
  static const String _cardsKey = 'saved_cards';

  // Get current user ID
  static Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // 保存卡片到后端
  static Future<Map<String, dynamic>> saveCard(CardModel card) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in'
        };
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}/$userId/cards');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cardNumber': card.cardNumber,
          'expiryDate': card.expiryDate,
          'cardHolderName': card.cardHolderName,
          'cvvCode': card.cvvCode,
          'backgroundImage': card.backgroundImage,
          'isDefault': card.isDefault,
        }),
      ).timeout(ApiConstants.timeoutDuration);

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Card added successfully',
          'data': responseData['data']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add card'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // 获取用户的所有卡片
  static Future<List<CardModel>> getCards() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        // 如果用户未登录，返回本地存储的卡片或默认卡片
        return _getLocalCards();
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}/$userId/cards');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConstants.timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final cardsList = responseData['data'] as List;
        return cardsList.map((json) => CardModel.fromJson(json)).toList();
      } else {
        // 如果API调用失败，回退到本地存储
        return _getLocalCards();
      }
    } catch (e) {
      // 网络错误时回退到本地存储
      return _getLocalCards();
    }
  }

  // 获取本地存储的卡片（回退方案）
  static Future<List<CardModel>> _getLocalCards() async {
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
  static Future<Map<String, dynamic>> deleteCard(String cardId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in'
        };
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}/$userId/cards/$cardId');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConstants.timeoutDuration);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Card deleted successfully'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete card'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // 更新卡片
  static Future<Map<String, dynamic>> updateCard(String cardId, Map<String, dynamic> updateData) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in'
        };
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}/$userId/cards/$cardId');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      ).timeout(ApiConstants.timeoutDuration);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Card updated successfully'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update card'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // 设置默认卡片
  static Future<Map<String, dynamic>> setDefaultCard(String cardId) async {
    return updateCard(cardId, {'isDefault': true});
  }

  // 获取默认卡片
  static Future<CardModel?> getDefaultCard() async {
    final cards = await getCards();
    return cards.where((card) => card.isDefault).isNotEmpty 
        ? cards.where((card) => card.isDefault).first 
        : (cards.isNotEmpty ? cards.first : null);
  }
}