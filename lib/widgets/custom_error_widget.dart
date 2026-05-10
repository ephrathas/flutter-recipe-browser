import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../services/api_exception.dart';

/// A robust, reusable error display component for the application.
/// 
/// ---
/// ## Architecture Benefits:
/// 
/// 1. **Decoupled Logic**: Screens only need to provide the error object and 
///    the logic to re-trigger a fetch. They don't need to know how to 
///    extract the message, center elements, which icons to use, or how to style.
/// 
/// 2. **Contextual Recovery**: By accepting an optional `onRetry` callback, 
///    the widget empowers the user to recover from transient failures 
///    (like losing Wi-Fi) without navigating away or restarting the app.
/// 
/// 3. **Branding & Consistency**: Centralizing error UI ensures that if the 
///    design team changes the "error" look, it can be updated globally.
/// 
/// 4. **Defensive UI**: Never exposes raw stack traces or cryptic exception 
///    messages to the user. Always falls back to friendly text.
/// ---
class CustomErrorWidget extends StatelessWidget {
  /// The original error object caught by the FutureBuilder or Try/Catch.
  final Object error;

  /// Optional callback to re-attempt the failed operation.
  /// If null, the retry button will not be displayed.
  final VoidCallback? onRetry;

  /// Optional custom icon to override the default error icon.
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.icon,
  });

  /// Extracts a safe, user-friendly error message from the exception.
  String _getErrorMessage() {
    if (error is ApiException) {
      return (error as ApiException).message;
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'The connection timed out. Please try again.';
    } else if (error is FormatException) {
      return 'Received invalid data from the server. Please try again later.';
    }
    // Generic fallback for any other unexpected exceptions to prevent stack traces in UI
    return 'An unexpected error occurred. Please try again.';
  }

  /// Determines the most appropriate contextual icon for the error type.
  IconData _getErrorIcon() {
    if (icon != null) return icon!;

    if (error is ApiException) {
      final apiError = error as ApiException;
      if (apiError.cause is SocketException || 
          apiError.message.toLowerCase().contains('internet') || 
          apiError.message.toLowerCase().contains('network')) {
        return Icons.wifi_off_rounded;
      }
      if (apiError.cause is TimeoutException || 
          apiError.message.toLowerCase().contains('time')) {
        return Icons.timer_off_rounded;
      }
      if (apiError.statusCode == 404) {
        return Icons.search_off_rounded;
      }
    } else if (error is SocketException) {
      return Icons.wifi_off_rounded;
    } else if (error is TimeoutException) {
      return Icons.timer_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

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
                _getErrorIcon(),
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
              _getErrorMessage(),
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
