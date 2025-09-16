import "package:apz_webview/models/error_data.dart";
import "package:apz_webview/models/webview_callbacks.dart";
import "package:flutter_test/flutter_test.dart";
import "package:webview_flutter/webview_flutter.dart";

void main() {
  group("WebviewCallbacks", () {
    test(
      "should create WebviewCallbacks with required and optional callbacks",
      () async {
        bool closeCalled = false;
        bool navRequestCalled = false;
        bool sslErrorCalled = false;
        bool errorCalled = false;

        final WebviewCallbacks callbacks = WebviewCallbacks(
          closeBtnAction: () => closeCalled = true,
          onNavigationRequest: (final NavigationRequest request) {
            navRequestCalled = true;
            return NavigationDecision.navigate;
          },
          onSslAuthError: (final SslAuthError request) {
            sslErrorCalled = true;
          },
          onError: (final ErrorData error) {
            errorCalled = true;
          },
        );

        // Test closeBtnAction
        callbacks.closeBtnAction();
        expect(closeCalled, isTrue);

        // Test onNavigationRequest
        if (callbacks.onNavigationRequest != null) {
          await callbacks.onNavigationRequest!(
            const NavigationRequest(url: "https://test.com", isMainFrame: true),
          );
          expect(navRequestCalled, isTrue);
        }

        // Test onSslAuthError
        if (callbacks.onSslAuthError != null) {
          callbacks.onSslAuthError!(FakeSslAuthError());
          expect(sslErrorCalled, isTrue);
        }

        // Test onError
        if (callbacks.onError != null) {
          callbacks.onError!(
            ErrorData(
              description: "Test error",
              code: "500",
              type: "TestErrorType",
            ),
          );
          expect(errorCalled, isTrue);
        }
      },
    );

    test("should allow null optional callbacks", () {
      final WebviewCallbacks callbacks = WebviewCallbacks(
        closeBtnAction: () {},
      );
      expect(callbacks.onNavigationRequest, isNull);
      expect(callbacks.onSslAuthError, isNull);
      expect(callbacks.onError, isNull);
    });
  });
}

// Fake SslAuthError for testing
class FakeSslAuthError implements SslAuthError {
  @override
  // ignore: no-empty-block
  dynamic noSuchMethod(final Invocation invocation) =>
      super.noSuchMethod(invocation);
}
