/// A strongly-typed, immutable model representing a single meal category
/// as returned by TheMealDB REST API.
///
/// ---
/// ## Clean Architecture role
///
/// This class lives in the **models** layer and has zero dependencies on
/// Flutter, HTTP, or any service class. It is a pure Dart data class whose
/// only responsibility is to carry category data safely across the app.
///
/// - **Services** parse raw JSON into [MealCategory] instances.
/// - **Screens** receive [MealCategory] objects — they never touch raw maps.
/// - **Widgets** read [MealCategory] fields — they never parse strings.
///
/// This strict boundary means the JSON shape can change in exactly one place
/// ([fromJson]) without any ripple effect through the UI layer.
///
/// ---
/// ## Immutability
///
/// All fields are `final`. The class is not marked `const` at the class level
/// because [description] can be very long, but individual instances can be
/// `const` when all values are compile-time constants (e.g., in tests).
///
/// To "change" a field, use [copyWith] — it returns a new instance, leaving
/// the original untouched. This is safe for use with Flutter's widget tree,
/// which relies on object identity to detect changes efficiently.
///
/// ---
/// ## API contract
///
/// Source endpoint: `GET https://www.themealdb.com/api/json/v1/1/categories.php`
///
/// Relevant JSON keys:
/// | JSON key                   | Dart field      | Type   |
/// |----------------------------|-----------------|--------|
/// | `idCategory`               | [id]            | String |
/// | `strCategory`              | [name]          | String |
/// | `strCategoryThumb`         | [thumbnailUrl]  | String |
/// | `strCategoryDescription`   | [description]   | String |
///
/// All four fields are documented as always present in the API, but [fromJson]
/// guards against `null` defensively with fallback empty strings so the app
/// never crashes on unexpected API changes.
class MealCategory {
  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  /// Unique numeric identifier for the category, returned as a String by the
  /// API (e.g., `"1"`, `"2"`). Kept as [String] to match the API contract
  /// without lossy int parsing.
  final String id;

  /// Display name of the category (e.g., `"Beef"`, `"Seafood"`, `"Vegan"`).
  ///
  /// Used as the card label in [CategoryCard] and as the query parameter when
  /// fetching meals via `filter.php?c={name}`.
  final String name;

  /// Fully-qualified HTTPS URL pointing to the category's representative image.
  ///
  /// Intended for use with [Image.network] in [CategoryCard].
  /// An empty string indicates the API did not provide a thumbnail.
  final String thumbnailUrl;

  /// A plain-text description of the category.
  ///
  /// May be multi-paragraph and several hundred characters long.
  /// Used in the category detail view if one is added in future.
  final String description;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  /// Creates a [MealCategory] with all fields explicitly required.
  ///
  /// Named parameters with `required` enforce that callers always supply every
  /// field — there are no nullable fields and no hidden defaults to forget.
  /// This makes construction predictable and keeps `fromJson` the single place
  /// where fallback logic lives.
  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.description,
  });

  // ---------------------------------------------------------------------------
  // Deserialization
  // ---------------------------------------------------------------------------

  /// Constructs a [MealCategory] from a raw JSON map returned by the API.
  ///
  /// ### Null handling strategy
  ///
  /// The API contract says all four keys are always present, but defensive
  /// null-coalescing (`?? ''`) is used throughout because:
  /// 1. APIs evolve — a future version may omit a field.
  /// 2. Tests can pass partial maps without crashing.
  /// 3. The UI will render gracefully (empty string) rather than throw.
  ///
  /// ### Explicit casting
  ///
  /// Each value is explicitly cast to `String?` before the null-coalescing
  /// fallback. Avoid `json['key'].toString()` — it returns the string `"null"`
  /// when the value is literally `null`, which is a silent, hard-to-debug bug.
  ///
  /// ```dart
  /// final category = MealCategory.fromJson(json['categories'][0]);
  /// ```
  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory'] as String? ?? '',
      name: json['strCategory'] as String? ?? '',
      thumbnailUrl: json['strCategoryThumb'] as String? ?? '',
      description: json['strCategoryDescription'] as String? ?? '',
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Converts this [MealCategory] back into a JSON-compatible [Map].
  ///
  /// The returned map mirrors the exact key names used by the API, making it
  /// suitable for:
  /// - Caching responses locally (e.g., SharedPreferences, Hive, SQLite).
  /// - Passing data between isolates as plain [Map] objects.
  /// - Snapshot-based unit tests that compare serialized output.
  ///
  /// All values are non-nullable [String]s — no null-checking needed on
  /// the consumer side because the model enforces non-null fields.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'idCategory': id,
      'strCategory': name,
      'strCategoryThumb': thumbnailUrl,
      'strCategoryDescription': description,
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a new [MealCategory] with the specified fields replaced.
  ///
  /// Fields that are not provided retain their current values. This pattern
  /// (borrowed from `package:freezed` and Flutter's own SDK) is the idiomatic
  /// way to produce modified copies of immutable value objects in Dart.
  ///
  /// ### Why not mutate the original?
  ///
  /// Mutation breaks Flutter's change-detection optimizations. Widgets compare
  /// object references (or values via `==`) to decide whether to rebuild.
  /// Returning a new instance guarantees a clean identity change.
  ///
  /// ```dart
  /// final updated = original.copyWith(name: 'Updated Name');
  /// // original.name is still 'Beef'
  /// // updated.name  is now  'Updated Name'
  /// ```
  MealCategory copyWith({
    String? id,
    String? name,
    String? thumbnailUrl,
    String? description,
  }) {
    return MealCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
    );
  }

  // ---------------------------------------------------------------------------
  // Object overrides
  // ---------------------------------------------------------------------------

  /// Two [MealCategory] instances are equal when all four fields match.
  ///
  /// This makes [MealCategory] behave as a value object — two instances
  /// constructed from the same JSON are considered identical, which is
  /// essential for correct behaviour in [Set]s, [Map] keys, and `==` checks
  /// inside widget `didUpdateWidget` lifecycle hooks.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealCategory &&
        other.id == id &&
        other.name == name &&
        other.thumbnailUrl == thumbnailUrl &&
        other.description == description;
  }

  /// Hash code derived from all four fields, consistent with [operator ==].
  ///
  /// [Object.hash] is preferred over XOR-based hashing because it distributes
  /// values more evenly and handles null automatically (though null cannot
  /// occur here given the `required` non-nullable fields).
  @override
  int get hashCode => Object.hash(id, name, thumbnailUrl, description);

  /// Returns a compact developer-facing string, useful in debug consoles
  /// and `expect(...).toString()` output in tests.
  ///
  /// Intentionally excludes [description] to keep log output readable —
  /// descriptions can be hundreds of characters long.
  @override
  String toString() =>
      'MealCategory(id: $id, name: $name, thumbnailUrl: $thumbnailUrl)';
}
