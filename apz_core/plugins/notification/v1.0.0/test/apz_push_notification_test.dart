import "package:apz_notification/apz_notification.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}
class MockRemoteMessage extends Mock implements RemoteMessage {}
class MockNotificationSettings extends Mock implements NotificationSettings {}    

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
    late MockFirebaseMessaging mockMessaging;
  late ApzNotification plugin;

  setUp(() {
     mockMessaging = MockFirebaseMessaging();
    plugin = ApzNotification.instance;
    plugin.overrideFirebaseMessaging(mockMessaging);
    mockPlugin = MockFlutterLocalNotificationsPlugin();
  });

 test('getToken returns token', () async {
    when(() => mockMessaging.getToken()).thenAnswer((_) async => 'abc123');

    final token = await plugin.getToken();

    expect(token, 'abc123');
    verify(() => mockMessaging.getToken()).called(1);
  });

  test('deleteToken completes', () async {
    when(() => mockMessaging.deleteToken()).thenAnswer((_) async => Future.value());

    await plugin.deleteToken();

    verify(() => mockMessaging.deleteToken()).called(1);
  });

  test('subscribeToTopic subscribes', () async {
    when(() => mockMessaging.subscribeToTopic('news')).thenAnswer((_) async {});

    await plugin.subscribeToTopic('news');

    verify(() => mockMessaging.subscribeToTopic('news')).called(1);
  });

  test('unsubscribeFromTopic unsubscribes', () async {
    when(() => mockMessaging.unsubscribeFromTopic('news')).thenAnswer((_) async {});

    await plugin.unsubscribeFromTopic('news');

    verify(() => mockMessaging.unsubscribeFromTopic('news')).called(1);
  });

  test('getNotificationSettings returns settings', () async {
    final mockSettings = MockNotificationSettings();
    when(() => mockMessaging.getNotificationSettings()).thenAnswer((_) async => mockSettings);

    final settings = await plugin.getNotificationSettings();

    expect(settings, mockSettings);
    verify(() => mockMessaging.getNotificationSettings()).called(1);
  });

  test('getInitialMessage returns message', () async {
    final mockMessage = MockRemoteMessage();
    when(() => mockMessaging.getInitialMessage()).thenAnswer((_) async => mockMessage);

    final result = await plugin.getInitialMessage();

    expect(result, mockMessage);
    verify(() => mockMessaging.getInitialMessage()).called(1);
  });

  test('FlutterLocalNotificationsPlugin initialize returns true', () async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    when(() => mockPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse: any(
              named: 'onDidReceiveBackgroundNotificationResponse'),
        )).thenAnswer((_) async => true);

    final result = await mockPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (_) {},
      onDidReceiveBackgroundNotificationResponse: (_) {},
    );

    expect(result, true);
    verify(() => mockPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse: any(
              named: 'onDidReceiveBackgroundNotificationResponse'),
        )).called(1);
  });
}
