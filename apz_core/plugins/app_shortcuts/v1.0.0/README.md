
# APZ App Shortcuts Plugin

This Flutter plugin allows you to manage dynamic app shortcuts for your application icon. You can set, clear, and handle shortcut tap events using a simple API.

## Features
- Add dynamic shortcuts to your app icon
- Remove all shortcuts
- Handle shortcut tap events

## Installation
Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  apz_app_shortcuts:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/app_shortcuts/v1.0.0
```

Run `flutter pub get` to install the package.

## Usage

### 1. Import the package
```dart
import 'package:apz_app_shortcuts/apz_app_shortcuts.dart';
import 'package:apz_app_shortcuts/shortcut_item.dart';
```

### 2. Register the shortcut callback
Call this early in your app (e.g., in `main()` or your root widget):

```dart
ApzAppShortcuts().registerShortcutCallback((String id) {
  // Handle shortcut tap event
  print('Shortcut tapped: $id');
});
```

### 3. Set shortcut items
You can set shortcuts dynamically:

```dart
final shortcuts = [
  ShortcutItem(id: 'home', title: 'Home', icon: 'home_icon'),
  ShortcutItem(id: 'profile', title: 'Profile', icon: 'profile_icon'),
];
await ApzAppShortcuts().setShortcutItems(shortcuts);
```

### 4. Clear shortcut items
To remove all shortcuts:

```dart
await ApzAppShortcuts().clearShortcutItems();
```

## Android Integration

Add the following code to your `MainActivity.kt` to handle app shortcuts:

```kotlin
class MainActivity : FlutterFragmentActivity() {
    private lateinit var shortcutChannel: MethodChannel
    // ...existing code...

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val shortcutId = intent.getStringExtra("shortcut_id")
        if (shortcutId != null && ::shortcutChannel.isInitialized) {
            shortcutChannel.invokeMethod("onShortcutItemTapped", shortcutId)
            intent.removeExtra("shortcut_id")
        }
        // ...existing code...
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val shortcutId = intent.getStringExtra("shortcut_id")
        if (shortcutId != null && ::shortcutChannel.isInitialized) {
            shortcutChannel.invokeMethod("onShortcutItemTapped", shortcutId)
            intent.removeExtra("shortcut_id")
        }
        // ...existing code...
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        shortcutChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.iexceed/apz_app_shortcuts")
        configChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.iexceed.retailneu/appWidget"
        )

        // ...existing code...
    }
}
```

## iOS Integration

Add the following code to your `AppDelegate.swift` to handle app shortcuts:

```swift
@main
@objc class AppDelegate: FlutterAppDelegate {

    private var initialShortcut: UIApplicationShortcutItem?
    // ...existing code...

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        // ...existing code...
        
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            self.initialShortcut = shortcutItem
            return false
        }
        // ...existing code...

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        if let shortcut = initialShortcut {
            sendShortcutToFlutter(shortcut)
            initialShortcut = nil
        }
        // ...existing code...
    }

    override func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        sendShortcutToFlutter(shortcutItem)
        completionHandler(true)
    }

    private func sendShortcutToFlutter(_ shortcut: UIApplicationShortcutItem) {
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "com.iexceed/apz_app_shortcuts",
                                               binaryMessenger: controller.binaryMessenger)
            channel.invokeMethod("onShortcutItemTapped", arguments: shortcut.type)
        }
    }
}
```

## Example

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApzAppShortcuts().registerShortcutCallback((String id) {
    // Navigate or handle shortcut
    print('Shortcut tapped: $id');
  });

  await ApzAppShortcuts().setShortcutItems([
    ShortcutItem(id: 'home', title: 'Home', icon: 'home_icon'),
    ShortcutItem(id: 'profile', title: 'Profile', icon: 'profile_icon'),
  ]);

  runApp(MyApp());
}
```

## API Reference

### ApzAppShortcuts
- `registerShortcutCallback(ShortcutCallback callback)` — Registers a callback for shortcut tap events.
- `setShortcutItems(List<ShortcutItem> items)` — Sets shortcut items for the app icon.
- `clearShortcutItems()` — Removes all shortcut items.


### ShortcutItem
- `id` — Unique identifier for the shortcut.
- `title` — Displayed title for the shortcut.
- `icon` — Icon name for the shortcut.

## Related Jira Ticket

[AN-154](https://appzillon.atlassian.net/browse/AN-154)

