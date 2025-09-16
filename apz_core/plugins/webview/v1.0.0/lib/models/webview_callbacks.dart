import "package:apz_webview/models/error_data.dart";
import "package:webview_flutter/webview_flutter.dart";

/// A class that contains callbacks for webview events.
class WebviewCallbacks {
  /// Constructs a [WebviewCallbacks] with the required [closeBtnAction]
  /// and optional
  const WebviewCallbacks({
    required this.closeBtnAction,
    this.onNavigationRequest,
    this.onSslAuthError,
    this.onError,
  });

  /// The action to perform when the close button is pressed.
  final void Function() closeBtnAction;

  /// Callbacks that report a pending navigation request.
  final NavigationRequestCallback? onNavigationRequest;

  /// The action to perform when an SSL authentication error occurs.
  final void Function(SslAuthError request)? onSslAuthError;

  /// The action to perform when an error occurs in the webview.
  final void Function(ErrorData error)? onError;
}
