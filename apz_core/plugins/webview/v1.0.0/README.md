# apz_webview

A Flutter plugin to open a customizable webview with support for GET/POST requests, custom headers, navigation callbacks, and optional accept/decline actions.

## Features

- Open webview with GET or POST
- Custom headers and post data
- Accept/Decline button support
- Navigation and error callbacks
- Easy integration with your Flutter app

## Platform Support

This plugin supports the following platforms:

- **Android**
- **iOS**

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  apz_webview:
    git:
      url: <your-git-repo-url>
      ref: <branch-or-tag>
      path: apz_core/plugins/webview/v1.0.0
```

Then run:

```sh
flutter pub get
```

## Usage

### 1. Import the package

```dart
import 'package:apz_webview/apz_webview.dart';
```

### 2. Create required models

#### TitleData

```dart
final titleData = TitleData(title: 'My Webview', titleColor: Colors.black);
```

#### WebviewCallbacks

```dart
final callbacks = WebviewCallbacks(
  closeBtnAction: () {
    // Handle close
  },
  onNavigationRequest: (final NavigationRequest request) async {
    // Handle navigation
    // Example: NavigationDecision.navigate; or NavigationDecision.prevent;
    return NavigationDecision.navigate;
  },
  onSslAuthError: (final SslAuthError request) {
    // Handle SSL authentication error
    // Example: request.proceed(); or request.cancel();
  },
  onError: (final ErrorData error) {
    // Handle error
    print('Error: ${error.description}, code: ${error.code}, type: ${error.type}');
  },
);
```

#### (Optional) AcceptDeclineBtn

```dart
final acceptDeclineBtn = AcceptDeclineBtn(
  acceptText: 'Accept',
  declineText: 'Decline',
  acceptBgColor: Colors.green,
  declineBgColor: Colors.red,
  acceptTextColor: Colors.white,
  declineTextColor: Colors.white,
  acceptTapAction: () {
    // Handle accept
  },
  declineTapAction: () {
    // Handle decline
  },
);
```

### 3. Open the webview

> **Note:** `openWebview` and `openWebviewWithPost` are **not supported on the web platform** and will throw an `UnsupportedPlatformException` if called from web.

#### GET request (Android/iOS only)

```dart
final apzWebview = ApzWebview();
await apzWebview.openWebview(
  context: context,
  url: 'https://example.com',
  webviewCallbacks: callbacks,
  titleData: titleData,
  isAcceptRejectVisible: true, // Show accept/decline buttons
  acceptDeclineBtn: acceptDeclineBtn, // Optional
  headers: {'Authorization': 'Bearer ...'}, // Optional
);
```

#### POST request (Android/iOS only)

```dart
await apzWebview.openWebviewWithPost(
  context: context,
  url: 'https://example.com',
  postData: {'key': 'value'},
  webviewCallbacks: callbacks,
  titleData: titleData,
  isAcceptRejectVisible: false,
);
```

### 4. Close the webview programmatically

```dart
apzWebview.closeWebview();
```

## Notes

- Always provide a valid `BuildContext` from a widget.
- The webview is pushed as a fullscreen dialog route.
- For testing, mock the platform interface and navigation as needed.

## Jira Link

- https://appzillon.atlassian.net/browse/AN-95
