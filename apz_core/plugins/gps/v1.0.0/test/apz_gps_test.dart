import 'package:apz_gps/apz_gps.dart';
import 'package:apz_gps/location_exception.dart';
import 'package:apz_gps/location_model.dart';
import 'package:apz_utils/apz_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPosition extends Mock implements Position {}

class MockGeolocator extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

class MockPermissionHandlerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApzGPS gps;
  late MockGeolocator mockGeolocator;
  late MockPermissionHandlerPlatform mockPermissionHandler;
  late MockPosition mockPosition;
  late DateTime testTimestamp;

  setUp(() {
    mockGeolocator = MockGeolocator();
    mockPermissionHandler = MockPermissionHandlerPlatform();
    mockPosition = MockPosition();
    testTimestamp = DateTime.now();
    gps = ApzGPS();

    // Setup mock position values
    when(() => mockPosition.latitude).thenReturn(37.4219999);
    when(() => mockPosition.longitude).thenReturn(-122.0840575);
    when(() => mockPosition.timestamp).thenReturn(testTimestamp);
    when(() => mockPosition.accuracy).thenReturn(5.0);
    when(() => mockPosition.altitude).thenReturn(0.0);
    when(() => mockPosition.heading).thenReturn(0.0);
    when(() => mockPosition.speed).thenReturn(0.0);
    when(() => mockPosition.speedAccuracy).thenReturn(0.0);
    when(() => mockPosition.altitudeAccuracy).thenReturn(0.0);
    when(() => mockPosition.headingAccuracy).thenReturn(0.0);

    // Register mock implementations
    GeolocatorPlatform.instance = mockGeolocator;
    PermissionHandlerPlatform.instance = mockPermissionHandler;

    // Default mock responses
    when(
      () => mockPermissionHandler.requestPermissions(any()),
    ).thenAnswer((_) async => {Permission.location: PermissionStatus.granted});
    when(
      () => mockGeolocator.isLocationServiceEnabled(),
    ).thenAnswer((_) async => true);
    when(
      () => mockGeolocator.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) async => mockPosition);
  });

  group('ApzGPS - getCurrentLocation', () {
    test(
      'returns location when permissions granted and services enabled',
      () async {
        // Act
        final result = await gps.getCurrentLocation();

        // Assert
        expect(result, isA<LocationModel>());
        expect(result.latitude, equals(37.4219999));
        expect(result.longitude, equals(-122.0840575));
        expect(result.timestamp, equals(testTimestamp));
        expect(result.accuracy, equals(5.0));
        expect(result.altitude, equals(0.0));
        expect(result.speed, equals(0.0));
      },
    );

    test(
      'throws LocationException when location services are disabled',
      () async {
        // Arrange
        when(
          () => mockGeolocator.isLocationServiceEnabled(),
        ).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => gps.getCurrentLocation(),
          throwsA(
            predicate(
              (e) =>
                  e is LocationException &&
                  e.message ==
                      "Location services are disabled. Please enable them in settings.",
            ),
          ),
        );
      },
    );

    test(
      'throws PermissionException when location permission is denied',
      () async {
        // Arrange
        when(
          () => mockPermissionHandler.requestPermissions([Permission.location]),
        ).thenAnswer(
          (_) async => {Permission.location: PermissionStatus.denied},
        );

        // Act & Assert
        expect(
          () => gps.getCurrentLocation(),
          throwsA(
            predicate(
              (e) =>
                  e is PermissionException &&
                  e.status == PermissionsExceptionStatus.denied,
            ),
          ),
        );
      },
    );

    test(
      'throws PermissionException when location permission is permanently denied',
      () async {
        // Arrange
        when(
          () => mockPermissionHandler.requestPermissions([Permission.location]),
        ).thenAnswer(
          (_) async => {
            Permission.location: PermissionStatus.permanentlyDenied,
          },
        );

        // Act & Assert
        expect(
          () => gps.getCurrentLocation(),
          throwsA(
            predicate(
              (e) =>
                  e is PermissionException &&
                  e.status == PermissionsExceptionStatus.permanentlyDenied,
            ),
          ),
        );
      },
    );

    test(
      'throws LocationException when Geolocator throws an exception',
      () async {
        // Arrange
        when(
          () => mockGeolocator.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          ),
        ).thenThrow(Exception('GPS hardware failure'));

        // Act & Assert
        expect(
          () => gps.getCurrentLocation(),
          throwsA(
            predicate(
              (e) =>
                  e is LocationException &&
                  e.message.contains('Failed to get location'),
            ),
          ),
        );
      },
    );

    test('handles position with different coordinate values', () async {
      // Arrange
      when(() => mockPosition.latitude).thenReturn(-34.6037);
      when(() => mockPosition.longitude).thenReturn(-58.3816);
      when(() => mockPosition.altitude).thenReturn(25.0);
      when(() => mockPosition.speed).thenReturn(10.5);
      when(() => mockPosition.accuracy).thenReturn(3.2);

      // Act
      final result = await gps.getCurrentLocation();

      // Assert
      expect(result.latitude, equals(-34.6037));
      expect(result.longitude, equals(-58.3816));
      expect(result.altitude, equals(25.0));
      expect(result.speed, equals(10.5));
      expect(result.accuracy, equals(3.2));
    });

    test('verifies location data mapping integrity', () async {
      // Act
      final result = await gps.getCurrentLocation();

      // Assert - ensure all position properties are correctly mapped
      expect(result.latitude, equals(mockPosition.latitude));
      expect(result.longitude, equals(mockPosition.longitude));
      expect(result.accuracy, equals(mockPosition.accuracy));
      expect(result.altitude, equals(mockPosition.altitude));
      expect(result.speed, equals(mockPosition.speed));
      expect(result.timestamp, equals(mockPosition.timestamp));
    });

    test('handles restricted permission status', () async {
      // Arrange
      when(
        () => mockPermissionHandler.requestPermissions([Permission.location]),
      ).thenAnswer(
        (_) async => {Permission.location: PermissionStatus.restricted},
      );

      // Act & Assert
      expect(
        () => gps.getCurrentLocation(),
        throwsA(
          predicate(
            (e) =>
                e is PermissionException &&
                e.status == PermissionsExceptionStatus.restricted,
          ),
        ),
      );
    });
  });

  group('ApzGPS - Error Handling', () {
    test('handles permission request failure', () async {
      // Arrange
      when(
        () => mockPermissionHandler.requestPermissions([Permission.location]),
      ).thenThrow(Exception('Permission system error'));

      // Act & Assert
      expect(() => gps.getCurrentLocation(), throwsA(isA<Exception>()));
    });

    test('handles location service check failure', () async {
      // Arrange
      when(
        () => mockGeolocator.isLocationServiceEnabled(),
      ).thenThrow(Exception('Service check failed'));

      // Act & Assert
      expect(() => gps.getCurrentLocation(), throwsA(isA<Exception>()));
    });
  });
}
