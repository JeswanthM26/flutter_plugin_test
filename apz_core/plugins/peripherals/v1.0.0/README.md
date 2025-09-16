
# APZ Peripherals

A Flutter plugin providing a unified interface to access device peripherals such as Battery, Bluetooth, and NFC.

## Features

- Check device battery level
- Check if Bluetooth is supported
- Check if NFC is supported

## Getting Started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  apz_peripherals:
    url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
    ref: develop
    path: apz_core/plugins/peripherals/v1.0.0
```

Run `flutter pub get` to install dependencies.

## Usage

Import the package:

```dart
import 'package:apz_peripherals/apz_peripherals.dart';
```

### Battery

```dart
final battery = Battery();
int level = await battery.getBatteryLevel();
print('Battery level: $level%');
```

### Bluetooth

```dart
final bluetooth = Bluetooth();
bool isSupported = await bluetooth.isBluetoothSupported();
print('Bluetooth supported: $isSupported');
```

### NFC

```dart
final nfc = NFC();
bool isSupported = await nfc.isNFCSupported();
print('NFC supported: $isSupported');
```

## Platform Support

| Platform | Bluetooth | NFC | Battery |
| -------- | --------- | --- | ------- |
| Android  |    ✅     | ✅  |    ✅    |
| iOS      |    ✅     | ✅  |    ✅    |
| Web      |    ❌     | ❌  |    ❌    |

## Notes

- Some features may not be available on all platforms.
- NFC and Bluetooth support may require additional permissions in your platform-specific configuration.

### JIRA Link : https://appzillon.atlassian.net/browse/AN-94