import "package:apz_pdf_viewer/apz_pdf_viewer.dart";

/// A function type that builds an instance of `ApzPdfViewer`.
typedef ApzPdfViewerBuilder = ApzPdfViewer Function({
  required String source,
  required ApzPdfSourceType sourceType,
  required PdfviewerModel config,
  required ApzPdfViewerController controller,
});
