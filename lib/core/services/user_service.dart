import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class UserService {
  // Delete user account
  static Future<Map<String, dynamic>> deleteAccount(String currentPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in'
        };
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}/$userId/delete-account');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'currentPassword': currentPassword,
        }),
      ).timeout(ApiConstants.timeoutDuration);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Clear all local user data
        await _clearUserData();
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Account deleted successfully'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete account'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Clear all user-related data from local storage
  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_phone');
    await prefs.remove('user_name');
    await prefs.remove('user_token');
    await prefs.remove('is_logged_in');
    // Clear any other user-related data
    await prefs.remove('cart_items');
    await prefs.remove('favorite_items');
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userPhone = prefs.getString('user_phone');
      final userName = prefs.getString('user_name');
      
      if (userId != null && userPhone != null && userName != null) {
        return {
          'id': userId,
          'phone': userPhone,
          'name': userName,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      return userId != null;
    } catch (e) {
      return false;
    }
  }
} 