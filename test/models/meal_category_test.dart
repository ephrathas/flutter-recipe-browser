import 'package:flutter_test/flutter_test.dart';
import 'package:meal_explorer_app/models/meal_category.dart';

void main() {
  group('MealCategory Model Tests', () {
    const validJson = {
      'idCategory': '1',
      'strCategory': 'Beef',
      'strCategoryThumb': 'https://example.com/beef.png',
      'strCategoryDescription': 'Beef is the culinary name for meat from cattle.',
    };

    // 1. fromJson & defensive parsing
    test('fromJson parses correctly with complete and valid data', () {
      final category = MealCategory.fromJson(validJson);

      expect(category.id, '1');
      expect(category.name, 'Beef');
      expect(category.thumbnailUrl, 'https://example.com/beef.png');
      expect(category.description, 'Beef is the culinary name for meat from cattle.');
    });

    test('fromJson handles nulls and missing fields defensively', () {
      final category = MealCategory.fromJson({});

      expect(category.id, '');
      expect(category.name, '');
      expect(category.thumbnailUrl, '');
      expect(category.description, '');
    });

    // 2. toJson serialization
    test('toJson serializes model back to correct JSON map', () {
      final category = const MealCategory(
        id: '2',
        name: 'Chicken',
        thumbnailUrl: 'thumb.jpg',
        description: 'Chicken description.',
      );

      final json = category.toJson();

      expect(json, {
        'idCategory': '2',
        'strCategory': 'Chicken',
        'strCategoryThumb': 'thumb.jpg',
        'strCategoryDescription': 'Chicken description.',
      });
    });

    // 3. copyWith behavior
    test('copyWith creates a new instance with explicitly updated values', () {
      final original = const MealCategory(
        id: '1',
        name: 'Beef',
        thumbnailUrl: 'thumb.jpg',
        description: 'Original description',
      );

      final updated = original.copyWith(
        name: 'Updated Beef', 
        description: 'New description',
      );

      expect(updated.id, '1'); // Unchanged
      expect(updated.thumbnailUrl, 'thumb.jpg'); // Unchanged
      expect(updated.name, 'Updated Beef'); // Changed
      expect(updated.description, 'New description'); // Changed
      expect(identical(original, updated), isFalse); // Ensure it's a new instance
    });

    // 4. Equality and HashCode
    test('Equality operator and hashCode are based on all fields', () {
      final category1 = const MealCategory(id: '1', name: 'A', thumbnailUrl: 'B', description: 'C');
      final category2 = const MealCategory(id: '1', name: 'A', thumbnailUrl: 'B', description: 'C');
      final category3 = const MealCategory(id: '2', name: 'A', thumbnailUrl: 'B', description: 'C');

      expect(category1, equals(category2));
      expect(category1.hashCode, equals(category2.hashCode));
      expect(category1, isNot(equals(category3)));
    });
  });
}
