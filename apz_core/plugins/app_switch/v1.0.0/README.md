Here’s a `README.md` file for your `apz_app_switch` Flutter plugin with clear steps and usage:

---

# apz_app_switch

A Flutter plugin to detect app lifecycle state changes (resumed, paused, inactive) using native Android and iOS lifecycle observers.  
This can be useful for logging, session management, or handling background/foreground transitions.

---

## 🔧 Step 1: Add dependency

In your project's `pubspec.yaml`:

```yaml
dependencies:
  apz_app_switch:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/app_switch/v1.0.0

```

---

## 📦 Step 2: Import the package

```dart
import 'package:apz_app_switch/apz_app_switch.dart';
```

## 🚀 Step 3: Initialize and use the lifecycle stream

```dart
Future<void> _initLifecycleDetector() async {
  try {
     ApzAppSwitch().lifecycleStream.listen(
      (final AppLifecycleState state) async {
        if (mounted) {
          switch (state) {
            case AppLifecycleState.resumed:
              print("AppLifecycleState.resumed");
            case AppLifecycleState.paused:
              print("AppLifecycleState.paused");
            case AppLifecycleState.inactive:
              print("AppLifecycleState.inactive");
          }
        }
      },
      onError: (final Object error) {
        print(error)
      },
    );
  } on Exception catch (e) {
    print(e)
  }
}
```

```dart
_initLifecycleDetector() - call in initState()
```

---

### 🗑️ Cleanup

Always cancel the subscription in `dispose()`:

```dart
@override
void dispose() {
  _lifecycleSubscription?.cancel();
  super.dispose();
}
```

---

### ✅ Supported AppLifecycleState values

* `resumed` – App is active and visible
* `inactive` – App is temporarily inactive 
* `paused` – App has moved to background

---

### Jira Ticket Link
- [Apz_App_Switch](https://appzillon.atlassian.net/browse/AN-93)

---


