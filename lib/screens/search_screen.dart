import 'dart:async';

import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

/// A production-quality search screen with debounced API calls.
///
/// Features:
/// - Timer-based debouncing (450ms) to prevent excessive API calls
/// - Material 3 SearchBar with clear functionality
/// - Comprehensive state management (Loading, Error, Empty, Success)
/// - Responsive GridView for search results
/// - Reuses existing MealCard and error/loading widgets
/// - Proper mounted checks after async gaps
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MealApiService _apiService = MealApiService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  /// Debouncing timer to prevent excessive API calls
  Timer? _debounceTimer;

  /// Current search query
  String _currentQuery = '';

  /// Future for the current search operation
  Future<List<Meal>>? _searchFuture;

  /// Debounce duration (450ms provides good UX balance)
  static const Duration _debounceDuration = Duration(milliseconds: 450);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handles search input changes with debouncing.
  /// Only triggers search after user stops typing for [_debounceDuration].
  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Cancel existing timer
    _debounceTimer?.cancel();

    // Don't search for empty queries
    if (query.isEmpty) {
      setState(() {
        _currentQuery = '';
        _searchFuture = null;
      });
      return;
    }

    // Start new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return; // Mounted check after async gap

      setState(() {
        _currentQuery = query;
        _searchFuture = _apiService.searchMeals(query);
      });
    });
  }

  /// Clears the search input and resets the state.
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = '';
      _searchFuture = null;
    });
    _searchFocusNode.requestFocus();
  }

  /// Navigates to the meal detail screen.
  void _onMealSelected(BuildContext context, Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MealDetailScreen(mealId: meal.id, mealName: meal.name),
      ),
    );
  }

  /// Retries the current search operation.
  void _retrySearch() {
    if (_currentQuery.isNotEmpty) {
      setState(() {
        _searchFuture = _apiService.searchMeals(_currentQuery);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Search Recipes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Material 3 Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search for recipes...',
              leading: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _clearSearch,
                    tooltip: 'Clear search',
                  ),
              ],
              backgroundColor: WidgetStateProperty.all(
                colorScheme.surfaceContainerHighest,
              ),
              elevation: WidgetStateProperty.all(0),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Search Results
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  /// Builds the search results area with proper state management.
  Widget _buildSearchResults() {
    // No search query yet
    if (_currentQuery.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_rounded,
        title: 'Start Searching',
        message: 'Enter a recipe name to find delicious meals',
      );
    }

    // Search in progress
    if (_searchFuture == null) {
      return const LoadingWidget(message: 'Preparing search...');
    }

    return FutureBuilder<List<Meal>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget(message: 'Searching for "$_currentQuery"...');
        }

        // Error state
        if (snapshot.hasError) {
          return CustomErrorWidget(
            errorMessage: snapshot.error.toString(),
            onRetry: _retrySearch,
          );
        }

        // Success state
        final meals = snapshot.data;
        if (meals == null || meals.isEmpty) {
          return _buildEmptyState(
            icon: Icons.no_meals_rounded,
            title: 'No Recipes Found',
            message: 'Try searching with different keywords',
          );
        }

        // Results grid
        return _buildResultsGrid(meals);
      },
    );
  }

  /// Builds an empty state widget.
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the responsive grid view for search results.
  Widget _buildResultsGrid(List<Meal> meals) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
  }
}
