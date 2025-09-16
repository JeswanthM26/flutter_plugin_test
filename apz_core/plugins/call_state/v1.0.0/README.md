# ApzCallState 

A Flutter plugin to listen for **real-time phone call state changes** (Active, Disconnected, Incoming, Outgoing) on Android and iOS.

## ✨ Features
- Get call state changes (`Active`, `Disconnected`, `Incoming`, `Outgoing`).
- Provides a simple `Stream<CallState>` API.

---

## 📦 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  apz_play_integrity:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/call_state/v1.0.0
```
### Then run:

``` sh
flutter pub get
```

## 🔑 Permissions
### Android

Below Permission is getting used in this plugin which is dangerous, so justification is required while publishing to playstore.
```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>

```

---

## 📥 Import

```dart
import 'package:apz_call_state/apz_call_state.dart';
```

```dart
final ApzCallState _apzCallState = ApzCallState();
StreamSubscription<CallState>? _callStateSubscription;
```

```dart
      _apzCallState.callStateStream.then((final Stream<CallState> stateStream) {
      _callStateSubscription = stateStream.listen((final CallState state){
           print("CALL STATE: $state");
        });
      }).catchError((final Object error) {
            print("$error");
      }),
```
Dispose the listener to prevent **Memory Leaks**:

```dart
 @override
  void dispose() {
    unawaited(_callStateSubscription?.cancel());
    _callStateSubscription = null;
    super.dispose();
  }

```
---

## 📊 CallState Enum
```dart
enum CallState {
  /// Indicates an incoming call is currently ringing.
  incoming,

  /// A call has been initiated by the user and is dialing (before it connects).
  outgoing,

  /// This state is active from the moment the call is
  ///  received until it is rejected.
  active,

  /// Represents the default state where there are no active,
  /// incoming, or outgoing calls.
  /// The phone is in a resting state.
  disconnected,
}
```
#### Jira Ticket Link
- [CallState Listener](https://appzillon.atlassian.net/browse/AN-126)


