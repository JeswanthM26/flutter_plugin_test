# 📇 apz_contact

A lightweight Flutter plugin to fetch device contacts (with optional email and photo) using native code integration for Android and iOS. This plugin handles permission checks internally and exposes a simple API to fetch contacts safely.

---

## ✨ Features

- Fetch contacts with:
  - Names (First, Last, Full)
  - Phone numbers
  - Emails (optional)
  - Thumbnails (optional)
- Search contacts by name, number, or email
- Platform-level permission handling
- Supports dependency injection for testing or customization

---

## 🚀 Getting Started

### 1. Add Dependency

```yaml
dependencies:
  apz_contact:
  git:
    url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
    ref: develop
    path: apz_core/plugins/contact/v1.0.0
  
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
import 'package:apz_contact/apz_contact.dart';
import "package:apz_utils/apz_utils.dart";
```

### Fetch Contacts

```dart
final plugin = ApzContact();

    try {
         final ContactsModel contacts =
    await plugin.loadContacts(
      fetchEmail: true,
      fetchPhoto: true,
      searchQuery: "john", // Optional
    );
    return contacts;
    }on PermissionException {
      // Log or handle permission-specific error
      rethrow; // let UI or use case layer handle this
    }on UnsupportedPlatformException{
      // Log or handle unsupported platform error
      rethrow; // let UI or use case layer handle this
    }

if (contacts != null) {
  for (final contact in contacts.contacts) {
    print('Name: ${contact.name}');
    print('First Name: ${contact.firstName}');
    print('Last Name: ${contact.lastName}');
    print('Numbers: ${contact.numbers}');
    print('Emails: ${contact.emails}');
  }
} 

```

---

## 📄 Contact Model

Each contact returned is a Dart object with:

```dart
class Contact {
  final String name; // Full name
  final String firstName;
  final String lastName;
  final List<String> numbers;
  final List<String> emails;
  final Uint8List? photoData;
}
```

---

## ✅ Permissions

This plugin uses [`permission_handler`](https://pub.dev/packages/permission_handler) internally. The plugin handles:

- Checking contact permissions
- Requesting permissions
- Handling permanently denied state

---

## 🧪 Dependency Injection (Advanced)

You can inject your own implementations for testing:

```dart
final plugin = ApzContact(
  nativeWrapper: MockNativeWrapper(),
  permissionHandler: MockPermissionHandler(),
);
```

---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS

Ensure you add the required permissions in each platform:

### Android (in `AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

### iOS (in `Info.plist`)

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts to function properly.</string>
```
### iOS (in `Podfile `)
To enable contacts permission for iOS when using the apz_contact,
add the following snippet to the bottom of your ios/Podfile, inside the post_install do |installer| ... end block:

```swift
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

---

### Jira Ticket

- [contact_plugin](https://appzillon.atlassian.net/browse/AN-80)

---
