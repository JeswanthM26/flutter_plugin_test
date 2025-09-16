// Import both the original service and our testable wrapper
import "package:apz_camera/services/camera_service.dart";
import "package:apz_camera/utils/permission_handler.dart";
import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "testable_camera_service.dart"; // Adjust path as needed

// Mock classes using Mocktail
class MockCameraPermissionHandler extends Mock
    implements CameraPermissionHandler {}

class MockCameraController extends Mock implements CameraController {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group("CameraService", () {
    late TestableCameraService cameraService;
    late MockCameraPermissionHandler mockPermissionHandler;
    late List<CameraDescription> mockCameras;

    setUpAll(() {
      // Register fallback values for Mocktail
      registerFallbackValue(MockBuildContext());
    });

    setUp(() {
      mockPermissionHandler = MockCameraPermissionHandler();

      // Setup mock cameras
      mockCameras = [
        const CameraDescription(
          name: "back_camera",
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
        const CameraDescription(
          name: "front_camera",
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 270,
        ),
      ];

      // Create TestableCameraService with mocked dependencies
      cameraService = TestableCameraService(
        permissionHandlerFactory: () => mockPermissionHandler,
        availableCamerasFunction: () async => mockCameras,
      );

      // Setup default behavior for permission handler
      when(
        () => mockPermissionHandler.checkCameraPermissions(),
      ).thenAnswer((_) async {});
    });

    tearDown(() {
      reset(mockPermissionHandler);
    });
    group("dispose", () {
      test("should dispose camera controller when available", () async {
        // Arrange
        final mockController = MockCameraController();
        when(() => mockController.dispose()).thenAnswer((_) async {});

        cameraService.mockCameraDisc(mockCameras, mockController);

        // Act
        await cameraService.dispose();

        // Assert
        verify(() => mockController.dispose()).called(1);
      });

      test("should handle dispose when controller is null", () async {
        // Arrange
        cameraService.mockCameraDisc(mockCameras, null);

        // Act & Assert - Should not throw
        await expectLater(cameraService.dispose(), completes);
      });
    });

    group("mockCameraDisc", () {
      test("should set cameras and controller for testing", () {
        // Arrange
        final mockController = MockCameraController();

        // Act & Assert
        expect(
          () => cameraService.mockCameraDisc(mockCameras, mockController),
          returnsNormally,
        );
      });
    });

    group("inheritance behavior", () {
      test("should inherit all parent class functionality", () {
        // Test that TestableCameraService is indeed a CameraService
        expect(cameraService, isA<CameraService>());
        expect(cameraService, isA<TestableCameraService>());
      });

      test("should allow testing without mocked dependencies", () {
        // Create service without any mocks to test fallback to original behavior
        final serviceWithoutMocks = TestableCameraService();
        expect(serviceWithoutMocks, isNotNull);
        expect(serviceWithoutMocks, isA<CameraService>());
      });
    });

    group("Original CameraService Integration", () {
      // Test that the wrapper doesn't break the original service usage
      test(
        "should not affect original CameraService when not using wrapper",
        () {
          final originalService = CameraService();
          expect(originalService, isNotNull);
          expect(originalService, isA<CameraService>());
          expect(originalService, isNot(isA<TestableCameraService>()));
        },
      );
    });
  });
}

// import "package:apz_camera/models/camera_capture_params.dart";
// import "package:apz_camera/services/camera_service.dart";
// import "package:apz_camera/utils/permission_handler.dart";
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class MockCameraController extends Mock implements CameraController {}

// class FakeCameraDescription extends Fake implements CameraDescription {}

// class MockPermissionHandler extends Mock implements CameraPermissionHandler {}

// void main() {
//   // Save originals to restore in tearDown
//   final _origAvailableCameras = availableCamerasFunction;
//   final _origPermissionFactory = cameraPermissionHandlerFactory;
//   final _origPreviewBuilder = cameraPreviewBuilder;
//   final _origNavigatorPush = navigatorPush;

//   setUpAll(() {
//     registerFallbackValue(FakeCameraDescription());
//   });

//   tearDown(() {
//     // Restore defaults so other tests aren't affected
//     availableCamerasFunction = _origAvailableCameras;
//     cameraPermissionHandlerFactory = _origPermissionFactory;
//     cameraPreviewBuilder = _origPreviewBuilder;
//     navigatorPush = _origNavigatorPush;
//   });

//   group('CameraService unit tests', () {
//     test(
//       'dispose calls CameraController.dispose when controller is set',
//       () async {
//         final service = CameraService();
//         final mockController = MockCameraController();

//         when(() => mockController.dispose()).thenAnswer((_) async {});

//         service.mockCameraDisc([FakeCameraDescription()], mockController);

//         await service.dispose();

//         verify(() => mockController.dispose()).called(1);
//       },
//     );

//     test('dispose does not throw when controller is null', () async {
//       final service = CameraService();

//       service.mockCameraDisc([FakeCameraDescription()], null);

//       await service.dispose();
//     });
//   });
// }
