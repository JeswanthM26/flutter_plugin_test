# apz_idle_timeout

apz_idle_timeout is a Flutter plugin that detects user inactivity (idle timeout) and executes a callback after a specified duration. It is designed to be lightweight, lifecycle-aware, and reusable across different Flutter projects.

## ✨ Features
- Automatically detects user inactivity across the entire app
- Triggers a callback when the user has been idle for a set duration
- Includes pause, resume, and reset controls
- Works without needing to wrap individual UI widgets
- App lifecycle aware (handles pause/resume states)

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  apz_idle_timeout:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/idle_timeout/v1.0.0
```

Then, run `flutter pub get` to fetch the package.

## Usage

### Step 1: Import

```dart
import 'package:apz_idle_timeout/apz_idle_timeout.dart';
```

### Step 2: Call it from main()


```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ApzIdleTimeout().start(
    () async {
      // Perform logout, show dialog, etc.
    },
    timeout: const Duration(minutes: 3),
  );

  runApp(MyApp());
}
```

### Step 3: Customize Timeout Duration and showDialog and navigate based on your requirement


```dart
ApzIdleTimeout().start(
      () async {
        final BuildContext? context = AppRouter.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          final bool? shouldLogout = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Session Timeout"),
              content: const Text("You've been idle for too long."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text("Stay Logged In"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text("Logout"),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            ApzIdleTimeout().pause(); // stop before navigating
            AppRouter.router.go("/"); // Go to login screen
          } else {
            ApzIdleTimeout().reset(); // Resume timeout timer
          }
        }
      },
      timeout: Duration(
        seconds:
            int.tryParse(dotenv.env[Constants.idealTimeout] ?? "") ??
            Constants.defaultIdealTimeout,
      ),
    );
```

### Step 4: Add navigatorKey to GoRouter
```dart
class AppRouter {
  AppRouter._();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: "/",
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
```
And update MaterialApp.router in MyApp:
```dart
return MaterialApp.router(
  routerConfig: AppRouter.router,
  ...
);
```

### ⏱ Public API

| Method                       | Description                                   |
| ---------------------------- | --------------------------------------------- |
| `pause()`                    | Pause idle tracking (e.g. on login screen)    |
| `resume()`                   | Resume tracking (e.g. after login)            |
| `reset()`                    | Manually reset the timer (e.g. on tab switch) |
| `dispose()`                  | Cancel timers and clean up (e.g. on logout)   |


## Notes

- Works on Android, iOS, Web platforms.
- Does not require UI widget wrapping — detects user interactions globally.
- Automatically handles app lifecycle events (pause/resume).

## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---

## Jira Links
-https://appzillon.atlassian.net/browse/AN-84

