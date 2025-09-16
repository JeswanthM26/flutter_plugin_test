import "package:apz_preference/apz_preference.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart";
import "fake_shared_preferences_async.dart";

// Mock classes
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApzPreference prefs;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockSharedPreferencesAsync mockSharedPrefs;

  setUp(() {
    // Register fallback values for any() matcher
    registerFallbackValue("");
    registerFallbackValue(<String>[]);

    // Set up mocks
    mockSecureStorage = MockFlutterSecureStorage();
    mockSharedPrefs = MockSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = FakeSharedPreferencesAsync();

    // Set up default mock behaviors
    when(() => mockSharedPrefs.getString(any())).thenAnswer((_) async => null);
    when(() => mockSharedPrefs.getInt(any())).thenAnswer((_) async => null);
    when(() => mockSharedPrefs.getBool(any())).thenAnswer((_) async => null);
    when(() => mockSharedPrefs.getDouble(any())).thenAnswer((_) async => null);
    when(
      () => mockSharedPrefs.getStringList(any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockSharedPrefs.setString(any(), any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockSharedPrefs.setInt(any(), any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockSharedPrefs.setBool(any(), any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockSharedPrefs.setDouble(any(), any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockSharedPrefs.setStringList(any(), any()),
    ).thenAnswer((_) async => true);
    when(() => mockSharedPrefs.remove(any())).thenAnswer((_) async => true);
    when(() => mockSharedPrefs.clear()).thenAnswer((_) async => true);

    // Create singleton instance and set mocks
    prefs = ApzPreference()
      ..setMocks(
        mockSharedPrefs: mockSharedPrefs,
        mockSecureStorage: mockSecureStorage,
      );
  });

  group("Non-secure storage tests", () {
    test("should save and retrieve String value", () async {
      const String key = "testString";
      const String value = "test value";

      when(
        () => mockSharedPrefs.setString(key, value),
      ).thenAnswer((_) async => true);
      when(() => mockSharedPrefs.getString(key)).thenAnswer((_) async => value);

      await prefs.saveData(key, value);
      final String? result = await prefs.getData(key, String) as String?;

      verify(() => mockSharedPrefs.setString(key, value)).called(1);
      verify(() => mockSharedPrefs.getString(key)).called(1);
      expect(result, equals(value));
    });

    test("should save and retrieve int value", () async {
      const String key = "testInt";
      const int value = 42;

      when(
        () => mockSharedPrefs.setInt(key, value),
      ).thenAnswer((_) async => true);
      when(() => mockSharedPrefs.getInt(key)).thenAnswer((_) async => value);

      await prefs.saveData(key, value);
      final int? result = await prefs.getData(key, int) as int?;

      verify(() => mockSharedPrefs.setInt(key, value)).called(1);
      verify(() => mockSharedPrefs.getInt(key)).called(1);
      expect(result, equals(value));
    });

    test("should save and retrieve bool value", () async {
      const String key = "testBool";
      const bool value = true;

      when(
        () => mockSharedPrefs.setBool(key, value),
      ).thenAnswer((_) async => true);
      when(() => mockSharedPrefs.getBool(key)).thenAnswer((_) async => value);

      await prefs.saveData(key, value);
      final bool? result = await prefs.getData(key, bool) as bool?;

      verify(() => mockSharedPrefs.setBool(key, value)).called(1);
      verify(() => mockSharedPrefs.getBool(key)).called(1);
      expect(result, equals(value));
    });

    test("should save and retrieve double value", () async {
      const String key = "testDouble";
      const double value = 3.14;

      when(
        () => mockSharedPrefs.setDouble(key, value),
      ).thenAnswer((_) async => true);
      when(() => mockSharedPrefs.getDouble(key)).thenAnswer((_) async => value);

      await prefs.saveData(key, value);
      final double? result = await prefs.getData(key, double) as double?;

      verify(() => mockSharedPrefs.setDouble(key, value)).called(1);
      verify(() => mockSharedPrefs.getDouble(key)).called(1);
      expect(result, equals(value));
    });

    test("should save and retrieve List<String> value", () async {
      const String key = "testList";
      const List<String> value = <String>["item1", "item2", "item3"];

      when(
        () => mockSharedPrefs.setStringList(key, value),
      ).thenAnswer((_) async => true);
      when(
        () => mockSharedPrefs.getStringList(key),
      ).thenAnswer((_) async => value);

      await prefs.saveData(key, value);
      final List<String>? result =
          await prefs.getData(key, List<String>) as List<String>?;

      verify(() => mockSharedPrefs.setStringList(key, value)).called(1);
      verify(() => mockSharedPrefs.getStringList(key)).called(1);
      expect(result, equals(value));
    });

    test("should throw exception for unsupported type", () async {
      const String key = "testUnsupported";
      final Map<String, String> value = <String, String>{
        "key": "value",
      }; // Map is unsupported

      expect(() => prefs.saveData(key, value), throwsException);
    });

    test("should remove value", () async {
      const String key = "testRemove";
      const String value = "test value";

      when(() => mockSharedPrefs.remove(key)).thenAnswer((_) async => true);

      await prefs.saveData(key, value);
      await prefs.removeData(key);
      final String? result = await prefs.getData(key, String) as String?;

      verify(() => mockSharedPrefs.remove(key)).called(1);
      expect(result, isNull);
    });

    test("should clear all values", () async {
      when(() => mockSharedPrefs.clear()).thenAnswer((_) async => true);

      await prefs.saveData("key1", "value1");
      await prefs.saveData("key2", 42);
      await prefs.clearAllData();

      verify(() => mockSharedPrefs.clear()).called(1);

      final String? result1 = await prefs.getData("key1", String) as String?;
      final int? result2 = await prefs.getData("key2", int) as int?;

      expect(result1, isNull);
      expect(result2, isNull);
    });
  });

  group("Secure storage tests", () {
    test("should save and retrieve secure String value", () async {
      const String key = "secureTestString";
      const String value = "secure test value";

      when(
        () => mockSecureStorage.write(key: key, value: value),
      ).thenAnswer((_) async {});
      when(
        () => mockSecureStorage.read(key: key),
      ).thenAnswer((_) async => value);

      await prefs.saveData(key, value, isSecure: true);
      final String? result =
          await prefs.getData(key, String, isSecure: true) as String?;

      verify(() => mockSecureStorage.write(key: key, value: value)).called(1);
      verify(() => mockSecureStorage.read(key: key)).called(1);
      expect(result, equals(value));
    });

    test("should throw exception for non-string secure value", () async {
      const String key = "secureInt";
      const int value = 42;

      expect(() => prefs.saveData(key, value, isSecure: true), throwsException);
    });

    test("should remove secure value", () async {
      const String key = "secureRemove";

      when(() => mockSecureStorage.delete(key: key)).thenAnswer((_) async {});

      await prefs.removeData(key, isSecure: true);

      verify(() => mockSecureStorage.delete(key: key)).called(1);
    });

    test("should clear all secure values", () async {
      when(() => mockSecureStorage.deleteAll()).thenAnswer((_) async {});

      await prefs.clearAllData(isSecure: true);

      verify(() => mockSecureStorage.deleteAll()).called(1);
    });
  });

  group("Singleton tests", () {
    test("should maintain singleton instance", () {
      final ApzPreference instance1 = ApzPreference();
      final ApzPreference instance2 = ApzPreference();
      expect(identical(instance1, instance2), isTrue);
    });
  });
}
