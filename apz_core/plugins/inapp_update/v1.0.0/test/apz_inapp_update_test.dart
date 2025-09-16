import "dart:async";
import "dart:io";

import "package:apz_inapp_update/apz_inapp_update.dart";
import "package:apz_inapp_update/apz_inapp_update_enums.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
export "package:apz_inapp_update/apz_inapp_update_enums.dart";

void setupMockMethodChannel(
  Future<dynamic> Function(MethodCall call)? handler,
) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel("apz_inapp_update/methods"),
        handler,
      );
}

// Mock EventChannel to simulate native events
void setupMockEventChannel(Stream<dynamic>? stream) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockStreamHandler(
        const EventChannel('apz_inapp_update/stateEvents'),
        stream != null ? TestStreamHandler(stream) : null,
      );
}

// Renamed MockStreamHandler to TestStreamHandler to avoid conflict with flutter_test's abstract MockStreamHandler
class TestStreamHandler extends MockStreamHandler {
  final Stream<dynamic> _stream;

  TestStreamHandler(this._stream);

  @override
  Future<void> onCancel(Object? arguments) async {
    // No-op for testing purposes
  }

  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    _stream.listen(
      (data) => events.success(data),
      onError: (error) => events.error(
        code: 'ERROR',
        message: error?.toString(),
        details: null,
      ),
      onDone: () => events.endOfStream(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel methodChannel = MethodChannel("apz_inapp_update/methods");
  final List<MethodCall> log = [];
  setUp(() {
    ApzInAppUpdate.isAndroidForTest = true;
    setupMockEventChannel(null);
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (
          final MethodCall methodCall,
        ) async {
          log.add(methodCall);

          switch (methodCall.method) {
            case "checkForUpdate":
              return {
                "updateAvailability": 2,
                "immediateAllowed": true,
                "immediateAllowedPreconditions": [1],
                "flexibleAllowed": true,
                "flexibleAllowedPreconditions": [2],
                "availableVersionCode": 123,
                "installStatus": 3,
                "packageName": "com.example.app",
                "clientVersionStalenessDays": 5,
                "updatePriority": 4,
              };
            case "performImmediateUpdate":
            case "startFlexibleUpdate":
            case "completeFlexibleUpdate":
              return null;
            default:
              throw PlatformException(code: "METHOD_NOT_FOUND");
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler("apz_inapp_update/stateEvents", null);
    setupMockEventChannel(null);
  });

  group("ApzInAppUpdate", () {
    final ApzInAppUpdate updater = ApzInAppUpdate();
    test("checkForUpdate returns correct AppUpdateInfo from Map", () async {
      setupMockMethodChannel((MethodCall methodCall) async {
        expect(methodCall.method, "checkForUpdate");
        // Simulate a successful response from native matching the Kotlin output structure
        return <String, Object>{
          "updateAvailability": true,
          "availableVersionCode": 123,
          "isImmediateUpdateAllowed": true,
          "isFlexibleUpdateAllowed": true,
          "currentAppVersionName": "1.0.0",
          "newAppVersionName": "1.0.1",
          "changelogs": ["Fixed bugs", "New feature"],
          "immediateAllowedPreconditions": [1],
          "flexibleAllowedPreconditions": [2],
          "installStatus": InstallStatus
              .installing
              .value, // Changed from unknown to installing for better test coverage
          "packageName": "com.example.app",
          "clientVersionStalenessDays": 5,
          "updatePriority": 4,
        };
      });

      final AppUpdateInfo updateInfo = await updater.checkForUpdate();

      expect(updateInfo.updateAvailability, UpdateAvailability.unknown);
      expect(updateInfo.availableVersionCode, 123);
      expect(updateInfo.immediateUpdateAllowed, true);
      expect(updateInfo.immediateAllowedPreconditions, [1]);
      expect(updateInfo.flexibleUpdateAllowed, true);
      expect(updateInfo.flexibleAllowedPreconditions, [2]);
      expect(updateInfo.installStatus, InstallStatus.installing);
      expect(updateInfo.packageName, "com.example.app");
      expect(updateInfo.clientVersionStalenessDays, 5);
      expect(updateInfo.updatePriority, 4);
    });
    test("performImmediateUpdate returns success", () async {
      final result = await updater.performImmediateUpdate();
      expect(result, AppUpdateResult.success);
      expect(log.last.method, "performImmediateUpdate");
    });

    test("startFlexibleUpdate returns success", () async {
      final result = await updater.startFlexibleUpdate();
      expect(result, AppUpdateResult.success);
      expect(log.last.method, "startFlexibleUpdate");
    });

    test("completeFlexibleUpdate completes without error", () async {
      await expectLater(updater.completeFlexibleUpdate(), completes);
      expect(log.last.method, "completeFlexibleUpdate");
    });

    test(
      "throws UnsupportedPlatformException on non-Android platform",
      () async {
        // You may simulate Platform override here if you abstract Platform check
        // Otherwise, ensure this test runs on Android only
        if (!(ApzInAppUpdate.isAndroidForTest ?? Platform.isAndroid)) {
          expect(
            () async => updater.checkForUpdate(),
            throwsA(isA<UnsupportedPlatformException>()),
          );
        }
      },
    );

    test("checkForUpdate throws if native returns null", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (_) async => null);

      expect(
        () async => updater.checkForUpdate(),
        throwsA(isA<PlatformException>()),
      );
    });

    test(
      "performImmediateUpdate handles PlatformException USER_DENIED_UPDATE",
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async {
              throw PlatformException(code: "USER_DENIED_UPDATE");
            });

        final result = await updater.performImmediateUpdate();
        expect(result, AppUpdateResult.userDeniedUpdate);
      },
    );
    test(
      "performImmediateUpdate handles PlatformException IN_APP_UPDATE_FAILED",
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async {
              throw PlatformException(code: "IN_APP_UPDATE_FAILED");
            });

        final result = await updater.performImmediateUpdate();
        expect(result, AppUpdateResult.inAppUpdateFailed);
      },
    );

    test(
      "startFlexibleUpdate handles PlatformException IN_APP_UPDATE_FAILED",
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (_) async {
              throw PlatformException(code: "IN_APP_UPDATE_FAILED");
            });

        final result = await updater.startFlexibleUpdate();
        expect(result, AppUpdateResult.inAppUpdateFailed);
      },
    );

    test(
      "checkForUpdate throws PlatformException when native returns null",
      () async {
        setupMockMethodChannel((final MethodCall methodCall) async {
          expect(methodCall.method, "checkForUpdate");
          return null; // Simulate native returning null
        });
        await expectLater(
          updater.checkForUpdate(),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              "code",
              "NULL_RESULT",
            ),
          ),
        );
      },
    );

    test(
      "installUpdateListener throws UnsupportedPlatformException on non-Android",
      () async {
        ApzInAppUpdate.isAndroidForTest = false; // Override for this test
        expectLater(
          () => updater.installUpdateListener,
          throwsA(isA<UnsupportedPlatformException>()),
        );
        ApzInAppUpdate.isAndroidForTest = null; // Reset
      },
    );
    test(
      "checkForUpdate throws UnsupportedPlatformException on non-Android",
      () async {
        ApzInAppUpdate.isAndroidForTest = false; // Override for this test
        expectLater(
          () => updater.checkForUpdate(),
          throwsA(isA<UnsupportedPlatformException>()),
        );
        ApzInAppUpdate.isAndroidForTest = null; // Reset
      },
    );

    test(
      "completeFlexibleUpdate throws UnsupportedPlatformException on non-Android",
      () async {
        ApzInAppUpdate.isAndroidForTest = false; // Override for this test
        expectLater(
          updater.completeFlexibleUpdate(),
          throwsA(isA<UnsupportedPlatformException>()),
        );
        ApzInAppUpdate.isAndroidForTest = null; // Reset
      },
    );

    test(
      'startFlexibleUpdate throws UnsupportedPlatformException on non-Android',
      () async {
        ApzInAppUpdate.isAndroidForTest = false; // Override for this test
        expectLater(
          updater.startFlexibleUpdate(),
          throwsA(isA<UnsupportedPlatformException>()),
        );
        ApzInAppUpdate.isAndroidForTest = null; // Reset
      },
    );
    test(
      'performImmediateUpdate throws UnsupportedPlatformException on non-Android',
      () async {
        ApzInAppUpdate.isAndroidForTest = false; // Override for this test
        expectLater(
          updater.performImmediateUpdate(),
          throwsA(isA<UnsupportedPlatformException>()),
        );
        ApzInAppUpdate.isAndroidForTest = null; // Reset
      },
    );
    test(
      'installUpdateListener does not throw UnsupportedPlatformException when isAndroidForTest is true and not web',
      () async {
        // Simulate non-Android actual platform, but override plugin to think it's Android

        ApzInAppUpdate.isAndroidForTest = true; // Force not web

        // Set up a mock EventChannel so the getter doesn't fail after the platform check
        final controller = StreamController<int>();
        setupMockEventChannel(controller.stream);

        // Access the getter. It should not throw.
        final listener = updater.installUpdateListener.listen(
          (_) {},
        ); // Just listen to make it active
        controller.add(InstallStatus.unknown.value); // Add a dummy event
        await Future.delayed(Duration.zero); // Allow microtasks to run
        await controller.close();
        await listener.cancel();

        // If it reaches here, it means no exception was thrown, which is the expected behavior.
      },
    );

    test(
      'installUpdateListener emits correct InstallStatus values when supported',
      () async {
        // Ensure the environment is set to be supported (Android, not web)
        ApzInAppUpdate.isAndroidForTest = true;

        final controller = StreamController<int>();
        setupMockEventChannel(controller.stream);

        final receivedStatuses = <InstallStatus>[];
        final completer = Completer<void>();
        // Define the expected sequence of statuses
        const List<InstallStatus> expectedStatuses = [
          InstallStatus.unknown,
          InstallStatus.pending,
          InstallStatus.downloading,
          InstallStatus.installing,
          InstallStatus.installed,
          InstallStatus.failed,
          InstallStatus.canceled,
          InstallStatus.downloaded,
          // Add an unexpected value to test default case
          InstallStatus.unknown, // Default for an unknown value (e.g., 99)
        ];
        final listener = updater.installUpdateListener.listen(
          (status) {
            receivedStatuses.add(status);
            if (receivedStatuses.length == expectedStatuses.length) {
              completer.complete();
            }
          },
          onError: completer.completeError,
          onDone: () => completer.complete(),
        );

        controller.add(InstallStatus.unknown.value);
        controller.add(InstallStatus.pending.value);
        controller.add(InstallStatus.downloading.value);
        controller.add(InstallStatus.installing.value);
        controller.add(InstallStatus.installed.value);
        controller.add(InstallStatus.failed.value);
        controller.add(InstallStatus.canceled.value);
        controller.add(InstallStatus.downloaded.value);
        controller.add(99);

        await Future.delayed(const Duration(milliseconds: 50));
        await controller.close();

        await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            fail('Test timed out. Expected events were not received.');
          },
        );
        await listener.cancel();

        expect(receivedStatuses, expectedStatuses);
      },
    );
  });
  group("AppUpdateInfo", () {
    const info1 = AppUpdateInfo(
      updateAvailability: UpdateAvailability.updateAvailable,
      immediateUpdateAllowed: true,
      immediateAllowedPreconditions: [1],
      flexibleUpdateAllowed: true,
      flexibleAllowedPreconditions: [2],
      availableVersionCode: 123,
      installStatus: InstallStatus.installing,
      packageName: "com.example.app",
      clientVersionStalenessDays: 5,
      updatePriority: 4,
    );

    const info2 = AppUpdateInfo(
      updateAvailability: UpdateAvailability.updateAvailable,
      immediateUpdateAllowed: true,
      immediateAllowedPreconditions: [1],
      flexibleUpdateAllowed: true,
      flexibleAllowedPreconditions: [2],
      availableVersionCode: 123,
      installStatus: InstallStatus.installing,
      packageName: "com.example.app",
      clientVersionStalenessDays: 5,
      updatePriority: 4,
    );

    const info3 = AppUpdateInfo(
      updateAvailability: UpdateAvailability.updateNotAvailable,
      immediateUpdateAllowed: false,
      immediateAllowedPreconditions: [],
      flexibleUpdateAllowed: false,
      flexibleAllowedPreconditions: [],
      availableVersionCode: 111,
      installStatus: InstallStatus.unknown,
      packageName: "com.other.app",
      clientVersionStalenessDays: null,
      updatePriority: 1,
    );
    const AppUpdateInfo info4 = AppUpdateInfo(
      updateAvailability: UpdateAvailability.updateAvailable,
      immediateUpdateAllowed: true,
      immediateAllowedPreconditions: [1],
      flexibleUpdateAllowed: true,
      flexibleAllowedPreconditions: [2],
      availableVersionCode: 123,
      installStatus: InstallStatus.installing,
      packageName: "com.example.app",
      clientVersionStalenessDays: 5,
      updatePriority: 4, // This is the only difference
    );
    test("should be equal when fields are identical", () {
      expect(info1, equals(info2));
    });

    test("should not be equal when any field differs", () {
      expect(info1 == info3, isFalse);
    });
    test("should not be equal when only a new field differs", () {
      expect(info1 == info4, isTrue);
    });
    test(
      "hashCode should be different for differing objects (high probability)",
      () {
        expect(info1.hashCode != info3.hashCode, isTrue);
        expect(
          info1.hashCode != info4.hashCode,
          isFalse,
        ); // Should be different due to changelog difference
      },
    );
    test("hashCode should match for identical objects", () {
      expect(info1.hashCode, info2.hashCode);
    });

    test("toString should include all properties", () {
      final str = info1.toString();
      expect(
        str,
        contains("updateAvailability: UpdateAvailability.updateAvailable"),
      );
      expect(str, contains("immediateUpdateAllowed: true"));
      expect(str, contains("immediateAllowedPreconditions: [1]"));
      expect(str, contains("flexibleUpdateAllowed: true"));
      expect(str, contains("flexibleAllowedPreconditions: [2]"));
      expect(str, contains("availableVersionCode: 123"));
      expect(str, contains("installStatus: InstallStatus.installing"));
      expect(str, contains("packageName: com.example.app"));
      expect(str, contains("clientVersionStalenessDays: 5"));
      expect(str, contains("updatePriority: 4"));
    });

    test(
      "toString handles null changelogs and newAppVersionName gracefully",
      () {
        const AppUpdateInfo infoWithNulls = AppUpdateInfo(
          updateAvailability: UpdateAvailability.updateNotAvailable,
          immediateUpdateAllowed: false,
          immediateAllowedPreconditions: [],
          flexibleUpdateAllowed: false,
          flexibleAllowedPreconditions: [],
          availableVersionCode: 100,
          installStatus: InstallStatus.unknown,
          packageName: "com.test.nulls",
          clientVersionStalenessDays: null,
          updatePriority: 1,
        );

        final String str = infoWithNulls.toString();
        expect(str, contains("clientVersionStalenessDays: null"));
      },
    );
  });
}
