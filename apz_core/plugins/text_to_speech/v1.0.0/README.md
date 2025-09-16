# Apz_text_to_speech
A Flutter package for a simple, cross-platform Text-to-Speech (TTS) implementation. This facade wraps core TTS functionalities, making it easy to integrate speaking capabilities into your mobile or desktop applications. It provides methods to speak, stop, pause, and resume speech, as well as to configure language, voice, pitch, and speech rate.

## Features
**Text-to-Speech:** Convert text strings into audible speech.

**Cross-Platform Support:** Works on both Android, iOS and Web.

**Customization:** Control the voice, language, pitch, volume, and speech rate.

**State Management:** Methods to stop, pause, and resume ongoing speech.

**Voice Discovery:** Retrieve a list of available voices on the device.

## Installation
Add apz_text_to_speech to your pubspec.yaml file:
```yaml
dependencies:
  apz_text_to_speech:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/text_to_speech/v1.0.0
```
Then, run **flutter pub get** in your terminal to install the package.

iOS Configuration
No additional steps are required for iOS.

Android Configuration
No additional steps are required for Android.

Web Configuration
No additional steps are required for Web.

## Usage
Start by importing the package and creating an instance of ApzTextToSpeech. It's recommended to create a singleton or use a dependency injection pattern to manage the instance throughout your app.
```dart
import 'package:apz_text_to_speech/apz_text_to_speech.dart';

final ApzTextToSpeech tts = ApzTextToSpeech();
```
Basic Speaking
To speak a text string, simply call the speak method.
```dart
void speakExample() async {
  await tts.speak("Hello, this is a text to speech example.");
}
```
Controlling Speech
You can control the speech flow with stop(), pause(), and resume().
```dart
// Stop the current speech
await tts.stop();

// Pause the current speech
await tts.pause();

// Resume the paused speech
await tts.resume();
```
Customizing Language and Voice
You can get a list of available voices and then set them.
```dart
void getAndSetVoices() async {

  // Get available voices
  final voices = await tts.getVoices();
  print('Available Voices: $voices');

  await tts.setVoice(voice);
  
}
```
Adjusting Pitch, Rate, and Volume
You can change the pitch, speech rate, and volume of the voice using the setPitch(), setSpeechRate(), and setVolume() methods.



### Pitch

``` dart
// Set pitch to a higher value (e.g., 1.0)
await tts.setPitch(1.0);
```
```yaml
Range: 0.5 – 2.0
Default: 1.0
< 1.0 → deeper voice
1.0 → higher voice
```

### Speech Rate

```dart
// Set speech rate to be faster (e.g., 1.0)
await tts.setSpeechRate(1.0);
```

```yaml
Android / iOS:
Range: 0.1 – 2.0
Default: 1.0 (approx. normal speed)
Web:
Range: 0.1 – 10.0 (but realistically 0.5 – 2.0 is usable)
Default: 1.0

To keep things consistent across all platforms, stick to 1.0.
```

### Volume

```dart
// Set volume to half (e.g., 1.0)
await tts.setVolume(1.0);
```
```yaml
Range: 0.5 – 1.0
Default: 1.0 (max)
Same across Android, iOS, and Web.
```
## jira Link 
- [Text to speech](https://appzillon.atlassian.net/browse/AN-184)
