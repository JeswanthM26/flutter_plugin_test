// file: test/image_preview_widget_test.dart
import 'dart:convert';
import 'dart:typed_data';
import "package:apz_camera/ui/image_preview_widget.dart";
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A tiny valid 1x1 transparent PNG so Image.memory has valid encoded bytes.
Uint8List _onePxTransparentPng() {
  const base64Png =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
  return base64Decode(base64Png);
}

void main() {
  testWidgets('tapping doneButton pops with true', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    // Build a minimal app with a Navigator.
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    // Push the preview screen and capture the resulting Future<bool?>.
    final resultFuture = navigatorKey.currentState!.push<bool>(
      MaterialPageRoute(
        builder: (_) => ImagePreviewWidget(
          imageBytes: _onePxTransparentPng(),
          title: "Preview",
        ),
      ),
    );

    // Let the page push animation complete.
    await tester.pumpAndSettle();

    // Tap the "use this photo" button (done).
    await tester.tap(find.byKey(const Key('doneButton')));
    await tester.pumpAndSettle();

    // The route should pop with true.
    final result = await resultFuture;
    expect(result, isTrue);
  });

  testWidgets('tapping retakeButton pops with false', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    final resultFuture = navigatorKey.currentState!.push<bool>(
      MaterialPageRoute(
        builder: (_) => ImagePreviewWidget(
          imageBytes: _onePxTransparentPng(),
          title: "Preview",
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the "retake" button.
    await tester.tap(find.byKey(const Key('retakeButton')));
    await tester.pumpAndSettle();

    final result = await resultFuture;
    expect(result, isFalse);
  });

  testWidgets('shows AppBar title and an Image widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ImagePreviewWidget(
          imageBytes: _onePxTransparentPng(),
          title: "Preview",
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
