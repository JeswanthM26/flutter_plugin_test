## apz_screen_security

A Flutter plugin to prevent screen recording, screenshots, and screen mirroring on Android and iOS.

## 📦 Installation

Add the plugin to your app’s pubspec.yaml file:
```yaml
dependencies:
  apz_screen_security:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/screen_security/v1.0.0
```
## 📥 Import

Import the package in your Dart widget:
```dart
import "package:apz_screen_security/apz_screen_security.dart";
```
## 🔧 API Methods

All methods return a Future<bool>:
```dart
try{
  await ApzScreenSecurity().enableScreenSecurity();
  await ApzScreenSecurity().disableScreenSecurity();
  await ApzScreenSecurity().isScreenSecureEnabled();
}
on UnsupportedPlatformException catch(e){
  print(e);
}
```
## 🧪 Usage Example
```dart
Future<void> _enableScreenSecurity() async {
  final bool isEnabled = await ApzScreenSecurity().enableScreenSecurity();

  setState(() {
    _isSecureEnabled = isEnabled;
  });

  if (_isSecureEnabled) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Screen security is enabled!"),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
```
## 🔒 Purpose

This plugin is used to:

Prevent screen recording

Block screenshots

Disable screen mirroring

Disable screen sharing

Useful for apps with sensitive content, such as banking, medical, or confidential data.

## 🛠️ Platform Support

✅ Android

✅ iOS

## Jira Ticket Link
- [Screenshot / Screen Recording Prevention & Listeners](https://appzillon.atlassian.net/browse/AN-85)
