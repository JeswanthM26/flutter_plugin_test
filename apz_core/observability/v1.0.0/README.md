## ApzObservability Usage

`ApzObservability` provides a unified interface for observability in your Flutter app, supporting pluggable backends (e.g., Sentry, Bugsnag).

**Supported Platforms:** iOS, Android, and Web

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  apz_observability:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/observability/v1.0.0
```

## Example

Below is a minimal example of how to use `apz_observability` in your Flutter app:

```dart
import 'package:apz_observability/apz_observability.dart';
// import your ObservabilityService implementation

void main() async {
  final observability = ApzObservability();
  await observability.init(YourObservabilityService());

  // Capture an exception
  try {
    throw Exception('Something went wrong');
  } catch (e, stack) {
    await observability.captureException(e, stackTrace: stack);
  }

  // Capture a message
  await observability.captureMessage('App started');
}
```

---

### Initialization

```dart
final observability = ApzObservability();
await observability.init(yourObservabilityServiceImplementation);
```

### Capturing Exceptions

```dart
try {
  // your code
} catch (e, stack) {
  await ApzObservability().captureException(e, stackTrace: stack, tags: {"env": "prod"}, hint: "optional");
}
```

### Capturing Messages

```dart
await ApzObservability().captureMessage(
  "A log message",
  tags: {"type": "info"},
  level: BreadcrumbLevel.info,
);
```

### Adding Breadcrumbs

```dart
await ApzObservability().addBreadcrumb(
  AppBreadcrumb(
    message: "User clicked login",
    category: BreadcrumbCategory.user,
    level: BreadcrumbLevel.info,
    data: {"button": "login"},
  ),
);
```

### Setting User Information

```dart
await ApzObservability().setUser(
  id: "user-id",
  username: "username",
  email: "user@example.com",
  extraData: {"role": "admin"},
);
```

### Clearing User Information

```dart
await ApzObservability().clearUser();
```

### Notes

- Always call `init()` before using any other methods.
- You must provide an implementation of `ObservabilityService` (e.g., for Sentry, Bugsnag, etc.).

## Jira Link
- https://appzillon.atlassian.net/browse/AN-113
