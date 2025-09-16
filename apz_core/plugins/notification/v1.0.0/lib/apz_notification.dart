import "dart:async";

import "package:apz_notification/apz_message.dart";
import "package:apz_utils/apz_utils.dart";
import "package:firebase_core/firebase_core.dart"; // Added for Firebase.initializeApp()
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

/// A callback function type for handling foreground messages.

typedef ApzNotificationOnMessageCallback = void Function(ApzMessage message);

/// A callback function type when the app is opened from a terminated state.

typedef ApzNotificationOnMessageOpenedAppCallback =
    void Function(ApzMessage message);

/// A callback function type for handling background messages.

typedef ApzNotificationBackgroundMessageHandler =
    Future<void> Function(ApzMessage message);

/// A callback function refresh the FCM token.

typedef ApzNotificationOnTokenRefreshCallback = void Function(String newToken);

/// The main class for the ApzNotification plugin.

class ApzNotification {
  // Private constructors to prevent direct instantiation.
  ApzNotification._();
  // Static instance of FirebaseMessaging for direct access
  //to its functionalities.
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Singleton instance of the plugin.
  static final ApzNotification _instance = ApzNotification._();

  /// Returns the singleton instance of [ApzNotification].
  static ApzNotification get instance => _instance;

  /// Private variable to store the background message handler.
  static ApzNotificationBackgroundMessageHandler? _backgroundMessageHandler;

  /// Flag to check if the plugin has been initialized.
  static bool _isInitialized = false;

  final APZLoggerProvider _logger = APZLoggerProvider();

  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        "apz_push_channel",
        "APZ Push Notifications",
        description: "Channel used for APZ push notifications.",
        importance: Importance.high,
      );

  @visibleForTesting
  /// Overrides the default FirebaseMessaging instance for testing purposes.
  // ignore: public_member_api_docs, use_setters_to_change_properties
  void overrideFirebaseMessaging(final FirebaseMessaging instance) {
    _firebaseMessaging = instance;
  }

  @visibleForTesting
  /// Resets the plugin's initialization state for testing purposes.
  // ignore: public_member_api_docs
  void resetInitialization() {
    _isInitialized = false;
  }

  /// Getter to check if the plugin is initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the push notification service.

  Future<void> initializePushNotification({
    final ApzNotificationOnMessageCallback? onMessage,
    final ApzNotificationOnMessageOpenedAppCallback? onMessageOpenedApp,
    final ApzNotificationBackgroundMessageHandler? onBackgroundMessage,
    final ApzNotificationOnTokenRefreshCallback? onTokenRefresh,
    final FirebaseOptions? firebaseOptions,
  }) async {
    if (_isInitialized) {
      _logger.debug("APZPN: Already initialized. Skipping duplicate setup.");
      return;
    }

    _isInitialized = true;

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/ic_launcher"),
          iOS: DarwinInitializationSettings(),
        );

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Create Android notification channel
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);

    // Firebase initialization
    if (Firebase.apps.isEmpty) {
      if (firebaseOptions != null) {
        await Firebase.initializeApp(options: firebaseOptions);
        _logger.debug("APZPN: Firebase initialized with provided options.");
      } else {
        _logger.debug(
          "APZPN: Warning: FirebaseOptions not provided. "
          "Attempting default Firebase initialization.",
        );
        await Firebase.initializeApp();
      }
    } else {
      _logger.debug("APZPN: Firebase already initialized. Skipping.");
    }

    await _requestPermissions();

    // Message listeners
    FirebaseMessaging.onMessage.listen((final RemoteMessage message) async {
      if (message.notification != null) {
        final RemoteNotification notification = message.notification!;
        final AndroidNotification? android = message.notification?.android;

        await _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _defaultChannel.id,
              _defaultChannel.name,
              channelDescription: _defaultChannel.description,
              icon: android?.smallIcon ?? "@mipmap/ic_launcher",
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }

      onMessage?.call(ApzMessage.fromRemoteMessage(message));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((final RemoteMessage message) {
      onMessageOpenedApp?.call(ApzMessage.fromRemoteMessage(message));
    });

    if (onBackgroundMessage != null) {
      _backgroundMessageHandler = onBackgroundMessage;
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    final RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      onMessageOpenedApp?.call(ApzMessage.fromRemoteMessage(initialMessage));
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((final String newToken) {
      onTokenRefresh?.call(newToken);
    });

    _logger.debug("APZPN: Push notification initialization complete.");
  }

  /// Show a local notification manually from the host app.
  Future<void> showLocalNotification({
    required final String title,
    required final String body,
    final int id = 0, // optional id for notification
  }) async {
    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher",
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Handles background messages using the registered handler.

  @pragma("vm:entry-point")
  static Future<void> _firebaseMessagingBackgroundHandler(
    final RemoteMessage message,
  ) async {
    if (Firebase.apps.isEmpty) {
      // Attempt a default initialization for background handler if needed.
      // await Firebase.initializeApp(); // Uncomment if you reliably need other Firebase services here.
    }

    // Call the user-defined background message handler.
    await _backgroundMessageHandler?.call(
      ApzMessage.fromRemoteMessage(message),
    );
  }

  /// Requests notification permissions from the user.

  Future<void> _requestPermissions() async {
    final NotificationSettings settings = await _firebaseMessaging
        .requestPermission();

    _logger.debug(
      "APZPN: User granted permission: "
      "${settings.authorizationStatus}",
    );

    // For iOS, you might also want to explicitly register
    //for remote notifications.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Retrieves the Firebase Cloud Messaging (FCM) token for the device.

  Future<String?> getToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();
      _logger.debug("APZPN: FCM Token: $token");
      return token;
    } on Exception catch (e) {
      _logger.debug("APZPN: Error getting FCM token: $e");
      return null;
    }
  }

  /// Deletes the FCM token for the device.

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _logger.debug("APZPN: FCM Token deleted.");
    } on Exception catch (e) {
      _logger.debug("APZPN: Error deleting FCM token: $e");
    }
  }

  /// Subscribes the device to a specific topic.

  Future<void> subscribeToTopic(final String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.debug("APZPN: Subscribed to topic: $topic");
    } on Exception catch (e) {
      _logger.debug("APZPN: Error subscribing to topic $topic: $e");
    }
  }

  /// Unsubscribes the device from a specific topic.

  Future<void> unsubscribeFromTopic(final String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.debug("APZPN: Unsubscribed from topic: $topic");
    } on Exception catch (e) {
      _logger.debug("APZPN: Error unsubscribing from topic $topic: $e");
    }
  }

  /// Retrieves the notification settings for the current device.

  Future<NotificationSettings> getNotificationSettings() async =>
      _firebaseMessaging.getNotificationSettings();

  /// Retrieves the message that opened the application from a terminated state.

  Future<RemoteMessage?> getInitialMessage() async =>
      _firebaseMessaging.getInitialMessage();
}
