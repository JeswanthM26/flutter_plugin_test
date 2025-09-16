import "package:apz_in_app_review/apz_in_app_review.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

class WebInAppReview extends ApzInAppReview {
  @override
  bool getIsWeb() => true;
}

void main() {
  // Ensure that the Flutter test environment is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  group("ApzInAppReview", () {
    // Define the MethodChannel name used in your plugin.
    const MethodChannel channel = MethodChannel("com.iexceed/in_app_review");

    // This is the instance of your plugin class that we will test.
    late ApzInAppReview apzInAppReview;

    setUp(() {
      // Initialize the plugin instance before each test.
      apzInAppReview = ApzInAppReview();

      // Reset the mock method call handler before each test.
      // This ensures that tests are isolated and don't affect each other.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    test(
      "requestReview completes successfully when native call succeeds",
      () async {
        // Arrange: Set up a mock handler for the MethodChannel.
        // When 'requestReview' is invoked, it will return null,
        // simulating a successful completion from the native side.
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              // Assert that the correct method is being called from Dart.
              expect(methodCall.method, "requestReview");
              // Return null to simulate a successful void return from the native side.
              return null;
            });
        await apzInAppReview.requestReview();
      },
    );

    test(
      "requestReview throws PlatformException when native call fails",
      () async {
        // Arrange: Set up a mock handler that throws a PlatformException.
        // This simulates an error originating from the native Android/iOS code.
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              // Assert that the correct method is being called.
              expect(methodCall.method, "requestReview");
              // Throw a PlatformException to simulate a native error.
              throw PlatformException(
                code: "UNAVAILABLE",
                message: "In-app review API is not available on this device.",
                details: "Some additional error details.",
              );
            });

        // Act & Assert: Call the requestReview method and expect it to throw a PlatformException.
        // `expectLater` is used for asynchronous matchers.
        await expectLater(
          apzInAppReview
              .requestReview(), // The Future that is expected to throw.
          throwsA(
            isA<PlatformException>(),
          ), // Matcher to check if a PlatformException is thrown.
        );
      },
    );
    test('requestReview throws UnsupportedPlatformException on web', () async {
      // Now just instantiate the top‑level subclass
      await expectLater(
        WebInAppReview().requestReview(),
        throwsA(
          isA<UnsupportedPlatformException>().having(
            (e) => e.message,
            'message',
            contains('not supported on the web'),
          ),
        ),
      );
    });
  });
}
