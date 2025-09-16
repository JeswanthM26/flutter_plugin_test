import "dart:async";

import "package:apz_deeplink/deeplink_data.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart"; // Import mocktail

// The class under test
import "package:apz_deeplink/apz_deeplink.dart"; // Adjust this import path to your ApzDeeplink class

// Mock classes for MethodChannel and EventChannel
class MockMethodChannel extends Mock implements MethodChannel {}

class MockEventChannel extends Mock implements EventChannel {}

void main() {
  late MockMethodChannel mockMethodChannel;
  late MockEventChannel mockEventChannel;
  late ApzDeeplink apzDeeplink;

  // StreamController to simulate events coming from the EventChannel
  late StreamController<Map<String, String>> eventStreamController;

  setUp(() {
    mockMethodChannel = MockMethodChannel();
    mockEventChannel = MockEventChannel();
    eventStreamController = StreamController<Map<String, String>>.broadcast();
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel("apz_deeplink/method"), (
          final MethodCall methodCall,
        ) async {
          if (methodCall.method == "getInitialLink") {
            return mockMethodChannel.invokeMethod(methodCall.method);
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel("apz_deeplink/events"), (
          final MethodCall methodCall,
        ) async {
          if (methodCall.method == "listen") {
            // Simulate the EventChannel starting to listen
            return null;
          }
          return null;
        });
    when(
      () => mockEventChannel.receiveBroadcastStream(),
    ).thenAnswer((_) => eventStreamController.stream);
    apzDeeplink = ApzDeeplink();
  });

  tearDown(() {
    eventStreamController.close();
    // Reset handlers to avoid interference with other tests
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel("apz_deeplink/method"),
          null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel("apz_deeplink/events"),
          null,
        );
  });

  group("ApzDeeplink", () {
    test("initialize() starts listening to EventChannel", () async {
      final completer = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel("apz_deeplink/events"),
            (MethodCall methodCall) async {
              if (methodCall.method == "listen") {
                completer.complete(); // Signal that listen was called
                return null;
              }
              return null;
            },
          );

      await apzDeeplink.initialize();
      expect(completer.isCompleted, isTrue);
    });

    test("initialize() is idempotent and only initializes once", () async {
      // First initialization
      await apzDeeplink.initialize();
      // Try to initialize again
      await apzDeeplink.initialize();
      int listenCallCount = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel("apz_deeplink/events"),
            (MethodCall methodCall) async {
              if (methodCall.method == "listen") {
                listenCallCount++;
                return null;
              }
              return null;
            },
          );
      await apzDeeplink.initialize();
      await apzDeeplink.initialize();
      await apzDeeplink.initialize();
    });

    test("linkStream is a broadcast stream", () {
      // A broadcast stream can have multiple listeners
      final stream = apzDeeplink.linkStream;
      final sub1 = stream.listen((_) {});
      final sub2 = stream.listen((_) {});

      expect(stream.isBroadcast, isTrue); // Verify it"s a broadcast stream
      sub1.cancel();
      sub2.cancel();
    });
    test("getInitialLink() returns a link", () async {
      const expectedLink = "https://example.com";

      // Mock the MethodChannel using the binary messenger
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel("apz_deeplink/method"),
            (MethodCall methodCall) async {
              if (methodCall.method == "getInitialLink") {
                return expectedLink;
              }
              return null;
            },
          );

      final apzDeeplink = ApzDeeplink();
      final link = await apzDeeplink.getInitialLink();

      expect(link, expectedLink);

      // Clean up the mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel("apz_deeplink/method"),
            null,
          );
    });

    test("linkStream emits DeeplinkData with correct values", () async {
      const testLink = "myapp://home?productid=456";
      final ByteData encoded = const StandardMethodCodec()
          .encodeSuccessEnvelope(testLink)!;

      final List<DeeplinkData> received = [];
      final sub = apzDeeplink.linkStream.listen(received.add);

      await Future.delayed(const Duration(milliseconds: 5));
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage("apz_deeplink/events", encoded, (_) {});

      await Future.delayed(const Duration(milliseconds: 10));

      expect(received, hasLength(1));
      final DeeplinkData data = received.first;
      expect(data.scheme, "myapp");
      expect(data.host, "home");
      expect(data.queryParameters["productid"], "456");
      expect(data.path, ""); // path is empty in myapp://home
      await sub.cancel();
    });
  });
}
