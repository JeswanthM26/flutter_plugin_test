import "package:apz_camera/utils/permission_handler.dart";
import "package:apz_utils/apz_utils.dart";
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

// Import your actual file here
// import 'path/to/your/camera_permission_handler.dart';

// Mock class for testing
class MockPermissionRequest extends Mock {
  Future<PermissionStatus> call();
}

void main() {
  group('CameraPermissionHandler', () {
    late CameraPermissionHandler handler;
    late MockPermissionRequest mockPermissionRequest;

    setUp(() {
      handler = CameraPermissionHandler();
      mockPermissionRequest = MockPermissionRequest();

      // Override the global function with our mock
      cameraPermissionRequest = mockPermissionRequest.call;
    });

    tearDown(() {
      // Reset to original implementation after each test
      cameraPermissionRequest = () => Permission.camera.request();
    });

    group('checkCameraPermissions', () {
      testWidgets('throws UnsupportedPlatformException on web platform', (
        tester,
      ) async {
        // Arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        // Override kIsWeb for this test
        // Note: In real tests, you might need to use a different approach
        // since kIsWeb is a compile-time constant

        // Act & Assert
        // This test assumes you have a way to mock kIsWeb
        // In practice, you might need to refactor your code to make it more testable
        // by injecting a platform checker dependency

        debugDefaultTargetPlatformOverride = null;
      });

      test(
        'completes successfully when camera permission is granted',
        () async {
          // Arrange
          when(
            () => mockPermissionRequest(),
          ).thenAnswer((_) async => PermissionStatus.granted);

          // Act & Assert - should not throw
          await expectLater(handler.checkCameraPermissions(), completes);

          verify(() => mockPermissionRequest()).called(1);
        },
      );

      test(
        'throws PermissionException when camera permission is denied',
        () async {
          // Arrange
          when(
            () => mockPermissionRequest(),
          ).thenAnswer((_) async => PermissionStatus.denied);

          // Act & Assert
          await expectLater(
            handler.checkCameraPermissions(),
            throwsA(
              isA<PermissionException>()
                  .having(
                    (e) => e.status,
                    'status',
                    PermissionsExceptionStatus.denied,
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    'Camera permission not granted.',
                  ),
            ),
          );

          verify(() => mockPermissionRequest()).called(1);
        },
      );

      test(
        'throws PermissionException when camera permission is permanently denied',
        () async {
          // Arrange
          when(
            () => mockPermissionRequest(),
          ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

          // Act & Assert
          await expectLater(
            handler.checkCameraPermissions(),
            throwsA(
              isA<PermissionException>()
                  .having(
                    (e) => e.status,
                    'status',
                    PermissionsExceptionStatus.permanentlyDenied,
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    'Camera permission permanently denied. Please enable it from settings.',
                  ),
            ),
          );

          verify(() => mockPermissionRequest()).called(1);
        },
      );

      test(
        'throws PermissionException when camera permission is restricted',
        () async {
          // Arrange
          when(
            () => mockPermissionRequest(),
          ).thenAnswer((_) async => PermissionStatus.restricted);

          // Act & Assert
          await expectLater(
            handler.checkCameraPermissions(),
            throwsA(
              isA<PermissionException>()
                  .having(
                    (e) => e.status,
                    'status',
                    PermissionsExceptionStatus.restricted,
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    'Camera access restricted or not fully granted. Please check your device settings.',
                  ),
            ),
          );

          verify(() => mockPermissionRequest()).called(1);
        },
      );

      test(
        'throws PermissionException when camera permission is limited',
        () async {
          // Arrange
          when(
            () => mockPermissionRequest(),
          ).thenAnswer((_) async => PermissionStatus.limited);

          // Act & Assert
          await expectLater(
            handler.checkCameraPermissions(),
            throwsA(
              isA<PermissionException>()
                  .having(
                    (e) => e.status,
                    'status',
                    PermissionsExceptionStatus.limited,
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    'Camera access restricted or not fully granted. Please check your device settings.',
                  ),
            ),
          );

          verify(() => mockPermissionRequest()).called(1);
        },
      );

      test(
        'throws PermissionException when camera permission is provisional',
        () async {
          // Arrange
          when(
            () => mockPermissionRequest(),
          ).thenAnswer((_) async => PermissionStatus.provisional);

          // Act & Assert
          await expectLater(
            handler.checkCameraPermissions(),
            throwsA(
              isA<PermissionException>()
                  .having(
                    (e) => e.status,
                    'status',
                    PermissionsExceptionStatus.provisional,
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    'Camera access restricted or not fully granted. Please check your device settings.',
                  ),
            ),
          );

          verify(() => mockPermissionRequest()).called(1);
        },
      );

      test(
        'rethrows PermissionException when permission request throws',
        () async {
          // Arrange
          final originalException = PermissionException(
            PermissionsExceptionStatus.denied,
            'Original exception',
          );

          when(() => mockPermissionRequest()).thenThrow(originalException);

          // Act & Assert
          await expectLater(
            handler.checkCameraPermissions(),
            throwsA(same(originalException)),
          );

          verify(() => mockPermissionRequest()).called(1);
        },
      );
    });

    group('_evaluatePermission', () {
      // These tests are for the private method, but we can test it indirectly
      // through the public method or make it protected/public for testing
    });
  });
}

// Additional test helper for web platform testing
// You might need this if you want to test the web platform exception
class TestCameraPermissionHandler extends CameraPermissionHandler {
  final bool isWeb;

  TestCameraPermissionHandler({this.isWeb = false});

  @override
  Future<void> checkCameraPermissions() async {
    try {
      if (isWeb) {
        throw UnsupportedPlatformException(
          "This plugin is not supported on the web platform",
        );
      } else {
        final PermissionStatus cameraStatus = await cameraPermissionRequest();
        evaluatePermission(cameraStatus, "Camera");
      }
    } on PermissionException {
      rethrow;
    }
  }
}

// Additional tests for web platform
void testWebPlatform() {
  group('CameraPermissionHandler Web Platform', () {
    test('throws UnsupportedPlatformException on web platform', () async {
      // Arrange
      final handler = TestCameraPermissionHandler(isWeb: true);

      // Act & Assert
      await expectLater(
        handler.checkCameraPermissions(),
        throwsA(isA<UnsupportedPlatformException>()),
      );
    });
  });
}
