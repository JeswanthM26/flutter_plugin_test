import "dart:async";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";

part "enums/breadcrumb_category.dart";
part "enums/breadcrumb_level.dart";
part "src/breadcrumb.dart";
part "src/observability_service.dart";

/// Main class to handle observability in the app.
class ApzObservability {
  /// Factory constructor returns the singleton instance
  factory ApzObservability() => _instance;
  ApzObservability._internal();
  static final ApzObservability _instance = ApzObservability._internal();

  ObservabilityService? _service;
  bool _isInitialized = false;
  final APZLoggerProvider _logger = APZLoggerProvider();

  /// Returns true if the observability service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Singleton instance of [ApzObservability].
  Future<void> init(final ObservabilityService service) async {
    if (_isInitialized) {
      _logger.debug(
        """ApzObservability is already initialized. Skipping re-initialization.""",
      );
      return;
    }

    _service = service;

    try {
      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError = (final FlutterErrorDetails details) async {
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(details);
        }
        if (_service != null && _isInitialized) {
          await _service?.captureException(
            details.exception,
            stackTrace: details.stack,
          );
        }
        originalOnError?.call(details);
      };

      PlatformDispatcher.instance.onError =
          (final Object error, final StackTrace stack) {
            _logger
              ..debug("PlatformDispatcher error: $error")
              ..debug("Stacktrace: $stack");
            if (_service != null && _isInitialized) {
              unawaited(_service?.captureException(error, stackTrace: stack));
            }
            return true;
          };

      _isInitialized = true;
    } on Exception catch (e, s) {
      _logger
        ..debug("ApzObservability: Failed to configure: $e")
        ..debug(s);
    }
  }

  /// Captures an exception with optional stack trace and tags.
  Future<void> captureException(
    final Object exception, {
    final StackTrace? stackTrace,
    final Map<String, String>? tags,
    final String? hint, // Sentry specific
  }) async {
    if (!_isInitialized || _service == null) {
      _logger
        ..debug(
          """ApzObservability: Not initialized or no service. Cannot capture exception.""",
        )
        ..debug("Exception: $exception");
      if (stackTrace != null) {
        _logger.debug("Stacktrace: $stackTrace");
      }
      return;
    }
    await _service?.captureException(
      exception,
      stackTrace: stackTrace,
      tags: tags,
      hint: hint,
    );
  }

  /// Captures a message with optional tags and level.
  Future<void> captureMessage(
    final String message, {
    final Map<String, String>? tags,
    final BreadcrumbLevel? level,
  }) async {
    if (!_isInitialized || _service == null) {
      _logger
        ..debug(
          """ApzObservability: Not initialized or no service. Cannot capture message.""",
        )
        ..debug("Message: $message");
      return;
    }
    await _service!.captureMessage(message, tags: tags, level: level);
  }

  /// Adds a breadcrumb to the observability service.
  Future<void> addBreadcrumb(final AppBreadcrumb breadcrumb) async {
    if (!_isInitialized || _service == null) {
      _logger.debug(
        """ApzObservability: Not initialized or no service. Cannot add breadcrumb.""",
      );
      return;
    }
    await _service?.addBreadcrumb(breadcrumb);
  }

  /// Sets the user information for the observability service.
  Future<void> setUser({
    final String? id,
    final String? username,
    final String? email,
    final Map<String, dynamic>? extraData,
  }) async {
    if (!_isInitialized || _service == null) {
      _logger.debug(
        "ApzObservability: Not initialized or no service. Cannot set user.",
      );
      return;
    }
    await _service?.setUser(
      id: id,
      username: username,
      email: email,
      extraData: extraData,
    );
  }

  /// Clears any set user information.
  Future<void> clearUser() async {
    if (!_isInitialized || _service == null) {
      _logger.debug(
        "ApzObservability: Not initialized or no service. Cannot clear user.",
      );
      return;
    }
    await _service?.clearUser();
  }

  /// Resets the singleton for testing purposes only.
  /// This should never be used in production code.
  @visibleForTesting
  void resetForTest() {
    _service = null;
    _isInitialized = false;
  }
}
