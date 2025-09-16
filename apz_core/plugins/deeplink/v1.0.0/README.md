# ApzDeeplink

A lightweight Flutter plugin for handling deep links (custom URL schemes) on Android and iOS. Supports cold start and runtime link listening, and provides a consistent data model with parsed host, path, scheme, and query parameters.

## ✨ Features

- Handles deep links on app launch (cold start) and while running.
- Emits parsed deep link data.
- Singleton usage – no need to manage multiple instances.
- Lightweight and native platform channel integration.

## 🛠 Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅ Yes     |
| iOS      | ✅ Yes     |
| Web      | ❌ Not supported (throws `UnsupportedPlatformException`) |

---

## 🚀 Getting Started

### 1. Install the plugin

Add to your `pubspec.yaml`:

```yaml
dependencies:
  apz_deeplink:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/deeplink/v1.0.0
```

Then run:

```bash
flutter pub get
```

---

### 2. Android Setup

Update your `AndroidManifest.xml` to declare intent filters:
```markdown
android/app/src/main/AndroidManifest.xml 
```

```xml
<activity>
  <intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="myapp" android:host="home"/>
  </intent-filter>
</activity>
```

> You can change `android:scheme` and `android:host` to match your app’s needs.

---

### 3. iOS Setup

In your iOS project:

1. Open `ios/Runner/Info.plist` and add:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

2. Also in `AppDelegate.swift`(below override application fun), handle the incoming link:

```swift
override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
  NotificationCenter.default.post(name: NSNotification.Name("ApzDeeplinkReceived"), object: url)
  return true
}
```

---

## 📦 Usage

### 1. Access the singleton

```dart
final deeplink = ApzDeeplink();
```

### 2. Listen to deep links

```dart
_deepLinkSubscription = deeplink.linkStream.listen((DeeplinkData data) {
  print("Scheme: ${data.scheme}");
  print("Host: ${data.host}");
  print("Path: ${data.path}");
  print("Product ID: ${data.queryParameters['productid']}");
});
```

### 3. Optionally get initial link (on cold start)

```dart
final initial = await deeplink.getInitialLink();
if (initial != null) {
  print("Initial launch link: $initial");
}
```

---

## 🔐 Permissions

No permissions required.

---

## ❌ Unsupported Platforms

This plugin throws `UnsupportedPlatformException` on web platforms automatically.

---

## Cancelling the Stream
Important: ApzDeeplink().linkStream returns a broadcast stream. If you're listening inside a StatefulWidget, cancel your subscription in dispose():

```dart

@override
void disponse(){
    super.dispose()
    _deepLinkSubscription?.cancel()
    <!-- or -->
    _deepLinkSubscription = null;
}
```
#### Run this command for android
```cmd
adb shell am start -a android.intent.action.VIEW -d "myapp://home" <your_package_name>
```

## Jira Ticket Link

- [ApzDeepLink](https://appzillon.atlassian.net/browse/AN-138)
