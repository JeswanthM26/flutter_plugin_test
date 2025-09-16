part of "../apz_observability.dart";

/// Abstract interface for an observability service.
/// This allows for interchangeable implementations (e.g., Sentry, BugSnag).
abstract class ObservabilityService {
  /// Captures an exception or error.
  ///
  /// [exception]: The error or exception object.
  /// [stackTrace]: The stack trace associated with the exception.
  /// [tags]: Additional tags for this specific event.
  Future<void> captureException(
    final Object exception, {
    final StackTrace? stackTrace,
    final Map<String, String>? tags,
    final String? hint,
  });

  /// Captures a message.
  ///
  /// [message]: The message string to report.
  /// [tags]: Additional tags for this specific event.
  Future<void> captureMessage(
    final String message, {
    final Map<String, String>? tags,
    final BreadcrumbLevel? level, // e.g., 'info', 'warning', 'error'
  });

  /// Adds a breadcrumb to track user actions or system events.
  ///
  /// [breadcrumb]: The breadcrumb to add.
  Future<void> addBreadcrumb(final AppBreadcrumb breadcrumb);

  /// Sets user information for the current session.
  ///
  /// [id]: A unique identifier for the user.
  /// [username]: The username.
  /// [email]: The user's email address.
  /// [extraData]: Additional custom data about the user.
  Future<void> setUser({
    final String? id,
    final String? username,
    final String? email,
    final Map<String, dynamic>? extraData,
  });

  /// Clears any set user information.
  Future<void> clearUser();
}
