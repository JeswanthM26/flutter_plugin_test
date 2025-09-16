import "package:pdfrx/pdfrx.dart";

/// Apz Pdf Controller
class ApzPdfViewerController {

  /// Constructor that allows injecting a PdfViewerController for testing.
  /// If no controller is provided (i.e., `pdfViewerController` is null),
  /// it defaults to creating a new [PdfViewerController] instance.
  ApzPdfViewerController({
     final PdfViewerController? pdfViewerController, 
  }) : _pdfViewerController = pdfViewerController ?? PdfViewerController();
  
//  final PdfViewerController _pdfViewerController = PdfViewerController();

  final PdfViewerController _pdfViewerController;


/// pdf zoom function
  Future<void> zoomUp({final bool loop = false}) => 
  _pdfViewerController.zoomUp(loop: loop);
  
/// rest back   
  Future<void> resetZoom() async {
      // Get current page and go to it (this typically resets position)
      final int? currentPage = _pdfViewerController.pageNumber;
      await _pdfViewerController.goToPage(pageNumber: currentPage??1);
      
      // Small delay to let the navigation complete
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));
      
    }

  
/// get pdf controller
  PdfViewerController get pdfController => _pdfViewerController; 
}
