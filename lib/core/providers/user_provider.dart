import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/search_history_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize user session on app start
  Future<void> initializeUser() async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userPhone = prefs.getString('user_phone');

      if (userId != null && userPhone != null) {
        // Try to get user from database
        try {
          final user = await DatabaseService.instance.getUserById(userId);
          if (user != null) {
            _currentUser = user;
            _isLoggedIn = true;
            // Sync search history service
            SearchHistoryService.instance.setCurrentUser(user.id);
            debugPrint('User session restored: ${user.name}');
          } else {
            // User not found in database, clear local session
            debugPrint('User not found in database, clearing session');
            SearchHistoryService.instance.clearUserSession();
            await _clearLocalSession();
          }
        } catch (e) {
          // If getUserById fails, don't affect the main app, just clear session
          debugPrint('Failed to restore user session: $e');
          SearchHistoryService.instance.clearUserSession();
          await _clearLocalSession();
        }
      } else {
        debugPrint('No user session found');
      }
    } catch (e) {
      debugPrint('Failed to initialize user session: $e');
      SearchHistoryService.instance.clearUserSession();
      await _clearLocalSession();
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    String? email,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Check if user already exists
      final existingUser = await DatabaseService.instance.getUserByPhone(phone);
      if (existingUser != null) {
        _setError('Phone number already registered');
        return false;
      }

      // Create new user
      final user = await DatabaseService.instance.createUser(
        name: name,
        phone: phone,
        password: password,
        email: email,
      );

      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        await _saveLocalSession(user);
        // Sync search history service
        SearchHistoryService.instance.setCurrentUser(user.id);
        debugPrint('User registered successfully: ${user.name}');
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await DatabaseService.instance.loginUser(
        phone: phone,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        await _saveLocalSession(user);
        // Sync search history service
        SearchHistoryService.instance.setCurrentUser(user.id);
        debugPrint('User logged in successfully: ${user.name}');
        return true;
      } else {
        _setError('Invalid password');
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _clearLocalSession();
    // Clear search history service
    SearchHistoryService.instance.clearUserSession();
    debugPrint('User logged out');
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? address,
    String? profileImage,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      final updatedUser = await DatabaseService.instance.updateUser(
        userId: _currentUser!.id!,
        name: name,
        email: email,
        address: address,
        profileImage: profileImage,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _saveLocalSession(updatedUser);
        debugPrint('User profile updated successfully');
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Update failed: $e');
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile image
  Future<bool> updateProfileImage(String imagePath) async {
    if (_currentUser == null) return false;

    try {
      final success = await updateProfile(profileImage: imagePath);
      if (success) {
        debugPrint('Profile image updated: $imagePath');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to update profile image: $e');
      return false;
    }
  }

  // Update user with a UserModel object
  Future<bool> updateUser(UserModel user) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      final updatedUser = await DatabaseService.instance.updateUser(
        userId: _currentUser!.id!,
        name: user.name,
        email: user.email,
        address: user.address,
        profileImage: user.profileImage,
        gender: user.gender,
        birthday: user.birthday,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _saveLocalSession(updatedUser);
        debugPrint('User profile updated successfully');
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Update failed: $e');
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Save user session to local storage
  Future<void> _saveLocalSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id!);
      await prefs.setString('user_phone', user.phone);
      await prefs.setString('user_name', user.name);
    } catch (e) {
      debugPrint('Failed to save local session: $e');
    }
  }

  // Clear local session data
  Future<void> _clearLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_phone');
      await prefs.remove('user_name');
    } catch (e) {
      debugPrint('Failed to clear local session: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Check if user needs to complete profile
  bool get needsProfileCompletion {
    if (_currentUser == null) return false;
    return _currentUser!.email == null ||
        _currentUser!.address == null ||
        _currentUser!.address!.isEmpty;
  }
}
