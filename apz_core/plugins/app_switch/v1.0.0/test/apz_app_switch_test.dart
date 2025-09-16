import "dart:async";
import "dart:ui";

import "package:apz_app_switch/apz_app_switch.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("ApzAppSwitch", () {
    late ApzAppSwitch appSwitch;
    const MethodChannel methodChannel = MethodChannel("apz_app_switch_method");
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      appSwitch = ApzAppSwitch()..resetForTest();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (
            final MethodCall methodCall,
          ) async {
            log.add(methodCall);
            if (methodCall.method == "initialize") {
              return null;
            }
            throw PlatformException(code: "METHOD_NOT_FOUND");
          });
    });

    tearDown(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
    });

    test(
      "initialize sets _isInitialized true and calls native method",
      () async {
        expect(() => appSwitch.initialize(), returnsNormally);
        await appSwitch.initialize(); // Call twice to test idempotency
        expect(log.length, 1);
        expect(log.first.method, "initialize");
      },
    );

    test("initialize handles PlatformException", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (
            MethodCall methodCall,
          ) async {
            throw PlatformException(code: "ERROR");
          });
      expect(
        () async => ApzAppSwitch().initialize(),
        throwsA(isA<PlatformException>()),
      );
    });

    test("initialize handles unknown errors", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (
            final MethodCall methodCall,
          ) async {
            throw Exception("Unknown error");
          });
      expect(
        () async => ApzAppSwitch().initialize(),
        throwsA(isA<Exception>()),
      );
    });
    test("throws UnsupportedPlatformException on web", () async {
      final ApzAppSwitch appSwitch = ApzAppSwitch()
        ..resetForTest()
        ..isWeb = true; // simulate web

      expect(
        () async => appSwitch.initialize(),
        throwsA(isA<UnsupportedPlatformException>()),
      );
    });

    test(
      "lifecycleStream emits correct mapped states from simulated stream",
      () async {
        final ApzAppSwitch appSwitch = ApzAppSwitch()..resetForTest();

        appSwitch.isWeb = false;

        final Stream<String> simulatedEvents = Stream<String>.fromIterable(
          <String>["resumed", "paused", "inactive"],
        );

        final List<AppLifecycleState> expectedStates = <AppLifecycleState>[
          AppLifecycleState.resumed,
          AppLifecycleState.paused,
          AppLifecycleState.inactive,
        ];

        appSwitch.debugOverrideEventStream = simulatedEvents;

        final List<AppLifecycleState> receivedStates = <AppLifecycleState>[];

        final Completer<void> completer = Completer<void>();

        late final StreamSubscription<AppLifecycleState> subscription;
        subscription = appSwitch.lifecycleStream.listen((
          AppLifecycleState state,
        ) {
          receivedStates.add(state);
          if (receivedStates.length == expectedStates.length) {
            completer.complete();
          }
        }, onError: completer.completeError);

        await completer.future;
        await subscription.cancel();

        expect(receivedStates, expectedStates);
      },
    );

    test("lifecycleStream emits states and updates currentState", () async {
      final ApzAppSwitch appSwitch = ApzAppSwitch()..resetForTest();

      appSwitch.isWeb = false;

      final Stream<String> simulatedEvents = Stream<String>.fromIterable(
        <String>["resumed", "paused", "inactive"],
      );

      appSwitch.debugOverrideEventStream = simulatedEvents;

      final List<AppLifecycleState> receivedStates = <AppLifecycleState>[];

      await for (final AppLifecycleState state in appSwitch.lifecycleStream) {
        receivedStates.add(state);

        // ✅ Check currentState each time
        expect(appSwitch.currentState, equals(state));

        if (receivedStates.length == 3) {
          break; // Exit after all expected values are received
        }
      }

      expect(receivedStates, <AppLifecycleState>[
        AppLifecycleState.resumed,
        AppLifecycleState.paused,
        AppLifecycleState.inactive
      ]);
    });
  });
}
