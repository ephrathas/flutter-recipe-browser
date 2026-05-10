/// A custom exception class for all API-related failures in the app.
///
/// ---
/// ## Why a custom exception instead of the built-in [Exception]?
///
/// Dart's built-in [Exception] and [Error] types are intentionally generic.
/// Using them directly across an entire app leads to several problems:
///
/// 1. **Loss of context** — A raw `Exception('Something went wrong')` gives
///    the UI no structured way to distinguish a 404 from a network timeout.
///
/// 2. **Tight coupling** — If screens catch `Exception` they may accidentally
///    swallow unrelated errors (e.g., null-pointer bugs), masking real issues.
///
/// 3. **Poor user experience** — Generic errors cannot be mapped to
///    friendly, actionable messages without guessing.
///
/// [ApiException] solves all of these by:
/// - Carrying a typed [statusCode] the UI can branch on.
/// - Providing a human-readable [message] ready for direct display.
/// - Exposing the underlying [cause] for logging/debugging without
///   surfacing raw stack traces to users.
/// - Offering named factory constructors so call-sites read like prose
///   (`ApiException.notFound(...)`) instead of raw constructors.
///
/// ---
/// ## Reusability
///
/// This class is intentionally kept in `services/` and has **zero** Flutter
/// or `http` package dependencies — it is pure Dart. This means it can be:
/// - Unit-tested without a widget tree or HTTP stack.
/// - Reused in any future service (auth, analytics, etc.) without changes.
/// - Safely thrown from isolates if background processing is added later.
///
/// ---
/// ## Future scaling
///
/// To extend error handling as the app grows, add new factory constructors
/// below (e.g., `ApiException.unauthorized()`, `ApiException.rateLimited()`)
/// and update only the service layer — screens and widgets remain untouched.
class ApiException implements Exception {
  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  /// Human-readable description of the failure.
  ///
  /// This is the only field intended to be shown directly in the UI.
  /// Keep messages concise, user-friendly, and free of technical jargon.
  final String message;

  /// HTTP status code associated with the failure, if applicable.
  ///
  /// `null` for non-HTTP errors such as:
  /// - No internet connection
  /// - DNS resolution failure
  /// - Request timeout
  /// - Malformed JSON response
  ///
  /// Common values and their meanings:
  /// | Code | Meaning               |
  /// |------|-----------------------|
  /// | 400  | Bad request           |
  /// | 401  | Unauthorized          |
  /// | 403  | Forbidden             |
  /// | 404  | Resource not found    |
  /// | 429  | Too many requests     |
  /// | 500  | Internal server error |
  /// | 503  | Service unavailable   |
  final int? statusCode;

  /// The original exception that caused this [ApiException], if any.
  ///
  /// Preserved for logging and debugging purposes. Never expose this
  /// to the user — use [message] for UI-facing text only.
  ///
  /// Example: a [FormatException] from `jsonDecode()` or a
  /// [SocketException] from the `http` package.
  final Object? cause;

  // ---------------------------------------------------------------------------
  // Constructors
  // ---------------------------------------------------------------------------

  /// Creates an [ApiException] with a required [message] and optional fields.
  ///
  /// Prefer the named factory constructors below for common scenarios,
  /// as they produce more descriptive, consistent messages automatically.
  const ApiException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  // ---------------------------------------------------------------------------
  // Named factory constructors — preferred for common error scenarios
  // ---------------------------------------------------------------------------

  /// Creates an [ApiException] for a network connectivity failure.
  ///
  /// Use when the device cannot reach the server at all (no Wi-Fi,
  /// airplane mode, DNS failure, etc.).
  factory ApiException.networkError({Object? cause}) {
    return ApiException(
      message: 'No internet connection. Please check your network and try again.',
      cause: cause,
    );
  }

  /// Creates an [ApiException] for an unexpected HTTP status code.
  ///
  /// [statusCode] is required; a sensible default message is generated
  /// automatically but can be overridden with [message].
  factory ApiException.httpError(
    int statusCode, {
    String? message,
    Object? cause,
  }) {
    return ApiException(
      message: message ?? _defaultMessageForStatus(statusCode),
      statusCode: statusCode,
      cause: cause,
    );
  }

  /// Creates an [ApiException] for a 404 Not Found response.
  factory ApiException.notFound({String resource = 'Resource', Object? cause}) {
    return ApiException(
      message: '$resource was not found.',
      statusCode: 404,
      cause: cause,
    );
  }

  /// Creates an [ApiException] for malformed or unexpected JSON.
  ///
  /// Use when `jsonDecode` succeeds but the shape of the data is wrong
  /// (e.g., a required key is missing, or a value has the wrong type).
  factory ApiException.invalidResponse({String? details, Object? cause}) {
    return ApiException(
      message: details != null
          ? 'Unexpected server response: $details'
          : 'The server returned an unexpected response. Please try again later.',
      cause: cause,
    );
  }

  /// Creates an [ApiException] for request timeout scenarios.
  factory ApiException.timeout({Object? cause}) {
    return ApiException(
      message: 'The request timed out. Please try again.',
      cause: cause,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Maps common HTTP status codes to a default user-facing message.
  ///
  /// Private because callers should use named factory constructors
  /// rather than constructing messages manually.
  static String _defaultMessageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'The request was invalid. Please try again.';
      case 401:
        return 'Authentication required. Please log in and try again.';
      case 403:
        return 'You do not have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'The server encountered an error. Please try again later.';
      case 503:
        return 'The service is temporarily unavailable. Please try again later.';
      default:
        return 'An unexpected error occurred (HTTP $statusCode).';
    }
  }

  // ---------------------------------------------------------------------------
  // Object overrides
  // ---------------------------------------------------------------------------

  /// Returns a developer-facing string representation.
  ///
  /// Intentionally verbose — this is for logs and debug consoles,
  /// NOT for display in the UI. Use [message] for user-facing text.
  @override
  String toString() {
    final buffer = StringBuffer('ApiException(');
    buffer.write('message: "$message"');
    if (statusCode != null) buffer.write(', statusCode: $statusCode');
    if (cause != null) buffer.write(', cause: $cause');
    buffer.write(')');
    return buffer.toString();
  }

  /// Two [ApiException] instances are equal when their [statusCode]
  /// and [message] match. Useful for deduplication in tests.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(message, statusCode);
}
