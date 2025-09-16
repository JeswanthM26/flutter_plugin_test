import "package:apz_utils/apz_utils.dart";
import "package:apz_webview/apz_webview.dart";
import "package:apz_webview/models/accept_decline_btn.dart";
import "package:apz_webview/models/title_data.dart";
import "package:apz_webview/models/webview_callbacks.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart";

class MockWebviewCallbacks extends Mock implements WebviewCallbacks {}

class MockAcceptDeclineBtn extends Mock implements AcceptDeclineBtn {}

class MockTitleData extends Mock implements TitleData {}

void main() {
  setUpAll(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  late MockWebviewCallbacks mockWebviewCallbacks;
  late MockAcceptDeclineBtn mockAcceptDeclineBtn;
  late MockTitleData mockTitleData;
  late ApzWebview apzWebview;

  setUp(() {
    mockWebviewCallbacks = MockWebviewCallbacks();
    mockAcceptDeclineBtn = MockAcceptDeclineBtn();
    mockTitleData = MockTitleData();
    apzWebview = ApzWebview();
    when(() => mockTitleData.title).thenReturn("Test Title");
    when(() => mockTitleData.titleColor).thenReturn(Colors.black);
    when(() => mockWebviewCallbacks.closeBtnAction()).thenReturn(null);
    when(
      () => mockWebviewCallbacks.onNavigationRequest,
    ).thenReturn((_) async => NavigationDecision.navigate);
    when(
      () => mockWebviewCallbacks.onSslAuthError?.call(any()),
    ).thenReturn(null);
    when(() => mockWebviewCallbacks.onError?.call(any())).thenReturn(null);
    when(() => mockAcceptDeclineBtn.acceptText).thenReturn("Accept");
    when(() => mockAcceptDeclineBtn.declineText).thenReturn("Decline");
    when(() => mockAcceptDeclineBtn.acceptBgColor).thenReturn(Colors.green);
    when(() => mockAcceptDeclineBtn.declineBgColor).thenReturn(Colors.red);
    when(() => mockAcceptDeclineBtn.acceptTextColor).thenReturn(Colors.white);
    when(() => mockAcceptDeclineBtn.declineTextColor).thenReturn(Colors.white);
    when(() => mockAcceptDeclineBtn.acceptTapAction).thenReturn(() {});
    when(() => mockAcceptDeclineBtn.declineTapAction).thenReturn(() {});
  });

  testWidgets("openWebview pushes WebviewScreen and passes correct params", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (final BuildContext context) => ElevatedButton(
            onPressed: () async {
              await apzWebview.openWebview(
                context: context,
                url: "https://example.com",
                webviewCallbacks: mockWebviewCallbacks,
                titleData: mockTitleData,
                isAcceptRejectVisible: true,
                acceptDeclineBtn: mockAcceptDeclineBtn,
                headers: <String, String>{"foo": "bar"},
              );
            },
            child: const Text("Open Webview"),
          ),
        ),
      ),
    );
    await tester.tap(find.text("Open Webview"));
    await tester.pumpAndSettle();
    expect(find.text("Test Title"), findsOneWidget);
    expect(find.text("Accept"), findsOneWidget);
    expect(find.text("Decline"), findsOneWidget);
  });

  testWidgets("openWebviewWithPost pushes WebviewScreen with postData", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (final BuildContext context) => ElevatedButton(
            onPressed: () async {
              await apzWebview.openWebviewWithPost(
                context: context,
                url: "https://example.com",
                postData: <String, String>{"key": "value"},
                webviewCallbacks: mockWebviewCallbacks,
                titleData: mockTitleData,
                isAcceptRejectVisible: false,
              );
            },
            child: const Text("Open Webview POST"),
          ),
        ),
      ),
    );
    await tester.tap(find.text("Open Webview POST"));
    await tester.pumpAndSettle();
    expect(find.text("Test Title"), findsOneWidget);
    // Accept/Decline buttons should not be visible
    expect(find.text("Accept"), findsNothing);
    expect(find.text("Decline"), findsNothing);
  });

  testWidgets("closeWebview pops the route if open", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (final BuildContext context) => ElevatedButton(
            onPressed: () async {
              await apzWebview.openWebview(
                context: context,
                url: "https://example.com",
                webviewCallbacks: mockWebviewCallbacks,
                titleData: mockTitleData,
                isAcceptRejectVisible: false,
              );
            },
            child: const Text("Open Webview"),
          ),
        ),
      ),
    );
    await tester.tap(find.text("Open Webview"));
    await tester.pumpAndSettle();
    expect(find.text("Test Title"), findsOneWidget);
    // Now close the webview
    apzWebview.closeWebview();
    await tester.pumpAndSettle();
    expect(find.text("Test Title"), findsNothing);
  });

  test("openWebview throws UnsupportedPlatformException on web", () async {
    apzWebview.setWeb(isWeb: true);
    expect(
      () => apzWebview.openWebview(
        context: FakeBuildContext(),
        url: "https://example.com",
        webviewCallbacks: mockWebviewCallbacks,
        titleData: mockTitleData,
        isAcceptRejectVisible: true,
        acceptDeclineBtn: mockAcceptDeclineBtn,
        headers: {"foo": "bar"},
      ),
      throwsA(
        isA<UnsupportedPlatformException>().having(
          (e) => e.toString(),
          "message",
          contains("Open Webview is not supported on the web platform"),
        ),
      ),
    );
  });

  test(
    "openWebviewWithPost throws UnsupportedPlatformException on web",
    () async {
      apzWebview.setWeb(isWeb: true);
      expect(
        () => apzWebview.openWebviewWithPost(
          context: FakeBuildContext(),
          url: "https://example.com",
          postData: {"key": "value"},
          webviewCallbacks: mockWebviewCallbacks,
          titleData: mockTitleData,
          isAcceptRejectVisible: false,
        ),
        throwsA(
          isA<UnsupportedPlatformException>().having(
            (e) => e.toString(),
            "message",
            contains(
              "Open Webview With Post is not supported on the web platform",
            ),
          ),
        ),
      );
    },
  );
}

// Fakes for platform interface (same as in webview_screen_test.dart)
class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    final PlatformWebViewControllerCreationParams params,
  ) => _FakePlatformWebViewController(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    final PlatformWebViewWidgetCreationParams params,
  ) => _FakePlatformWebViewWidget(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    final PlatformNavigationDelegateCreationParams params,
  ) => _FakePlatformNavigationDelegate(params);

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    final PlatformWebViewCookieManagerCreationParams params,
  ) => _FakePlatformWebViewCookieManager(params);
}

class _FakePlatformWebViewController extends PlatformWebViewController {
  _FakePlatformWebViewController(
    final PlatformWebViewControllerCreationParams params,
  ) : super.implementation(params);

  @override
  Future<void> setJavaScriptMode(final JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> loadRequest(final LoadRequestParams params) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    final PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> setBackgroundColor(final Color color) async {}
}

class _FakePlatformWebViewWidget extends PlatformWebViewWidget {
  _FakePlatformWebViewWidget(final PlatformWebViewWidgetCreationParams params)
    : super.implementation(params);

  @override
  Widget build(final BuildContext context) => Container();
}

class _FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  _FakePlatformNavigationDelegate(
    final PlatformNavigationDelegateCreationParams params,
  ) : super.implementation(params);

  @override
  Future<void> setOnNavigationRequest(
    final NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnPageStarted(final PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(final PageEventCallback onPageFinished) async {
    onPageFinished("https://example.com");
  }

  @override
  Future<void> setOnHttpError(
    final HttpResponseErrorCallback onHttpError,
  ) async {}

  @override
  Future<void> setOnProgress(final ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(
    final WebResourceErrorCallback onWebResourceError,
  ) async {}

  @override
  Future<void> setOnUrlChange(final UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(
    final HttpAuthRequestCallback onHttpAuthRequest,
  ) async {}

  @override
  Future<void> setOnSSlAuthError(
    final SslAuthErrorCallback onSslAuthError,
  ) async {}
}

class _FakePlatformWebViewCookieManager extends PlatformWebViewCookieManager {
  _FakePlatformWebViewCookieManager(
    final PlatformWebViewCookieManagerCreationParams params,
  ) : super.implementation(params);
}

// Add a minimal fake BuildContext for unit test exception checks
class FakeBuildContext extends Fake implements BuildContext {}
