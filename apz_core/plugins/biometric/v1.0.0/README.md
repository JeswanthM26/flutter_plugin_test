#  Apz Biometric Plugin

The `apz_biometric` is a reusable Flutter plugin that enables biometric authentication (such as fingerprint or face recognition) on supported Android and iOS devices.

---

## ✨ Features

- ✅ Check if biometric authentication is supported
- ✅ Fetch available biometric types (e.g., fingerprint, face)
- ✅ Perform biometric authentication

## 🚀 Getting Started


### 1. Add Dependency

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  apz_biometric:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/biometric/v1.0.0
```

---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS

---

## 🔐 For Android

Add the following permissions in your `AndroidManifest.xml`:

**Outside `<application>` tag:**
```xml
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

## 🔐 For IOS

Add the following permissions in your `Info.plist`:
```
<key>NSFaceIDUsageDescription</key>
<string>Why is my app authenticating using face id?</string>
```
---

## 📱 Usage

### Step 1: Import the Plugin

```dart
import "package:apz_biometric/apz_biometric.dart";
import "package:apz_biometric/apz_auth_result.dart";
```

### Step 2: Instantiate the Plugin

```dart
final ApzBiometric biometric = ApzBiometric();
```
### Step 3: Check Biometric is Supported

```dart
try{
final bool checkBiometricStatus = await biometric.isBiometricSupported();
  }on Exception catch (error) {
    print("Exception result: $error");
  } 
```
### Step 4: Fetch Available Biometric Types

```dart
try{
final Future<List<BiometricType>> availableBiometricsTypes = await biometric.fetchAvailableBiometrics();
  }on Exception catch (error) {
        print("Exception result: $error");
  } 
``` 

### Step 5: Create an Instance for AndroidAuthMessages and IOSAuthMessages

```dart
const androidMessages = AndroidAuthMessages(
  signInTitle: 'Biometric Authentication',
  cancelButton: 'Cancel',
  biometricHint: 'Touch sensor',
  // ... other optional properties
);

const iosMessages = IOSAuthMessages(
  localizedReason: 'Authenticate to access the app',
  cancelButton: 'OK',
  // ... other optional properties
);
```

### Step 6: To Authenticate biometric

```dart
try{
final AuthResult result = await biometric.authenticate(
  reason: "Authenticate to access the app",
  stickyAuth: true,
  biometricOnly: true,
  androidAuthMessage: androidMessages,
  iosAuthMessage: iosMessages,
);

if (result.status) {
  print("Authentication successful!");
} else {
  print("Authentication failed: ${result.message}");
}
}on Exception catch (error) {
  print("Exception result: $error");
} 
```

---

## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---
## Jira Links
-https://appzillon.atlassian.net/browse/AN-88