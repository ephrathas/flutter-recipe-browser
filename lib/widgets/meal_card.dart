import 'package:flutter/material.dart';

import '../models/meal.dart';

/// A modern, performance-optimized card widget for displaying a meal.
/// 
/// ---
/// ## Why Widget Reusability Matters:
/// 
/// 1. **Maintainability**: If the UI requirements for a "Meal item" change 
///    (e.g., adding a rating or a price), you only need to edit this single 
///    file to reflect changes across search screens, favorites, and categories.
/// 
/// 2. **Encapsulation**: This widget owns its internal layout, image loading, 
///    and Hero animations. The parent screen only needs to pass the data, 
///    ignoring the complexity of the visual implementation.
/// 
/// 3. **Performance**: By using a dedicated stateless widget, we ensure that 
///    Flutter can optimize its rebuild cycles. Only the cards that change 
///    identity will be repainted, keeping list scrolling smooth at 60fps+.
/// ---
class MealCard extends StatelessWidget {
  /// The meal data model to display.
  final Meal meal;

  /// Triggered when the user taps the card.
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias, // Ensures image corners are clipped to the card shape
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal Image with Hero Transition
            Expanded(
              flex: 5,
              child: Hero(
                tag: 'meal_${meal.id}',
                child: Image.network(
                  meal.thumbnailUrl,
                  fit: BoxFit.cover,
                  // Performance: Uses a low-weight placeholder while loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  // Performance: Graceful error fallback
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.no_meals_rounded,
                      size: 40,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

            // Meal Title and info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    
                    // Display area/cuisine if available (detail mode)
                    if (meal.area != null && meal.area!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meal.area!,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
