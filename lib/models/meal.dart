import 'package:flutter/foundation.dart';

/// A professional, strongly-typed model representing a Meal.
/// 
/// This class is designed following production standards:
/// - **Immutability**: All fields are final to ensure thread safety and predictable state.
/// - **Clean Data**: Ingredients are parsed from the API's flat structure into a single `List<String>`.
/// - **Defensive Parsing**: Handles nulls and malformed JSON to prevent runtime crashes.
@immutable
class Meal {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String? category;
  final String? area;
  final String? instructions;
  final String? youtubeUrl;
  final String? sourceUrl;
  final String? tags;
  final List<String> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    this.category,
    this.area,
    this.instructions,
    this.youtubeUrl,
    this.sourceUrl,
    this.tags,
    this.ingredients = const [],
  });

  /// Creates a summary [Meal] from a JSON map.
  /// 
  /// Used for listing meals where only basic info is provided by the API.
  factory Meal.fromSummaryJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? 'Unknown Meal',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
    );
  }

  /// Creates a full [Meal] from a JSON map, including ingredients.
  /// 
  /// This factory handles the complexity of TheMealDB's ingredient structure.
  /// It defensively checks for types and existence of keys to ensure safety.
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? 'Unknown Meal',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
      category: json['strCategory']?.toString(),
      area: json['strArea']?.toString(),
      instructions: json['strInstructions']?.toString(),
      youtubeUrl: json['strYoutube']?.toString(),
      sourceUrl: json['strSource']?.toString(),
      tags: json['strTags']?.toString(),
      ingredients: _parseIngredients(json),
    );
  }

  /// Helper logic to extract ingredients and measurements from the API's flat structure.
  /// 
  /// TheMealDB stores data in fields like strIngredient1, strMeasure1, etc.
  /// This method:
  /// 1. Iterates from index 1 to 20.
  /// 2. Safely extracts the ingredient and measure strings.
  /// 3. Ignores entries where the ingredient is null or empty.
  /// 4. Combines them into a clean "Measure Ingredient" format.
  static List<String> _parseIngredients(Map<String, dynamic> json) {
    final List<String> result = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim();
      final measure = json['strMeasure$i']?.toString().trim();

      // Only add to the list if the ingredient name is actually present
      if (ingredient != null && ingredient.isNotEmpty) {
        // Cleanly combine measure and ingredient. 
        // If measure is empty, just use the ingredient name.
        if (measure != null && measure.isNotEmpty) {
          result.add('$measure $ingredient');
        } else {
          result.add(ingredient);
        }
      }
    }
    return List.unmodifiable(result);
  }

  /// Convenience getter to split tags into a list.
  List<String> get tagList {
    if (tags == null || tags!.trim().isEmpty) return const [];
    return tags!
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Converts the [Meal] instance back to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': thumbnailUrl,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strYoutube': youtubeUrl,
      'strSource': sourceUrl,
      'strTags': tags,
      'ingredients': ingredients,
    };
  }

  /// Creates a copy of this Meal with the given fields replaced.
  Meal copyWith({
    String? id,
    String? name,
    String? thumbnailUrl,
    String? category,
    String? area,
    String? instructions,
    String? youtubeUrl,
    String? sourceUrl,
    String? tags,
    List<String>? ingredients,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Meal(id: $id, name: $name)';
}
