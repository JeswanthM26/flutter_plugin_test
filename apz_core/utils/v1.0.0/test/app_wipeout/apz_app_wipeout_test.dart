import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apz_utils/apz_utils.dart'; // Adjust import
import 'package:apz_utils/src/app_wipeout/wipeout_platform.dart';

class MockWipeoutPlatform extends Mock implements WipeoutPlatform {}

void main() {
  late MockWipeoutPlatform mockPlatform;
  late ApzAppWipeOut wipeOut;

  setUp(() {
    mockPlatform = MockWipeoutPlatform();
    platform = mockPlatform; // override global platform
    wipeOut = ApzAppWipeOut();
  });

  test('calls all wipeout methods successfully', () async {
    when(() => mockPlatform.clearPreferences()).thenAnswer((_) async {});
    when(() => mockPlatform.clearFiles()).thenAnswer((_) async {});
    when(() => mockPlatform.clearCache()).thenAnswer((_) async {});

    await wipeOut.wipeAllData();

    verify(() => mockPlatform.clearPreferences()).called(1);
    verify(() => mockPlatform.clearFiles()).called(1);
    verify(() => mockPlatform.clearCache()).called(1);
  });

  test('throws if clearPreferences fails but runs all methods', () async {
    when(() => mockPlatform.clearPreferences()).thenThrow(Exception('prefs fail'));
    when(() => mockPlatform.clearFiles()).thenAnswer((_) async {});
    when(() => mockPlatform.clearCache()).thenAnswer((_) async {});

    await expectLater(wipeOut.wipeAllData(), throwsException);

    verify(() => mockPlatform.clearPreferences()).called(1);
    verify(() => mockPlatform.clearFiles()).called(1); // ✅ was still called
    verify(() => mockPlatform.clearCache()).called(1); // ✅ was still called
  });

  test('throws if clearFiles fails but runs all methods', () async {
    when(() => mockPlatform.clearPreferences()).thenAnswer((_) async {});
    when(() => mockPlatform.clearFiles()).thenThrow(Exception('files fail'));
    when(() => mockPlatform.clearCache()).thenAnswer((_) async {});

    await expectLater(wipeOut.wipeAllData(), throwsException);

    verify(() => mockPlatform.clearPreferences()).called(1);
    verify(() => mockPlatform.clearFiles()).called(1);
    verify(() => mockPlatform.clearCache()).called(1);
  });

  test('throws if clearCache fails but runs all methods', () async {
    when(() => mockPlatform.clearPreferences()).thenAnswer((_) async {});
    when(() => mockPlatform.clearFiles()).thenAnswer((_) async {});
    when(() => mockPlatform.clearCache()).thenThrow(Exception('cache fail'));

    await expectLater(wipeOut.wipeAllData(), throwsException);

    verify(() => mockPlatform.clearPreferences()).called(1);
    verify(() => mockPlatform.clearFiles()).called(1);
    verify(() => mockPlatform.clearCache()).called(1);
  });

  test('throws aggregated exception if multiple methods fail', () async {
    when(() => mockPlatform.clearPreferences()).thenThrow(Exception('prefs fail'));
    when(() => mockPlatform.clearFiles()).thenThrow(Exception('files fail'));
    when(() => mockPlatform.clearCache()).thenThrow(Exception('cache fail'));

   await expectLater(
      () => wipeOut.wipeAllData(),
      throwsA(isA<Exception>()),
    );

    verify(() => mockPlatform.clearPreferences()).called(1);
    verify(() => mockPlatform.clearFiles()).called(1);
    verify(() => mockPlatform.clearCache()).called(1);
  });
}
