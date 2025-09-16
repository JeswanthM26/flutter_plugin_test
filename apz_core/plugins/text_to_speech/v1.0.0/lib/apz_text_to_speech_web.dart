import "dart:async";
import "dart:js_interop";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/services.dart";
import "package:flutter_web_plugins/flutter_web_plugins.dart";
import "package:web/web.dart" as web;

/// A Flutter web plugin for Text to Speech (TTS) functionality
/// using the Web Speech API.
class ApzTextToSpeechWeb {
  /// Registers the web plugin with the Flutter web plugin registrar.
  static void registerWith(final Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      "apz_text_to_speech",
      const StandardMethodCodec(),
      registrar,
    );
    final ApzTextToSpeechWeb instance = ApzTextToSpeechWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  static final web.SpeechSynthesis _synth = web.window.speechSynthesis;
  static web.SpeechSynthesisUtterance? _utterance;
  static bool _isPaused = false;
  static String? _currentLanguageTag;
  static web.SpeechSynthesisVoice? _currentVoice;
  static double _currentRate = 1;
  static double _currentPitch = 1;
  static double _currentVolume = 1;

  /// Handles method calls from the Flutter side and routes them to
  Future<dynamic> handleMethodCall(final MethodCall call) async {
    switch (call.method) {
      case "speak":
        final Map<dynamic, dynamic> args =
            call.arguments as Map<dynamic, dynamic>;
        final String text = args["text"];
        return speak(text);
      case "stop":
        return stop();
      case "pause":
        return pause();
      case "resume":
        return resume();
      case "getVoices":
        return getVoices();
      case "setVoice":
        final Map<dynamic, dynamic> voiceArgs =
            call.arguments as Map<dynamic, dynamic>;
        final String voiceName = voiceArgs["voiceName"];
        final String locale = voiceArgs["locale"];
        return setVoice(voiceName, locale);
      case "setSpeechRate":
        final Map<dynamic, dynamic> rateArgs =
            call.arguments as Map<dynamic, dynamic>;
        final double rate = rateArgs["rate"];
        return setSpeechRate(rate);
      case "setPitch":
        final Map<dynamic, dynamic> pitchArgs =
            call.arguments as Map<dynamic, dynamic>;
        final double pitch = pitchArgs["pitch"];
        return setPitch(pitch);
      case "setVolume":
        final Map<dynamic, dynamic> volumeArgs =
            call.arguments as Map<dynamic, dynamic>;
        final double volume = volumeArgs["volume"];
        return setVolume(volume);
      default:
        throw UnsupportedPlatformException(
          "apz_text_to_speech for web doesn't implement ${call.method}.",
        );
    }
  }

  /// Speaks the given [text] using text-to-speech.
  Future<bool> speak(final String text) async {
    // Consider the engine paused if
    // our own flag says so (and optionally check _synth.paused if available)
    final bool paused = _isPaused;
    // or: final bool paused = _isPaused || _synth.paused;

    // If paused: replace if text differs, otherwise resume
    if (paused) {
      final bool sameTextAsPaused = (_utterance?.text ?? "") == text;
      if (!sameTextAsPaused) {
        _synth.cancel();
        // Give the engine a tick to
        //flush the queue before speaking a new utterance
        await Future<void>.delayed(Duration.zero);
      } else {
        _synth.resume();
        _isPaused = false;
        return true;
      }
    } else if (_synth.speaking) {
      // If already speaking, flush the current utterance before starting new
      _synth.cancel();
      await Future<void>.delayed(Duration.zero);
    }

    // Build new utterance
    final web.SpeechSynthesisUtterance u = web.SpeechSynthesisUtterance(text);
    _utterance = u;

    if (_currentLanguageTag != null) {
      u.lang = _currentLanguageTag!;
    }
    if (_currentVoice != null) {
      u.voice = _currentVoice;
    }
    u
      ..rate = _currentRate
      ..pitch = _currentPitch
      ..volume = _currentVolume
      // Keep our pause state in sync with engine events
      ..onend =
          ((web.Event _) {
                _isPaused = false;
              }).toJS
              as web.EventHandler
      ..onpause =
          ((web.Event _) {
                _isPaused = true;
              }).toJS
              as web.EventHandler
      ..onresume =
          ((web.Event _) {
                _isPaused = false;
              }).toJS
              as web.EventHandler
      ..onerror =
          ((web.Event _) {
                _isPaused = false;
              }).toJS
              as web.EventHandler;

    _isPaused = false;
    _synth.speak(u);
    return true;
  }

  /// Stops any ongoing speech.
  Future<bool> stop() async {
    _synth.cancel();
    _isPaused = false;
    return true;
  }

  /// Pauses the ongoing speech.
  Future<bool> pause() async {
    if (_synth.speaking && !_isPaused) {
      _synth.pause();
      _isPaused = true;
      return true;
    }
    return false;
  }

  /// Resumes the paused speech.
  Future<bool> resume() async {
    if (_isPaused) {
      _synth.resume();
      _isPaused = false;
      return true;
    }
    return false;
  }

  /// Returns a list of available voices with their names and language tags.
  Future<List<Map<dynamic, dynamic>>> getVoices() async {
    final Completer<List<Map<String, String>>> completer =
        Completer<List<Map<String, String>>>();
    final List<web.SpeechSynthesisVoice> voices = _synth.getVoices().toDart;
    if (voices.isNotEmpty) {
      completer.complete(
        voices
            .map(
              (final web.SpeechSynthesisVoice v) => <String, String>{
                "name": v.name,
                "locale": v.lang,
              },
            )
            .toSet()
            .toList(),
      );
    } else {
      void handler(final web.Event event) {
        final List<web.SpeechSynthesisVoice> updatedVoices = _synth
            .getVoices()
            .toDart;
        completer.complete(
          updatedVoices
              .map(
                (final web.SpeechSynthesisVoice v) => <String, String>{
                  "name": v.name,
                  "locale": v.lang,
                },
              )
              .toSet()
              .toList(),
        );
        _synth.removeEventListener("voiceschanged", handler.toJS);
      }

      _synth.addEventListener("voiceschanged", handler.toJS);
    }
    return completer.future;
  }

  /// Sets the voice for speech using the given [voiceName].
  Future<bool> setVoice(final String voiceName, final String locale) async {
    final List<web.SpeechSynthesisVoice> voices = _synth
        .getVoices()
        .toDart;
    
    try {
      final web.SpeechSynthesisVoice voice = voices.firstWhere(
        (final web.SpeechSynthesisVoice v) =>
            v.name == voiceName && v.lang == locale,
      );
      // We save the selected voice to a class-level variable
      _currentVoice = voice;
      return true;
    } on Exception {
      return false;
    }
  }

  /// Sets the speech rate using the given [rate].
  Future<bool> setSpeechRate(final double rate) async {
    _currentRate = rate * 2.0; // Map Flutter rate to Web Speech API range
    return true;
  }

  /// Sets the pitch for speech using the given [pitch].
  Future<bool> setPitch(final double pitch) async {
    _currentPitch = pitch;
    return true;
  }

  /// Sets the volume for speech using the given [volume].
  Future<bool> setVolume(final double volume) async {
    _currentVolume = volume;
    return true;
  }
}
