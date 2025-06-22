import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchHistoryService {
  static final SearchHistoryService _instance = SearchHistoryService._internal();
  static SearchHistoryService get instance => _instance;
  SearchHistoryService._internal();

  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;
  
  String? _currentUserId;

 
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
  }

 
  void clearUserSession() {
    _currentUserId = null;
  }

 
  Future<List<String>> getSearchHistory() async {
    if (_currentUserId == null) return [];
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyKey = '${_searchHistoryKey}_$_currentUserId';
      final historyJson = prefs.getString(historyKey);
      
      if (historyJson == null) {
        return [];
      }
      
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList.cast<String>();
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  // Add search term to history for current user
  Future<void> addSearchTerm(String searchTerm) async {
    if (searchTerm.trim().isEmpty || _currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHistory = await getSearchHistory();
      
      // Remove if already exists to avoid duplicates
      currentHistory.remove(searchTerm);
      
      // Add to the beginning of the list
      currentHistory.insert(0, searchTerm);
      
      // Keep only the most recent items
      if (currentHistory.length > _maxHistoryItems) {
        currentHistory.removeRange(_maxHistoryItems, currentHistory.length);
      }
      
      // Save to local storage
      final historyKey = '${_searchHistoryKey}_$_currentUserId';
      final historyJson = json.encode(currentHistory);
      await prefs.setString(historyKey, historyJson);
    } catch (e) {
      print('Error adding search term: $e');
    }
  }

  // Remove specific search term from history for current user
  Future<void> removeSearchTerm(String searchTerm) async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHistory = await getSearchHistory();
      
      currentHistory.remove(searchTerm);
      
      final historyKey = '${_searchHistoryKey}_$_currentUserId';
      final historyJson = json.encode(currentHistory);
      await prefs.setString(historyKey, historyJson);
    } catch (e) {
      print('Error removing search term: $e');
    }
  }

  // Clear all search history for current user
  Future<void> clearSearchHistory() async {
    if (_currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyKey = '${_searchHistoryKey}_$_currentUserId';
      await prefs.remove(historyKey);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  // Check if search term exists in history
  Future<bool> hasSearchTerm(String searchTerm) async {
    final history = await getSearchHistory();
    return history.contains(searchTerm);
  }
} 