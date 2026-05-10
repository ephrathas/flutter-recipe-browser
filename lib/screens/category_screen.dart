import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_error_widget.dart';
import 'meal_detail_screen.dart';

/// Screen displaying all meals within a selected category.
/// 
/// ---
/// ## Async & State Considerations:
/// 
/// 1. **Avoid .then()**: This screen uses `async/await` exclusively 
///    to maintain linear, readable control flow.
/// 
/// 2. **Mounted Guard**: The `_initFetch` method is designed to be 
///    re-entrant. We use `if (!mounted) return` to ensure that 
///    asynchronous callbacks don't try to update a screen that 
///    has already been popped from the stack.
/// 
/// 3. **Future Caching**: By storing `_mealsFuture` in the State 
///    object, we avoid "flicker" and redundant network calls when 
///    the widget tree rebuilds due to parent updates.
/// ---
class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final MealApiService _apiService = MealApiService();
  late Future<List<Meal>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  void _initFetch() {
    // Safety check: ensure widget is still alive before updating state.
    if (!mounted) return;

    setState(() {
      _mealsFuture = _apiService.fetchMealsByCategory(widget.categoryName);
    });
  }

  void _onMealSelected(BuildContext context, Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailScreen(
          mealId: meal.id,
          mealName: meal.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: FutureBuilder<List<Meal>>(
          key: ValueKey(_mealsFuture),
          future: _mealsFuture,
          builder: (context, snapshot) {
            // --- 1. Loading State ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingWidget(
                key: const ValueKey('loading'),
                message: 'Finding best ${widget.categoryName} recipes...',
              );
            }

            // --- 2. Error State ---
            if (snapshot.hasError) {
              return CustomErrorWidget(
                key: const ValueKey('error'),
                errorMessage: snapshot.error.toString(),
                onRetry: _initFetch,
              );
            }

            // --- 3. Empty State ---
            final meals = snapshot.data;
            if (meals == null || meals.isEmpty) {
              return Center(
                key: const ValueKey('empty'),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.no_food_outlined, size: 64, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No meals found in this category.',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            // --- 4. Success State (GridView) ---
            return GridView.builder(
              key: const ValueKey('success'),
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75, // Slightly taller for better text spacing
              ),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return MealCard(
                  meal: meal,
                  onTap: () => _onMealSelected(context, meal),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
