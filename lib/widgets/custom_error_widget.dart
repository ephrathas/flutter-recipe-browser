import 'package:flutter/material.dart';

/// A robust, reusable error display component for the application.
/// 
/// ---
/// ## Architecture Benefits:
/// 
/// 1. **Decoupled Logic**: Screens only need to provide the error string and 
///    the logic to re-trigger a fetch. They don't need to know how to 
///    center elements, which icons to use, or how to style error buttons.
/// 
/// 2. **Contextual Recovery**: By accepting an optional `onRetry` callback, 
///    the widget empowers the user to recover from transient failures 
///    (like losing Wi-Fi) without navigating away or restarting the app.
/// 
/// 3. **Branding & Consistency**: Centralizing error UI ensures that if the 
///    design team changes the "error" look, it can be updated globally 
///    in seconds, maintaining a professional and cohesive brand image.
/// 
/// 4. **Accessibility**: This widget provides a central place to ensure 
///    that error states have high-contrast text and meaningful icons 
///    for all users.
/// ---
class CustomErrorWidget extends StatelessWidget {
  /// The human-readable error message to display.
  final String errorMessage;

  /// Optional callback to re-attempt the failed operation.
  /// If null, the retry button will not be displayed.
  final VoidCallback? onRetry;

  /// Optional custom icon to override the default error icon.
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prominent error icon using Material 3's error color
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Primary error heading
            Text(
              'Oops! Something went wrong',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Detailed, user-friendly error message
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              
              // Recovery action button
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
