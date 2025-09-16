import "package:apz_screen_security/apz_screen_security.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/services.dart"; // For MethodChannel and EventChannel
import "package:flutter/foundation.dart"
    show kIsWeb; // Needed if kIsWeb is directly involved in test assertions
import "package:flutter_test/flutter_test.dart"; // Import the plugin class

void main() {
  const MethodChannel channel = MethodChannel("apz_screen_security");

  TestWidgetsFlutterBinding.ensureInitialized();

  // A mutable handler to control MethodChannel responses for each test
  Future<dynamic> Function(MethodCall)? _mockMethodCallHandler;

  setUp(() {
    // Set a mock handler that delegates to _mockMethodCallHandler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (_mockMethodCallHandler != null) {
            return _mockMethodCallHandler!(methodCall);
          }
          return null; // Default to null if no specific handler is set
        });
  });

  tearDown(() {
    // Clear the mock handler after each test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    _mockMethodCallHandler = null; // Reset the mutable handler
  });

  group("ApzScreenSecurity Singleton and Basic Functionality", () {
    test("Multiple calls to constructor return same instance", () {
      final instance1 = ApzScreenSecurity();
      final instance2 = ApzScreenSecurity();

      expect(
        identical(instance1, instance2),
        isTrue,
        reason: "Both instances should be identical (same memory reference)",
      );
    });

    test("access singleton instance to cover constructor", () {
      // This line ensures the private constructor and instance getter are hit
      final instance = ApzScreenSecurity();

      // Optional: assert it’s of correct type
      expect(instance, isA<ApzScreenSecurity>());
    });
  });

  group("ApzScreenSecurity Method Tests", () {
    test("enableScreenSecurity returns true on success", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        if (methodCall.method == "enableSecure") {
          return true;
        }
        return null;
      };

      final result = await ApzScreenSecurity().enableScreenSecurity();
      expect(result, true);
    });

    test(
      "enableScreenSecurity returns false when native result is null",
      () async {
        _mockMethodCallHandler = (MethodCall methodCall) async {
          return null; // Simulate native returning null
        };

        final result = await ApzScreenSecurity().enableScreenSecurity();
        expect(result, false);
      },
    );

    test("enableScreenSecurity rethrows PlatformException", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw PlatformException(
          code: "ERROR",
          message: "Simulated Platform Error",
        );
      };

      expect(
        () async => await ApzScreenSecurity().enableScreenSecurity(),
        throwsA(isA<PlatformException>()),
      );
    });

    test("enableScreenSecurity rethrows MissingPluginException", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw MissingPluginException("Simulated Missing Plugin");
      };

      expect(
        () async => await ApzScreenSecurity().enableScreenSecurity(),
        throwsA(isA<MissingPluginException>()),
      );
    });

    test("enableScreenSecurity rethrows other Exceptions", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw Exception("Generic simulated error");
      };

      expect(
        () async => await ApzScreenSecurity().enableScreenSecurity(),
        throwsA(isA<Exception>()),
      );
    });

    // --- disableScreenSecurity Tests ---
    test("disableScreenSecurity returns true on success", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        if (methodCall.method == "disableSecure") {
          return true;
        }
        return null;
      };

      final result = await ApzScreenSecurity().disableScreenSecurity();
      expect(result, true); // It should return true if native reports success
    });

    test(
      "disableScreenSecurity returns false when native result is null",
      () async {
        _mockMethodCallHandler = (MethodCall methodCall) async {
          return null; // Simulate native returning null
        };

        final result = await ApzScreenSecurity().disableScreenSecurity();
        expect(result, false);
      },
    );

    test("disableScreenSecurity rethrows PlatformException", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw PlatformException(
          code: "ERROR",
          message: "Simulated Platform Error",
        );
      };

      expect(
        () async => await ApzScreenSecurity().disableScreenSecurity(),
        throwsA(isA<PlatformException>()),
      );
    });

    test("disableScreenSecurity rethrows MissingPluginException", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw MissingPluginException("Simulated Missing Plugin");
      };

      expect(
        () async => await ApzScreenSecurity().disableScreenSecurity(),
        throwsA(isA<MissingPluginException>()),
      );
    });

    test("disableScreenSecurity rethrows other Exceptions", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw Exception("Generic simulated error");
      };

      expect(
        () async => await ApzScreenSecurity().disableScreenSecurity(),
        throwsA(isA<Exception>()),
      );
    });

    // --- isScreenSecureEnabled Tests ---
    test("isScreenSecureEnabled returns true on success", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        if (methodCall.method == "isScreenCaptured") {
          return true;
        }
        return null;
      };

      final result = await ApzScreenSecurity().isScreenSecureEnabled();
      expect(result, true);
    });

    test(
      "isScreenSecureEnabled returns false when native result is null",
      () async {
        _mockMethodCallHandler = (MethodCall methodCall) async {
          return null; // Simulate native returning null
        };

        final result = await ApzScreenSecurity().isScreenSecureEnabled();
        expect(result, false);
      },
    );

    test("isScreenSecureEnabled rethrows PlatformException", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw PlatformException(
          code: "ERROR",
          message: "Simulated Platform Error",
        );
      };

      expect(
        () async => await ApzScreenSecurity().isScreenSecureEnabled(),
        throwsA(isA<PlatformException>()),
      );
    });

    test("isScreenSecureEnabled rethrows MissingPluginException", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw MissingPluginException("Simulated Missing Plugin");
      };

      expect(
        () async => await ApzScreenSecurity().isScreenSecureEnabled(),
        throwsA(isA<MissingPluginException>()),
      );
    });

    test("isScreenSecureEnabled rethrows other Exceptions", () async {
      _mockMethodCallHandler = (MethodCall methodCall) async {
        throw Exception("Generic simulated error");
      };

      expect(
        () async => await ApzScreenSecurity().isScreenSecureEnabled(),
        throwsA(isA<Exception>()),
      );
    });
    test("enableScreenSecurity throws UnimplementedError on web", () async {
      if (kIsWeb) {
        // This check makes the test conditional to web compilation
        expect(
          () async => await ApzScreenSecurity().enableScreenSecurity(),
          throwsA(isA<UnsupportedPlatformException>()),
        );
      } else {
        print(
          "Skipping web-specific test for enableScreenSecurity as kIsWeb is false.",
        );
      }
    });
    test("disableScreenSecurity throws UnimplementedError on web", () async {
      if (kIsWeb) {
        // This check makes the test conditional to web compilation
        expect(
          () async => await ApzScreenSecurity().disableScreenSecurity(),
          throwsA(isA<UnsupportedPlatformException>()),
        );
      } else {
        print(
          "Skipping web-specific test for disableScreenSecurity as kIsWeb is false.",
        );
      }
    });
    test("isScreenSecureEnabled throws UnimplementedError on web", () async {
      if (kIsWeb) {
        // This check makes the test conditional to web compilation
        expect(
          () async => await ApzScreenSecurity().isScreenSecureEnabled(),
          throwsA(isA<UnsupportedPlatformException>()),
        );
      } else {
        print(
          "Skipping web-specific test for isScreenSecureEnabled as kIsWeb is false.",
        );
      }
    });
  });
}
