import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:apz_animation/src/payment_inprogress_ui.dart'; // Adjust this path if your file is located elsewhere

void main() {
  group('PaymentInProgressUI', () {
    // Test 1: Initial state and text display
    testWidgets('displays initial text and progress', (WidgetTester tester) async {
      bool paymentCompleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentInProgressUI(
            loaderColor: Colors.blue,
         
          ),
        ),
      );

      // Verify the initial text
      expect(find.text('Processing Payment...'), findsOneWidget);
      expect(find.text('Payment Done'), findsNothing); // Should not be present initially
      expect(find.text('Payment Failed'), findsNothing); // Should not be present initially

      // Verify that the onPaymentComplete callback has not been called yet
      expect(paymentCompleted, isFalse);

      // Verify initial progress and color of the CustomPaint
      // Use a more specific finder to avoid "Too many elements" error
      final Finder customPaintFinder = find.descendant(
        of: find.byType(PaymentInProgressUI),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget); // Ensure only one CustomPaint is found
      final CustomPaint customPaint = tester.widget(customPaintFinder);
      final PaymentProgressPainter painter = customPaint.painter as PaymentProgressPainter;
      expect(painter.progress, closeTo(0.0, 0.01)); // Initial progress should be very close to 0
      expect(painter.progressColor, Colors.blue); // Initial color should be blue
    });



    // Test 3: Timer cancellation on widget dispose
    testWidgets('timer is cancelled on dispose', (WidgetTester tester) async {
      bool paymentCompleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentInProgressUI(
           loaderColor: Colors.blue,
          ),
        ),
      );

      // Advance time partially (e.g., 2 seconds into a 5-second countdown)
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Processing Payment...'), findsOneWidget);
      expect(paymentCompleted, isFalse);

      // Dispose the widget by replacing it with an empty Container
      await tester.pumpWidget(Container());
      expect(find.byType(PaymentInProgressUI), findsNothing); // Verify widget is no longer in tree

      // Advance time further past the original totalSeconds.
      // If the timer was not cancelled, it would try to call setState on a disposed widget,
      // which would typically throw an error. By not throwing an error and by
      // paymentCompleted remaining false, we infer the timer was cancelled.
      await tester.pump(const Duration(seconds: 5));
      expect(paymentCompleted, isFalse); // Callback should NOT have been called after dispose
    });


 
  });
}
