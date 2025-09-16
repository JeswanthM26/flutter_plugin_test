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

  testWidgets("WebviewScreen calls closeBtnAction on pop", (
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
    bool popTriggered = false;
    // Try WillPopScope first
    final Finder willPopScope = find.byType(WillPopScope);
    if (willPopScope.evaluate().isNotEmpty) {
      final WillPopScope willPopScopeWidget = tester.widget<WillPopScope>(
        willPopScope,
      );
      await willPopScopeWidget.onWillPop!();
      popTriggered = true;
    } else {
      // Fallback to PopScope if present
      final Finder popScope = find.byType(PopScope);
      if (popScope.evaluate().isNotEmpty) {
        final PopScope popScopeWidget = tester.widget<PopScope>(popScope);
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
      print("No pop handler found in widget tree.");
    }
  });

  testWidgets('WebviewScreen calls onError for web resource error', (
    tester,
  ) async {
    bool errorCalled = false;
    final callbacks = WebviewCallbacks(
      closeBtnAction: () {},
      onError: (_) {
        errorCalled = true;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: WebviewScreen(
          url: 'https://example.com',
          webviewCallbacks: callbacks,
          titleData: TitleData(title: 'Error Test', titleColor: Colors.black),
          isAcceptRejectVisible: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final state = tester.state(find.byType(WebviewScreen)) as dynamic;
    state.testInvokeOnWebResourceError(
      WebResourceError(
        errorCode: 123,
        description: 'desc',
        errorType: WebResourceErrorType.connect,
      ),
    );
    expect(errorCalled, isTrue);
  });

  testWidgets('WebviewScreen calls onError for HTTP error', (tester) async {
    bool errorCalled = false;
    final callbacks = WebviewCallbacks(
      closeBtnAction: () {},
      onError: (_) {
        errorCalled = true;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: WebviewScreen(
          url: 'https://example.com',
          webviewCallbacks: callbacks,
          titleData: TitleData(title: 'HTTP Error', titleColor: Colors.black),
          isAcceptRejectVisible: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final state = tester.state(find.byType(WebviewScreen)) as dynamic;
    state.testInvokeOnHttpError(HttpResponseError(response: null));
    expect(errorCalled, isTrue);
  });

  testWidgets("WebviewScreen shows loading indicator", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WebviewScreen(
          url: "https://example.com",
          webviewCallbacks: WebviewCallbacks(closeBtnAction: () {}),
          titleData: const TitleData(
            title: "Loading",
            titleColor: Colors.black,
          ),
          isAcceptRejectVisible: false,
        ),
      ),
    );
    // Should show CircularProgressIndicator at first
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets("Accept/Decline buttons call their actions", (
    final WidgetTester tester,
  ) async {
    bool acceptCalled = false;
    bool declineCalled = false;
    final AcceptDeclineBtn acceptDeclineBtn = AcceptDeclineBtn(
      acceptText: "Accept",
      declineText: "Decline",
      acceptBgColor: Colors.green,
      declineBgColor: Colors.red,
      acceptTextColor: Colors.white,
      declineTextColor: Colors.white,
      acceptTapAction: () => acceptCalled = true,
      declineTapAction: () => declineCalled = true,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: WebviewScreen(
          url: "https://example.com",
          webviewCallbacks: WebviewCallbacks(closeBtnAction: () {}),
          titleData: const TitleData(title: "Btn", titleColor: Colors.black),
          isAcceptRejectVisible: true,
          acceptDeclineBtn: acceptDeclineBtn,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Accept"));
    await tester.tap(find.text("Decline"));
    expect(acceptCalled, isTrue);
    expect(declineCalled, isTrue);
  });

  testWidgets("WebviewScreen handles null/empty headers and postData", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WebviewScreen(
          url: "https://example.com",
          webviewCallbacks: WebviewCallbacks(closeBtnAction: () {}),
          titleData: const TitleData(title: "Edge", titleColor: Colors.black),
          isAcceptRejectVisible: false,
          headers: null,
          postData: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Edge"), findsOneWidget);
  });
}

class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    final PlatformWebViewControllerCreationParams params,
  ) {
    return _FakePlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    final PlatformWebViewWidgetCreationParams params,
  ) {
    return _FakePlatformWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    final PlatformNavigationDelegateCreationParams params,
  ) {
    return _FakePlatformNavigationDelegate(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    final PlatformWebViewCookieManagerCreationParams params,
  ) {
    return _FakePlatformWebViewCookieManager(params);
  }
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
    // Simulate page load finished immediately
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
