part of "../apz_observability.dart";

//// Enum to specify the observability level.
enum BreadcrumbLevel {
  /// Represents a fatal error.
  fatal,

  /// Represents an error that needs attention.
  error,

  /// Represents a warning that might indicate a potential issue.
  warning,

  /// Represents general information.
  info,

  /// Represents debug-level information.
  debug,
}
