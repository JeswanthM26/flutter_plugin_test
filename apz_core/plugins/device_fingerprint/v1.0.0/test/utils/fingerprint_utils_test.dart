import 'package:flutter_test/flutter_test.dart';
import 'package:apz_device_fingerprint/utils/fingerprint_utils.dart';
import 'package:apz_gps/apz_gps.dart';
import 'package:apz_gps/location_model.dart';


class MockApzGPS extends ApzGPS {
  final LocationModel? location;
  final bool throwError;
  MockApzGPS({this.location, this.throwError = false});

  @override
  Future<LocationModel> getCurrentLocation() async {
    if (throwError) throw Exception('Location error');
    if (location != null) return location!;
    return LocationModel(
      latitude: 0.0,
      longitude: 0.0,
      accuracy: 1.0,
      altitude: 0.0,
      speed: 0.0,
    );
  }
}

void main() {
  group('FingerprintUtils', () {
    late FingerprintUtils utils;

    setUp(() {
      utils = FingerprintUtils();
    });

    test('generateRandomString returns unique string of expected length', () {
      final str1 = utils.generateRandomString();
      final str2 = utils.generateRandomString();
      expect(str1, isNot(str2));
      expect(str1.length, greaterThan(20));
      expect(str2.length, greaterThan(20));
    });

    test('generateDigest returns a base64 string', () {
      final digest = utils.generateDigest(['a', 'b', 'c']);
      // base64 should only contain valid base64 chars
      final base64Pattern = RegExp(r'^[A-Za-z0-9+/=]+$');
      expect(base64Pattern.hasMatch(digest), isTrue);
      expect(digest, isNotEmpty);
    });

    test('getLatLong returns lat,long string', () async {
      final mockGPS = MockApzGPS(
        location: LocationModel(
          latitude: 12.34,
          longitude: 56.78,
          accuracy: 1.0,
          altitude: 0.0,
          speed: 0.0,
        ),
      );
      utils.setApzGPS(apzGPS: mockGPS);
      final result = await utils.getLatLong();
      expect(result, '12.34,56.78');
    });

    test('getLatLong returns null on exception', () async {
      final mockGPS = MockApzGPS(throwError: true);
      utils.setApzGPS(apzGPS: mockGPS);
      final result = await utils.getLatLong();
      expect(result, isNull);
    });
  });
}
