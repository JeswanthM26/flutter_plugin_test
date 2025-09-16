import "package:apz_animation/enum/carousel_type.dart";
import "package:apz_animation/src/carousel.dart";
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  // Define a list of test images
  const List<String> imagePaths = [
    'assets/images/image1.png',
    'assets/images/image2.png',
    'assets/images/image3.png',
  ];

  // Define a list of welcome titles and descriptions
  const List<String> welcomeTitles = [
    'Title 1',
    'Title 2',
    'Title 3',
  ];

  const List<String> welcomeDescriptions = [
    'Description 1',
    'Description 2',
    'Description 3',
  ];

  /// A utility function to pump the widget for a specific configuration
  Future<void> pumpCarousel(
    WidgetTester tester, {
    CarouselType isForBanner = CarouselType.walkthrough,
    bool showIndicator = true,
    bool autoScroll = false,
    Duration? interval,
    VoidCallback? onButtonPressed,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Carousel(
            imagePaths: imagePaths,
            carouselType: isForBanner,
            showIndicator: showIndicator,
            autoScroll: autoScroll,
            interval: interval,
            welcomeTitle: welcomeTitles,
            welcomeDescription: welcomeDescriptions,
            onButtonPressed: onButtonPressed,
          ),
        ),
      ),
    );
  }

  group('Carousel Widget Tests', () {

    // --- Onboarding Mode Tests (isForBanner: false) ---

    testWidgets('Onboarding mode shows all pages with text and indicator',
        (WidgetTester tester) async {
      await pumpCarousel(tester);

      // Verify that the first page's title and description are present
      expect(find.text('Title 1'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);

      // Verify that indicators are visible
      expect(find.byKey(const ValueKey('indicatorRow')), findsOneWidget);
      
      // The current page indicator should have the active size
      final activeIndicator = tester.widget<AnimatedContainer>(
          find.byWidgetPredicate((widget) => 
              widget is AnimatedContainer && (
                  widget.constraints?.maxWidth == 20.0 || widget.constraints?.maxHeight == 20.0
              )
          )
      );
      
      // Correct way to access the color from the decoration
      final BoxDecoration? decoration = activeIndicator.decoration as BoxDecoration?;
      expect(decoration?.color, Colors.blue);
    });

    testWidgets('Scrolling in Onboarding mode changes content and indicator',
        (WidgetTester tester) async {
      await pumpCarousel(tester);

      // Swipe to the next page
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify the content of the second page is visible
      expect(find.text('Title 2'), findsOneWidget);

      // Verify that the second indicator is now active
      final activeIndicator = tester.widget<AnimatedContainer>(
          find.byWidgetPredicate((widget) => 
              widget is AnimatedContainer && (
                  widget.constraints?.maxWidth == 20.0 || widget.constraints?.maxHeight == 20.0
              )
          )
      );

      // Correct way to access the color from the decoration
      final BoxDecoration? decoration = activeIndicator.decoration as BoxDecoration?;
      expect(decoration?.color, Colors.blue);
    });

    testWidgets('Onboarding mode shows "Get Started" button on the last page',
        (WidgetTester tester) async {
      await pumpCarousel(tester);

      // Drag to the last page (index 2)
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify "Get Started" button is visible and indicators are gone
      expect(find.byKey(const ValueKey('getStarted')), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byKey(const ValueKey('indicatorRow')), findsNothing);
    });

    testWidgets('Tapping "Get Started" button calls the callback',
        (WidgetTester tester) async {
      bool buttonPressed = false;
      await pumpCarousel(
        tester,
        onButtonPressed: () {
          buttonPressed = true;
        },
      );

      // Drag to the last page
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap the button and verify the callback was called
      await tester.tap(find.byKey(const ValueKey('getStarted')));
      expect(buttonPressed, isTrue);
    });
    
    // --- Banner Mode Tests (isForBanner: true) ---

    testWidgets('Banner mode renders with a fixed height and no text',
        (WidgetTester tester) async {
      await pumpCarousel(tester, isForBanner: CarouselType.banner);

      // Verify that no onboarding text is present
      expect(find.text('Title 1'), findsNothing);
      expect(find.text('Description 1'), findsNothing);

      // Verify the size of the container, which should be the fixed height
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 250.0); // Default height
    });

    testWidgets('Banner mode has infinite scrolling and updates indicators correctly',
        (WidgetTester tester) async {
      await pumpCarousel(tester, isForBanner: CarouselType.banner);
      
      // Initial state: `_currentPage` starts at 1, so the first indicator is active (index 0)
      final initialActiveIndicator = tester.widget<AnimatedContainer>(
          find.byWidgetPredicate((widget) => 
              widget is AnimatedContainer && (
                  widget.constraints?.maxWidth == 20.0 || widget.constraints?.maxHeight == 20.0
              )
          )
      );

      // Correct way to access the color from the decoration
      final BoxDecoration? initialDecoration = initialActiveIndicator.decoration as BoxDecoration?;
      expect(initialDecoration?.color, Colors.blue);

      // Swipe to the last "real" item (which is at index 3 in the padded list)
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      
      // Now at index 3 in the padded list, which corresponds to widget._imagePaths[2]
      // The indicator for widget._imagePaths[2] (index 2) should be active
      final secondActiveIndicator = tester.widget<AnimatedContainer>(
          find.byWidgetPredicate((widget) => 
              widget is AnimatedContainer && (
                  widget.constraints?.maxWidth == 20.0 || widget.constraints?.maxHeight == 20.0
              )
          )
      );

      // Correct way to access the color from the decoration
      final BoxDecoration? secondDecoration = secondActiveIndicator.decoration as BoxDecoration?;
      expect(secondDecoration?.color, Colors.blue);
      
      // Simulate an auto-scroll jump from the last padded page back to the first real page
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      
      // After the jump, the indicator for the first item (index 0) should be active again
      final jumpedIndicator = tester.widget<AnimatedContainer>(
          find.byWidgetPredicate((widget) => 
              widget is AnimatedContainer && (
                  widget.constraints?.maxWidth == 20.0 || widget.constraints?.maxHeight == 20.0
              )
          )
      );
      
      // Correct way to access the color from the decoration
      final BoxDecoration? jumpedDecoration = jumpedIndicator.decoration as BoxDecoration?;
      expect(jumpedDecoration?.color, Colors.blue);
    });

    // --- General Tests ---

    testWidgets('No auto-scroll when autoScroll is false',
        (WidgetTester tester) async {
      await pumpCarousel(tester, autoScroll: false);

      // Wait for longer than the interval, nothing should have changed
      await tester.pump(const Duration(seconds: 4));

      // Verify that the content is still the first page's content
      expect(find.text('Title 1'), findsOneWidget);
    });


testWidgets('Carousel auto-scrolls pages correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Carousel(
        autoScroll: true,
        imagePaths: ['img1', 'img2', 'img3'],
        interval: const Duration(seconds: 2),
        carouselType: CarouselType.banner,
      ),
    ),
  );

  // Wait for auto-scroll to move to second page
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(milliseconds: 500)); // AnimateToPage

  // First page transition
  final PageView pageView = tester.widget(find.byType(PageView));
  final PageController controller = pageView.controller!;
  expect(controller.page, isNotNull);
  expect(controller.page!.round(), equals(2));

  // Wait for another 4 seconds (2 intervals), should go to page 2 and then back to 1
  await tester.pump(const Duration(seconds: 4));
  await tester.pump(const Duration(milliseconds: 500));

  // You can optionally test looping back to page 1 if that's part of the logic
  expect(controller.page!.round(), equals(1));
});

 testWidgets('Tapping Skip button jumps to last page', (WidgetTester tester) async {
    // Test data
    final List<String> images = ['img1', 'img2', 'img3'];

    // Pump the Carousel widget
    await tester.pumpWidget(
      MaterialApp(
        home: Carousel(
          imagePaths: images,
          carouselType: CarouselType.walkthrough, // This ensures the "Skip" button is shown
          autoScroll: false,
        ),
      ),
    );

    // Wait for widget to settle
    await tester.pumpAndSettle();

    // Find the "Skip" text button
    final skipFinder = find.text("Skip");
    expect(skipFinder, findsOneWidget);

    // Tap the "Skip" button
    await tester.tap(skipFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 600)); // Wait for animateToPage

    // Retrieve the PageView and its controller
    final PageView pageView = tester.widget(find.byType(PageView));
    final PageController controller = pageView.controller!;

    // Expect the page to be the last one (index 2)
    expect(controller.page?.round(), equals(images.length - 1));
  });
  
  });
}

