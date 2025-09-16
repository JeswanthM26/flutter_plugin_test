import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

/// Enum representing the status of the SMS sending operation.
enum SendSMSStatus {
  /// Indicates that the SMS sending operation was launched successfully.
  launched,

  /// Indicates that the SMS message was sent successfully.
  sent,

  /// Indicates that the SMS sending operation was cancelled.
  cancelled,
}

/// A class to send SMS messages using a platform channel.
/// This class provides a method to send SMS messages by invoking a method
/// on the native platform through a MethodChannel.
class ApzSendSMS {
  bool _isWeb = kIsWeb;

  @visibleForTesting
  /// Sets whether the current platform is web.
  // ignore: use_setters_to_change_properties
  void setIsWeb({required final bool isWeb}) {
    _isWeb = isWeb;
  }

  /// Sends an SMS message to the specified phone number.
  /// /// [phoneNumber] is the recipient's phone number.
  /// [message] is the content of the SMS message.
  /// /// Returns a [Future<String>] that resolves to the status of the SMS sending operation.
  /// /// Throws an exception if the SMS sending operation fails.
  Future<SendSMSStatus> send({
    required final String phoneNumber,
    required final String message,
  }) async {
    if (_isWeb) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web platform",
      );
    }

    if (phoneNumber.trim().isEmpty) {
      throw Exception("PhoneNumber cannot be empty");
    }

    if (message.trim().isEmpty) {
      throw Exception("Message cannot be empty");
    }

    try {
      const MethodChannel channel = MethodChannel("com.iexceed/apz_send_sms");
      final String status = await channel.invokeMethod(
        "sendSMS",
        <String, Object?>{"number": phoneNumber, "message": message},
      );
      switch (status) {
        case "launched":
          return SendSMSStatus.launched;
        case "sent":
          return SendSMSStatus.sent;
        case "cancelled":
          return SendSMSStatus.cancelled;
        default:
          throw Exception("Unknown status: $status");
      }
    } on Exception catch (_) {
      rethrow;
    }
  }
}
