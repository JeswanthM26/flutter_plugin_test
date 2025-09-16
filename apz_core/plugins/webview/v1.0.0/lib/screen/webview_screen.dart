import "dart:async";
import "dart:convert";
import "dart:typed_data";
import "package:apz_webview/models/accept_decline_btn.dart";
import "package:apz_webview/models/error_data.dart";
import "package:apz_webview/models/title_data.dart";
import "package:apz_webview/models/webview_callbacks.dart";
import "package:flutter/material.dart";
import "package:webview_flutter/webview_flutter.dart";

/// A screen that displays a secure web page using a WebView.
class WebviewScreen extends StatefulWidget {
  /// Constructs a [WebviewScreen] with the given [url] and optional parameters.
  const WebviewScreen({
    required final String url,
    required final WebviewCallbacks webviewCallbacks,
    required final TitleData titleData,
    required final bool isAcceptRejectVisible,
    final Map<String, String>? headers,
    final Map<String, String>? postData,
    final AcceptDeclineBtn? acceptDeclineBtn,
    super.key,
  }) : _url = url,
       _webviewCallbacks = webviewCallbacks,
       _titleData = titleData,
       _isAcceptRejectVisible = isAcceptRejectVisible,
       _headers = headers,
       _postData = postData,
       _acceptDeclineBtn = acceptDeclineBtn;

  final String _url;
  final WebviewCallbacks _webviewCallbacks;
  final TitleData _titleData;
  final bool _isAcceptRejectVisible;
  final Map<String, String>? _headers;
  final Map<String, String>? _postData;
  final AcceptDeclineBtn? _acceptDeclineBtn;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late final WebViewController _controller;
  bool _isControllerInitialised = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller = await _getWebViewController(
        widget._webviewCallbacks.onNavigationRequest,
        widget._webviewCallbacks.onSslAuthError,
        widget._webviewCallbacks.onError,
      );

      Map<String, String> finalHeaders = const <String, String>{};

      if (widget._headers != null) {
        finalHeaders = widget._headers!;
      }

      if (widget._postData != null && widget._postData!.isNotEmpty) {
        final String jsonString = jsonEncode(widget._postData);
        final Uint8List uint8List = Uint8List.fromList(utf8.encode(jsonString));

        await _controller.loadRequest(
          Uri.parse(widget._url),
          method: LoadRequestMethod.post,
          headers: finalHeaders,
          body: uint8List,
        );
      } else {
        await _controller.loadRequest(
          Uri.parse(widget._url),
          headers: finalHeaders,
        );
      }

      setState(() {
        _isControllerInitialised = true;
      });
    });
  }

  @override
  Widget build(final BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (final bool didPop, _) async {
      if (didPop) {
        return;
      }

      widget._webviewCallbacks.closeBtnAction();
    },
    child: Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: widget._titleData.titleColor),
        title: Text(
          widget._titleData.title,
          style: TextStyle(color: widget._titleData.titleColor),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              if (_isControllerInitialised)
                Expanded(child: WebViewWidget(controller: _controller)),
              if (widget._isAcceptRejectVisible &&
                  widget._acceptDeclineBtn != null)
                _getAcceptRejectBtn(),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    ),
  );

  Future<WebViewController> _getWebViewController(
    final FutureOr<NavigationDecision> Function(NavigationRequest request)?
    onNavigationRequest,
    final void Function(SslAuthError request)? onSslAuthError,
    final void Function(ErrorData error)? onError,
  ) async {
    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    final NavigationDelegate delegate = NavigationDelegate(
      onNavigationRequest: onNavigationRequest,
      onSslAuthError: onSslAuthError ?? _onSslAuthError,
      onWebResourceError: (final WebResourceError error) {
        if (onError != null) {
          final ErrorData errorData = ErrorData(
            description: error.description,
            code: error.errorCode.toString(),
            type: error.errorType?.toString() ?? "WebResourceError",
          );
          onError(errorData);
        }
      },
      onHttpError: (final HttpResponseError error) {
        if (onError != null) {
          final ErrorData errorData = ErrorData(
            description: error.response.toString(),
            code: error.response?.statusCode.toString() ?? "-1",
            type: "HTTPError",
          );
          onError(errorData);
        }
      },
      onPageStarted: (final String url) {
        setState(() {
          _isLoading = true;
        });
      },
      onPageFinished: (final String url) {
        setState(() {
          _isLoading = false;
        });
      },
    );

    await controller.setNavigationDelegate(delegate);

    return controller;
  }

  Future<void> _onSslAuthError(final SslAuthError request) async {
    await request.proceed();
  }

  Widget _getAcceptRejectBtn() => Padding(
    padding: const EdgeInsetsGeometry.directional(
      start: 10,
      end: 10,
      top: 10,
      bottom: 20,
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: _getElevatedButton(
            widget._acceptDeclineBtn!.declineText,
            widget._acceptDeclineBtn!.declineBgColor,
            widget._acceptDeclineBtn!.declineTextColor,
            widget._acceptDeclineBtn!.declineTapAction,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _getElevatedButton(
            widget._acceptDeclineBtn!.acceptText,
            widget._acceptDeclineBtn!.acceptBgColor,
            widget._acceptDeclineBtn!.acceptTextColor,
            widget._acceptDeclineBtn!.acceptTapAction,
          ),
        ),
      ],
    ),
  );

  Widget _getElevatedButton(
    final String text,
    final Color backgroundColor,
    final Color textColor,
    final void Function() tapAction,
  ) => ElevatedButton(
    onPressed: tapAction,
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: Text(text),
  );

  // BEGIN TEST-ONLY METHODS
  @visibleForTesting
  void testInvokeOnWebResourceError(final WebResourceError error) {
    final void Function(ErrorData error)? onError =
        widget._webviewCallbacks.onError;
    if (onError != null) {
      final ErrorData errorData = ErrorData(
        description: error.description,
        code: error.errorCode.toString(),
        type: error.errorType?.toString() ?? "WebResourceError",
      );
      onError(errorData);
    }
  }

  @visibleForTesting
  void testInvokeOnHttpError(final HttpResponseError error) {
    final void Function(ErrorData error)? onError =
        widget._webviewCallbacks.onError;
    if (onError != null) {
      final ErrorData errorData = ErrorData(
        description: error.response.toString(),
        code: error.response?.statusCode.toString() ?? "-1",
        type: "HTTPError",
      );
      onError(errorData);
    }
  }

  // END TEST-ONLY METHODS
}
