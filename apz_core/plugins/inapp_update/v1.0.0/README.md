# 📦 ApzInAppUpdate

ApzInAppUpdate is a Flutter plugin that provides native Android **in-app update** functionality using platform channels and enums for `InstallStatus`, `UpdateAvailability`, and `AppUpdateResult`. It offers a clean and testable interface for checking, performing, and monitoring app updates, without relying on third-party libraries.

> ✅ Android only support (no-op on iOS)  
> 🚫 No external dependencies like `in_app_update` or `upgrader`  
> ⚙️ Powered by the Google Play Core in-app updates mechanism via native Kotlin

---

## 🚀 Usage

### 📥 Import the package

```dart
import 'package:apz_inapp_update/apz_inapp_update.dart';
```

```dart
import "package:apz_inapp_update/apz_inapp_update_enums.dart";
```


### 🧠 Initialize

Create a singleton or direct instance of `ApzInAppUpdate`:

```dart
final updater = ApzInAppUpdate();
```

### 📦 Methods Overview

| Method | Description |
|--------|-------------|
| `checkForUpdate()` | Checks if an update is available and returns `AppUpdateInfo` |
| `performImmediateUpdate()` | Starts an **immediate** update flow (blocking) |
| `startFlexibleUpdate()` | Starts a **flexible** update flow (background download) |
| `completeFlexibleUpdate()` | Completes the update after flexible download finishes |
| `installUpdateListener` | Listens to install status updates from native side |


### 💡 Full Example

```dart
import 'package:apz_inapp_update/apz_inapp_update.dart';
```

```dart
  final ApzInAppUpdate _updater = ApzInAppUpdate();
```

```dart
  Future<void> _checkAndUpdate() async {
    try {
      final info = await _updater.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await _updater.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          await _updater.startFlexibleUpdate();
        }
      }

      _updater.installUpdateListener.listen((status) {
        debugPrint('Install status: $status');
        if (status == InstallStatus.downloaded) {
          _updater.completeFlexibleUpdate();
        }
      });
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

```

---

## 🎯 Enum References

### `UpdateAvailability`
- `unknown`
- `updateNotAvailable`
- `updateAvailable`
- `developerTriggeredUpdateInProgress`

### `InstallStatus`
- `unknown`
- `pending`
- `downloading`
- `installing`
- `installed`
- `failed`
- `canceled`
- `downloaded`

### `AppUpdateResult`
- `success`
- `userDeniedUpdate`
- `inAppUpdateFailed`

---

## 📦 Comparison with Other Packages

| Package       | Platform | Play Store Integration | iOS Support | In-app Update Flow |
|---------------|----------|------------------------|-------------|--------------------|
| `upgrader`    | Android / iOS | Opens Play/App Store URL | ✅ Yes       | ❌ No               |
| `in_app_update` | Android only | Native Play Core API     | ❌ No        | ✅ Yes              |
| `apz_inapp_update` | Android only | ✅ Native Kotlin logic | ❌ No        | ✅ Yes (Flexible/Immediate) |

> ✅ Use `apz_inapp_update` for native Play Core behavior on Android.

---

### Jira Ticket Link

- [ApzInAppUpdate](http://prodgit.i-exceed.com:8009/appzillon-neu/core/-/blob/develop/apz_core/plugins/inapp_update/v1.0.0/README.md?ref_type=heads)