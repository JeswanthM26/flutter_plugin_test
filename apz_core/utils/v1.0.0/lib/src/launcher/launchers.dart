import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:url_launcher/url_launcher.dart";

/// A utility class for launching the phone dialer, sms, etc.
class Launchers {
  /// Singleton factory constructor to ensure only one instance exists.
  factory Launchers() => _instance;
  Launchers._();
  static final Launchers _instance = Launchers._();

  bool _isWeb = kIsWeb;

  /// Opens phone dialer with the given phone number.
  Future<void> launchCall(final String phoneNumber) async {
    if (_isWeb) {
      throw UnsupportedPlatformException(
        "Web platform is not supported for phone dialer.",
      );
    }

    if (phoneNumber.isEmpty) {
      throw Exception("Phone number cannot be empty.");
    }

    final Uri launchUri = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw Exception(
        "Could not launch phone dialer with number: $phoneNumber",
      );
    }
  }

  /// Opens SMS app with the given phone number and optional message.
  Future<void> sendSMS(
    final String phoneNumber, {
    final String? message,
  }) async {
    if (_isWeb) {
      throw UnsupportedPlatformException(
        "Web platform is not supported for SMS.",
      );
    }

    if (phoneNumber.isEmpty) {
      throw Exception("Phone number cannot be empty.");
    }

    final Uri launchUri = Uri(
      scheme: "sms",
      path: phoneNumber,
      query: message != null
          ? _encodeQueryParameters(<String, String>{"body": message})
          : null,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw Exception(
        """Could not launch SMS app with number: $phoneNumber${message != null ? ' and message: $message' : ''}""",
      );
    }
  }

  /// Launches a URL in the default browser or external application.
  Future<void> launchInExternalBrowser(final String url) async {
    try {
      final String sanitisedUrl = _sanitiseUrl(url);
      final Uri uri = Uri.parse(sanitisedUrl);

      final bool nativeAppLaunchSucceeded = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!nativeAppLaunchSucceeded) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on Exception {
      rethrow;
    }
  }

  String _sanitiseUrl(final String url) {
    if (url.isEmpty) {
      throw Exception("URL cannot be empty.");
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri != null && (uri.hasScheme || uri.hasAuthority)) {
      return url;
    } else {
      throw Exception("Invalid URL format: $url");
    }
  }

  String? _encodeQueryParameters(final Map<String, String> params) => params
      .entries
      .map(
        (final MapEntry<String, String> e) =>
            "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}",
      )
      .join("&");

  @visibleForTesting
  /// Sets the platform to web for testing purposes.
  // ignore: use_setters_to_change_properties
  void setWeb({required final bool isWeb}) {
    _isWeb = isWeb;
  }
}
