import "dart:async";
import "package:apz_call_state/apz_call_state.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:permission_handler/permission_handler.dart";
import "dart:io" show Platform;
import "package:flutter/foundation.dart";

/// ----------------------
/// Mock Classes
/// ----------------------
///
class FakePlatform {
  static bool get isWeb => kIsWeb;
  static bool isAndroid = false;
  static bool isIOS = false;
}

class MockPermissionService extends Mock implements PermissionService {}

class FakeEventChannel extends EventChannel {
  FakeEventChannel() : super("call_state_events");

  StreamController<String>? _controller;

  @override
  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    _controller = StreamController<String>.broadcast();
    return _controller!.stream;
  }

  void addEvent(String event) => _controller?.add(event);

  void close() => _controller?.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPermissionService mockPermissionService;
  late FakeEventChannel fakeEventChannel;

  setUp(() {
    ApzCallState().resetForTest();
    mockPermissionService = MockPermissionService();
    fakeEventChannel = FakeEventChannel();

    ApzCallState().configureForTest(
      channel: fakeEventChannel,
      permissionService: mockPermissionService,
    );
  });

  tearDown(() {
    fakeEventChannel.close();
  });

  group("ApzCallState", () {
    test("throws exception if permission not granted", () async {
      when(
        () => mockPermissionService.requestPhoneStatePermission(),
      ).thenAnswer((_) async => PermissionStatus.denied);

      final apz = ApzCallState();

      expect(
        () async => apz.callStateStream, // ✅ await inside closure
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            "message",
            contains("Phone Permission is not granted"),
          ),
        ),
      );
    });

    test("emits CallState events when permission is granted", () async {
      when(
        () => mockPermissionService.requestPhoneStatePermission(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      final apz = ApzCallState();

      // Access stream
      final stream = await apz.callStateStream;

      // Listen to stream
      final events = <CallState>[];
      final sub = stream.listen(events.add);

      // Simulate events
      fakeEventChannel.addEvent("disconnected");
      fakeEventChannel.addEvent("incoming");
      fakeEventChannel.addEvent("active");
      fakeEventChannel.addEvent("outgoing");

      // Give stream time to process
      await Future.delayed(const Duration(milliseconds: 50));

      expect(events, [
        CallState.disconnected,
        CallState.incoming,
        CallState.active,
        CallState.outgoing,
      ]);
      await sub.cancel();
    });

    test("maps unknown call state to disconnected", () async {
      when(
        () => mockPermissionService.requestPhoneStatePermission(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      final apz = ApzCallState();
      final stream = await apz.callStateStream;

      final events = <CallState>[];
      final sub = stream.listen(events.add);

      // Send unknown event
      fakeEventChannel.addEvent("mystery");

      // Give stream time to process
      await Future.delayed(const Duration(milliseconds: 50));

      expect(events, [CallState.disconnected]);

      await sub.cancel();
    });

  });

  group("PermissionService", () {
    late PermissionService service;

    setUp(() {
      service = PermissionService();
    });

    test("throws UnsupportedPlatformException on Web", () async {
      if (kIsWeb) {
        expect(
          () => service.requestPhoneStatePermission(),
          throwsA(isA<UnsupportedPlatformException>()),
        );
      }
    });

    test("requests permission on Android", () async {
      if (!kIsWeb && Platform.isAndroid) {
        final status = await service.requestPhoneStatePermission();
        expect(status, isA<PermissionStatus>());
      }
    });

    test("returns granted on iOS", () async {
      if (!kIsWeb && Platform.isIOS) {
        final status = await service.requestPhoneStatePermission();
        expect(status, PermissionStatus.granted);
      }
    });

    test("returns granted on desktop platforms", () async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        final status = await service.requestPhoneStatePermission();
        expect(status, PermissionStatus.granted);
      }
    });
  });
}
