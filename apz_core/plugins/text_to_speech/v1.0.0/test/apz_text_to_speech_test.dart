import "package:apz_text_to_speech/apz_text_to_speech.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel("apz_text_to_speech");
  final ApzTextToSpeech tts = ApzTextToSpeech();

  setUp(() {
    // Reset handler before every test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case "speak":
              return true;
            case "stop":
              return true;
            case "pause":
              return true;
            case "resume":
              return true;
            case "getVoices":
              return [
                {"name": "Alice", "locale": "en-US"},
                {"name": "Ravi", "locale": "hi-IN"},
                // Intentionally add a duplicate to test filtering
                {"name": "Alice", "locale": "en-US"},
              ];
            case "setVoice":
              // Check that both voiceName and locale are passed correctly
              final String? voiceName = methodCall.arguments["voiceName"];
              final String? locale = methodCall.arguments["locale"];
              if (voiceName == "VoiceA" && locale == "en-US") {
                return true;
              }
              return false;
            case "setSpeechRate":
              return true;
            case "setPitch":
              return true;
            case "setVolume":
              return true;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test("speak calls native and returns true", () async {
    final result = await tts.speak("Hello");
    expect(result, true);
  });

  test("stop calls native and returns true", () async {
    final result = await tts.stop();
    expect(result, true);
  });

  test("pause calls native and returns true", () async {
    final result = await tts.pause();
    expect(result, true);
  });

  test("resume calls native and returns true", () async {
    final result = await tts.resume();
    expect(result, true);
  });

  test("setSpeechRate returns true", () async {
    final result = await tts.setSpeechRate(1.2);
    expect(result, true);
  });

  test("setPitch returns true", () async {
    final result = await tts.setPitch(0.9);
    expect(result, true);
  });

  test("setVolume returns true", () async {
    final result = await tts.setVolume(0.5);
    expect(result, true);
  });

  test("callbacks update ValueNotifiers", () async {
    // Simulate callback from native side
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall("onStart", "Hello")),
      (_) {},
    );

    expect(tts.onStart.value, "Hello");
  });
  test("callbacks update ValueNotifiers", () async {
    // Simulate callback from native side
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall("onCompletion", "Hello")),
      (_) {},
    );

    expect(tts.onCompletion.value, "Hello");
  });
  test("callbacks update ValueNotifiers", () async {
    // Simulate callback from native side
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall("onError", "Error")),
      (_) {},
    );

    expect(tts.onError.value, "Error");
  });
  test("callbacks update ValueNotifiers", () async {
    // Simulate callback from native side
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall("onStop", "Stop")),
      (_) {},
    );

    expect(tts.onStop.value, "Stop");
  });

  group("Voice Methods", () {
    test("getVoices returns a grouped map of voices", () async {
      final Map<String, List<String>> voices = await tts.getVoices();
      expect(voices, {
        "Alice": ["en-US"],
        "Ravi": ["hi-IN"],
      });
    });

    test("setVoice succeeds with a valid voice and locale", () async {
      // Mock getVoices() to return a valid map for this test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == "getVoices") {
          return [
            {"name": "Alice", "locale": "en-US"},
          ];
        }
        if (methodCall.method == "setVoice") {
          return true;
        }
        return null;
      });
      final bool result = await tts.setVoice("Alice", "en-US");
      expect(result, isTrue);
    });

    test("setVoice throws an exception for unsupported voice", () async {
      // Mock getVoices() to return a map that doesn't contain the requested voice
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == "getVoices") {
          return [
            {"name": "Ravi", "locale": "hi-IN"},
          ];
        }
        return null;
      });
      expect(
        () => tts.setVoice("Alice", "en-US"),
        throwsA(isA<Exception>()),
      );
    });

    test("setVoice throws an exception for unsupported locale", () async {
      // Mock getVoices() to return a map where the voice exists, but not the locale
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == "getVoices") {
          return [
            {"name": "Alice", "locale": "fr-FR"},
          ];
        }
        return null;
      });
      expect(
        () => tts.setVoice("Alice", "en-US"),
        throwsA(isA<Exception>()),
      );
    });
  });
}
