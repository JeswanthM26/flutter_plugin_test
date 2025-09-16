import 'dart:io';

import 'package:apz_preference/apz_preference.dart';
import "package:flutter/services.dart";
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:apz_utils/src/app_wipeout/wipeout_io.dart';

// Mock classes
class MockApzPreference extends Mock implements ApzPreference {}

class MockDirectory extends Mock implements Directory {}

class MockCacheManager extends Mock implements CacheManager {}

const MethodChannel pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

void setUpPathProviderMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  pathProviderChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getTemporaryDirectory':
        return '/mock_temp_dir';
      case 'getApplicationSupportDirectory':
        return '/mock_app_support_dir';
      default:
        return null;
    }
  });
}

void tearDownPathProviderMocks() {
  pathProviderChannel.setMockMethodCallHandler(null);
}

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockApzPreference mockPrefs;
  late MockDirectory mockTempDir;
  late MockDirectory mockDocDir;
  late MockCacheManager mockCacheManager;
  late WipeoutIo wipeoutIo;

  setUp(() {
    mockPrefs = MockApzPreference();
    mockTempDir = MockDirectory();
    mockDocDir = MockDirectory();
    mockCacheManager = MockCacheManager();

    // Create the WipeoutIo instance with mocks injected
    wipeoutIo = WipeoutIo(
      prefs: mockPrefs,
      getTempDir: () async => mockTempDir,
      getDocDir: () async => mockDocDir,
      cacheManager: mockCacheManager,
    );

    // Register fallback values for Directory since mocktail might need it
    registerFallbackValue(MockDirectory());
  });
  setUpAll(() {
    setUpPathProviderMocks();
  });

  tearDownAll(() {
    tearDownPathProviderMocks();
  });

  group('clearPreferences', () {
    test('calls clearAllData twice with correct parameters', () async {
      when(() => mockPrefs.clearAllData()).thenAnswer((_) async {});
      when(
        () => mockPrefs.clearAllData(isSecure: true),
      ).thenAnswer((_) async {});

      await wipeoutIo.clearPreferences();

      verify(() => mockPrefs.clearAllData()).called(1);
      verify(() => mockPrefs.clearAllData(isSecure: true)).called(1);
    });

    test('throws exception if clearAllData fails', () async {
      when(() => mockPrefs.clearAllData()).thenThrow(Exception('fail'));

      expect(() => wipeoutIo.clearPreferences(), throwsException);
    });
  });

  group('clearFiles', () {
    setUp(() {
      when(() => mockTempDir.existsSync()).thenReturn(true);
      when(() => mockDocDir.existsSync()).thenReturn(true);

      when(
        () => mockTempDir.delete(recursive: true),
      ).thenAnswer((_) async => mockTempDir);
      when(() => mockTempDir.create()).thenAnswer((_) async => mockTempDir);

      when(
        () => mockDocDir.delete(recursive: true),
      ).thenAnswer((_) async => mockDocDir);
      when(() => mockDocDir.create()).thenAnswer((_) async => mockDocDir);
    });

    test('deletes and recreates temp and doc directories', () async {
      when(() => mockTempDir.existsSync()).thenReturn(true);
      when(() => mockDocDir.existsSync()).thenReturn(true);
      when(
        () => mockTempDir.delete(recursive: true),
      ).thenAnswer((_) async => mockTempDir);
      when(
        () => mockDocDir.delete(recursive: true),
      ).thenAnswer((_) async => mockDocDir);
      when(() => mockTempDir.create()).thenAnswer((_) async => mockTempDir);
      when(() => mockDocDir.create()).thenAnswer((_) async => mockDocDir);

      await wipeoutIo.clearFiles();

      verify(() => mockTempDir.delete(recursive: true)).called(1);
      verify(() => mockDocDir.delete(recursive: true)).called(1);
      verify(() => mockTempDir.create()).called(1);
      verify(() => mockDocDir.create()).called(1);
    });
    test('does nothing if directories do not exist', () async {
      when(() => mockTempDir.existsSync()).thenReturn(false);
      when(() => mockDocDir.existsSync()).thenReturn(false);

      await wipeoutIo.clearFiles();

      // These were called once each
      verify(() => mockTempDir.existsSync()).called(1);
      verify(() => mockDocDir.existsSync()).called(1);

      // These were NOT called
      verifyNever(() => mockTempDir.delete(recursive: true));
      verifyNever(() => mockTempDir.create());

      verifyNever(() => mockDocDir.delete(recursive: true));
      verifyNever(() => mockDocDir.create());
    });

    test('skips delete if directory does not exist', () async {
      final mockTempDir = MockDirectory();
      final mockDocDir = MockDirectory();

      when(() => mockTempDir.existsSync()).thenReturn(false);
      when(() => mockDocDir.existsSync()).thenReturn(false);

      final wipeoutIo = WipeoutIo(
        prefs: MockApzPreference(),
        getTempDir: () async => mockTempDir,
        getDocDir: () async => mockDocDir,
      );

      await wipeoutIo.clearFiles();

      verifyNever(() => mockTempDir.delete(recursive: true));
      verifyNever(() => mockDocDir.delete(recursive: true));
    });

    test('throws exception on failure', () async {
      when(() => mockTempDir.existsSync()).thenThrow(Exception('fail'));

      expect(() => wipeoutIo.clearFiles(), throwsException);
    });
  });

  group('clearCache', () {
    test('calls emptyCache on cacheManager', () async {
      when(() => mockCacheManager.emptyCache()).thenAnswer((_) async {});
      await wipeoutIo.clearCache();
      verifyNever(
        () => mockCacheManager.emptyCache(),
      ); // No cache manager was passed, so it should not be called
    });

    test('throws exception if emptyCache fails', () async {
      when(() => mockCacheManager.emptyCache()).thenThrow(Exception('fail'));

      await wipeoutIo.clearCache();
    });
  });
}
