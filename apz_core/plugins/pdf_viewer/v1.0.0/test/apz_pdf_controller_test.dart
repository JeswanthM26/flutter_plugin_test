import "package:apz_pdf_viewer/apz_pdf_viewer.dart";
import "package:flutter/material.dart";
import 'package:flutter_test/flutter_test.dart'; // For test utilities like `group` and `test`
import 'package:mocktail/mocktail.dart';          // For creating mock objects with Mocktail
import 'package:pdfrx/pdfrx.dart';             // Your PdfViewerController and other pdfrx types


// 1. Create a Mock class for PdfViewerController using Mocktail
// This allows us to control the behavior of PdfViewerController during tests
class MockPdfViewerController extends Mock implements PdfViewerController {}
void main() {
  // 2. Group tests related to ApzPdfViewerController
  group('ApzPdfViewerController', () {
    // Declare variables that will be initialized before each test
    late ApzPdfViewerController apzPdfViewerController;
    late MockPdfViewerController mockPdfViewerController;

    // 3. Set up common conditions before each test in this group
    setUpAll(() {
      // Removed: registerFallbackValue(const PdfViewerGoToPageParams(pageNumber: 1));
      // Explanation: The goToPage method directly accepts primitive types or basic objects
      // like Duration/Offset. It does not take a 'PdfViewerGoToPageParams' object directly
      // as a parameter. Therefore, no fallback is needed for it.
       registerFallbackValue(Duration.zero); // Fallback for Duration
      registerFallbackValue(Curves.linear); // Fallback for Curve
      registerFallbackValue(Offset.zero);   // Fallback for Offset
    });

    setUp(() {
      // Initialize a new mock PdfViewerController for each test to ensure isolation
      mockPdfViewerController = MockPdfViewerController();

      // Now, instantiate ApzPdfViewerController and inject the mock.
      // This relies on the ApzPdfViewerController having a constructor
      // that accepts a PdfViewerController (see modifications below).
      apzPdfViewerController = ApzPdfViewerController(
        pdfViewerController: mockPdfViewerController,
      );
    });

    // 4. Test case for the `zoomUp` method
    test('zoomUp should call zoomUp on the underlying PdfViewerController', () async {
      // Arrange: Define what the mock should do when `zoomUp` is called
      // Use `when(() => ...)` syntax for Mocktail
      when(() => mockPdfViewerController.zoomUp(loop: any(named: 'loop')))
          .thenAnswer((_) async {}); // Simulate an async completion

      // Act: Call the method on your controller
      await apzPdfViewerController.zoomUp(loop: true);

      // Assert: Verify that the corresponding method on the mock was called
      // Use `verify(() => ...)` syntax for Mocktail
      verify(() => mockPdfViewerController.zoomUp(loop: true)).called(1);

      // Test with default loop value (false)
      await apzPdfViewerController.zoomUp();
      verify(() => mockPdfViewerController.zoomUp(loop: false)).called(1);
    });

    // 5. Test case for the `resetZoom` method
    test('resetZoom should get current page and then go to that page', () async {
      // Arrange:
      const int testPageNumber = 5;
      // When `pageNumber` is accessed, return `testPageNumber`
      when(() => mockPdfViewerController.pageNumber).thenReturn(testPageNumber);
      // When `goToPage` is called, simulate an async completion
      when(() => mockPdfViewerController.goToPage(
            pageNumber: any(named: 'pageNumber'),
            duration: any(named: 'duration'),
          
          )).thenAnswer((_) async {});

      // Act: Call the method on your controller
      await apzPdfViewerController.resetZoom();

      // Assert:
      // Verify that `pageNumber` was accessed
      verify(() => mockPdfViewerController.pageNumber).called(1);
      // Verify that `goToPage` was called with the correct page number
      verify(() => mockPdfViewerController.goToPage(pageNumber: testPageNumber)).called(1);

      // Note on `Future.delayed`: We typically don't directly test `Future.delayed`.
      // Its presence ensures a brief pause. If there were subsequent operations
      // after the delay that depend on it, we'd test their eventual state.
      // For unit tests, we primarily check the sequence of calls.
    });

    // Test `resetZoom` when pageNumber is null
  test('resetZoom should get current page and then go to that page', () async {
      // Arrange:
      const int testPageNumber = 5;
      // When `pageNumber` is accessed, return `testPageNumber`.
      // For getters, you directly provide the return value, no `any()` needed.
      when(() => mockPdfViewerController.pageNumber).thenReturn(testPageNumber);
      // When `goToPage` is called, simulate an async completion
      when(() => mockPdfViewerController.goToPage(
            pageNumber: any(named: 'pageNumber'),
            duration: any(named: 'duration'),
          
          )).thenAnswer((_) async {});

      // Act: Call the method on your controller
      await apzPdfViewerController.resetZoom();

      // Assert:
      // Verify that `pageNumber` was accessed
      verify(() => mockPdfViewerController.pageNumber).called(1);
      // Verify that `goToPage` was called with the correct page number
      verify(() => mockPdfViewerController.goToPage(pageNumber: testPageNumber)).called(1);

      // Note on `Future.delayed`: We typically don't directly test `Future.delayed`.
      // Its presence ensures a brief pause. If there were subsequent operations
      // after the delay that depend on it, we'd test their eventual state.
      // For unit tests, we primarily check the sequence of calls.
    });

    // 6. Test case for the `pdfController` getter
    test('pdfController getter should return the internal PdfViewerController instance', () {
      // Act: Access the getter
      final PdfViewerController returnedController = apzPdfViewerController.pdfController;

      // Assert: Verify that the returned instance is the same as the mock we injected
      expect(returnedController, equals(mockPdfViewerController));
    });
  });
}
