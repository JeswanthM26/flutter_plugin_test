# apz_send_sms

A utility Flutter plugin to send SMS messages from your Flutter app using native platform capabilities.

## Features
- Simple API to send SMS messages
- Uses platform channels to invoke native SMS sending on Android and iOS

## Installation
Add this to your `pubspec.yaml`:

```yaml
dependencies:
  apz_send_sms:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/send_sms/v1.0.0
```

Then run:
```sh
flutter pub get
```


## Usage

Import the package:

```dart
import 'package:apz_send_sms/apz_send_sms.dart';
```

Create an instance and send an SMS:

```dart
final sendSMS = ApzSendSMS();

try {
  final SendSMSStatus status = await sendSMS.send(
    phoneNumber: '1234567890',
    message: 'Hello from Flutter!',
  );
  switch (status) {
    case SendSMSStatus.launched:
      print('SMS app launched');
      break;
    case SendSMSStatus.sent:
      print('SMS sent');
      break;
    case SendSMSStatus.cancelled:
      print('SMS sending cancelled');
      break;
  }
} catch (e) {
  print('Failed to send SMS: $e');
}
```

### Parameters
- `phoneNumber` (**required**): The recipient's phone number as a string.
- `message` (**required**): The SMS message content.

### Return Value
Returns a `Future<SendSMSStatus>` that resolves to the status of the SMS sending operation. On Android (Intent-based), the status will be `SendSMSStatus.launched` if the SMS app was opened. On iOS, it may be `SendSMSStatus.sent`, `SendSMSStatus.cancelled`, or an error depending on user action.

### Error Handling
If the SMS sending operation fails, an exception is thrown. Handle exceptions using try-catch as shown above.

## Platform Notes
- **Android:** Uses an Intent to open the default SMS app. Does not guarantee the message was sent, only that the app was launched.
- **iOS:** Uses `MFMessageComposeViewController` to present the native SMS UI. The result reflects user action.
- **Web:** This plugin is **not supported** on the web platform. Calling `send()` on web will throw an `UnsupportedPlatformException`.

## License
Copyright © i-exceed Technology Solutions. All rights reserved.

## Jira Links
- https://appzillon.atlassian.net/browse/AN-105
- https://appzillon.atlassian.net/browse/AN-139
