# Auto Read OTP

`auto_read_otp` is a Flutter plugin designed to simplify the process of reading One-Time Passwords (OTPs) in Android applications. It leverages the `otp_autofill` package to automatically retrieve OTPs from SMS messages using the **User Consent API** and **SMS Retriever API**.

## Features

- Automatically retrieves OTPs from SMS messages.
- Supports both **User Consent API** and **SMS Retriever API**.
- Exposes a callback to receive the full SMS message.
- Simple API to start and stop listening for OTPs.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  apz_auto_read_otp:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/auto_read_otp/v1.0.0
```

Then, run `flutter pub get` to fetch the package.

## Usage

### Step 1: Create and Configure the Plugin

Instantiate the plugin and set the callback to receive the SMS message:

```dart
final autoReadOtp = APZAutoReadOtp();

@override
void initState() {
  super.initState();
  autoReadOtp.onSms = (sms) {
    // Extract OTP from sms and update your UI
    print('Received SMS: $sms');
  };
}
```

### Step 2: Start Listening for OTP

To start listening for OTP messages, use one of the following:

- **User Consent API** (optionally pass sender number):

  ```dart
  autoReadOtp.startOTPListener(ListenerType.consent, senderNumber: "+1234567890");
  ```

- **SMS Retriever API**:

  ```dart
  autoReadOtp.startOTPListener(ListenerType.retriever);
  ```

### Step 3: Stop Listening for OTP

To stop listening for OTP messages, call:

```dart
autoReadOtp.stopOtpListener();
```

### Example

Here is a complete example of how to use the plugin:

```dart
final autoReadOtp = APZAutoReadOtp();

@override
void initState() {
  super.initState();
  autoReadOtp.onSms = (sms) {
    // Extract OTP from sms and update your UI
    print('Received SMS: $sms');
  };
}

@override
void dispose() {
  autoReadOtp.stopOtpListener();
  super.dispose();
}

Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('OTP Autofill Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                autoReadOtp.startOTPListener(ListenerType.smsRetriever);
              },
              child: const Text('Start SMS Retriever Listener'),
            ),
            ElevatedButton(
              onPressed: () {
                autoReadOtp.startOTPListener(ListenerType.userConsent, senderNumber: "+1234567890");
              },
              child: const Text('Start User Consent Listener'),
            ),
            ElevatedButton(
              onPressed: autoReadOtp.stopOtpListener,
              child: const Text('Stop Listener'),
            ),
          ],
        ),
      ),
    );
```

## Notes

- This plugin is currently designed for Android only. Ensure that your app is running on an Android device.

## Jira Link

- https://appzillon.atlassian.net/browse/AN-72

