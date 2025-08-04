import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_qr/apz_qr_scanner.dart';

void main() {
  testWidgets('ApzQrScanner renders without crashing', (WidgetTester tester) async {
    // Define dummy callbacks
    final callbacks = ApzQrScannerCallbacks(
      onScanSuccess: (_) {},
      onScanFailure: (_) {},
      onMultiScanSuccess: (_) {},
      onMultiScanFailure: (_) {},
      onMultiScanModeChanged: ({required bool isEnabled}) {},
      onError: (_) {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApzQrScanner(callbacks: callbacks),
        ),
      ),
    );

    expect(find.byType(ApzQrScanner), findsOneWidget);
  });
}
