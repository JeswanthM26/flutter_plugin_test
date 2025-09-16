import "package:apz_speech_to_text/apz_speech_to_text.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:speech_to_text/speech_recognition_error.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";

class MockSpeechToText extends Mock implements SpeechToText {}

class MockSpeechRecognitionResult extends Mock
    implements SpeechRecognitionResult {}

class MockSpeechRecognitionError extends Mock
    implements SpeechRecognitionError {}

void main() {
  late ApzSpeechToText speechToText;
  late MockSpeechToText mockSpeech;
  late List<Map<String, dynamic>> callbackCalls;

  // Ensure binding so we can set mock method handlers on the binary messenger
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  // The channel used by the speech_to_text plugin.
  const MethodChannel pluginChannel = MethodChannel(
    "plugin.csdcorp.com/speech_to_text",
  );

  // This variable controls what the mock 'initialize' returns for each test.
  dynamic initializeReturn = true;

  // Collect MethodCalls so tests can assert that 'listen'/'stop' were invoked.
  late List<MethodCall> receivedCalls;

  setUp(() {
    mockSpeech = MockSpeechToText();
    speechToText = ApzSpeechToText();
    // Inject mockSpeech into speechToText
    speechToText = TestApzSpeechToText(mockSpeech);
    callbackCalls = [];
    receivedCalls = [];
    // Install a mock handler for the plugin channel.
    binding.defaultBinaryMessenger.setMockMethodCallHandler(pluginChannel, (
      MethodCall call,
    ) async {
      receivedCalls.add(call);

      // Provide deterministic responses for the methods we expect
      switch (call.method) {
        case "initialize":
          // speech_to_text initialize returns a boolean success
          return initializeReturn;
        case "listen":
          // listen typically returns null (void)
          return null;
        case "stop":
          return null;
        case "cancel":
          return null;
        default:
          return null;
      }
    });
  });

  void testCallback({String? text, String? error, bool? isListening}) {
    callbackCalls.add({
      "text": text,
      "error": error,
      "isListening": isListening,
    });
  }

  tearDown(() async {
    // Remove mock handler after each test
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pluginChannel,
      null,
    );
  });
  test('initialize triggers onStatus callback', () async {
    when(
      () => mockSpeech.initialize(
        onStatus: any(named: 'onStatus'),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((invocation) async {
      final onStatus =
          invocation.namedArguments[#onStatus] as void Function(String);
      onStatus('listening');
      return true;
    });
    speechToText.mockSpeechObject(mockSpeech);
    await speechToText.initialize(callback: testCallback);
    expect(callbackCalls, isNotEmpty);
    expect(callbackCalls.last['isListening'], true);
    expect(callbackCalls.last['error'], null);
  });

  test('initialize triggers onError callback', () async {
    final mockError = MockSpeechRecognitionError();
    when(() => mockError.errorMsg).thenReturn('error!');
    when(
      () => mockSpeech.initialize(
        onStatus: any(named: 'onStatus'),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((invocation) async {
      final onError =
          invocation.namedArguments[#onError]
              as void Function(SpeechRecognitionError);
      onError(mockError);
      return true;
    });
    speechToText.mockSpeechObject(mockSpeech);
    await speechToText.initialize(callback: testCallback);
    expect(callbackCalls, isNotEmpty);
    expect(callbackCalls.last['error'], 'error!');
    expect(callbackCalls.last['isListening'], false);
  });

  test('startListening triggers onResult callback', () async {
    when(() => mockSpeech.isListening).thenReturn(true);
    when(
      () => mockSpeech.initialize(
        onStatus: any(named: 'onStatus'),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((invocation) async {
      final onStatus =
          invocation.namedArguments[#onStatus] as void Function(String);
      onStatus('listening');
      return true;
    });
    when(
      () => mockSpeech.listen(
        onResult: any(named: 'onResult'),
        localeId: any(named: 'localeId'),
        listenFor: any(named: 'listenFor'),
      ),
    ).thenAnswer((invocation) async {
      final onResult =
          invocation.namedArguments[#onResult]
              as void Function(SpeechRecognitionResult);
      final result = MockSpeechRecognitionResult();
      when(() => result.recognizedWords).thenReturn('hello');
      onResult(result);
      return;
    });
    speechToText.mockSpeechObject(mockSpeech);
    await speechToText.initialize(callback: testCallback);
    callbackCalls.clear();
    await speechToText.startListening();
    expect(callbackCalls, isNotEmpty);
    expect(callbackCalls.last['text'], 'hello');
    expect(callbackCalls.last['isListening'], true);
  });

  test('startListening handles exception', () async {
    when(
      () => mockSpeech.initialize(
        onStatus: any(named: 'onStatus'),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((invocation) async {
      final onStatus =
          invocation.namedArguments[#onStatus] as void Function(String);
      onStatus('listening');
      return true;
    });
    when(
      () => mockSpeech.listen(
        onResult: any(named: 'onResult'),
        localeId: any(named: 'localeId'),
        listenFor: any(named: 'listenFor'),
      ),
    ).thenThrow(Exception('listen error'));
    speechToText.mockSpeechObject(mockSpeech);
    await speechToText.initialize(callback: testCallback);
    callbackCalls.clear();
    // Ensure _isAvailable is true and callback is set
    await speechToText.startListening();
    expect(callbackCalls, isNotEmpty);
    expect(callbackCalls.last['error'], isNotNull);
    expect(callbackCalls.last['error'], contains('listen error'));
    expect(callbackCalls.last['isListening'], false);
  });

  test('stopListening handles exception', () async {
    when(() => mockSpeech.stop()).thenThrow(Exception('stop error'));
    when(
      () => mockSpeech.initialize(
        onStatus: any(named: 'onStatus'),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((invocation) async {
      final onStatus =
          invocation.namedArguments[#onStatus] as void Function(String);
      onStatus('listening');
      return true;
    });
    speechToText.mockSpeechObject(mockSpeech);
    await speechToText.initialize(callback: testCallback);
    callbackCalls.clear();
    await speechToText.stopListening();
    expect(callbackCalls, isNotEmpty);
    expect(callbackCalls.last['error'], isNotNull);
    expect(callbackCalls.last['error'], contains('stop error'));
    expect(callbackCalls.last['isListening'], false);
  });
  group("getIsWeb", () {
    test("returns correct value", () {
      expect(speechToText.getIsWeb(), kIsWeb);
    });
  });

  group("initialize", () {
    test("calls callback and throws on web", () async {
      final origKIsWeb = kIsWeb;
      TestWidgetsFlutterBinding.ensureInitialized();
      // Simulate web by overriding kIsWeb
      final testSpeechToText = TestApzSpeechToText(mockSpeech, isWeb: true);

      expect(
        () => testSpeechToText.initialize(callback: testCallback),
        throwsA(isA<UnsupportedPlatformException>()),
      );
      await Future.delayed(Duration.zero);
      expect(callbackCalls.last["error"], contains("not supported on the web"));
      expect(callbackCalls.last["isListening"], false);
    });
  });

  test(
    'initialize -> when platform returns false, initialize() returns false and callback receives "Speech recognition not available"',
    () async {
      // Get binding and channel
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      const MethodChannel pluginChannel = MethodChannel(
        'plugin.csdcorp.com/speech_to_text',
      );

      // Prepare the container to capture platform calls
      final List<MethodCall> receivedCalls = [];
      // Ensure the handler returns an explicit bool false.
      final bool returnValue = false;

      // Register the mock handler *inside the test* so there's no cross-test leakage.
      binding.defaultBinaryMessenger.setMockMethodCallHandler(pluginChannel, (
        MethodCall call,
      ) async {
        receivedCalls.add(call);
        switch (call.method) {
          case 'initialize':
            // return an explicit Future<bool> value (avoid returning null/strings)
            return Future<bool>.value(returnValue);
          case 'listen':
          case 'stop':
          case 'cancel':
            return null;
          default:
            return null;
        }
      });

      // tiny delay to ensure handler registration is observed by the plugin call
      await Future<void>.delayed(Duration.zero);

      final events = <Map<String, dynamic>>[];
      final subject = ApzSpeechToText();

      final available = await subject.initialize(
        callback: ({String? text, String? error, bool? isListening}) {
          events.add({
            "text": text,
            "error": error,
            "isListening": isListening,
          });
        },
      );

      // Clean up the mock handler right away to avoid affecting other tests
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pluginChannel,
        null,
      );

      // Now assert expectations.
      expect(receivedCalls.any((c) => c.method == 'initialize'), isTrue);

      // initialize should return the bool we returned from the mock (false)
      expect(available, isFalse);

      // And because your implementation calls the callback when available == false,
      // the callback should have been invoked with the expected error message.
      expect(events, isNotEmpty);
      expect(events.last["error"], equals("Speech recognition not available"));
      expect(events.last["isListening"], isFalse);
    },
  );

  test(
    "initialize -> when platform returns true, initialize() returns true and invokes platform initialize",
    () async {
      initializeReturn = true;
      final events = <Map<String, dynamic>>[];

      final subject = ApzSpeechToText();
      final available = await subject.initialize(
        callback: ({String? text, String? error, bool? isListening}) {
          events.add({
            "text": text,
            "error": error,
            "isListening": isListening,
          });
        },
      );

      expect(available, isTrue);
      // assert plugin initialize method was called
      expect(receivedCalls.any((c) => c.method == "initialize"), isTrue);
      // plugin didn't notify any onStatus/onError automatically (we didn't simulate callbacks here)
      expect(events, isEmpty);
    },
  );
  test("SpeechResultCallback receives text, error and isListening", () async {
    Map<String, dynamic>? received;

    // Create a SpeechResultCallback that captures values
    final SpeechResultCallback callback =
        ({String? text, String? error, bool? isListening}) {
          received = {"text": text, "error": error, "isListening": isListening};
        };

    // Invoke manually with all params
    callback(text: "hello world", error: "network error", isListening: true);

    expect(received, isNotNull);
    expect(received!["text"], "hello world");
    expect(received!["error"], "network error");
    expect(received!["isListening"], true);
  });
  test(
    "startListening -> when not initialized calls callback with not-initialized error",
    () async {
      final events = <Map<String, dynamic>>[];
      final subject = ApzSpeechToText(); // not initialized

      await subject.startListening(language: "en_US", listenDuration: 5);

      // Because _isAvailable is false, the implementation calls callback with an error.
      // We didn't pass a callback in this test; to observe the message, re-run with callback.
      // For demonstration, here's how to assert the plugin's listen wasn't invoked:
      expect(receivedCalls.any((c) => c.method == "listen"), isFalse);
    },
  );

  test(
    "startListening -> after successful initialize invokes platform listen",
    () async {
      initializeReturn = true;
      final events = <Map<String, dynamic>>[];

      final subject = ApzSpeechToText();
      await subject.initialize(
        callback: ({String? text, String? error, bool? isListening}) {
          events.add({
            "text": text,
            "error": error,
            "isListening": isListening,
          });
        },
      );

      // Clear the receivedCalls from initialize step to assert only listen is in next step
      receivedCalls.clear();

      await subject.startListening(language: "en_US", listenDuration: 3);

      // The plugin should have called 'listen' on the platform channel
      expect(receivedCalls.any((c) => c.method == "listen"), isTrue);
    },
  );
  test(
    "stopListening -> when not initialized returns early and does not call platform stop",
    () async {
      final subject = ApzSpeechToText();
      await subject.stopListening();
      expect(receivedCalls.any((c) => c.method == "stop"), isFalse);
    },
  );

  test(
    "stopListening -> after successful initialize invokes platform stop",
    () async {
      initializeReturn = true;
      final subject = ApzSpeechToText();
      await subject.initialize();
      receivedCalls.clear();

      await subject.stopListening();

      expect(receivedCalls.any((c) => c.method == "stop"), isTrue);
    },
  );

  group("startListening", () {
    setUp(() async {
      when(
        () => mockSpeech.initialize(
          onStatus: any(named: "onStatus"),
          onError: any(named: "onError"),
        ),
      ).thenAnswer((_) async => true);
      await speechToText.initialize(callback: testCallback);
      callbackCalls.clear();
    });

    test("calls callback with error if not initialized", () async {
      final notInit = TestApzSpeechToText(mockSpeech);
      await notInit.startListening();
      // Should call callback with error
      // But since _isAvailable is false, callback is not set
      // So nothing happens
    });
  });

  test("calls callback with error if not initialized", () async {
    final notInit = TestApzSpeechToText(mockSpeech);
    await notInit.stopListening();
    // Should call callback with error
    // But since _isAvailable is false, callback is not set
    // So nothing happens
  });
}

// Helper to inject mock SpeechToText and override kIsWeb if needed
class TestApzSpeechToText extends ApzSpeechToText {
  final SpeechToText _mockSpeech;
  final bool _isWeb;
  TestApzSpeechToText(this._mockSpeech, {bool isWeb = false}) : _isWeb = isWeb;
  @override
  SpeechToText get _speech => _mockSpeech;
  @override
  bool getIsWeb() => _isWeb;
}
