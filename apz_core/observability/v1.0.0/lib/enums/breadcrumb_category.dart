part of "../apz_observability.dart";

/// Enum to categorize breadcrumbs for observability.
enum BreadcrumbCategory {
  /// Represents navigation events, such as page views or route changes.
  navigation,

  /// Represents network requests, such as API calls or data fetching.
  request,

  /// Represents system processes, such as background tasks or operations.
  process,

  /// Represents logging events, such as debug or info logs.
  log,

  /// Represents user actions, such as sign-ins or profile updates.
  user,

  /// Represents application state changes, such as loading or error states.
  state,

  /// Represents errors or exceptions that occur in the application.
  error,

  /// Represents manual actions or notes added by developers or users.
  manual,
}
