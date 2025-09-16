import "dart:async";
import "dart:io";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:otp_autofill/otp_autofill.dart";

///Auto read otp
class APZAutoReadOtp {
  OTPInteractor _otpInteractor = OTPInteractor();

  @visibleForTesting
  /// For testing purposes, allows mocking the OTPInteractor
  /// This should only be used in tests to inject a mock or stub.
  // ignore: use_setters_to_change_properties
  void mockOTPInteractor(final OTPInteractor otpInteractor) {
    _otpInteractor = otpInteractor;
  }

  /// callback that will receive the full SMS text each time an SMS arrives.
  void Function(String smsText)? onSms;

  bool _listening = false;

  /// Returns true if the current platform is web.
  bool getIsWeb() => kIsWeb;

  ///listner for auto read otp
  Future<void> startOTPListener({
    required final ListenerType type,
    final String? senderNumber,
  }) async {
    if (getIsWeb() || Platform.isIOS) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web and iOS",
      );
    }
    if (_listening) {
      return;
    }
    _listening = true;
    try {
      if (type == ListenerType.consent) {
        await _otpInteractor.startListenUserConsent(senderNumber).then((
          final String? rawSms,
        ) {
          if (!_listening) {
            return; // ignore if already stopped
          }
          if (rawSms != null) {
            _emit(rawSms);
          }
        });
      } else {
        // ListenerType.retriever
        await _otpInteractor.startListenRetriever().then((
          final String? rawSms,
        ) {
          if (!_listening) {
            return;
          }
          if (rawSms != null) {
            _emit(rawSms);
          }
        });
      }
    } catch (e) {
      _listening = false;
      rethrow;
    }
  }

  /// Stop listening
  Future<void> stopOtpListener() async {
    try {
      await _otpInteractor.stopListenForCode();
    } finally {
      _listening = false;
    }
  }

  void _emit(final String fullSmsText) {
    // Emit raw SMS text to callback
    if (onSms != null) {
      onSms?.call(fullSmsText);
    }
  }
}

/// Listener types for auto read OTP
enum ListenerType {
  /// User consent listener
  consent,

  /// SMS Retriever listener
  retriever,
}
