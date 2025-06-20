import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchHistoryService {
  static final SearchHistoryService _instance = SearchHistoryService._internal();
  static SearchHistoryService get instance => _instance;
  SearchHistoryService._internal();

  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  // Get search history from local storage
  Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_searchHistoryKey);
      
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

  // Add search term to history
  Future<void> addSearchTerm(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    
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
      final historyJson = json.encode(currentHistory);
      await prefs.setString(_searchHistoryKey, historyJson);
    } catch (e) {
      print('Error adding search term: $e');
    }
  }

  // Remove specific search term from history
  Future<void> removeSearchTerm(String searchTerm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHistory = await getSearchHistory();
      
      currentHistory.remove(searchTerm);
      
      final historyJson = json.encode(currentHistory);
      await prefs.setString(_searchHistoryKey, historyJson);
    } catch (e) {
      print('Error removing search term: $e');
    }
  }

  // Clear all search history
  Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
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