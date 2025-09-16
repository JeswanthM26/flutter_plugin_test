# 🔔 apz_notification

A Flutter plugin to simplify Firebase push notification setup across Android and iOS with clean architecture and optional callbacks.

---

## ✨ Features

- Firebase Cloud Messaging (FCM) integration
- Token management: Get, delete, and refresh token callback
- Foreground, background & terminated notification handling
- Android & iOS local notification support
- Multiple notification channels (Android)
- Supports dependency injection for testing

---

## 🚀 Getting Started

### Add Dependency

```yaml
dependencies:
  apz_notification:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/notification/v1.0.0
```

```bash
flutter pub get
```

---

## 📱 Android Setup

### 🔧 `android/build.gradle`

```
buildscript {
    repositories {
        google()           // Required for com.google.gms
        mavenCentral()
    }
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0' // add latest version
    }
}
```

### 🔧 `android/app/build.gradle`

```
plugins {
    id "com.google.gms.google-services"
}

android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
        coreLibraryDesugaringEnabled true
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```

### 🧾 `AndroidManifest.xml`

Make sure `<manifest>` tag includes:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
```

Inside `<application>`:

```xml
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="true"
    tools:replace="android:exported">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT"/>
    </intent-filter>
</service>

<service
    android:name="com.google.firebase.components.ComponentDiscoveryService"
    android:exported="false">
    <meta-data
        android:name="com.google.firebase.components:com.google.firebase.messaging.FirebaseMessagingRegistrar"
        android:value="com.google.firebase.components.ComponentRegistrar"/>
</service>

```

### 📄 `google-services.json`

Download it from Firebase Console and place in:

```
android/app/google-services.json
```

``` dart
### `Initializes push notifications for the application.`

Future<void> setupPushNotifications() async {
  await ApzNotification.instance.initializePushNotification(
    onMessage: (final ApzMessage message) {
      if (kDebugMode) {
        print("Foreground: ${message.notification?.title}");
      }
    },
    onMessageOpenedApp: (final ApzMessage message) {
      if (kDebugMode) {
        print("App opened from notification");
      }
    },
    onBackgroundMessage: _firebaseBackgroundHandler,
    onTokenRefresh: (final String token) {
      if (kDebugMode) {
        print("Token refreshed: $token");
      }
    },
  );

  final String? token = await ApzNotification.instance.getToken();
  if (kDebugMode) {
    print("Device Token: $token");
  }
}
@pragma("vm:entry-point")
Future<void> _firebaseBackgroundHandler(final ApzMessage message) async {
  if (kDebugMode) {
    print("Background message: ${message.messageId}");
  }
}
```
``` dart
_showInappNotification() async {
     await ApzNotification.instance.showLocalNotification(
     title: "Reminder",
     body: "Don't forget to check the new updates!",
        );
    },
```

---

## 🍏 iOS Setup

iOS+
## ✅ 1. Enable App Capabilities in Xcode

1. Open your Xcode project using:  
   ```
   ios/Runner.xcworkspace
   ```

2. Go to your project target → **Signing & Capabilities** tab.

3. Enable the following capabilities:
   - **Push Notifications**
   - **Background Modes**
     - Check **Background fetch**
     - Check **Remote notifications**

---

## ✅ 2. Upload Your APNs Authentication Key or Certificates

To enable FCM to communicate with Apple Push Notification Service (APNs):

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Open your project.
3. Click the **gear icon** → **Project Settings** → **Cloud Messaging** tab.
4. Under **iOS app configuration**, choose:
   - **Upload Certificate** for **Development** and/or **Production**.
5. For each, select the `.p12` file and enter the password if any.
6. Ensure the certificate’s **Bundle ID** matches your app’s Bundle ID.
7. Click **Save**.

---

## ✅ 3. Download the `GoogleService-Info.plist`

1. In the **Firebase Console**, go to **Project Settings** → **General** tab.
2. Under your iOS app, click **Download `GoogleService-Info.plist`**.

---

## ✅ 4. Add `GoogleService-Info.plist` to Xcode

1. Open your project in Xcode (`ios/Runner.xcworkspace`).
2. Drag and drop the `GoogleService-Info.plist` file into the **Runner** target (not just the folder).
3. Ensure **"Copy items if needed"** is selected and that the file is added to the correct target.

---

---

## 📢 Notification Channels (Android only)

```dart
const AndroidNotificationChannel updatesChannel = AndroidNotificationChannel(
  "apz_updates_channel",
  "Updates Channel",
  description: "Channel for general updates",
  importance: Importance.high,
);

const AndroidNotificationChannel offersChannel = AndroidNotificationChannel(
  "apz_offers_channel",
  "Offers Channel",
  description: "Channel for promotional offers",
  importance: Importance.high,
);
```
---

### Jira Ticket

- [notification](https://appzillon.atlassian.net/browse/AN-108)

---

## 🔚 Done!

