import "package:apz_utils/src/exception/unsupported_exception.dart";
import "package:apz_utils/src/launcher/launchers.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("Launchers Tests", () {
    late Launchers launchers;

    setUp(() {
      launchers = Launchers();
    });

    group("Phone Call Tests", () {
      test("should throw exception for empty phone number", () {
        expect(
          () => launchers.launchCall(""),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Phone number cannot be empty"),
            ),
          ),
        );
      });

      test("should throw UnsupportedPlatformException for web platform", () {
        launchers.setWeb(isWeb: true);
        expect(
          () => launchers.launchCall("1234567890"),
          throwsA(
            isA<UnsupportedPlatformException>().having(
              (final UnsupportedPlatformException e) => e.toString(),
              "message",
              contains("Web platform is not supported for phone dialer"),
            ),
          ),
        );
      });

      test("should handle web platform status changes", () {
        // Test with web enabled
        launchers.setWeb(isWeb: true);
        expect(
          () => launchers.launchCall("1234567890"),
          throwsA(
            isA<UnsupportedPlatformException>().having(
              (final UnsupportedPlatformException e) => e.toString(),
              "message",
              contains("Web platform is not supported for phone dialer"),
            ),
          ),
        );

        // Test with web disabled
        launchers.setWeb(isWeb: false);
        expect(
          () => launchers.launchCall(""),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Phone number cannot be empty"),
            ),
          ),
        );
      });
    });

    group("SMS Tests", () {
      test("should throw exception for empty phone number", () {
        expect(
          () => launchers.sendSMS(""),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Phone number cannot be empty"),
            ),
          ),
        );
      });

      test("should throw UnsupportedPlatformException for web platform", () {
        launchers.setWeb(isWeb: true);
        expect(
          () => launchers.sendSMS("1234567890"),
          throwsA(
            isA<UnsupportedPlatformException>().having(
              (final UnsupportedPlatformException e) => e.toString(),
              "message",
              contains("Web platform is not supported for SMS"),
            ),
          ),
        );
      });

      test(
        """should throw UnsupportedPlatformException for web platform with message""",
        () {
          launchers.setWeb(isWeb: true);
          expect(
            () => launchers.sendSMS("1234567890", message: "Test message"),
            throwsA(
              isA<UnsupportedPlatformException>().having(
                (final UnsupportedPlatformException e) => e.toString(),
                "message",
                contains("Web platform is not supported for SMS"),
              ),
            ),
          );
        },
      );

      test("should validate SMS URI format", () {
        launchers.setWeb(isWeb: true);
        expect(
          () => launchers.sendSMS("1234567890", message: "Test message"),
          throwsA(isA<UnsupportedPlatformException>()),
        );

        launchers.setWeb(isWeb: false);
        expect(
          () => launchers.sendSMS("", message: "Test message"),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Phone number cannot be empty"),
            ),
          ),
        );
      });
    });

    group("URL Validation Tests", () {
      test("should throw exception for empty URL", () {
        expect(
          () => launchers.launchInExternalBrowser(""),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("URL cannot be empty"),
            ),
          ),
        );
      });

      test("should throw exception for invalid URL format", () {
        expect(
          () => launchers.launchInExternalBrowser("not a url"),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Invalid URL format"),
            ),
          ),
        );
      });

      test("should throw exception for URLs without scheme", () {
        expect(
          () => launchers.launchInExternalBrowser("example.com"),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Invalid URL format"),
            ),
          ),
        );
      });

      test("should throw exception for invalid URL", () {
        expect(
          () => launchers.launchInExternalBrowser("httpsexample .com"),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Invalid URL format"),
            ),
          ),
        );
      });
    });

    group("Additional URL Validation Tests", () {
      test("should handle various URL schemes", () {
        // Test HTTPS
        expect(
          () => launchers.launchInExternalBrowser("https://example.com"),
          throwsException,
        );

        // Test HTTP
        expect(
          () => launchers.launchInExternalBrowser("http://example.com"),
          throwsException,
        );

        // Test FTP
        expect(
          () => launchers.launchInExternalBrowser("ftp://example.com"),
          throwsException,
        );

        // Test file protocol
        expect(
          () => launchers.launchInExternalBrowser("file:///path/to/file"),
          throwsException,
        );
      });

      test("should handle URLs with query parameters", () {
        expect(
          () => launchers.launchInExternalBrowser(
            "https://example.com?param=value",
          ),
          throwsException,
        );

        expect(
          () => launchers.launchInExternalBrowser(
            "https://example.com?param1=value1&param2=value2",
          ),
          throwsException,
        );
      });

      test("should handle URLs with fragments", () {
        expect(
          () =>
              launchers.launchInExternalBrowser("https://example.com#section"),
          throwsException,
        );

        expect(
          () => launchers.launchInExternalBrowser(
            "https://example.com?param=value#section",
          ),
          throwsException,
        );
      });

      test("should handle URLs with ports", () {
        expect(
          () => launchers.launchInExternalBrowser("https://example.com:8080"),
          throwsException,
        );

        expect(
          () => launchers.launchInExternalBrowser("http://localhost:3000"),
          throwsException,
        );
      });
    });

    group("Advanced URL Validation Tests", () {
      test("should handle complex URLs", () {
        // URL with userinfo component
        expect(
          () => launchers.launchInExternalBrowser(
            "https://user:pass@example.com",
          ),
          throwsException,
        );

        // URL with special characters in query params
        expect(
          () => launchers.launchInExternalBrowser(
            "https://example.com/path?q=hello%20world&special=%23%26",
          ),
          throwsException,
        );

        // URL with multiple path segments
        expect(
          () => launchers.launchInExternalBrowser(
            "https://example.com/api/v1/users/123/profile",
          ),
          throwsException,
        );

        // URL with international domain name
        expect(
          () => launchers.launchInExternalBrowser("https://café.com"),
          throwsException,
        );
      });

      test(
        """should handle URLs with multiple query parameters and fragments""",
        () {
          expect(
            () => launchers.launchInExternalBrowser(
              "https://example.com/path?q1=val1&q2=val2&q3=val3#section/subsection",
            ),
            throwsException,
          );

          expect(
            () => launchers.launchInExternalBrowser(
              "https://example.com/search?q=test&lang=en&page=1#results",
            ),
            throwsException,
          );
        },
      );
    });

    group("Singleton Tests", () {
      test("should return same instance", () {
        final Launchers launchers2 = Launchers();
        expect(identical(launchers, launchers2), isTrue);
      });

      test("web status should be shared between instances", () {
        final Launchers launchers2 = Launchers();
        launchers.setWeb(isWeb: true);

        expect(
          () => launchers2.launchCall("1234567890"),
          throwsA(isA<UnsupportedPlatformException>()),
        );
      });
    });

    group("Additional Phone Number Tests", () {
      test("should handle various phone number formats", () {
        // Test with country code
        expect(() => launchers.launchCall("+1234567890"), throwsException);

        // Test with spaces and dashes
        expect(() => launchers.launchCall("123-456-7890"), throwsException);

        expect(() => launchers.launchCall("(123) 456-7890"), throwsException);
      });

      test("should handle invalid phone number characters", () {
        expect(() => launchers.launchCall("123abc4567"), throwsException);

        expect(() => launchers.launchCall("12345\n67890"), throwsException);
      });
    });

    group("Web Status Tests", () {
      test("should maintain web status across method calls", () {
        launchers.setWeb(isWeb: true);

        // Phone call should fail
        expect(
          () => launchers.launchCall("1234567890"),
          throwsA(isA<UnsupportedPlatformException>()),
        );

        // SMS should fail
        expect(
          () => launchers.sendSMS("1234567890"),
          throwsA(isA<UnsupportedPlatformException>()),
        );

        // Reset web status
        launchers.setWeb(isWeb: false);

        // Should now fail with different exceptions
        expect(
          () => launchers.launchCall(""),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Phone number cannot be empty"),
            ),
          ),
        );
      });
    });

    group("Extended Phone Number Tests", () {
      test("should handle international phone numbers", () {
        // International format with plus
        expect(() => launchers.launchCall("+44 20 7123 4567"), throwsException);

        // International format without plus
        expect(
          () => launchers.launchCall("0044 20 7123 4567"),
          throwsException,
        );

        // Complex international format
        expect(
          () => launchers.launchCall("+1 (555) 123-4567 ext. 890"),
          throwsException,
        );
      });

      test("should handle edge case phone numbers", () {
        // Very long phone number
        expect(
          () => launchers.launchCall("+1234567890123456789"),
          throwsException,
        );

        // Phone number with valid special characters
        expect(() => launchers.launchCall("+1.234.567.8900"), throwsException);
      });
    });

    group("Extended SMS Tests", () {
      test("should handle SMS with special characters", () {
        launchers.setWeb(isWeb: false);

        // Message with emoji and special characters
        expect(
          () => launchers.sendSMS(
            "+1234567890",
            message: r"Hello! 👋 Special chars: @#$%",
          ),
          throwsException,
        );

        // Message with newlines and tabs
        expect(
          () => launchers.sendSMS(
            "+1234567890",
            message: "Line 1\nLine 2\tTabbed",
          ),
          throwsException,
        );
      });

      test("should handle empty and null messages", () {
        launchers.setWeb(isWeb: false);

        // Empty message
        expect(
          () => launchers.sendSMS("+1234567890", message: ""),
          throwsException,
        );

        // Null message
        expect(() => launchers.sendSMS("+1234567890"), throwsException);
      });

      test("should handle international numbers with SMS", () {
        launchers.setWeb(isWeb: false);

        expect(
          () => launchers.sendSMS(
            "+44 20 7123 4567",
            message: "International SMS test",
          ),
          throwsException,
        );
      });
    });
  });
}
