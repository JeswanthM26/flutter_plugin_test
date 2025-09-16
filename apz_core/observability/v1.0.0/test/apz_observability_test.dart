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
  group("ApzObservability", () {
    late ApzObservability apzObs;
    late MockObservabilityService mockService;

    setUp(() {
      apzObs = ApzObservability()..resetForTest();
      mockService = MockObservabilityService();
    });

    test("should not be initialized by default", () {
      expect(apzObs.isInitialized, isFalse);
    });

    test("should initialize and set service", () async {
      await apzObs.init(mockService);
      expect(apzObs.isInitialized, isTrue);
    });

    test("should not re-initialize if already initialized", () async {
      await apzObs.init(mockService);
      final bool prevInitialized = mockService.initialized;
      await apzObs.init(mockService);
      expect(mockService.initialized, prevInitialized);
    });

    test("should capture exception if initialized", () async {
      await apzObs.init(mockService);
      final Exception exception = Exception("Test");
      final StackTrace stack = StackTrace.current;
      await apzObs.captureException(
        exception,
        stackTrace: stack,
        tags: <String, String>{"env": "test"},
        hint: "hint",
      );
      expect(mockService.capturedException, exception);
      expect(mockService.capturedStackTrace, stack);
      expect(mockService.capturedTags, <String, String>{"env": "test"});
      expect(mockService.capturedHint, "hint");
    });

    test("should not capture exception if not initialized", () async {
      final Exception exception = Exception("Test");
      await apzObs.captureException(exception);
      expect(mockService.capturedException, isNull);
    });

    test("should capture message if initialized", () async {
      await apzObs.init(mockService);
      await apzObs.captureMessage(
        "A message",
        tags: <String, String>{"type": "info"},
        level: BreadcrumbLevel.info,
      );
      expect(mockService.capturedMessage, "A message");
      expect(mockService.capturedTags, <String, String>{"type": "info"});
      expect(mockService.capturedLevel, BreadcrumbLevel.info);
    });

    test("should not capture message if not initialized", () async {
      await apzObs.captureMessage("A message");
      expect(mockService.capturedMessage, isNull);
    });

    test("should add breadcrumb if initialized", () async {
      await apzObs.init(mockService);
      final AppBreadcrumb breadcrumb = AppBreadcrumb(message: "User action");
      await apzObs.addBreadcrumb(breadcrumb);
      expect(mockService.addedBreadcrumb, breadcrumb);
    });

    test("should not add breadcrumb if not initialized", () async {
      final AppBreadcrumb breadcrumb = AppBreadcrumb(message: "User action");
      await apzObs.addBreadcrumb(breadcrumb);
      expect(mockService.addedBreadcrumb, isNull);
    });

    test("should set user if initialized", () async {
      await apzObs.init(mockService);
      await apzObs.setUser(
        id: "123",
        username: "testuser",
        email: "test@example.com",
        extraData: <String, dynamic>{"role": "admin"},
      );
      expect(mockService.user, <String, Object>{
        "id": "123",
        "username": "testuser",
        "email": "test@example.com",
        "extraData": <String, String>{"role": "admin"},
      });
    });

    test("should not set user if not initialized", () async {
      await apzObs.setUser(id: "123");
      expect(mockService.user, isNull);
    });

    test("should clear user if initialized", () async {
      await apzObs.init(mockService);
      await apzObs.clearUser();
      expect(mockService.userCleared, isTrue);
    });

    test("should not clear user if not initialized", () async {
      await apzObs.clearUser();
      expect(mockService.userCleared, isFalse);
    });
  });
}
