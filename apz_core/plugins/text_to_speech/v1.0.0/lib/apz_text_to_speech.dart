import "package:apz_text_to_speech/config.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

/// A Flutter plugin for Text to Speech (TTS) functionality
/// across Android, iOS, and Web.
class ApzTextToSpeech {
  /// Factory constructor to ensure singleton usage.
  factory ApzTextToSpeech() => _instance;

  /// Constructor to initialize the plugin and set up callbacks.
  ApzTextToSpeech._() {
    _setupCallbacks();
  }
  static final ApzTextToSpeech _instance = ApzTextToSpeech._();

  static const MethodChannel _channel = MethodChannel("apz_text_to_speech");

  // Events from native side
  /// Notifier for when speech starts.
  final ValueNotifier<String?> _onStart = ValueNotifier<String?>(null);

  /// For Testing Purpose
  @visibleForTesting
  ValueNotifier<String?> get onStart => _onStart;

  /// Notifier for when speech completes.
  final ValueNotifier<String?> _onCompletion = ValueNotifier<String?>(null);

  /// For Testing Purpose
  @visibleForTesting
  ValueNotifier<String?> get onCompletion => _onCompletion;

  /// Notifier for when an error occurs during speech.
  final ValueNotifier<String?> _onError = ValueNotifier<String?>(null);

  /// For Testing Purpose
  @visibleForTesting
  ValueNotifier<String?> get onError => _onError;

  /// Notifier for when speech is stopped.
  final ValueNotifier<String?> _onStop = ValueNotifier<String?>(null);

  /// For Testing Purpose
  @visibleForTesting
  ValueNotifier<String?> get onStop => _onStop;
  
  bool _callbacksInitialized = false;

  void _setupCallbacks() {
    if (_callbacksInitialized) {
      return;
    }
    _callbacksInitialized = true;

    _channel.setMethodCallHandler((final MethodCall call) async {
      switch (call.method) {
        case "onStart":
          _onStart.value = call.arguments?.toString();
        case "onCompletion":
          _onCompletion.value = call.arguments?.toString();
        case "onError":
          _onError.value = call.arguments?.toString();
        case "onStop":
          _onStop.value = call.arguments?.toString();
      }
    });
  }

  /// Speaks the given [text] using text-to-speech.
  Future<bool> speak(final String text) async {
    await stop(); // Stop any ongoing speech
    return await _channel.invokeMethod("speak", <String, String>{"text": text});
  }

  /// Stops any ongoing speech.
  Future<bool> stop() async => await _channel.invokeMethod("stop");

  /// Pauses the ongoing speech.
  Future<bool> pause() async => await _channel.invokeMethod("pause");

  /// Resumes the paused speech.
  Future<bool> resume() async => await _channel.invokeMethod("resume");

  /// Returns a list of available voices with their names and language tags.
  Future<Map<String, List<String>>> getVoices() async {
    final List<dynamic> voices = await _channel.invokeMethod("getVoices");
    final Map<String, Set<String>> grouped = <String, Set<String>>{};
    for (final Map<dynamic, dynamic> v in voices) {
      final String name = v["name"] as String;
      final String locale = v["locale"] as String;

      grouped.putIfAbsent(name, () => <String>{}).add(locale);
    }
    // Convert the Sets back to Lists before returning
    return grouped.map(
      (final String key, final Set<String> value) =>
          MapEntry<String, List<String>>(key, value.toList()),
    );
  }

  /// Sets the voice for speech using the given [voiceName].
  Future<bool> setVoice(final String voiceName, final String locale) async {
    // First fetch available voices from the device
    final Map<String, List<String>> voices = await getVoices();
    if (!voices.containsKey(voiceName)) {
      throw Exception("Selected $voiceName not supported.");
    }
    if (!isLocalePresent(voices, locale)) {
      throw Exception("Selected $locale not supported for this $voiceName");
    }
    return await _channel.invokeMethod("setVoice", <String, String>{
      "voiceName": voiceName,
      "locale": locale,
    });
  }

  final double _minRate = minRate;
  // Some platforms crash on 0
  final double _maxRate = maxRate; // Android/iOS usually allow ~0.1–2.0

  final double _minPitch = 0.5;
  final double _maxPitch = 2; // Safari caps around 2

  final double _minVolume = 0.5; // 0 = mute
  final double _maxVolume = 1; // 1 = full volume

  double _clamp(final double value, final double min, final double max) =>
      value.clamp(min, max);

  /// Sets the speech rate (speed) using the given [rate].
  Future<bool> setSpeechRate(final double rate) async {
    final double safeRate = _clamp(rate, _minRate, _maxRate);
    return await _channel.invokeMethod("setSpeechRate", <String, double>{
      "rate": safeRate,
    });
  }

  /// Sets the pitch for speech using the given [pitch].
  Future<bool> setPitch(final double pitch) async {
    final double safePitch = _clamp(pitch, _minPitch, _maxPitch);
    return await _channel.invokeMethod("setPitch", <String, double>{
      "pitch": safePitch,
    });
  }

  /// Sets the volume for speech using the given [volume].
  Future<bool> setVolume(final double volume) async {
    final double safeVolume = _clamp(volume, _minVolume, _maxVolume);
    return await _channel.invokeMethod("setVolume", <String, double>{
      "volume": safeVolume,
    });
  }
}
