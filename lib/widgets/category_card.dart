import 'package:flutter/material.dart';

import '../models/meal_category.dart';

/// A modern, responsive card component for displaying a meal category.
/// 
/// ---
/// ## Design Choices:
/// 
/// 1. **Visual Hierarchy**: Uses a large, high-quality image at the top to 
///    capture interest, followed by a bold name and a subtle description 
///    preview to provide context without clutter.
/// 
/// 2. **Material 3 Elevated Card**: Employs `Card` with rounded corners 
///    (standard in M3) and an `InkWell` for satisfying interactive feedback.
/// 
/// 3. **Image Optimization**: Includes a `loadingBuilder` with a progress 
///    indicator to handle network latency gracefully and an `errorBuilder` 
///    to prevent UI breakage on dead links.
/// 
/// 4. **Hero Animation**: Wraps the image in a `Hero` widget to enable 
///    smooth, cinematic transitions when navigating to category details.
/// 
/// 5. **Defensive Layout**: Uses `maxLines` and `TextOverflow.ellipsis` 
///    everywhere to ensure long text from the API doesn't break the layout 
///    on small screens.
/// ---
class CategoryCard extends StatelessWidget {
  /// The category data model to display.
  final MealCategory category;

  /// Triggered when the user taps the card.
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias, // Ensures image corners follow card shape
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Featured Category Image with Hero Transition
            Expanded(
              flex: 4,
              child: Hero(
                tag: 'category_${category.id}',
                child: Image.network(
                  category.thumbnailUrl,
                  fit: BoxFit.cover,
                  // Smoothly handles image loading states
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  // Handles network/parsing errors gracefully
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.restaurant_rounded,
                      size: 32,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Shortened Description Preview
                    Text(
                      category.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
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
