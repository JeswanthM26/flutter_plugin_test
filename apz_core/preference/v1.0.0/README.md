# ApzPreference Usage Guide

`ApzPreference` is a singleton class for managing app preferences using both `SharedPreferences` and `FlutterSecureStorage` in Flutter. It provides a unified API to save, retrieve, remove, and clear data securely or non-securely.

## Features

- Store and retrieve data using `SharedPreferences` (non-secure) or `FlutterSecureStorage` (secure)
- Supports `int`, `String`, `bool`, `double`, and `List<String>` types
- Secure storage for sensitive data
- Singleton pattern for easy access
- Supported on **Android**, **iOS** and **Web**

## Getting Started

### 1. Add Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  apz_preference:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/preference/v1.0.0
```

### 2. Import the Class

```dart
import 'package:apz_preference/apz_preference.dart';
```

### 3. Access the Singleton

```dart
final prefs = ApzPreference();
```

## Usage

### Save Data

```dart
// Save a string (non-secure)
await prefs.saveData('username', 'john_doe');

// Save an int (non-secure)
await prefs.saveData('age', 30);

// Save a string securely
await prefs.saveData('token', 'secret_token', isSecure: true);
```

### Get Data

```dart
// Get a string (non-secure)
String? username = await prefs.getData('username', String) as String?;

// Get an int (non-secure)
int? age = await prefs.getData('age', int) as int?;

// Get a string securely
String? token = await prefs.getData('token', String, isSecure: true) as String?;
```

### Remove Data

```dart
// Remove a key (non-secure)
await prefs.removeData('username');

// Remove a key (secure)
await prefs.removeData('token', isSecure: true);
```

### Clear All Data

```dart
// Clear all non-secure data
await prefs.clearAllData();

// Clear all secure data
await prefs.clearAllData(isSecure: true);
```

## Notes

- Only `String` values are supported for secure storage.
- For unsupported types, an exception will be thrown.
- The class uses a custom shared preferences name: `apz_preference`.

##Jira Links

- https://appzillon.atlassian.net/browse/AN-69
- https://appzillon.atlassian.net/browse/AN-89
