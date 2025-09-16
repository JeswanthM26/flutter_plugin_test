import "dart:async";
import "package:audioplayers/audioplayers.dart";


/// Singleton class to handle audio playback using the audioplayers package.
class ApzAudioplayer {

  /// Factory constructor to return the same instance every time
  factory ApzAudioplayer() => _instance;
  // Private constructor
  ApzAudioplayer._internal();
  static final ApzAudioplayer _instance = ApzAudioplayer._internal();

  AudioPlayer? _testAudioPlayer;
  AudioPlayer? _realAudioPlayer;

  AudioPlayer get _audioPlayer =>
      _testAudioPlayer ??= _realAudioPlayer ??= AudioPlayer();

 /// Sets a test audio player for unit testing purposes.
 // ignore: use_setters_to_change_properties
  void setAudioPlayerForTesting(final AudioPlayer player) {
    _testAudioPlayer = player;
  }
  
  /// Resets the audio player to null for testing purposes.
  void resetForTesting() {
    _testAudioPlayer = null;
  }




  /// Plays audio from a URL.
  /// If [stopAfterSeconds] is provided, the audio will stop 
  /// after that many seconds.
  Future<void> playUrlAudio({
    required final String audioUrl,
    final int? stopAfterSeconds,
    final bool isLoop = false,
  }) async {

    if (stopAfterSeconds != null) {
       if (isLoop) {
     await _audioPlayer.stop();
     await _audioPlayer.setReleaseMode(ReleaseMode.loop);
     await _audioPlayer.play(UrlSource(audioUrl));  
      Future<void>.delayed(
        Duration(seconds: stopAfterSeconds),
        _audioPlayer.stop,
      );
       }else {
    await _audioPlayer.stop();
     await _audioPlayer.setReleaseMode(ReleaseMode.release);
    await _audioPlayer.play(UrlSource(audioUrl));  
      Future<void>.delayed(
        Duration(seconds: stopAfterSeconds),
        _audioPlayer.stop,
      );
       }

    } else {
      if (isLoop) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(UrlSource(audioUrl));

      } else {
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.play(UrlSource(audioUrl));
    }
    }
  }

  /// Plays audio from an asset.
  /// If [stopAfterSeconds] is provided, the audio will 
  /// stop after that many seconds.
  Future<void> playAssetAudio({
    required final String audioUrl,
    final int? stopAfterSeconds,
    final bool isLoop = false,
  }) async {
    if (stopAfterSeconds != null) {
    if (isLoop) {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(audioUrl));
      Future<void>.delayed(
        Duration(seconds: stopAfterSeconds),
        _audioPlayer.stop,
      );
    }else{
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.play(AssetSource(audioUrl));
      Future<void>.delayed(
        Duration(seconds: stopAfterSeconds),
        _audioPlayer.stop,
      );
    }

    } else {
      if (isLoop) {
         await _audioPlayer.setReleaseMode(ReleaseMode.loop);
         await _audioPlayer.play(AssetSource(audioUrl));
      } else {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.play(AssetSource(audioUrl));
    }
    }
  }

  /// Plays audio from an file.
  /// If [stopAfterSeconds] is provided, the audio will 
  /// stop after that many seconds.
  Future<void> playFileAudio({
    required final String filePath,
    final int? stopAfterSeconds,
    final bool isLoop = false,
  }) async {
    if (stopAfterSeconds != null) {
    if (isLoop) {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(DeviceFileSource(filePath));
      Future<void>.delayed(
        Duration(seconds: stopAfterSeconds),
        _audioPlayer.stop,
      );
    }else{
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.play(DeviceFileSource(filePath));
      Future<void>.delayed(
        Duration(seconds: stopAfterSeconds),
        _audioPlayer.stop,
      );
    }

    } else {
      if (isLoop) {
         await _audioPlayer.setReleaseMode(ReleaseMode.loop);
         await _audioPlayer.play(DeviceFileSource(filePath));
      } else {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.play(DeviceFileSource(filePath));
    }
    }
  }  

  /// Stops playback and releases resources.
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.release();
  }

}
