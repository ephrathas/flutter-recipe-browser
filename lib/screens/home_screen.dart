import 'package:flutter/material.dart';

import '../models/meal_category.dart';
import '../services/meal_api_service.dart';
import '../widgets/category_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_error_widget.dart';
import 'category_screen.dart';
import 'search_screen.dart';

/// The entry-point screen of the application.
///
/// ---
/// ## Flutter Architecture & Rebuild Considerations:
///
/// 1. **FutureBuilder & Rebuilds**: One of the most common mistakes is
///    instantiating the Future directly in the `build()` method. Since
///    `build()` runs frequently, this causes infinite network loops.
///    Always store the Future in a state variable in `initState`.
///
/// 2. **Separation of Concerns**: This screen does not know "how" to
///    fetch data or "where" it comes from. It only knows how to request
///    it from [MealApiService] and how to display the result.
///
/// 3. **Mounted Checks**: Before calling `setState()` after an `await`
///    gap, always verify if the widget is still in the tree. This
///    prevents "setState called after dispose" errors.
/// ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MealApiService _apiService = MealApiService();

  /// Storing the future in a variable is CRITICAL for performance.
  late Future<CachedResponse<List<MealCategory>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  /// Initializes or re-initializes the data fetch.
  void _initFetch() {
    // Architectural Note: We verify 'mounted' before calling setState.
    // This is best practice for any logic that could be triggered
    // asynchronously or delayed.
    if (!mounted) return;

    setState(() {
      _categoriesFuture = _apiService.fetchCategories();
    });
  }

  /// Navigates to the Category detail screen.
  void _onCategorySelected(BuildContext context, MealCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(categoryName: category.name),
      ),
    );
  }

  /// Navigates to the search screen.
  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Recipe Explorer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _navigateToSearch(context),
            tooltip: 'Search recipes',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: FutureBuilder<CachedResponse<List<MealCategory>>>(
          key: ValueKey(_categoriesFuture),
          future: _categoriesFuture,
          builder: (context, snapshot) {
            // --- 1. Loading State ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(
                key: ValueKey('loading'),
                message: 'Exploring culinary categories...',
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

            // --- 3. Success State ---
            final response = snapshot.data;
            final categories = response?.data;
            final fromCache = response?.fromCache ?? false;

            if (categories == null || categories.isEmpty) {
              return Center(
                key: const ValueKey('empty'),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 72, color: colorScheme.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No categories found.',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check your connection or try again later.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            }

            final categoryList = RefreshIndicator(
              key: const ValueKey('success'),
              onRefresh: () async => _initFetch(),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 260,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    category: category,
                    onTap: () => _onCategorySelected(context, category),
                  );
                },
              ),
            );

            if (!fromCache) {
              return categoryList;
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Chip(
                        label: const Text('Cached Data'),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
                Expanded(child: categoryList),
              ],
            );
          },
        ),
      ),
    );
  }
}
