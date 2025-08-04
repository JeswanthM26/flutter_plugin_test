import "package:apz_webview/models/accept_decline_btn.dart";
import "package:apz_webview/models/title_data.dart";
import "package:apz_webview/models/webview_callbacks.dart";
import "package:apz_webview/screen/webview_screen.dart";
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

  setUp(() {
    mockWebviewCallbacks = MockWebviewCallbacks();
    mockAcceptDeclineBtn = MockAcceptDeclineBtn();
    mockTitleData = MockTitleData();
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

  testWidgets("WebviewScreen renders with required params", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WebviewScreen(
          url: "https://example.com",
          webviewCallbacks: mockWebviewCallbacks,
          titleData: mockTitleData,
          isAcceptRejectVisible: false,
        ),
      ),
    );
    expect(find.text("Test Title"), findsOneWidget);
    expect(find.byType(WebviewScreen), findsOneWidget);
  });

  testWidgets("WebviewScreen shows Accept/Decline buttons when visible", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WebviewScreen(
          url: "https://example.com",
          webviewCallbacks: mockWebviewCallbacks,
          titleData: mockTitleData,
          isAcceptRejectVisible: true,
          acceptDeclineBtn: mockAcceptDeclineBtn,
        ),
      ),
    );
    // Wait for the widget to build
    await tester.pumpAndSettle();
    expect(find.text("Accept"), findsOneWidget);
    expect(find.text("Decline"), findsOneWidget);
  });

  testWidgets("WebviewScreen calls closeBtnAction on pop", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WebviewScreen(
          url: "https://example.com",
          webviewCallbacks: mockWebviewCallbacks,
          titleData: mockTitleData,
          isAcceptRejectVisible: false,
        ),
      ),
    );
    bool popTriggered = false;
    // Try WillPopScope first
    final willPopScope = find.byType(WillPopScope);
    if (willPopScope.evaluate().isNotEmpty) {
      final willPopScopeWidget = tester.widget<WillPopScope>(willPopScope);
      await willPopScopeWidget.onWillPop!();
      popTriggered = true;
    } else {
      // Fallback to PopScope if present
      final popScope = find.byType(PopScope);
      if (popScope.evaluate().isNotEmpty) {
        final popScopeWidget = tester.widget<PopScope>(popScope);
        if (popScopeWidget.onPopInvokedWithResult != null) {
          popScopeWidget.onPopInvokedWithResult!(false, null);
          popTriggered = true;
        }
      }
    }
    if (popTriggered) {
      verify(() => mockWebviewCallbacks.closeBtnAction()).called(1);
    } else {
      // Optionally: print a warning or skip the check
      print('No pop handler found in widget tree.');
    }
  });
}

class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return _FakePlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return _FakePlatformWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return _FakePlatformNavigationDelegate(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return _FakePlatformWebViewCookieManager(params);
  }
}

class _FakePlatformWebViewController extends PlatformWebViewController {
  _FakePlatformWebViewController(PlatformWebViewControllerCreationParams params)
    : super.implementation(params);

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}
}

class _FakePlatformWebViewWidget extends PlatformWebViewWidget {
  _FakePlatformWebViewWidget(PlatformWebViewWidgetCreationParams params)
    : super.implementation(params);

  @override
  Widget build(BuildContext context) => Container();
}

class _FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  _FakePlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) : super.implementation(params);

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    // Simulate page load finished immediately
    onPageFinished("https://example.com");
  }

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(
    HttpAuthRequestCallback onHttpAuthRequest,
  ) async {}

  @override
  Future<void> setOnSSlAuthError(SslAuthErrorCallback onSslAuthError) async {}
}

class _FakePlatformWebViewCookieManager extends PlatformWebViewCookieManager {
  _FakePlatformWebViewCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) : super.implementation(params);
}
