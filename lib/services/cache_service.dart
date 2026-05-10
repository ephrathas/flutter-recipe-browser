import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_category.dart';

/// A lightweight caching layer for local persistent storage.
///
/// Keeps cache-specific logic out of the UI and helps preserve clean
/// architecture boundaries between persistence and presentation.
class CacheService {
  static const String _cachedCategoriesKey = 'cached_categories';

  /// Saves a list of categories into local storage as JSON.
  ///
  /// Returns true when the write succeeds, false otherwise.
  Future<bool> saveCategories(List<MealCategory> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(categories.map((c) => c.toJson()).toList());
      return await prefs.setString(_cachedCategoriesKey, encoded);
    } catch (_) {
      return false;
    }
  }

  /// Retrieves cached categories from local storage.
  ///
  /// Returns null when no valid cache is available or the stored data is malformed.
  Future<List<MealCategory>?> getCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_cachedCategoriesKey);
      if (rawJson == null || rawJson.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(rawJson);
      if (decoded is! List<dynamic>) {
        await _invalidateMalformedCache(prefs);
        return null;
      }

      return decoded
          .map((item) => MealCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      final prefs = await SharedPreferences.getInstance();
      await _invalidateMalformedCache(prefs);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Removes a malformed cache entry to avoid repeated parse failures.
  Future<void> _invalidateMalformedCache(SharedPreferences prefs) async {
    await prefs.remove(_cachedCategoriesKey);
  }
}
