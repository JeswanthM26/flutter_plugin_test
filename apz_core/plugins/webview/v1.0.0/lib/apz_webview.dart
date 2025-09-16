import "dart:async";
import "package:apz_utils/apz_utils.dart";
import "package:apz_webview/models/accept_decline_btn.dart";
import "package:apz_webview/models/title_data.dart";
import "package:apz_webview/models/webview_callbacks.dart";
import "package:apz_webview/screen/webview_screen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// A class that provides methods to open and close a webview.
class ApzWebview {
  WebviewScreen? _webviewScreen;
  BuildContext? _context;
  bool _isWeb = kIsWeb;

  /// Opens the webview with a GET request.
  Future<void> openWebview({
    required final BuildContext context,
    required final String url,
    required final WebviewCallbacks webviewCallbacks,
    required final TitleData titleData,
    final bool isAcceptRejectVisible = false,
    final Map<String, String>? headers,
    final AcceptDeclineBtn? acceptDeclineBtn,
  }) async {
    if (_isWeb) {
      throw UnsupportedPlatformException(
        "Open Webview is not supported on the web platform",
      );
    }
    _context = context;
    _webviewScreen = WebviewScreen(
      url: url,
      webviewCallbacks: webviewCallbacks,
      titleData: titleData,
      isAcceptRejectVisible: isAcceptRejectVisible,
      headers: headers,
      acceptDeclineBtn: acceptDeclineBtn,
    );
    await Navigator.push(
      context,
      MaterialPageRoute<WebviewScreen>(
        builder: (final BuildContext context) => _webviewScreen!,
        fullscreenDialog: true,
      ),
    );
  }

  /// Opens the webview with a POST request.
  Future<void> openWebviewWithPost({
    required final BuildContext context,
    required final String url,
    required final Map<String, String> postData,
    required final WebviewCallbacks webviewCallbacks,
    required final TitleData titleData,
    final bool isAcceptRejectVisible = false,
    final Map<String, String>? headers,
    final AcceptDeclineBtn? acceptDeclineBtn,
  }) async {
    if (_isWeb) {
      throw UnsupportedPlatformException(
        "Open Webview With Post is not supported on the web platform",
      );
    }

    _context = context;
    _webviewScreen = WebviewScreen(
      url: url,
      webviewCallbacks: webviewCallbacks,
      titleData: titleData,
      isAcceptRejectVisible: isAcceptRejectVisible,
      headers: headers,
      postData: postData,
      acceptDeclineBtn: acceptDeclineBtn,
    );
    await Navigator.push(
      context,
      MaterialPageRoute<WebviewScreen>(
        builder: (final BuildContext context) => _webviewScreen!,
        fullscreenDialog: true,
      ),
    );
  }

  /// Closes the webview if it is open.
  void closeWebview() {
    if (_context != null && _webviewScreen != null) {
      Navigator.pop(_context!);
      _context = null;
      _webviewScreen = null;
    }
  }

  @visibleForTesting
  /// Sets the platform to web for testing purposes.
  // ignore: use_setters_to_change_properties
  void setWeb({required final bool isWeb}) {
    _isWeb = isWeb;
  }
}
