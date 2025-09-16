import "package:apz_utils/src/exception/unsupported_exception.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("UnsupportedPlatformException", () {
    test("should create instance with correct message", () {
      const String message = "This platform is not supported";
      final UnsupportedPlatformException exception =
          UnsupportedPlatformException(message);

      expect(exception.message, equals(message));
    });

    test("toString should return formatted message", () {
      const String message = "This platform is not supported";
      final UnsupportedPlatformException exception =
          UnsupportedPlatformException(message);

      expect(
        exception.toString(),
        equals("UnsupportedPlatformException: $message"),
      );
    });

    test("should handle different message types", () {
      final List<String> testMessages = <String>[
        "iOS platform is not supported",
        "Android version below 21 is not supported",
        "Web platform features are not available",
        "Desktop implementation is pending",
      ];

      for (final String message in testMessages) {
        final UnsupportedPlatformException exception =
            UnsupportedPlatformException(message);
        expect(exception.message, equals(message));
        expect(
          exception.toString(),
          equals("UnsupportedPlatformException: $message"),
        );
      }
    });

    test("implements Exception interface", () {
      final UnsupportedPlatformException exception =
          UnsupportedPlatformException("Test message");

      expect(exception, isA<Exception>());
    });
  });
}
