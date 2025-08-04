import 'dart:io';
import "dart:typed_data";

import "package:flutter/services.dart";
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:apz_share/apz_share.dart'; // Adjust import as per your project

class MockSharePlus extends Mock implements SharePlus {}
class FakeShareParams extends Fake implements ShareParams {}
class FakeShareResult extends Fake implements ShareResult {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockSharePlus mockSharePlus;
  late ApzShare apzShare;

  setUpAll(() {
    registerFallbackValue(FakeShareParams());
    registerFallbackValue(FakeShareResult()); // Register FakeShareResult too
  });

  setUp(() {
    mockSharePlus = MockSharePlus();
    apzShare = ApzShare()
    
    ..setSharePlusForTest(mockSharePlus);
    // This is the primary stubbing for mockSharePlus.share, applied to all tests.
    when(() => mockSharePlus.share(any()))
        .thenAnswer((_) async => const ShareResult('mock', ShareResultStatus.success));
  });

  group('ApzShare General Shares', () { // Renamed group for clarity
    test('shareText calls SharePlus with correct params', () async {
      // Removed redundant when(() => mockSharePlus.share(any()))
      await apzShare.shareText(text: 'Hello', title: 'Greetings',subject: 'Greetings');

      final captured = verify(() => mockSharePlus.share(captureAny())).captured.single as ShareParams;

      expect(captured.text, 'Hello');
      expect(captured.subject, 'Greetings');
      expect(captured.title, 'Greetings');
    });

    test('shareFile calls SharePlus with correct file and text', () async {
      // Removed redundant when(() => mockSharePlus.share(any()))
      await apzShare.shareFile(filePath: '/fake/path/file.pdf', text: 'Sharing a file',title: "Greetings");

      final captured = verify(() => mockSharePlus.share(captureAny())).captured.single as ShareParams;

      expect(captured.text, 'Sharing a file');
      expect(captured.files?.first.path, '/fake/path/file.pdf');
    });

    test('shareMultipleFiles shares all files with optional text', () async {
      // Removed redundant when(() => mockSharePlus.share(any()))
      await apzShare.shareMultipleFiles(
        filePaths: ['/path/one.txt', '/path/two.txt'],
        text: 'Here are multiple files',
        title: "Greetings"
      );

      final captured = verify(() => mockSharePlus.share(captureAny())).captured.single as ShareParams;

      expect(captured.files?.length, 2);
      expect(captured.files?.map((f) => f.path), containsAll(['/path/one.txt', '/path/two.txt']));
      expect(captured.text, 'Here are multiple files');
    });

  });
  
  group('ApzShare.shareAssetFile', () {
    late Directory fakeTempDir;
    late Uint8List fakeData;
    late ByteData fakeByteData;

    setUp(() async {
      // Set up mock ByteData from asset
      fakeData = Uint8List.fromList([1, 2, 3, 4]);
      fakeByteData = ByteData.view(fakeData.buffer);

      // Set up a fake temp directory
      // Using Directory.systemTemp.createTemp is fine for creating a *real* temp dir for the test
      // if you want to verify file existence, but for mocking, you could also just return a string path.
      // For this test, verifying file existence makes sense.
      fakeTempDir = await Directory.systemTemp.createTemp('test_temp');

      // Override rootBundle for asset loading
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (ByteData? message) async {
        // You might want to inspect 'message' here to return different ByteData based on assetPath
        // For simplicity, returning the same fakeByteData for any asset load.
        return fakeByteData.buffer.asByteData();
      });

      // Mock the method channel for path_provider
      const MethodChannel pathProviderChannel = MethodChannel("plugins.flutter.io/path_provider");
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProviderChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == "getTemporaryDirectory") {
            return fakeTempDir.path; // Return the path of the *real* temp dir created above
          }
          return null; // Return null for other methods if not explicitly mocked
        },
      );
    });

    tearDown(() async {
      // Clean up the real temporary directory
      await fakeTempDir.delete(recursive: true);
      // Reset the mock message handlers
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel("plugins.flutter.io/path_provider"), null);
    });

    
test('shareAssetFile should load asset, write to temp, and call SharePlus.share', () async {
  final fileName = 'sample_from_asset.pdf';
  final expectedFilePath = '${fakeTempDir.path}/$fileName';

  await apzShare.shareAssetFile(
    assetPath: 'assets/sample_from_asset.pdf',
    text: 'test',
    title: "Greetings",
    mimeType: 'application/pdf',
  );

  // Verify file written to temp dir
  final writtenFile = File(expectedFilePath);
  expect(await writtenFile.exists(), isTrue);
  expect(await writtenFile.readAsBytes(), equals(fakeData));

  // Verify SharePlus called with expected ShareParams
  final captured = verify(() => mockSharePlus.share(captureAny())).captured.single as ShareParams;
  expect(captured.text, 'test');
  expect(captured.files?.length, 1);
  expect(captured.files?.first.path, expectedFilePath);
  expect(captured.files?.first.mimeType, 'application/pdf');
});



  });

}
