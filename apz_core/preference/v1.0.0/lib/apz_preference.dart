import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:shared_preferences/shared_preferences.dart";

/// A singleton class to manage preferences using SharedPreferences
/// and FlutterSecureStorage.
class ApzPreference {
  /// Factory constructor to ensure a single instance of ApzPreference
  factory ApzPreference() => _instance;

  ApzPreference._internal() {
    AndroidOptions androidOptions() => AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      sharedPreferencesName: _sharedPreferencesName,
    );

    IOSOptions iosOptions() => IOSOptions(
      accountName: _sharedPreferencesName,
      accessibility: KeychainAccessibility.unlocked_this_device,
    );

    WebOptions webOptions() => WebOptions(
      dbName: _sharedPreferencesName,
      publicKey: _sharedPreferencesName,
    );

    _securePrefs = FlutterSecureStorage(
      aOptions: androidOptions(),
      iOptions: iosOptions(),
      webOptions: webOptions(),
    );
  }

  static final ApzPreference _instance = ApzPreference._internal();
  final String _sharedPreferencesName = "apz_preference";
  final String _unsupportedTypeString = "Unsupported type";
  SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  FlutterSecureStorage? _securePrefs;

  /// Used for testing purposes only
  @visibleForTesting
  void setMocks({
    required final SharedPreferencesAsync mockSharedPrefs,
    required final FlutterSecureStorage mockSecureStorage,
  }) {
    _prefs = mockSharedPrefs;
    _securePrefs = mockSecureStorage;
  }

  /// Saves data to SharedPreferences or SecureStorage
  Future<void> saveData(
    final String key,
    final Object value, {
    final bool isSecure = false,
  }) async {
    if (isSecure) {
      if (value is String) {
        await _securePrefs?.write(key: key, value: value);
      } else {
        throw Exception(_unsupportedTypeString);
      }
    } else {
      final Type valueType = value.runtimeType;
      switch (valueType) {
        case const (int):
          await _prefs.setInt(key, value as int);
        case const (String):
          await _prefs.setString(key, value as String);
        case const (bool):
          await _prefs.setBool(key, value as bool);
        case const (double):
          await _prefs.setDouble(key, value as double);
        case const (List<String>):
          await _prefs.setStringList(key, value as List<String>);
        default:
          throw Exception(_unsupportedTypeString);
      }
    }
    return;
  }

  /// Gets data from SharedPreferences or SecureStorage
  Future<Object?> getData(
    final String key,
    final Type type, {
    final bool isSecure = false,
  }) async {
    Object? value;
    if (isSecure) {
      value = await _securePrefs?.read(key: key);
    } else {
      switch (type) {
        case const (String):
          value = await _prefs.getString(key);
        case const (int):
          value = await _prefs.getInt(key);
        case const (bool):
          value = await _prefs.getBool(key);
        case const (double):
          value = await _prefs.getDouble(key);
        case const (List<String>):
          value = await _prefs.getStringList(key);
        default:
          throw Exception(_unsupportedTypeString);
      }
    }
    return value;
  }

  /// Removes data from SharedPreferences or SecureStorage
  Future<void> removeData(
    final String key, {
    final bool isSecure = false,
  }) async {
    if (isSecure) {
      await _securePrefs?.delete(key: key);
    } else {
      await _prefs.remove(key);
    }
    return;
  }

  /// Clears all data from SharedPreferences or SecureStorage
  Future<void> clearAllData({final bool isSecure = false}) async {
    if (isSecure) {
      await _securePrefs?.deleteAll();
    } else {
      await _prefs.clear();
    }
    return;
  }
}
