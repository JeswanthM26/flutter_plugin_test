import 'package:apz_gps/location_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationException', () {
    test('creates exception with message', () {
      const testMessage = 'Test location error';
      final exception = LocationException(testMessage);

      expect(exception, isA<LocationException>());
      expect(exception.message, equals(testMessage));
      expect(exception, isA<Exception>());
    });

    test('toString returns the message', () {
      const testMessage = 'Location service unavailable';
      final exception = LocationException(testMessage);

      expect(exception.toString(), equals(testMessage));
    });

    test('handles empty message', () {
      const emptyMessage = '';
      final exception = LocationException(emptyMessage);

      expect(exception.message, equals(emptyMessage));
      expect(exception.toString(), equals(emptyMessage));
    });

    test('can be thrown and caught', () {
      const testMessage = 'Test exception throwing';

      expect(
        () => throw LocationException(testMessage),
        throwsA(
          predicate((e) => e is LocationException && e.message == testMessage),
        ),
      );
    });

    test('can be caught as Exception', () {
      const testMessage = 'General exception test';

      expect(
        () => throw LocationException(testMessage),
        throwsA(isA<Exception>()),
      );
    });
  });
}
