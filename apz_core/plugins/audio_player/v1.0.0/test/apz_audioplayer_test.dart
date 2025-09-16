import "package:apz_audioplayer/apz_audioplayer.dart";
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:audioplayers/audioplayers.dart';

// Import your actual file
// import 'package:your_package/apz_audioplayer.dart';

// Mock class for AudioPlayer
class MockAudioPlayer extends Mock implements AudioPlayer {}

// Fake classes for fallback values
class FakeUrlSource extends Fake implements UrlSource {}
class FakeAssetSource extends Fake implements AssetSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(ReleaseMode.release);
    registerFallbackValue(FakeUrlSource());
    registerFallbackValue(FakeAssetSource());
  });

  group('ApzAudioplayer Tests', () {
    late MockAudioPlayer mockAudioPlayer;
    late ApzAudioplayer audioPlayer;

    setUp(() {
      mockAudioPlayer = MockAudioPlayer();
      audioPlayer = ApzAudioplayer();
      audioPlayer.setAudioPlayerForTesting(mockAudioPlayer);

      // Setup default mock returns
      when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.release()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => mockAudioPlayer.play(any())).thenAnswer((_) async {});
    });

    tearDown(() {
      audioPlayer.resetForTesting();
      reset(mockAudioPlayer);
    });

    group('Singleton Pattern Tests', () {
      test('should return same instance', () {
        final instance1 = ApzAudioplayer();
        final instance2 = ApzAudioplayer();
        
        expect(instance1, same(instance2),reason: 'Both should be the same singleton instance');
      });
    });

    group('playUrlAudio Tests', () {
      const testUrl = 'https://example.com/audio.mp3';

      test('should play URL audio without loop and without stop timer', () async {
        // Act
        await audioPlayer.playUrlAudio(audioUrl: testUrl);

        // Assert
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.release)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<UrlSource>()))).called(1);
      });

      test('should play URL audio with loop enabled', () async {
        // Act
        await audioPlayer.playUrlAudio(audioUrl: testUrl, isLoop: true);

        // Assert
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<UrlSource>()))).called(1);
      });

      test('should play URL audio with stop timer and no loop', () async {
        // Act
        await audioPlayer.playUrlAudio(
          audioUrl: testUrl, 
          stopAfterSeconds: 5,
        );

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.release)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<UrlSource>()))).called(1);
      });

      test('should play URL audio with stop timer and loop enabled', () async {
        // Act
        await audioPlayer.playUrlAudio(
          audioUrl: testUrl, 
          stopAfterSeconds: 5,
          isLoop: true,
        );

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<UrlSource>()))).called(1);
      });

      test('should call play with correct UrlSource', () async {
        // Act
        await audioPlayer.playUrlAudio(audioUrl: testUrl);

        // Assert
        verify(() => mockAudioPlayer.play(
          any(that: isA<UrlSource>().having(
            (source) => source.url, 
            'url', 
            equals(testUrl)
          ))
        )).called(1);
      });
    });

    group('playAssetAudio Tests', () {
      const testAssetPath = 'assets/audio/test.mp3';

      test('should play asset audio without loop and without stop timer', () async {
        // Act
        await audioPlayer.playAssetAudio(audioUrl: testAssetPath);

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.release)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<AssetSource>()))).called(1);
      });

      test('should play asset audio with loop enabled', () async {
        // Act
        await audioPlayer.playAssetAudio(audioUrl: testAssetPath, isLoop: true);

        // Assert
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<AssetSource>()))).called(1);
      });

      test('should play asset audio with stop timer and no loop', () async {
        // Act
        await audioPlayer.playAssetAudio(
          audioUrl: testAssetPath, 
          stopAfterSeconds: 3,
        );

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.release)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<AssetSource>()))).called(1);
      });

      test('should play asset audio with stop timer and loop enabled', () async {
        // Act
        await audioPlayer.playAssetAudio(
          audioUrl: testAssetPath, 
          stopAfterSeconds: 3,
          isLoop: true,
        );

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<AssetSource>()))).called(1);
      });

      test('should call play with correct AssetSource', () async {
        // Act
        await audioPlayer.playAssetAudio(audioUrl: testAssetPath);

        // Assert
        verify(() => mockAudioPlayer.play(
          any(that: isA<AssetSource>().having(
            (source) => source.path, 
            'path', 
            equals(testAssetPath)
          ))
        )).called(1);
      });
    });

    group('stop Tests', () {
      test('should call stop and release on audio player', () async {
        // Act
        await audioPlayer.stop();

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.release()).called(1);
      });

      test('should call stop before release', () async {
        final calls = <String>[];
        
        when(() => mockAudioPlayer.stop()).thenAnswer((_) async {
          calls.add('stop');
        });
        
        when(() => mockAudioPlayer.release()).thenAnswer((_) async {
          calls.add('release');
        });

        // Act
        await audioPlayer.stop();

        // Assert
        expect(calls, equals(['stop', 'release']));
      });
    });

    group('Error Handling Tests', () {
      test('should handle stop() throwing an exception', () async {
        // Arrange
        when(() => mockAudioPlayer.stop()).thenThrow(Exception('Stop failed'));

        // Act & Assert
        expect(
          () => audioPlayer.playUrlAudio(audioUrl: 'test.mp3', stopAfterSeconds: 1),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle setReleaseMode() throwing an exception', () async {
        // Arrange
        when(() => mockAudioPlayer.setReleaseMode(any())).thenThrow(Exception('SetReleaseMode failed'));

        // Act & Assert
        expect(
          () => audioPlayer.playUrlAudio(audioUrl: 'test.mp3'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle play() throwing an exception', () async {
        // Arrange
        when(() => mockAudioPlayer.play(any())).thenThrow(Exception('Play failed'));

        // Act & Assert
        expect(
          () => audioPlayer.playUrlAudio(audioUrl: 'test.mp3'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Integration Tests', () {

      test('should handle rapid successive calls', () async {
        // Act
        final futures = [
          audioPlayer.playUrlAudio(audioUrl: 'test1.mp3'),
          audioPlayer.playAssetAudio(audioUrl: 'test2.mp3'),
          audioPlayer.stop(),
        ];
        
        await Future.wait(futures);

        // Assert - verify all calls were made
        verify(() => mockAudioPlayer.play(any())).called(2);
        verify(() => mockAudioPlayer.stop()).called(greaterThanOrEqualTo(1));
        verify(() => mockAudioPlayer.release()).called(1);
      });
    });
    
    group('playFileAudio Tests', () {
      const testFilePath = '/storage/emulated/0/Music/test.mp3';

      test('should play file audio without loop and without stop timer', () async {
        // Act
        await audioPlayer.playFileAudio(filePath: testFilePath);

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.release)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<DeviceFileSource>()))).called(1);
      });

      test('should play file audio with loop enabled', () async {
        // Act
        await audioPlayer.playFileAudio(filePath: testFilePath, isLoop: true);

        // Assert
        verifyNever(() => mockAudioPlayer.stop()); // no stop called in this branch
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<DeviceFileSource>()))).called(1);
      });

      test('should play file audio with stop timer and no loop', () async {
        // Act
        await audioPlayer.playFileAudio(filePath: testFilePath, stopAfterSeconds: 5);

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.release)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<DeviceFileSource>()))).called(1);
      });

      test('should play file audio with stop timer and loop enabled', () async {
        // Act
        await audioPlayer.playFileAudio(
          filePath: testFilePath,
          stopAfterSeconds: 5,
          isLoop: true,
        );

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
        verify(() => mockAudioPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
        verify(() => mockAudioPlayer.play(any(that: isA<DeviceFileSource>()))).called(1);
      });

      test('should call play with correct DeviceFileSource', () async {
        // Act
        await audioPlayer.playFileAudio(filePath: testFilePath);

        // Assert
        verify(() => mockAudioPlayer.play(
          any(that: isA<DeviceFileSource>().having(
            (source) => source.path,
            'path',
            equals(testFilePath),
          )),
        )).called(1);
      });
    });

  
  });
}