import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../utils/pagination_controller.dart';
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
  final PaginationController<Meal> _paginationController = PaginationController<Meal>(pageSize: 10);

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  void _initFetch() {
    // Safety check: ensure widget is still alive before updating state.
    if (!mounted) return;

    setState(() {
      _paginationController.reset();
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
                error: snapshot.error!,
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
                      Icon(Icons.no_meals_rounded, size: 72, color: colorScheme.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No meals found.',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We could not find any recipes for ${widget.categoryName}.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            }

            // --- 4. Success State (GridView) ---
            final paginatedMeals = _paginationController.getPaginatedItems(meals);

            return Column(
              key: const ValueKey('success'),
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: GridView.builder(
                      key: ValueKey('grid_${_paginationController.currentPage}'),
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisExtent: 280,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                      ),
                      itemCount: paginatedMeals.length,
                      itemBuilder: (context, index) {
                        final meal = paginatedMeals[index];
                        return MealCard(
                          meal: meal,
                          onTap: () => _onMealSelected(context, meal),
                        );
                      },
                    ),
                  ),
                ),
                if (meals.length > _paginationController.pageSize)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilledButton.icon(
                          onPressed: _paginationController.hasPreviousPage()
                              ? () {
                                  setState(() {
                                    _paginationController.previousPage();
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                        Text(
                          'Page ${_paginationController.currentPage + 1} of ${(meals.length / _paginationController.pageSize).ceil()}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FilledButton(
                          onPressed: _paginationController.hasNextPage(meals.length)
                              ? () {
                                  setState(() {
                                    _paginationController.nextPage(meals.length);
                                  });
                                }
                              : null,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Next'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
