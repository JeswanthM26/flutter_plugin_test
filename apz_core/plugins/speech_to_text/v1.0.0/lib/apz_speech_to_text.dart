import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:speech_to_text/speech_recognition_error.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";

///speech to text plugin
class ApzSpeechToText {
  SpeechToText _speech = SpeechToText();
  SpeechResultCallback? _callback;
  bool _isAvailable = false;

  @visibleForTesting
  /// For testing purposes, allows mocking the SpeechToText object
  /// This should only be used in tests to inject a mock or stub.
  // ignore: use_setters_to_change_properties
  void mockSpeechObject(final SpeechToText speech) {
    _speech = speech;
  }

  /// Returns true if the current platform is web.
  bool getIsWeb() => kIsWeb;

  /// Initialize the plugin
  Future<bool> initialize({final SpeechResultCallback? callback}) async {
    _callback = callback;
    if (getIsWeb()) {
      const String error = "This plugin is not supported on the web platform";
      _callback?.call(text: null, error: error, isListening: false);
      throw UnsupportedPlatformException(error);
    }
    try {
      final bool available = await _speech.initialize(
        onStatus: (final String status) {
          _callback?.call(
            text: null,
            error: null,
            isListening: status == "listening",
          );
        },
        onError: (final SpeechRecognitionError error) {
          _callback?.call(
            text: null,
            error: error.errorMsg,
            isListening: false,
          );
        },
      );
      // Set availability based on initialization result
      _isAvailable = available;

      if (!available) {
        // notify caller that initialization failed
        _callback?.call(
          text: null,
          error: "Speech recognition not available",
          isListening: false,
        );
      }
      return available;
    } on Exception catch (e) {
      _isAvailable = false;
      _callback?.call(text: null, error: e.toString(), isListening: false);
      return false;
    }
  }

  /// Start listening
  Future<void> startListening({
    final String language = "en_US", // default English
    final int listenDuration = 30, // default 30 seconds
  }) async {
    if (!_isAvailable) {
      _callback?.call(
        text: null,
        error: "Speech plugin not initialized. Call initialize() first.",
        isListening: false,
      );
      return;
    }
    try {
      await _speech.listen(
        onResult: (final SpeechRecognitionResult result) {
          _callback?.call(
            text: result.recognizedWords,
            error: null,
            isListening: _speech.isListening,
          );
        },
        localeId: language,
        listenFor: Duration(seconds: listenDuration),
      );
    } on Exception catch (e) {
      _callback?.call(text: null, error: e.toString(), isListening: false);
    }
  }

  /// Stop listening (process result)
  Future<void> stopListening() async {
    if (!_isAvailable) {
      _callback?.call(
        text: null,
        error: "Speech plugin not initialized. Nothing to stop.",
        isListening: false,
      );
      return;
    }
    try {
      await _speech.stop();
      // Inform caller we've stopped listening (no error)
      _callback?.call(text: null, error: null, isListening: false);
    } on Exception catch (e) {
      _callback?.call(text: null, error: e.toString(), isListening: false);
    }
  }
}

/// A callback type for receiving speech recognition results.
typedef SpeechResultCallback =
    void Function({String? text, String? error, bool? isListening});
