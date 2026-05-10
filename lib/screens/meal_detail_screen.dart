import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_error_widget.dart';

/// A production-quality screen displaying full recipe details.
/// 
/// ---
/// ## Architecture & Async Best Practices:
/// 
/// 1. **Context Safety**: Since `_launchYouTube` is asynchronous, we use 
///    `if (context.mounted)` before accessing `ScaffoldMessenger`. This 
///    is a critical pattern to avoid crashes when an async task finishes 
///    after a user has navigated away from the screen.
/// 
/// 2. **Declarative States**: Instead of complex boolean flags (isError, 
///    isLoading), we use [FutureBuilder] to reactively render the UI 
///    based on the `snapshot` state.
/// 
/// 3. **Separation of Concerns**: The detailed layout is kept separate 
///    from the data fetching logic. We use private helper methods to 
///    maintain a clean, readable build method.
/// ---
class MealDetailScreen extends StatefulWidget {
  final String mealId;
  final String? mealName;

  const MealDetailScreen({
    super.key,
    required this.mealId,
    this.mealName,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealApiService _apiService = MealApiService();
  late Future<Meal> _mealFuture;

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  void _initFetch() {
    if (!mounted) return;
    
    setState(() {
      _mealFuture = _apiService.fetchMealDetail(widget.mealId);
    });
  }

  /// Securely launches the YouTube tutorial using url_launcher.
  Future<void> _launchYouTube(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // CRITICAL: Always check context.mounted after an 'await' gap.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the YouTube tutorial.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: FutureBuilder<Meal>(
          key: ValueKey(_mealFuture),
          future: _mealFuture,
          builder: (context, snapshot) {
            // --- 1. Loading State ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScaffold(key: const ValueKey('loading'));
            }

            // --- 2. Error State ---
            if (snapshot.hasError) {
              return Scaffold(
                key: const ValueKey('error'),
                appBar: AppBar(title: Text(widget.mealName ?? 'Error')),
                body: CustomErrorWidget(
                  error: snapshot.error!,
                  onRetry: _initFetch,
                ),
              );
            }

            // --- 3. Success State ---
            final meal = snapshot.data;
            if (meal == null) return const SizedBox.shrink();

            return _buildMainContent(context, meal, key: const ValueKey('success'));
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScaffold({required Key key}) {
    return Scaffold(
      key: key,
      appBar: AppBar(title: Text(widget.mealName ?? 'Loading...')),
      body: const LoadingWidget(message: 'Gathering fresh ingredients...'),
    );
  }

  Widget _buildMainContent(BuildContext context, Meal meal, {required Key key}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      key: key,
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              meal.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
              ),
            ),
            background: Hero(
              tag: 'meal_${meal.id}',
              child: Image.network(meal.thumbnailUrl, fit: BoxFit.cover),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetaChips(colorScheme, meal),
                const SizedBox(height: 24),
                _buildSectionTitle(theme, 'Ingredients'),
                const SizedBox(height: 12),
                _IngredientsList(ingredients: meal.ingredients),
                const SizedBox(height: 32),
                _buildSectionTitle(theme, 'Cooking Instructions'),
                const SizedBox(height: 12),
                Text(
                  meal.instructions ?? 'No instructions provided.',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 40),
                if (meal.youtubeUrl != null && meal.youtubeUrl!.isNotEmpty)
                  _buildYouTubeButton(context, meal.youtubeUrl!),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChips(ColorScheme colorScheme, Meal meal) {
    return Wrap(
      spacing: 8,
      children: [
        if (meal.category != null)
          Chip(label: Text(meal.category!), backgroundColor: colorScheme.primaryContainer),
        if (meal.area != null)
          Chip(label: Text(meal.area!), backgroundColor: colorScheme.secondaryContainer),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildYouTubeButton(BuildContext context, String url) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _launchYouTube(context, url),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFF0000),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const Icon(Icons.play_circle_fill, color: Colors.white),
        label: const Text('Watch Video Tutorial', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  final List<String> ingredients;
  const _IngredientsList({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(ingredient)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
