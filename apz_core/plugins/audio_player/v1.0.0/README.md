# apz_audioplayer Usage

## Overview

`ApzAudioPlayer` is a singleton class that provides a simple and clean API for playing audio files from both network URLs and local assets. It wraps the `audioplayers` package, offering a straightforward way to handle audio playback, including options for looping and timed playback.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  apz_audioplayer:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/audio_player/v1.0.0
```

Then run:

```bash
flutter pub get
```

## Example

```dart
import "package:apz_audioplayer/apz_audioplayer.dart";

final apzAudioPlayer = ApzAudioplayer();

// Play an audio file from a network URL
apzAudioPlayer.playUrlAudio(
  audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
);

// Play an audio file from a network URL and stop after 5 seconds
apzAudioPlayer.playUrlAudio(
  audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  stopAfterSeconds: 5,
);

// Play an audio file from assets in a loop
apzAudioPlayer.playAssetAudio(
  audioUrl: 'assets/audio/my_looping_sound.mp3',
  isLoop: true,
);

// Play an audio file from assets and stop after 10 seconds
apzAudioPlayer.playAssetAudio(
  audioUrl: 'assets/audio/my_one_time_sound.mp3',
  stopAfterSeconds: 10,
);

// Play an audio file from files in a loop
apzAudioPlayer.playFileAudio(
  filePath: _filePath,
  isLoop: true,
  );

// Play an audio file from files and stop after 10 seconds
apzAudioPlayer.playFileAudio(
  filePath: _filePath,
  isLoop: true,
  stopAfterSeconds: 10,  
  );

// Stop the currently playing audio and release resources
apzAudioPlayer.stop();
```

## Methods

### playUrlAudio
Plays an audio file from a network URL.

- `audioUrl`: The URL of the audio file.
- `stopAfterSeconds`: (Optional) The duration in seconds after which to stop the audio.
- `isLoop`: (Optional) Set to true to loop the audio. Defaults to false.

### playAssetAudio
Plays an audio file from a local asset.

- `audioUrl`: The path to the audio asset (e.g., 'assets/audio/my_sound.mp3').
- `stopAfterSeconds`: (Optional) The duration in seconds after which to stop the audio.
- `isLoop`: (Optional) Set to true to loop the audio. Defaults to false.

### stop
Stops the currently playing audio and releases the player's resources.

## Testing

The class includes methods for testing purposes:

- `setAudioPlayerForTesting(player)`: Injects a mock AudioPlayer instance for testing.
- `resetForTesting()`: Resets the audio player to null after tests.

## Notes

- Ensure you've included your local audio files in your `pubspec.yaml` under the `assets` section.
- For playing network audio, make sure you have the required internet permissions in your platform-specific configuration files.

## Jira Links

- https://appzillon.atlassian.net/browse/AN-172

