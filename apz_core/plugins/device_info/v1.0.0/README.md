# Device Info Plugin

`device_info` is a Flutter plugin designed to retrieve detailed information about the device on which your Flutter app is running.

## Features

- Retrieve device brand, model, and other details.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  apz_device_info:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/device_info/v1.0.0
```

Then, run `flutter pub get` to fetch the package.

## Usage

### Step 1: Initialize the Plugin

Create an instance of `APZDeviceInfoManager`:

```dart
final APZDeviceInfoManager deviceInfoManager = APZDeviceInfoManager();
```

### Step 2: Load Device Information

Call the `loadDeviceInfo` method to fetch device details:

```dart
final deviceInfo = await deviceInfoManager.loadDeviceInfo();
```

### Step 3: Access Device Information

Once the device information is loaded, you can access it using the `deviceInfo` property:

```dart
print('Device Brand: ${deviceInfo?.brand}');
print('Device Model: ${deviceInfo?.model}');
```

### Example

Here is a complete example of how to use the plugin:

```dart
import 'package:apz_device_info/apz_device_info.dart';

final APZDeviceInfoManager deviceInfoManager = APZDeviceInfoManager();

void fetchDeviceInfo() async {
  final deviceInfo = await deviceInfoManager.loadDeviceInfo();
  print('Device Brand: ${deviceInfo?.brand}');
  print('Device Model: ${deviceInfo?.model}');
}
```

## Notes

- This plugin is designed for both Android and iOS platforms. Ensure that your app is running on a supported device or emulator.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Jira Links
-https://appzillon.atlassian.net/browse/AN-74