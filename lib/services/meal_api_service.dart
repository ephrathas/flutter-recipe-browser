import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/meal.dart';
import '../models/meal_category.dart';
import 'api_exception.dart';

/// Senior-level API service layer for TheMealDB.
/// 
/// Refactored for maximum scalability and maintainability:
/// - **Orchestrated Flow**: Centralized request/response lifecycle.
/// - **Robust Decoding**: Defensive type checking for JSON maps.
/// - **Clean Error Mapping**: Conversion of raw exceptions to [ApiException].
class MealApiService {
  static const String _authority = 'www.themealdb.com';
  static const String _basePath = '/api/json/v1/1';
  static const Duration _timeoutDuration = Duration(seconds: 10);

  final http.Client _client;

  /// Injects an http.Client for better testability and resource management.
  MealApiService({http.Client? client}) : _client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // Public API Methods
  // ---------------------------------------------------------------------------

  /// Fetches the list of all available meal categories.
  Future<List<MealCategory>> fetchCategories() async {
    return _safeApiCall(
      uri: _buildUri('/categories.php'),
      onSuccess: (data) {
        final List<dynamic>? categoriesJson = data['categories'];
        if (categoriesJson == null) {
          throw ApiException.invalidResponse(details: 'Missing "categories" key');
        }
        return categoriesJson
            .map((item) => MealCategory.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Fetches meals filtered by a specific [category] name.
  Future<List<Meal>> fetchMealsByCategory(String category) async {
    return _safeApiCall(
      uri: _buildUri('/filter.php', {'c': category}),
      onSuccess: (data) {
        final List<dynamic>? mealsJson = data['meals'];
        if (mealsJson == null) return <Meal>[];
        return mealsJson
            .map((item) => Meal.fromSummaryJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Fetches full details for a specific meal by its [mealId].
  Future<Meal> fetchMealDetail(String mealId) async {
    return _safeApiCall(
      uri: _buildUri('/lookup.php', {'i': mealId}),
      onSuccess: (data) {
        final List<dynamic>? mealsJson = data['meals'];
        if (mealsJson == null || mealsJson.isEmpty) {
          throw ApiException.notFound(resource: 'Meal with ID $mealId');
        }
        return Meal.fromJson(mealsJson.first as Map<String, dynamic>);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable Helper Methods (Senior Level Architecture)
  // ---------------------------------------------------------------------------

  /// A generic wrapper that orchestrates the entire API lifecycle.
  /// 
  /// Benefits:
  /// 1. **Zero Duplication**: Network, timeout, and HTTP error handling happens in one place.
  /// 2. **Type Safety**: Uses Generics `<T>` to return correctly typed data models.
  /// 3. **Future Proof**: If we add global logging or caching, we only edit this method.
  Future<T> _safeApiCall<T>({
    required Uri uri,
    required T Function(Map<String, dynamic> data) onSuccess,
  }) async {
    try {
      final response = await _client.get(uri).timeout(_timeoutDuration);
      
      // 1. Validate HTTP Status
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException.httpError(response.statusCode);
      }

      // 2. Decode JSON
      final dynamic decodedBody = _decodeJson(response.body);

      // 3. Validate Shape
      if (decodedBody is! Map<String, dynamic>) {
        throw ApiException.invalidResponse(
          details: 'Expected JSON Object, got ${decodedBody.runtimeType}',
        );
      }

      // 4. Transform to Domain Model
      return onSuccess(decodedBody);
      
    } on SocketException catch (e) {
      throw ApiException.networkError(cause: e);
    } on TimeoutException catch (e) {
      throw ApiException.timeout(cause: e);
    } on FormatException catch (e) {
      throw ApiException.invalidResponse(details: 'Invalid JSON format', cause: e);
    } on ApiException {
      rethrow; // Pass custom exceptions up as-is
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred', cause: e);
    }
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    return Uri.https(_authority, '$_basePath$path', queryParameters);
  }

  dynamic _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      throw const FormatException('Failed to decode JSON response');
    }
  }
}
