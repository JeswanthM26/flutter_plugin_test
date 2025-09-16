# apz_speech_to_text

apz_speech_to_text is a Flutter plugin that provides a simple, cross-platform interface for speech-to-text recognition. It wraps the popular speech_to_text package and offers a callback-driven API for easy integration.

## ✨ Features
- Initialize and check speech recognition availability
- Start and stop listening for speech
- Receive recognition results and errors via callback
- Platform-aware (throws on unsupported platforms like web)

## 🖥 Supported Platforms

| Platform   | Supported | Notes                        |
|-----------|-----------|------------------------------|
| Android   | ✅        | Supported              |
| iOS       | ✅        | Supported              |
| Web       | ❌        | Not supported (throws error) |

## 🔐 For Android

Add the following permissions in your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```
Android SDK 30 or later
```xml
<queries>
    <intent>
        <action android:name="android.speech.RecognitionService" />
    </intent>
</queries>
```

## 🔐 For IOS

Add the following permissions in your `Info.plist`:
```
    <key>NSMicrophoneUsageDescription</key>
	<string>This listens for speech on the device microphone on your request.</string>
	<key>NSSpeechRecognitionUsageDescription</key>
	<string>This recognizes words as you speak them and displays them. </string>
```


## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
	apz_speech_to_text:
		git:
			url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
            ref: develop
			path: apz_core/plugins/speech_to_text/v1.0.0
```

Then, run `flutter pub get` to fetch the package.

## Usage

### Step 1: Import

```dart
import 'package:apz_speech_to_text/apz_speech_to_text.dart';
```

### Step 2: Initialize the Plugin

Call `initialize()` before starting speech recognition. Provide a callback to receive results and errors.

```dart
final ApzSpeechToText speech = ApzSpeechToText();

Future<void> initSpeech() async {
	await speech.initialize(
		callback: ({String? text, String? error, bool? isListening}) {
			if (error != null) {
				// Handle error
			} else if (text != null) {
				// Handle recognized text
			} else if (isListening != null) {
				// Update UI for listening state
			}
		},
	);
}
```

### Step 3: Start Listening

```dart
// Start listening for speech (default: English, 30 seconds)
await speech.startListening(
	language: 'en_US',
	listenDuration: 30,
);
```

### Step 4: Stop Listening

```dart
await speech.stopListening();
```

### Example: Full Integration

```dart
final ApzSpeechToText speech = ApzSpeechToText();

@override
void initState() {
	super.initState();
	speech.initialize(
		callback: ({String? text, String? error, bool? isListening}) {
			if (error != null) {
				print('Speech error: $error');
			} else if (text != null) {
				print('Recognized: $text');
			} else if (isListening != null) {
				print('Listening: $isListening');
			}
		},
	);
}

void start() => speech.startListening(language: 'en_US', listenDuration: 10);
void stop() => speech.stopListening();
```

## 🛠 API Reference

| Method                | Description                                                      |
|-----------------------|------------------------------------------------------------------|
| `initialize()`        | Initializes the plugin. Must be called before listening.          |
| `startListening()`    | Starts listening for speech. Specify language and duration.       |
| `stopListening()`     | Stops listening and processes the result.                         |
| `SpeechResultCallback`| Callback for results: `{String? text, String? error, bool? isListening}` |

## Notes

- Throws an error if used on unsupported platforms (e.g., web).
- Always call `initialize()` before `startListening()`.
- The callback provides recognized text, errors, and listening state updates.


## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---

## Jira Links
-https://appzillon.atlassian.net/browse/AN-90

---


