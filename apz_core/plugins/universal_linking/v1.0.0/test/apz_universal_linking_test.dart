import "dart:async";

// Adjust these import paths to where your files are located
import "package:apz_universal_linking/apz_universal_linking.dart";
import "package:apz_utils/apz_utils.dart"; // For UnsupportedPlatformException
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  final TestDefaultBinaryMessenger messenger = binding.defaultBinaryMessenger;

  // Define the name of your method channel
  const MethodChannel channel = MethodChannel("apz_universal_linking");

  group("ApzUniversalLinking", () {
    setUp(() async {
      await ApzUniversalLinking().resetForTesting();
      messenger.setMockMethodCallHandler(channel, null);
    });

    test("throws on web (via override)", () {
      expect(
        () => ApzUniversalLinking(isWebOverride: () => true),
        throwsA(isA<UnsupportedPlatformException>()),
      );
    });

    // Test Case 1: Singleton instance
    test("should return the same instance", () {
      final instance1 = ApzUniversalLinking();
      final instance2 = ApzUniversalLinking();
      expect(instance1, same(instance2));
    });

    // Test Case 2: getInitialLink returns a valid LinkData
    test(
      "getInitialLink returns LinkData when platform provides a link",
      () async {
        // Set up the mock handler for "getInitialLink" method
        messenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == "getInitialLink") {
            return {
              "host": "initial.example.com",
              "path": "/initial/path",
              "scheme": "https",
              "fullUrl": "https://initial.example.com/initial/path",
            };
          }
          return null;
        });

        final ApzUniversalLinking plugin = ApzUniversalLinking();
        final LinkData? link = await plugin.getInitialLink();

        expect(link, isNotNull);
        expect(link!.host, "initial.example.com");
        expect(link.path, "/initial/path");
        expect(link.scheme, "https");
        expect(link.fullUrl, "https://initial.example.com/initial/path");
      },
    );

    // Test Case 3: getInitialLink returns null when no initial link
    test(
      "getInitialLink returns null when platform provides no link",
      () async {
        // Set up the mock handler to return null for "getInitialLink"
        messenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == "getInitialLink") {
            return null; // Simulate no initial link
          }
          return null;
        });

        final plugin = ApzUniversalLinking();
        final link = await plugin.getInitialLink();

        expect(link, isNull);
      },
    );

    // Test Case 4: dispose closes the stream
    test("dispose closes the linkStream", () async {
      final ApzUniversalLinking plugin = ApzUniversalLinking();
      final Completer<void> completer = Completer<void>();

      // Listen for the stream to close
      plugin.linkStream.listen(
        (data) {}, // Dummy listener
        onDone: completer.complete,
      );

      await plugin.dispose();

      // Expect the completer to complete, indicating the stream is closed
      expect(completer.isCompleted, isTrue);
      // Try adding to a closed stream to confirm it"s closed
      //(will throw error usually)
      expect(
        () => plugin.handleIncomingLink({"host": "closed.com"}),
        throwsA(isA<StateError>()),
      );
    });
    test(
      'method channel "onLinkReceived" triggers handleIncomingLink',
      () async {
        final ApzUniversalLinking plugin = ApzUniversalLinking();

        final LinkData expectedData = LinkData(
          host: "platform.com",
          path: "/receive",
          scheme: "https",
          fullUrl: "https://platform.com/receive",
          queryParams: {"foo": "bar", "baz": "qux"},
        );

        final Completer<LinkData> completer = Completer<LinkData>();

        plugin.linkStream.listen(completer.complete);
        plugin.methodChannel.setMethodCallHandler((MethodCall call) async {
          if (call.method == "onLinkReceived") {
            plugin.handleIncomingLink(
              (call.arguments as Map).cast<String, dynamic>(),
            );
          }
        });

        // Trigger the method call manually
        final ByteData? encoded = plugin.methodChannel.codec.encodeMethodCall(
          const MethodCall("onLinkReceived", {
            "host": "platform.com",
            "path": "/receive",
            "scheme": "https",
            "fullUrl": "https://platform.com/receive",
            "queryParams": {"foo": "bar", "baz": "qux"},
          }),
        );

        await ServicesBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              plugin.methodChannel.name,
              encoded,
              (ByteData? _) {},
            );

        final received = await completer.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () => throw Exception("Stream event not received."),
        );

        expect(received.host, expectedData.host);
        expect(received.path, expectedData.path);
        expect(received.scheme, expectedData.scheme);
        expect(received.fullUrl, expectedData.fullUrl);
        expect(received.queryParams, expectedData.queryParams);
      },
    );

    test('dispose closes the linkStream', () async {
      final plugin = ApzUniversalLinking();
      final completer = Completer<void>();

      plugin.linkStream.listen((_) {}, onDone: () => completer.complete());

      await plugin.dispose();

      expect(completer.isCompleted, isTrue);
    });

    // Test Case 8: dispose can be called twice without crashing
    test("dispose can be called multiple times safely", () async {
      final ApzUniversalLinking plugin = ApzUniversalLinking();
      await plugin.dispose();

      // Should not throw even if called again
      await expectLater(plugin.dispose(), completes);
    });
  });
}
