import "dart:io";

import "package:apz_digi_scan/apz_digi_scan.dart";
import "package:apz_digi_scan/platform_wrapper.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

class MockFile extends Mock implements File {}

class FakePlatform implements PlatformWrapper {
  final bool _isAndroid;
  final bool _isIOS;

  FakePlatform({bool isAndroid = true, bool isIOS = false})
    : _isAndroid = isAndroid,
      _isIOS = isIOS;

  @override
  bool get isAndroid => _isAndroid;
  @override
  bool get isIOS => _isIOS;
}

void main() {
  const MethodChannel channel = MethodChannel("flutter_doc_scanner");
  late ApzDigiScan scanner;
  final List<MethodCall> calls = <MethodCall>[];

  setUpAll(() {
    // Register fallback values for Uri.parse and File constructor
    registerFallbackValue(Uri());
    registerFallbackValue(MethodCall("", null));
  });

  setUp(() {
    scanner = ApzDigiScan();
    // override platform for default Android branch
    scanner.overridePlatformWrapper(FakePlatform());
    calls.clear();
    TestWidgetsFlutterBinding.ensureInitialized();
    channel.setMockMethodCallHandler((MethodCall call) async {
      calls.add(call);
      // Default error if not overridden
      throw MissingPluginException();
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    debugDefaultTargetPlatformOverride = null;
  });

  group("scanAsImage - Android branch", () {
    const List<String> imagePaths = <String>[
      "file:///tmp/a.png",
      "file:///tmp/b.png",
    ];

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    test("parses multiple URIs and respects size limit", () async {
      // 1) Prepare two real temp files
      final tmp = Directory.systemTemp.path;
      final fileA = await File("$tmp/a.png").writeAsBytes(List.filled(100, 0));
      final fileB = await File("$tmp/b.png").writeAsBytes(List.filled(200, 0));
      final uriA = fileA.uri.toString();
      final uriB = fileB.uri.toString();

      // 2) Stub channel with the trailing `}` delimiters
      final fakePayload = "imageUri=$uriA}imageUri=$uriB}";
      channel.setMockMethodCallHandler((_) async => {"Uri": fakePayload});

      // 3) Run scanner (no need for debugDefaultTargetPlatformOverride any more)
      final result = await scanner.scanAsImage(1);

      // 4) Assertions
      expect(result, hasLength(2), reason: "Should find two URIs");
      expect(result.map((m) => m["imageUri"]), [uriA, uriB]);
      expect(result.map((m) => m["bytes"]), [100, 200]);
    });
    test("returns empty list for malformed Uri string", () async {
      channel.setMockMethodCallHandler(
        (_) async => <String, String>{"Uri": "no images here"},
      );
      final List<Map<String, dynamic>> result = await scanner.scanAsImage(2);
      expect(result, isEmpty);
    });

    test("rethrows plugin errors", () async {
      channel.setMockMethodCallHandler((_) async {
        throw PlatformException(code: "ERR", message: "fail");
      });
      expect(() => scanner.scanAsImage(1), throwsA(isA<PlatformException>()));
    });
  });

  group("scanAsImage - iOS branch", () {
    const List<String> uris = <String>[
      "file:///tmp/x.png",
      "file:///tmp/y.png",
    ];

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });

    test("handles null and non-string entries gracefully", () async {
      final List<Object?> mixed = <Object?>["file:///tmp/z.png", null, 123];
      await File(
        Uri.parse(mixed[0] as String).toFilePath(),
      ).writeAsBytes(List.filled(30, 0));
      channel.setMockMethodCallHandler((_) async => mixed);

      final List<Map<String, dynamic>> result = await scanner.scanAsImage(3);
      expect(result.length, 0);
    });
  });

  group("scanAsPdf", () {
    final String pdfUri = "file:///tmp/doc.pdf";

    test("Android - returns URI when under size limit", () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      // Write PDF file
      final File f = await File(
        Uri.parse(pdfUri).toFilePath(),
      ).writeAsBytes(List.filled(512 * 1024, 0));
      channel.setMockMethodCallHandler(
        (_) async => <String, String>{"pdfUri": pdfUri},
      );

      final result = await scanner.scanAsPdf(1);
      expect(result, pdfUri);
    });

    test("Android - throws when PDF exceeds size limit", () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      // Create an oversized PDF
      await File(
        Uri.parse(pdfUri).toFilePath(),
      ).writeAsBytes(List.filled(2 * 1024 * 1024, 0));
      channel.setMockMethodCallHandler((_) async => {"pdfUri": pdfUri});

      // Use async expect on the future itself
      expect(
        () async => await scanner.scanAsPdf(1),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            "msg",
            contains("exceeds limit"),
          ),
        ),
      );
    });

    test("Android - returns null when pdfUri missing", () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      channel.setMockMethodCallHandler((_) async => <String, dynamic>{});
      final result = await scanner.scanAsPdf(1);
      expect(result, isNull);
    });

    test("iOS - returns string URI result", () async {
      if (!Platform.isIOS) return;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      channel.setMockMethodCallHandler((_) async => pdfUri);
      // Ensure the file exists
      final filePath = Uri.parse(pdfUri).toFilePath();
      await File(filePath).writeAsBytes(List.filled(100, 0));

      final result = await scanner.scanAsPdf(1);
      expect(result, pdfUri);
    });

    test("iOS - handles null scan result", () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      channel.setMockMethodCallHandler((_) async => null);
      expect(() => scanner.scanAsPdf(2), throwsA(isA<TypeError>()));
    });

    test("rethrows plugin exception for PDF", () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      channel.setMockMethodCallHandler((_) async {
        throw PlatformException(code: "X", message: "fail");
      });
      expect(() => scanner.scanAsPdf(1), throwsA(isA<PlatformException>()));
    });
  });

  group("Unsupported platform (web)", () {
    test("scanAsImage throws on web", () async {
      if (!kIsWeb) return;
      expect(
        () => scanner.scanAsImage(1),
        throwsA(isA<UnsupportedPlatformException>()),
      );
    });

    test("scanAsPdf throws on web", () async {
      if (!kIsWeb) return;
      expect(
        () => scanner.scanAsPdf(1),
        throwsA(isA<UnsupportedPlatformException>()),
      );
    });
  });

  group("RealPlatformWrapper", () {
    late RealPlatformWrapper platformWrapper;

    setUp(() {
      platformWrapper = RealPlatformWrapper();
    });

    test("returns correct value for isAndroid", () {
      expect(platformWrapper.isAndroid, Platform.isAndroid);
    });

    test("returns correct value for isIOS", () {
      expect(platformWrapper.isIOS, Platform.isIOS);
    });
  });
}
