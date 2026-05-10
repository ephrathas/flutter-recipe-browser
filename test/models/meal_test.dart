import 'package:flutter_test/flutter_test.dart';
import 'package:meal_explorer_app/models/meal.dart';

void main() {
  group('Meal Model Tests', () {
    // 1. fromSummaryJson
    test('fromSummaryJson parses correctly with valid data', () {
      final json = {
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken Casserole',
        'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg'
      };

      final meal = Meal.fromSummaryJson(json);

      expect(meal.id, '52772');
      expect(meal.name, 'Teriyaki Chicken Casserole');
      expect(meal.thumbnailUrl, 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg');
      expect(meal.category, isNull);
      expect(meal.ingredients, isEmpty);
    });

    test('fromSummaryJson handles missing or null fields defensively', () {
      final meal = Meal.fromSummaryJson({});

      expect(meal.id, '');
      expect(meal.name, 'Unknown Meal');
      expect(meal.thumbnailUrl, '');
    });

    // 2. fromJson
    test('fromJson parses full data correctly including tags and ingredients', () {
      final json = {
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken Casserole',
        'strCategory': 'Chicken',
        'strArea': 'Japanese',
        'strInstructions': 'Preheat oven to 350° F...',
        'strMealThumb': 'thumb.jpg',
        'strTags': 'Meat,Casserole',
        'strYoutube': 'https://youtube.com',
        'strSource': 'https://source.com',
        // Ingredient parsing fields
        'strIngredient1': 'soy sauce',
        'strMeasure1': '3/4 cup',
        'strIngredient2': 'water',
        'strMeasure2': '1/2 cup',
        'strIngredient3': ' ', // Empty should be ignored
        'strMeasure3': ' ',
        'strIngredient4': null, // Null should be ignored
      };

      final meal = Meal.fromJson(json);

      expect(meal.id, '52772');
      expect(meal.name, 'Teriyaki Chicken Casserole');
      expect(meal.category, 'Chicken');
      expect(meal.area, 'Japanese');
      expect(meal.instructions, 'Preheat oven to 350° F...');
      expect(meal.thumbnailUrl, 'thumb.jpg');
      expect(meal.tags, 'Meat,Casserole');
      expect(meal.tagList, ['Meat', 'Casserole']);
      expect(meal.youtubeUrl, 'https://youtube.com');
      expect(meal.sourceUrl, 'https://source.com');
      
      // Check ingredients defensive parsing
      expect(meal.ingredients, [
        '3/4 cup soy sauce',
        '1/2 cup water',
      ]);
    });

    test('fromJson parses ingredient correctly when measure is empty', () {
      final json = {
        'idMeal': '1',
        'strIngredient1': 'Salt',
        'strMeasure1': '',
        'strIngredient2': 'Pepper',
        'strMeasure2': null,
      };

      final meal = Meal.fromJson(json);
      expect(meal.ingredients, ['Salt', 'Pepper']);
    });

    test('fromJson handles completely empty JSON gracefully', () {
      final meal = Meal.fromJson({});

      expect(meal.id, '');
      expect(meal.name, 'Unknown Meal');
      expect(meal.thumbnailUrl, '');
      expect(meal.category, isNull);
      expect(meal.ingredients, isEmpty);
      expect(meal.tagList, isEmpty);
    });

    // 3. toJson
    test('toJson serializes model correctly', () {
      final meal = const Meal(
        id: '1',
        name: 'Test Meal',
        thumbnailUrl: 'thumb.jpg',
        category: 'Test Category',
        ingredients: ['1 cup Water'],
      );

      final json = meal.toJson();

      expect(json['idMeal'], '1');
      expect(json['strMeal'], 'Test Meal');
      expect(json['strMealThumb'], 'thumb.jpg');
      expect(json['strCategory'], 'Test Category');
      expect(json['ingredients'], ['1 cup Water']);
      expect(json['strArea'], isNull); // Was not set, so should be null
    });

    // 4. copyWith
    test('copyWith creates a new instance with updated values', () {
      final original = const Meal(
        id: '1',
        name: 'Original',
        thumbnailUrl: 'thumb.jpg',
      );

      final updated = original.copyWith(name: 'Updated', category: 'New Category');

      expect(updated.id, '1'); // Unchanged
      expect(updated.thumbnailUrl, 'thumb.jpg'); // Unchanged
      expect(updated.name, 'Updated'); // Changed
      expect(updated.category, 'New Category'); // Changed
      expect(identical(original, updated), isFalse); // New instance
    });

    // 5. tagList logic
    test('tagList safely handles null, empty, and malformed tags', () {
      expect(const Meal(id: '1', name: 'A', thumbnailUrl: '').tagList, isEmpty);
      expect(const Meal(id: '1', name: 'A', thumbnailUrl: '', tags: ' ').tagList, isEmpty);
      expect(const Meal(id: '1', name: 'A', thumbnailUrl: '', tags: 'Chicken, , Beef ').tagList, ['Chicken', 'Beef']);
    });

    // 6. Equality and hashCode
    test('Equality is based on id and name', () {
      final meal1 = const Meal(id: '1', name: 'A', thumbnailUrl: 'thumb1.jpg');
      final meal2 = const Meal(id: '1', name: 'A', thumbnailUrl: 'thumb2.jpg');
      final meal3 = const Meal(id: '2', name: 'A', thumbnailUrl: 'thumb1.jpg');

      expect(meal1, equals(meal2));
      expect(meal1.hashCode, equals(meal2.hashCode));
      expect(meal1, isNot(equals(meal3)));
    });
  });
}
