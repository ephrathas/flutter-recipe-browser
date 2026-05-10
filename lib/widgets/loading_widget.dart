import 'package:flutter/material.dart';

/// A reusable, centered loading indicator component.
/// 
/// ---
/// ## Why reusable widgets improve maintainability:
/// 
/// 1. **Consistency**: Ensures that the loading state looks and behaves exactly
///    the same way across every screen in the application.
/// 
/// 2. **Single Source of Truth**: If you decide to change the loading animation 
///    to something else (like a Lottie animation or a custom painter), you only 
///    need to update it in this one file rather than hunting through 
///    every screen.
/// 
/// 3. **Reduced Boilerplate**: Screens remain clean and focused on their 
///    specific layout logic, rather than being cluttered with repetitive 
///    UI setup code.
/// 
/// 4. **Easier Testing**: You can write a single widget test for this component 
///    to ensure it handles optional text correctly, which covers all 
///    usages in the app.
/// ---
class LoadingWidget extends StatelessWidget {
  /// Optional text to display below the progress indicator.
  /// If null, only the spinner is shown.
  final String? message;

  /// The size of the progress indicator. Defaults to standard Material size.
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Using Material 3's primary color for the indicator
            SizedBox(
              width: size ?? 40,
              height: size ?? 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
