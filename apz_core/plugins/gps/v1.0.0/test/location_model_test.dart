import 'package:apz_gps/location_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocationModel testLocation;
  late DateTime testTimestamp;

  setUp(() {
    testTimestamp = DateTime.now();
    testLocation = LocationModel(
      latitude: 37.4219999,
      longitude: -122.0840575,
      accuracy: 5.0,
      altitude: 0.0,
      speed: 0.0,
      timestamp: testTimestamp,
    );
  });

  group('LocationModel - Constructor', () {
    test('creates instance with required parameters', () {
      expect(testLocation.latitude, closeTo(37.4219999, 0.000001));
      expect(testLocation.longitude, closeTo(-122.0840575, 0.000001));
      expect(testLocation.accuracy, closeTo(5.0, 0.001));
      expect(testLocation.altitude, closeTo(0.0, 0.001));
      expect(testLocation.speed, closeTo(0.0, 0.001));
      expect(testLocation.timestamp, testTimestamp);
    });

    test('creates instance with null timestamp', () {
      final location = LocationModel(
        latitude: 37.4219999,
        longitude: -122.0840575,
        accuracy: 5.0,
        altitude: 0.0,
        speed: 0.0,
        timestamp: null,
      );

      expect(location.timestamp, isNull);
      expect(location.latitude, equals(37.4219999));
    });

    test('creates instance with negative coordinates', () {
      final location = LocationModel(
        latitude: -34.6037,
        longitude: -58.3816,
        accuracy: 3.0,
        altitude: -10.0,
        speed: 0.0,
      );

      expect(location.latitude, equals(-34.6037));
      expect(location.longitude, equals(-58.3816));
      expect(location.altitude, equals(-10.0));
    });

    test('creates instance with zero values', () {
      final location = LocationModel(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 0.0,
        altitude: 0.0,
        speed: 0.0,
      );

      expect(location.latitude, equals(0.0));
      expect(location.longitude, equals(0.0));
      expect(location.accuracy, equals(0.0));
      expect(location.altitude, equals(0.0));
      expect(location.speed, equals(0.0));
    });
  });

  group('LocationModel - toMap', () {
    test('converts to map correctly', () {
      final map = testLocation.toMap();

      expect(map['latitude'], closeTo(37.4219999, 0.000001));
      expect(map['longitude'], closeTo(-122.0840575, 0.000001));
      expect(map['accuracy'], closeTo(5.0, 0.001));
      expect(map['altitude'], closeTo(0.0, 0.001));
      expect(map['speed'], closeTo(0.0, 0.001));
      expect(map['timestamp'], testTimestamp.toIso8601String());
    });

    test('converts to map with null timestamp', () {
      final location = LocationModel(
        latitude: 37.4219999,
        longitude: -122.0840575,
        accuracy: 5.0,
        altitude: 0.0,
        speed: 0.0,
        timestamp: null,
      );

      final map = location.toMap();
      expect(map['timestamp'], isNull);
      expect(map['latitude'], equals(37.4219999));
    });

    test('map contains all required keys', () {
      final map = testLocation.toMap();

      expect(map.containsKey('latitude'), isTrue);
      expect(map.containsKey('longitude'), isTrue);
      expect(map.containsKey('accuracy'), isTrue);
      expect(map.containsKey('altitude'), isTrue);
      expect(map.containsKey('speed'), isTrue);
      expect(map.containsKey('timestamp'), isTrue);
      expect(map.length, equals(6));
    });
  });

  group('LocationModel - fromMap', () {
    test('creates instance from map', () {
      final map = {
        'latitude': 37.4219999,
        'longitude': -122.0840575,
        'accuracy': 5.0,
        'altitude': 0.0,
        'speed': 0.0,
        'timestamp': testTimestamp.toIso8601String(),
      };

      final location = LocationModel.fromMap(map);

      expect(location.latitude, closeTo(37.4219999, 0.000001));
      expect(location.longitude, closeTo(-122.0840575, 0.000001));
      expect(location.accuracy, closeTo(5.0, 0.001));
      expect(location.altitude, closeTo(0.0, 0.001));
      expect(location.speed, closeTo(0.0, 0.001));
      expect(
        location.timestamp?.toIso8601String(),
        testTimestamp.toIso8601String(),
      );
    });

    test('handles null timestamp in fromMap', () {
      final map = {
        'latitude': 37.4219999,
        'longitude': -122.0840575,
        'accuracy': 5.0,
        'altitude': 0.0,
        'speed': 0.0,
        'timestamp': null,
      };

      final location = LocationModel.fromMap(map);
      expect(location.timestamp, isNull);
      expect(location.latitude, equals(37.4219999));
    });

    test('handles missing timestamp in fromMap', () {
      final map = {
        'latitude': 37.4219999,
        'longitude': -122.0840575,
        'accuracy': 5.0,
        'altitude': 0.0,
        'speed': 0.0,
      };

      final location = LocationModel.fromMap(map);
      expect(location.timestamp, isNull);
    });

    test('handles invalid data types in fromMap', () {
      final map = {
        'latitude': 'invalid',
        'longitude': -122.0840575,
        'accuracy': 5.0,
        'altitude': 0.0,
        'speed': 0.0,
        'timestamp': null,
      };

      expect(() => LocationModel.fromMap(map), throwsA(isA<TypeError>()));
    });

    test('handles missing required data in fromMap', () {
      final map = {
        'latitude': 37.4219999,
        'accuracy': 5.0,
        'altitude': 0.0,
        'speed': 0.0,
      };

      expect(() => LocationModel.fromMap(map), throwsA(isA<TypeError>()));
    });

    test('handles invalid timestamp format', () {
      final map = {
        'latitude': 37.4219999,
        'longitude': -122.0840575,
        'accuracy': 5.0,
        'altitude': 0.0,
        'speed': 0.0,
        'timestamp': 'invalid-date',
      };

      expect(() => LocationModel.fromMap(map), throwsA(isA<FormatException>()));
    });
  });

  group('LocationModel - Data Integrity', () {
    test('toMap and fromMap round-trip conversion', () {
      final map = testLocation.toMap();
      final recreatedLocation = LocationModel.fromMap(map);

      expect(recreatedLocation.latitude, equals(testLocation.latitude));
      expect(recreatedLocation.longitude, equals(testLocation.longitude));
      expect(recreatedLocation.accuracy, equals(testLocation.accuracy));
      expect(recreatedLocation.altitude, equals(testLocation.altitude));
      expect(recreatedLocation.speed, equals(testLocation.speed));
      expect(
        recreatedLocation.timestamp?.toIso8601String(),
        equals(testLocation.timestamp?.toIso8601String()),
      );
    });

    test('handles extreme coordinate values', () {
      final location = LocationModel(
        latitude: 90.0, // Maximum latitude
        longitude: 180.0, // Maximum longitude
        accuracy: 0.1,
        altitude: 8848.86, // Mount Everest height
        speed: 343.0, // Speed of sound in m/s
      );

      expect(location.latitude, equals(90.0));
      expect(location.longitude, equals(180.0));
      expect(location.altitude, equals(8848.86));
      expect(location.speed, equals(343.0));

      // Test round-trip
      final map = location.toMap();
      final recreated = LocationModel.fromMap(map);
      expect(recreated.latitude, equals(90.0));
      expect(recreated.longitude, equals(180.0));
    });

    test('handles minimum coordinate values', () {
      final location = LocationModel(
        latitude: -90.0, // Minimum latitude
        longitude: -180.0, // Minimum longitude
        accuracy: 0.0,
        altitude: -413.0, // Dead Sea level
        speed: 0.0,
      );

      expect(location.latitude, equals(-90.0));
      expect(location.longitude, equals(-180.0));
      expect(location.altitude, equals(-413.0));
    });

    test('handles high precision values', () {
      final location = LocationModel(
        latitude: 37.4219983276782,
        longitude: -122.0840597465753,
        accuracy: 3.14159265359,
        altitude: 2.71828182846,
        speed: 1.41421356237,
      );

      final map = location.toMap();
      final recreated = LocationModel.fromMap(map);

      expect(recreated.latitude, equals(37.4219983276782));
      expect(recreated.longitude, equals(-122.0840597465753));
      expect(recreated.accuracy, equals(3.14159265359));
    });
  });
}
