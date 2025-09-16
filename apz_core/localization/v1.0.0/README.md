# APZLocalization

APZLocalization is a simple localization manager for Flutter applications. It provides a singleton class to manage and update the app's locale at runtime, making it easy to switch languages and reset to a default language.

## Installation

Add the following to your `pubspec.yaml` to use `apz_localization` directly from git:

````yaml
apz_localization:
  git:
    url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
    ref: develop
    path: apz_core/localization/v1.0.0

## Features

- Singleton pattern for global access
- Change and reset app locale
- Notifies listeners on locale change (extends `ChangeNotifier`)
- Set a default language code

## Usage

### 1. Import the package

```dart
import 'package:apz_localization/apz_localization.dart';
````

### 2. Access the Singleton

```dart
final localization = APZLocalization();
```

### 3. Set Default Locale

```dart
localization.setDefaultLocale('en'); // Set default to English
```

### 4. Change Locale

```dart
localization.changeLocale('fr'); // Change to French
```

### 5. Reset Locale to Default

```dart
localization.resetLocale();
```

### 6. Listen for Locale Changes

Since `APZLocalization` extends `ChangeNotifier`, you can listen for changes using a `ChangeNotifierProvider` or similar state management solution.

## API Reference

| Method                   | Description                                    |
| ------------------------ | ---------------------------------------------- |
| `locale`                 | Get the current `Locale`                       |
| `setDefaultLocale(code)` | Set the default language code                  |
| `changeLocale(code)`     | Change the current locale and notify listeners |
| `resetLocale()`          | Reset locale to the default language code      |

## Example

```dart
final localization = APZLocalization();
localization.setDefaultLocale('en');
localization.changeLocale('es');
print(localization.locale); // Output: Locale('es')
localization.resetLocale();
print(localization.locale); // Output: Locale('en')
```

## Jira Link

- https://appzillon.atlassian.net/browse/AN-63
