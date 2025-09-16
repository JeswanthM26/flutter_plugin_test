# jailbreak_root_detection

Uses [RootBeer](https://github.com/scottyab/rootbeer) + DetectFrida for Android root detection and [IOSSecuritySuite (~> 1.9.10)](<[https://github.com/securing/IOSSecuritySuite](https://github.com/securing/IOSSecuritySuite/releases/tag/1.9.10)>) for iOS jailbreak detection.

## Getting started

In your flutter project add the dependency:

```yaml
jailbreak_root_detection:
  git:
    url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
    ref: develop
    path: apz_core/jailbreak_root_detection/v1.0.0
```

## Usage

### Android

```dart
final isNotTrust = await JailbreakRootDetection.instance.isNotTrust;
final isJailBroken = await JailbreakRootDetection.instance.isJailBroken;
final isRealDevice = await JailbreakRootDetection.instance.isRealDevice;
final isOnExternalStorage = await JailbreakRootDetection.instance.isOnExternalStorage;
final checkForIssues = await JailbreakRootDetection.instance.checkForIssues;
final isDevMode = await JailbreakRootDetection.instance.isDevMode;
```

### iOS

- Update `Info.plist`

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>undecimus</string>
    <string>sileo</string>
    <string>zbra</string>
    <string>filza</string>
    <string>activator</string>
    <string>cydia</string>
</array>
```

```dart
final isNotTrust = await JailbreakRootDetection.instance.isNotTrust;
final isJailBroken = await JailbreakRootDetection.instance.isJailBroken;
final isRealDevice = await JailbreakRootDetection.instance.isRealDevice;
final checkForIssues = await JailbreakRootDetection.instance.checkForIssues;

final bundleId = 'my-bundle-id'; // Ex: final bundleId = 'com.w3conext.jailbreakRootDetectionExample'
final isTampered = await JailbreakRootDetection.instance.isTampered(bundleId);
```

### Reference

- https://appzillon.atlassian.net/browse/AN-71
