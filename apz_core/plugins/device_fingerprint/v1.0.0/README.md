# apz_device_fingerprint

`apz_device_fingerprint` is a Flutter plugin for generating a unique, privacy-preserving device fingerprint across Android, iOS, and Web platforms. It collects device metadata, hashes it securely, and provides a consistent identifier for security, analytics, and fraud prevention use cases.

## Features

- **Cross-platform support:** Android, iOS, and Web
- **Device fingerprinting:** Collects device and browser metadata
- **Privacy-focused:** All fingerprints are hashed using SHA256
- **No PII stored:** Only non-personal device characteristics are used
- **Native integration:** Uses platform channels for native data
- **Web support:** Uses browser APIs and local/session storage

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  apz_device_fingerprint:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/device_fingerprint/v1.0.0
```

Then run:

```sh
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:apz_device_fingerprint/apz_device_fingerprint.dart';
```

Create an instance and fetch the fingerprint:

```dart
final apzDeviceFingerprint = ApzDeviceFingerprint();
final String fingerprint = await apzDeviceFingerprint.getFingerprint();
print('Device fingerprint: $fingerprint');
```

## What data is used for fingerprinting?

Depending on the platform, the following device/browser metadata is collected:

- Device manufacturer, model, and name
- OS version, build number, kernel version
- Screen resolution
- Device type (phone, tablet, desktop)
- CPU architecture, count, endianness
- Total RAM, disk space, free disk space
- Time zone
- Network connection type
- Unique install/secure ID (persisted securely)
- Browser user agent (Web)
- WebGL and graphics card details (Web)
- Enabled keyboard languages
- Latitude/longitude (if permission granted)

All of this data is combined and hashed using SHA256 for privacy.

## Platform-specific notes

- **Android/iOS:** Uses platform channels to fetch native device info. Uses secure storage for persistent IDs.
- **Web:** Uses browser APIs, localStorage/sessionStorage, and WebGL for device info. No native code required.

## Example

```dart
import 'package:apz_device_fingerprint/apz_device_fingerprint.dart';

void main() async {
  final apzDeviceFingerprint = ApzDeviceFingerprint();
  final fingerprint = await apzDeviceFingerprint.getFingerprint();
  print('Device fingerprint: $fingerprint');
}
```

## Jira Link
- https://appzillon.atlassian.net/browse/AN-132
