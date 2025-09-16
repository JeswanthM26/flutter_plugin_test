import "package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart";

/// A class representing a message sent from Firebase Cloud Messaging.
class ApzMessage {
  /// Creates a new instance of [ApzMessage].
  const ApzMessage({
    this.senderId,
    this.category,
    this.collapseKey,
    this.contentAvailable = false,
    this.data = const <String, dynamic>{},
    this.from,
    this.messageId,
    this.messageType,
    this.mutableContent = false,
    this.notification,
    this.sentTime,
    this.threadId,
    this.ttl,
  });

  /// Constructs a [ApzMessage] from a [RemoteMessage].
  factory ApzMessage.fromRemoteMessage(final RemoteMessage message) =>
      ApzMessage(
        senderId: message.senderId,
        category: message.category,
        collapseKey: message.collapseKey,
        contentAvailable: message.contentAvailable,
        data: message.data,
        from: message.from,
        messageId: message.messageId,
        messageType: message.messageType,
        mutableContent: message.mutableContent,
        notification: message.notification == null
            ? null
            : RemoteNotification(
                title: message.notification?.title,
                body: message.notification?.body,
                android: message.notification?.android,
                apple: message.notification?.apple,
              ),
        sentTime: message.sentTime,
        threadId: message.threadId,
        ttl: message.ttl,
      );

  /// Constructs a [ApzMessage] from a raw Map.
  factory ApzMessage.fromMap(final Map<String, dynamic> map) => ApzMessage(
    senderId: map["senderId"],
    category: map["category"],
    collapseKey: map["collapseKey"],
    contentAvailable: map["contentAvailable"] ?? false,
    data: map["data"] == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(map["data"]),
    from: map["from"],
    // Note: using toString on messageId as it can be an int or string
    // when being sent from native.
    messageId: map["messageId"]?.toString(),
    messageType: map["messageType"],
    mutableContent: map["mutableContent"] ?? false,
    notification: map["notification"] == null
        ? null
        : RemoteNotification.fromMap(
            Map<String, dynamic>.from(map["notification"]),
          ),
    // Note: using toString on sentTime as it can be an int or string
    // when being sent from native.
    sentTime: map["sentTime"] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            int.parse(map["sentTime"].toString()),
          ),
    threadId: map["threadId"],
    ttl: map["ttl"],
  );

  /// Returns the [ApzMessage] as a raw Map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    "senderId": senderId,
    "category": category,
    "collapseKey": collapseKey,
    "contentAvailable": contentAvailable,
    "data": data,
    "from": from,
    "messageId": messageId,
    "messageType": messageType,
    "mutableContent": mutableContent,
    "notification": notification?.toMap(),
    "sentTime": sentTime?.millisecondsSinceEpoch,
    "threadId": threadId,
    "ttl": ttl,
  };

  /// The ID of the upstream sender location.
  final String? senderId;

  /// The iOS category this notification is assigned to.
  final String? category;

  /// The collapse key a message was sent with.
  /// Used to override existing messages with the same key.
  final String? collapseKey;

  /// Whether the iOS APNs message was configured as a
  /// background update notification.
  final bool contentAvailable;

  /// Any additional data sent with the message.
  final Map<String, dynamic> data;

  /// The topic name or message identifier.
  final String? from;

  /// A unique ID assigned to every message.
  final String? messageId;

  /// The message type of the message.
  final String? messageType;

  /// Whether the iOS APNs `mutable-content` property on the message was set
  /// allowing the app to modify the notification via app extensions.
  final bool mutableContent;

  /// Additional Notification data sent with the message.
  final RemoteNotification? notification;

  /// The time the message was sent, represented as a [DateTime].
  final DateTime? sentTime;

  /// An iOS app specific identifier used for notification grouping.
  final String? threadId;

  /// The time to live for the message in seconds.
  final int? ttl;
}
