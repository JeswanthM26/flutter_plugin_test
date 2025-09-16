import "package:apz_observability/apz_observability.dart";
import "package:flutter_test/flutter_test.dart";

class MockObservabilityService extends ObservabilityService {
  bool initialized = false;
  Object? capturedException;
  StackTrace? capturedStackTrace;
  Map<String, String>? capturedTags;
  String? capturedHint;
  String? capturedMessage;
  BreadcrumbLevel? capturedLevel;
  AppBreadcrumb? addedBreadcrumb;
  Map<String, dynamic>? user;
  bool userCleared = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> captureException(
    final Object exception, {
    final StackTrace? stackTrace,
    final Map<String, String>? tags,
    final String? hint,
  }) async {
    capturedException = exception;
    capturedStackTrace = stackTrace;
    capturedTags = tags;
    capturedHint = hint;
  }

  @override
  Future<void> captureMessage(
    final String message, {
    final Map<String, String>? tags,
    final BreadcrumbLevel? level,
  }) async {
    capturedMessage = message;
    capturedTags = tags;
    capturedLevel = level;
  }

  @override
  Future<void> addBreadcrumb(final AppBreadcrumb breadcrumb) async {
    addedBreadcrumb = breadcrumb;
  }

  @override
  Future<void> setUser({
    final String? id,
    final String? username,
    final String? email,
    final Map<String, dynamic>? extraData,
  }) async {
    user = <String, dynamic>{
      "id": id,
      "username": username,
      "email": email,
      "extraData": extraData,
    };
  }

  @override
  Future<void> clearUser() async {
    userCleared = true;
  }
}

void main() {
  group("ObservabilityService", () {
    late MockObservabilityService service;

    setUp(() {
      service = MockObservabilityService();
    });

    test("should initialize service", () async {
      await service.initialize();
      expect(service.initialized, isTrue);
    });

    test("should capture exception with details", () async {
      final Exception exception = Exception("Test error");
      final StackTrace stack = StackTrace.current;
      await service.captureException(
        exception,
        stackTrace: stack,
        tags: <String, String>{"env": "test"},
        hint: "hint",
      );
      expect(service.capturedException, exception);
      expect(service.capturedStackTrace, stack);
      expect(service.capturedTags, <String, String>{"env": "test"});
      expect(service.capturedHint, "hint");
    });

    test("should capture message with tags and level", () async {
      await service.captureMessage(
        "A message",
        tags: <String, String>{"type": "info"},
        level: BreadcrumbLevel.info,
      );
      expect(service.capturedMessage, "A message");
      expect(service.capturedTags, <String, String>{"type": "info"});
      expect(service.capturedLevel, BreadcrumbLevel.info);
    });

    test("should add breadcrumb", () async {
      final AppBreadcrumb breadcrumb = AppBreadcrumb(message: "User action");
      await service.addBreadcrumb(breadcrumb);
      expect(service.addedBreadcrumb, breadcrumb);
    });

    test("should set user info", () async {
      await service.setUser(
        id: "123",
        username: "testuser",
        email: "test@example.com",
        extraData: <String, dynamic>{"role": "admin"},
      );
      expect(service.user, <String, Object>{
        "id": "123",
        "username": "testuser",
        "email": "test@example.com",
        "extraData": <String, String>{"role": "admin"},
      });
    });

    test("should clear user info", () async {
      await service.clearUser();
      expect(service.userCleared, isTrue);
    });
  });
}
