import "package:apz_animation/apz_animation.dart";
import "package:apz_animation/src/carousel.dart";
import "package:apz_animation/src/payment_inprogress_ui.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ApzAnimation apzAnimation;
  late BuildContext overlayContext;

  setUp(() {
    apzAnimation = ApzAnimation()..isForTesting = true;
  });

  Widget buildTestWidget() => MaterialApp(
    home: Overlay(
      initialEntries: <OverlayEntry>[
        OverlayEntry(
          builder: (final BuildContext context) {
            overlayContext = context;
            return Container();
          },
        ),
      ],
    ),
  );

  testWidgets("shows and hides GIF overlay at top position", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    apzAnimation.showGif(
      context: overlayContext,
      gifPath: "assets/test.gif",
      duration: const Duration(milliseconds: 500),
      position: GifPosition.top,
    );
    await tester.pump();
    expect(find.byType(FlutterLogo), findsOneWidget);
    apzAnimation.hideGif();
    await tester.pump();
    expect(find.byType(FlutterLogo), findsNothing);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets("shows GIF overlay at center position", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    apzAnimation.showGif(
      context: overlayContext,
      gifPath: "assets/test.gif",
      duration: const Duration(milliseconds: 500),
      position: GifPosition.center,
    );
    await tester.pump();
    expect(find.byType(FlutterLogo), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets("shows GIF overlay at bottom position", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    apzAnimation.showGif(
      context: overlayContext,
      gifPath: "assets/test.gif",
      duration: const Duration(milliseconds: 500),
      position: GifPosition.bottom,
    );
    await tester.pump();
    expect(find.byType(FlutterLogo), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets("removes overlay after duration", (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    apzAnimation.showGif(
      context: overlayContext,
      gifPath: "assets/test.gif",
      duration: const Duration(milliseconds: 100),
      position: GifPosition.center,
    );
    await tester.pump();
    expect(find.byType(FlutterLogo), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(FlutterLogo), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
  });

  
  testWidgets("showPaymentStatus returns correct widget for loading status", (
    final WidgetTester tester,
  ) async {
    final loadingWidget = apzAnimation.showPaymentStatus(
      paymentStatus: PaymentStatus.loading,
      successGifPath: "assets/test.gif",
      failureGifPath: "assets/test.gif",
      loadingColor: Colors.blue
    );

    // When isForTesting is true, it should return FlutterLogo immediately
    expect(loadingWidget, isA<FlutterLogo>());

    // If you want to test the actual PaymentInProgressUI, you'd set isForTesting to false
    // and then check for the type of PaymentInProgressUI.
  });

  testWidgets("showPaymentStatus returns correct widget for failure status", (
    final WidgetTester tester,
  ) async {
    final failureWidget = apzAnimation.showPaymentStatus(
      paymentStatus: PaymentStatus.failure,
      failureGifPath: "assets/test.gif",
            loadingColor: Colors.blue

    );
    expect(failureWidget, isA<FlutterLogo>());
  });

  testWidgets("showPaymentStatus returns correct widget for success status", (
    final WidgetTester tester,
  ) async {
    final successWidget = apzAnimation.showPaymentStatus(
      paymentStatus: PaymentStatus.success,
      successGifPath: "assets/test.gif",
      loadingColor: Colors.blue

    );
    expect(successWidget, isA<FlutterLogo>());
  });

  testWidgets("showPaymentStatus builds actual PaymentInProgressUI when not testing", (WidgetTester tester) async {
  final apz = ApzAnimation();
  final widget = apz.showPaymentStatus(paymentStatus: PaymentStatus.loading, loadingColor: Colors.green);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  expect(find.byType(PaymentInProgressUI), findsOneWidget);
});

tearDown(() {
  apzAnimation.hideGif(); 
});
   group('showCarousel Tests', () {

    testWidgets("ApzAnimation.walkthroughCarousel returns a Carousel widget", (WidgetTester tester) async {
  final widget = apzAnimation.walkthroughCarousel(
    carouselData:WalkthroughModel(
      buttonText: "Next",
      onButtonPressed: () {
        
      },
      imagePaths: ['image1.png', 'image2.png']
    ));
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  expect(find.byType(Carousel), findsOneWidget);
});

    testWidgets("ApzAnimation.bannerCarousel returns a Carousel widget", (WidgetTester tester) async {
  final widget = apzAnimation.bannerCarousel(
    carouselData:BannerModel(
      imagePaths: ['image1.png', 'image2.png']
    ));
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  expect(find.byType(Carousel), findsOneWidget);
});


    testWidgets('showCarousel creates a Carousel widget with correct parameters', (WidgetTester tester) async {
      // 1. Define all the test parameters
      final List<String> testImagePaths = ['path1', 'path2', 'path3'];
      const bool testShowIndicator = false;
      const bool testAutoScroll = false;
      const double testHeight = 300.0;
      const String testTitle = 'Test Title 1';
      const String testDescription = 'Test Description 1';
      final List<String> testTitles = [testTitle, 'Test Title 2', 'Test Title 3'];
      final List<String> testDescriptions = [testDescription, 'Test Description 2', 'Test Description 3'];
      const CarouselType testIsForBanner = CarouselType.walkthrough;

      // 2. Wrap the helper function call in a widget and pump it
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Carousel(
              imagePaths: testImagePaths,
              showIndicator: testShowIndicator,
              autoScroll: testAutoScroll,
              height: testHeight,
              welcomeTitle: testTitles,
              welcomeDescription: testDescriptions,
              carouselType: testIsForBanner,),
          ),
        ),
      );

      // 3. Verify that the rendered widget has the correct properties.
      // We'll inspect the rendered output to confirm the widget was built correctly.

      // Check for the rendered image content (we can't see the path, but we can see the widget)
      expect(find.byType(Image), findsOneWidget); 
      // Check for the text from the welcomeTitle list
      expect(find.text(testTitle), findsOneWidget);
      // Check for the text from the welcomeDescription list
      expect(find.text(testDescription), findsOneWidget);
      
      // Since showIndicator is false, the indicator row should not be found.
      expect(find.byKey(const ValueKey('indicatorRow')), findsNothing);

    
    });

    testWidgets('showCarousel uses correct default values when optional parameters are not provided', (WidgetTester tester) async {
      final List<String> testImagePaths = ['path1', 'path2', 'path3'];

      // Call the function with only the required imagePaths
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Carousel(
              carouselType: CarouselType.walkthrough,
              imagePaths: testImagePaths),
          ),
        ),
      );

      // Verify that the widget renders the default values
      expect(find.text('Title 1'), findsNothing); // Should use a default, but not these specific titles
      
      // The indicator row should be present because the default is true
      expect(find.byKey(const ValueKey('indicatorRow')), findsOneWidget);
    });
  });

}
