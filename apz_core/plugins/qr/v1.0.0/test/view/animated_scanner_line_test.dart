import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_qr/view/animated_scanner_line.dart';

void main() {
  const double cropSize = 300.0;
  testWidgets('scanner line animates vertically', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedScannerLine(cropSize: cropSize, isMultiScan: false),
        ),
      ),
    );

    // Capture initial position
    final initialPosition = tester.getTopLeft(find.byType(Container));

    // Advance the animation manually
    await tester.pump(const Duration(milliseconds: 500));

    // Capture new position
    final newPosition = tester.getTopLeft(find.byType(Container));

    // Expect it moved vertically
    expect(initialPosition.dy != newPosition.dy, isTrue);
  });
  testWidgets('does not render animation when isMultiScan is true', (
    WidgetTester tester,
  ) async {
    const testKey = Key('scanner_line');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedScannerLine(
            key: testKey,
            cropSize: 300.0,
            isMultiScan: true,
          ),
        ),
      ),
    );

    // Search within just our widget
    final animatedBuilderFinder = find.descendant(
      of: find.byKey(testKey),
      matching: find.byType(AnimatedBuilder),
    );

    expect(animatedBuilderFinder, findsNothing); // ✅ precise
    expect(
      find.byType(SizedBox),
      findsOneWidget,
    ); // ✅ matches SizedBox.shrink()
  });

  testWidgets('scanner line animates vertically', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              AnimatedScannerLine(cropSize: cropSize, isMultiScan: false),
            ],
          ),
        ),
      ),
    );

    final lineFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          (widget).constraints?.minHeight == 2,
    );

    Offset firstPosition = tester.getTopLeft(lineFinder);
    await tester.pump(const Duration(milliseconds: 500));
    Offset secondPosition = tester.getTopLeft(lineFinder);

    expect(
      firstPosition.dy != secondPosition.dy,
      isTrue,
      reason: 'Line should animate vertically',
    );
  });
}
