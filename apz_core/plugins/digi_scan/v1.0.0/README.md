# apz_digi_scan

The `apz_digi_scan` is a reusable Flutter plugin that allows you to scan documents and retrieve them as images or a PDF on Android and iOS devices.

---

## ✨ Features

- ✅ Scan and return a document as a image path
- ✅ Scan and return a document as a single PDF file path

## 🚀 Getting Started


### 1. Add Dependency

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  apz_digi_scan:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/digi_scan/v1.0.0
```

---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS

---

## 🔐 For Android

No additional setup required, but ensure your `minSdkVersion` is `21`.


## 🔐 For IOS

Add the following permissions in your `Info.plist`:
```
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to scan documents</string>
```
---

## 📱 Usage

### Step 1: Import the Plugin

```dart
import 'package:apz_digi_scan/apz_digi_scan.dart';
```

### Step 2: Instantiate the Plugin

```dart
final ApzDigiScan scanner = ApzDigiScan();
```
### Step 3: Scan Document as Images

```dart
try {
  final result = await scanner.scanAsImage(1);
  if (result != null) {
    print("Scanned image paths: $result");
  }
} on Exception catch (e) {
  print("Exception: $e");
}

```
### Step 4: Scan Document as PDF

```dart
try {
  final result = await scanner.scanAsPdf(2, pages: 6);
  if (result != null) {
    print("PDF file path: $result");
  }
}on Exception catch (e) {
  print("Exception: $e");
}

``` 

## 🎨 UI Customization

❌ This plugin does not provide UI customization options. 

---

## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

## Jira Links
-https://appzillon.atlassian.net/browse/AN-122