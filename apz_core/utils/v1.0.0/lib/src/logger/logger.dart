import "package:logger/logger.dart" show Level;

/// Enum representing different log levels
enum APZLogLevel {
  /// Debug level for detailed information, typically used for development
  debug,

  /// Info level for general information, typically used for normal operations
  info,

  /// Error level for error messages,
  /// typically used for exceptions or critical issues
  error;

  /// Convert LogLevel enum to Logger's Level
  Level toLevel() {
    switch (this) {
      case APZLogLevel.debug:
        return Level.debug;
      case APZLogLevel.info:
        return Level.info;
      case APZLogLevel.error:
        return Level.error;
    }
  }

  /// Convert Logger's Level to LogLevel enum
  static APZLogLevel fromLevel(final Level level) {
    switch (level) {
      case Level.debug:
        return APZLogLevel.debug;
      case Level.error:
        return APZLogLevel.error;

      /// Info level is the default for any unspecified levels
      // ignore: no_default_cases
      default:
        return APZLogLevel.info;
    }
  }
}

/// Abstract class defining the logging interface
abstract class APZLogger {
  /// Log a debug message
  void debug(
    final Object message, [
    final Object error,
    final StackTrace? stackTrace,
  ]);

  /// Log an info message
  void info(
    final Object message, [
    final Object error,
    final StackTrace? stackTrace,
  ]);

  /// Log an error message
  void error(
    final Object message, [
    final Object error,
    final StackTrace? stackTrace,
  ]);

  /// Set the log level
  void setLogLevel(final APZLogLevel level);

  /// Get the current log level
  APZLogLevel getLogLevel();

  /// Get all available log levels
  // List<APZLogLevel> get logLevel;

  /// Enable file logging
  Future<void> enableFileLogging();

  /// Disable file logging
  Future<void> disableFileLogging();

  /// Check if file logging is enabled
  bool isFileLoggingEnabled();

  /// Get the path where logs are stored
  String? getLogFilePath();

  /// Clear all stored logs
  Future<void> clearLogs();
}
