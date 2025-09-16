# 📇 apz_contact_picker

A lightweight Flutter plugin to **launch the device's native contact picker** and fetch a single contact on user selection. This plugin handles permission checks internally and uses platform-native intent to allow users to pick a contact directly from their address book.

---

## ✨ Features

- Launches the native contact picker UI
- Fetches:
  - Contact name
  - Primary phone number
  - Email
  - Photo
- Clean and simple API
- Platform-level permission handling
- Supports dependency injection for testing or customization

---

## 🚀 Getting Started

### 1. Add Dependency

```yaml
dependencies:
  apz_contact_picker:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/contact_picker/v1.0.0

  apz_utils:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/utils/v1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 📦 Usage

### Import the plugin

```dart
import 'package:apz_contact_picker/apz_contact_picker.dart';
import 'package:apz_utils/apz_utils.dart';
```

### Pick a Contact

```dart
final plugin = ApzContactPicker();

try {
  final PickedContact? pickedContact = await plugin.pickedContact();

  if (pickedContact != null) {
    print('Name: ${pickedContact.name}');
    print('Phone: ${pickedContact.phone}');
  }
} on PermissionException {
  // Log or handle permission-specific error
  rethrow; // let UI or use case layer handle this
} on UnsupportedPlatformException {
  // Log or handle unsupported platform error
  rethrow; // let UI or use case layer handle this
} catch (e) {
  // Log or handle unexpected errors
  rethrow;
}
```

---

## 📄 Picked Contact Model

Each contact selected by the user is returned as a Dart object with:

```dart
class PickedContact {
    this.fullName,
    this.phoneNumber,
    this.email,
    this.thumbnail,
    this.error
}
```

---

## ✅ Permissions

This plugin uses [`permission_handler`](https://pub.dev/packages/permission_handler) internally and manages:

- Checking contact permissions
- Requesting runtime permissions
- Handling permanently denied or restricted states

---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS

Make sure the following permissions are declared:

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

### iOS (`Info.plist`)

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts to allow contact selection.</string>
```

### iOS (`Podfile`)

Add this snippet to the bottom of your iOS `Podfile`, inside the `post_install do |installer| ... end` block:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CONTACTS=1'
      ]
    end
  end
end
```

---

## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---

### Jira Ticket

- [contact_picker](https://appzillon.atlassian.net/browse/AN-82)

---