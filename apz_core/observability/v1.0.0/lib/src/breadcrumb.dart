part of "../apz_observability.dart";

/// Represents a breadcrumb for tracking user actions or system events.
class AppBreadcrumb {
  /// Creates an instance of [AppBreadcrumb].
  AppBreadcrumb({required this.message, this.category, this.level, this.data});

  /// A short message describing the event.
  final String message;

  /// The category of the breadcrumb (e.g., "navigation", "ui.click", "network")
  final BreadcrumbCategory? category;

  /// The severity level of the breadcrumb.
  /// Specific to Sentry: SentryBreadcrumbLevel.info,
  /// SentryBreadcrumbLevel.debug etc.
  /// For Bugsnag, this might be mapped to BreadcrumbType.
  final BreadcrumbLevel? level;

  /// Additional arbitrary data to associate with the breadcrumb.
  final Map<String, dynamic>? data;
}
