# APZ GPS Plugin

A lightweight Flutter plugin to access device GPS and location services with built-in permission handling. Provides accurate location data with proper error handling and platform-specific implementations, while using ```geolocator``` plugin.

---

## Features

- High accuracy location retrieval
- Built-in permission handling
- Cross-platform support (Android & iOS)
- Optimized for performance
- Proper error handling and type safety

## Getting Started

### Add Dependency

```yaml
dependencies:
  apz_gps:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/gps/v1.0.0
```

Then run:
```bash
flutter pub get
```

## Platform Setup

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open to provide location-based services.</string>
```

### iOS (`Podfile`)

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1'
      ]
    end
  end
end
```

## Usage

### Import the plugin

```dart
import 'package:apz_gps/apz_gps.dart';
```

### Get current location

```dart
final gps = ApzGPS();

try {
  final location = await gps.getCurrentLocation();
  print('Latitude: ${location.latitude}');
  print('Longitude: ${location.longitude}');
  print('Accuracy: ${location.accuracy}');
  print('Speed: ${location.speed}');
} on PermissionException catch (e) {
  print('Permission error: ${e.message}');
} on LocationException catch (e) {
  print('Location error: ${e.message}');
} on UnsupportedPlatformException catch (e) {
  print('Platform error: ${e.message}');
}
```

## Location Model

The plugin returns location data as a `LocationModel` with the following properties:

```dart
LocationModel({
  required double latitude,    // Latitude in degrees
  required double longitude,   // Longitude in degrees
  required double accuracy,    // Accuracy radius in meters
  required double altitude,    // Altitude in meters
  required double speed,      // Speed in meters per second
  DateTime? timestamp,        // Timestamp of the location fix
});
```

## Error Handling

The plugin provides specific exceptions for different error cases:

- `PermissionException`: When location permissions are denied
- `LocationException`: When location services are disabled or unavailable
- `UnsupportedPlatformException`: When running on unsupported platforms

## Plugin Dependencies

This plugin is built on top of the following Flutter packages:

- [geolocator](https://pub.dev/packages/geolocator): Provides platform-specific implementation for location services
- [permission_handler](https://pub.dev/packages/permission_handler): Handles runtime permissions across platforms

### Why Geolocator?

- Robust and well-maintained location services implementation
- High accuracy location data
- Extensive platform support
- Active community and regular updates
- Proper error handling and type safety

## Testing

The plugin supports dependency injection for testing. Mock examples are provided in the test directory.

## Contributing

Contributions are welcome! Please follow the existing code style and add unit tests for any new or changed functionality.

### JIRA Link : https://appzillon.atlassian.net/browse/AN-91
