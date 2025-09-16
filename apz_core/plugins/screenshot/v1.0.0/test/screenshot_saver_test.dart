import 'dart:io';
import 'dart:typed_data';
import 'package:apz_screenshot/screenshot_saver_io.dart';
import 'package:apz_share/apz_share.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class MockApzShare extends Mock implements ApzShare {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });
  setUp(() {
    // Mock path_provider
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final dir = await Directory.systemTemp.createTemp('test');
        return dir.path;
      }
      throw PlatformException(code: 'Unimplemented');
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('save writes file, shares it, and then deletes it using setShareInstance', () async {
    final mockShare = MockApzShare();
    // 1. Instantiate ScreenshotSaver using its default constructor
    final ScreenshotSaver screenshotSaver = ScreenshotSaver(); // <--- No apzShare parameter here

    // 2. Inject the mock using setShareInstance
    screenshotSaver.setShareInstance(mockShare); // <--- This is where the mock is set

    final Uint8List testBytes = Uint8List.fromList([1, 2, 3, 4]);
    final fileName = 'test.png';
    final shareText = 'Sharing profile image';

    // Mock getApplicationDocumentsDirectory for path_provider
    final tempDir = await Directory.systemTemp.createTemp('test_screenshot_dir');
    MethodChannel(
      'plugins.flutter.io/path_provider',
      const StandardMethodCodec(),
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      throw PlatformException(code: 'Unimplemented');
    });

    // Mock ApzShare's shareFile method
    when(() => mockShare.shareFile(
      filePath: any(named: 'filePath'),
      title: any(named: 'title'),
      text: any(named: 'text'),
    )).thenAnswer((_) async {});

    // Call save
    await screenshotSaver.save(testBytes, fileName, shareText);

    final expectedFile = File('${tempDir.path}/$fileName');
    print('Expecting file at: ${expectedFile.path}');

    final fileExistsAfterSave = await expectedFile.exists();
    expect(fileExistsAfterSave, isFalse, reason: 'Screenshot file should be deleted after saving and sharing.');

    // Verify share was called on your ApzShare mock
    verify(() => mockShare.shareFile(
      filePath: expectedFile.path,
      title: fileName,
      text: shareText,
    )).called(1);

    addTearDown(() => tempDir.delete(recursive: true));
  });

//  test('save writes file, shares it, and then deletes it', () async {
//     final mockShare = MockApzShare();
//     // This line is now correct, assuming ScreenshotSaver class is fixed
//     final ScreenshotSaver screenshotSaver = ScreenshotSaver(apzShare: mockShare);

//     final Uint8List testBytes = Uint8List.fromList([1, 2, 3, 4]);
//     final fileName = 'test.png';
//     final shareText = 'Sharing profile image';

//     // Mock getApplicationDocumentsDirectory for path_provider
//     final tempDir = await Directory.systemTemp.createTemp('test_screenshot_dir');
//     MethodChannel(
//       'plugins.flutter.io/path_provider',
//       const StandardMethodCodec(),
//     ).setMockMethodCallHandler((MethodCall methodCall) async {
//       if (methodCall.method == 'getApplicationDocumentsDirectory') {
//         return tempDir.path;
//       }
//       throw PlatformException(code: 'Unimplemented');
//     });

//     // Mock ApzShare's shareFile method
//     when(() => mockShare.shareFile(
//       filePath: any(named: 'filePath'),
//       title: any(named: 'title'),
//       text: any(named: 'text'),
//     )).thenAnswer((_) async {});

//     // Call save
//     await screenshotSaver.save(testBytes, fileName, shareText);

//     final expectedFile = File('${tempDir.path}/$fileName');
//     print('Expecting file at: ${expectedFile.path}');

//     final fileExistsAfterSave = await expectedFile.exists();
//     expect(fileExistsAfterSave, isFalse, reason: 'Screenshot file should be deleted after saving and sharing.');

//     // Verify share was called on your ApzShare mock
//     verify(() => mockShare.shareFile(
//       filePath: expectedFile.path,
//       title: fileName,
//       text: shareText,
//     )).called(1);

//     addTearDown(() => tempDir.delete(recursive: true));
//   });

// Don't forget to clean up the temporary directory after tests are done
tearDown(() async {
  final tempDirList = Directory.systemTemp.listSync().whereType<Directory>().where((dir) => dir.path.contains('test_screenshot_dir'));
  for (final dir in tempDirList) {
    await dir.delete(recursive: true);
  }
});

}
