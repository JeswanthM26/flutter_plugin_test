import "package:apz_pdf_viewer/apz_pdf_viewer.dart";
import "package:flutter/material.dart";
import "package:pdfrx/pdfrx.dart";

/// enum to define the source type of the PDF
enum ApzPdfSourceType {
  /// PDF is loaded from a network URL
  network,

  /// PDF is loaded from an asset file
  asset,

  /// PDF is loaded from a local file
  file,
}

/// ApzPdfViewer is a
/// widget that displays a PDF document using the pdfrx package.
class ApzPdfViewer extends StatefulWidget {
  /// Creates an instance of [ApzPdfViewer].
  ///
  /// The [pdfViewerBuilder] is an optional parameter typically used for testing
  /// to inject a mock or fake [PdfViewer] widget. In production, it defaults
  /// to `null`, causing the widget to create the standard pdfrx.PdfViewer.
  const ApzPdfViewer({
    required final String source,
    required final ApzPdfSourceType sourceType,
    required final ApzPdfViewerController controller,
    required final PdfviewerModel config,
    super.key,
    final Map<String, String>? headers,
    @visibleForTesting // Mark as visible for testing
    final Widget Function(
      String source,
      ApzPdfSourceType sourceType,
      PdfViewerController pdfController,
      PdfViewerParams commonParams,
      Map<String, String>? headers,
    )?
    pdfViewerBuilder, // Constructor parameter
  }) : _source = source,
       _sourceType = sourceType,
       _controller = controller,
       _config = config,
       _headers = headers,
       _pdfViewerBuilder = pdfViewerBuilder; // Assignment in initializer list

  /// The source of the PDF document, which can be a URL,
  /// asset path, or file path.
  final String _source;

  /// The type of source from which the PDF is loaded.
  final ApzPdfSourceType _sourceType;

  /// The controller that manages the PDF viewer's state and actions.
  final ApzPdfViewerController _controller;

  /// Configuration model for the PDF viewer, containing texts and colors.
  final PdfviewerModel _config;

  /// Optional headers for network requests, used when loading PDFs from a URL.
  final Map<String, String>? _headers;

  /// Optional builder to provide a custom [PdfViewer] widget,
  /// typically for testing.
  // This is the correct declaration of the field within the class.
  final Widget Function(
    String source,
    ApzPdfSourceType sourceType,
    PdfViewerController pdfController,
    PdfViewerParams commonParams,
    Map<String, String>? headers,
  )?
  _pdfViewerBuilder;

  @override
  State<ApzPdfViewer> createState() => ApzPdfViewerState();
}

/// State class for [ApzPdfViewer].
class ApzPdfViewerState extends State<ApzPdfViewer> {
  /// Flag to show error text when PDF loading fails
  bool _showErrorText = false;

  /// Sets the error text visibility state.
  @visibleForTesting
  void setShowErrorText({required final bool value}) {
    setState(() {
      _showErrorText = value;
    });
  }

  /// Builds the common PdfViewerParams used in the PdfViewer.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  PdfViewerParams buildPdfViewerParams() => PdfViewerParams(
    enableTextSelection: true,
    loadingBannerBuilder:
        (final BuildContext context, final int downloaded, final int? total) =>
            Container(
              color: widget._config.backgroundColor,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: total != null ? downloaded / total : null,
              ),
            ),
    viewerOverlayBuilder:
        (
          final BuildContext context,
          final Size size,
          final bool Function(Offset) handleLinkTap,
        ) => <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPress: () async => widget._controller.resetZoom(),
            onDoubleTap: () async => widget._controller.zoomUp(loop: true),
            onTapUp: (final TapUpDetails details) =>
                handleLinkTap(details.localPosition),
            child: IgnorePointer(
              child: SizedBox(width: size.width, height: size.height),
            ),
          ),
          PdfViewerScrollThumb(
            controller: widget._controller.pdfController,
            thumbSize: const Size(40, 25),
            thumbBuilder:
                (
                  final BuildContext context,
                  final Size size,
                  final int? pageNumber,
                  final PdfViewerController controller,
                ) => ColoredBox(
                  color: widget._config.scrollThumbColor,
                  child: Center(
                    child: Text(
                      pageNumber.toString(),
                      style: TextStyle(
                        color: widget._config.pageNumberTextColor,
                      ),
                    ),
                  ),
                ),
          ),
          PdfViewerScrollThumb(
            controller: widget._controller.pdfController,
            orientation: ScrollbarOrientation.bottom,
            thumbSize: const Size(80, 30),
            thumbBuilder:
                (
                  final BuildContext context,
                  final Size size,
                  final int? pageNumber,
                  final PdfViewerController controller,
                ) => Container(color: widget._config.scrollThumbColor),
          ),
        ],
    pageOverlaysBuilder:
        (final BuildContext context, final Rect pageRect, final PdfPage page) =>
            <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  page.pageNumber.toString(),
                  style: TextStyle(color: widget._config.pageNumberTextColor),
                ),
              ),
            ],
  );

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final BuildContext context, final BoxConstraints constraints) {
      if (_showErrorText) {
        return SingleChildScrollView(
          child: Center(child: Text(widget._config.pdfErrorText)),
        );
      }

      final PdfViewerParams commonParams = PdfViewerParams(
        enableTextSelection: true,
        loadingBannerBuilder:
            (
              final BuildContext context,
              final int downloaded,
              final int? total,
            ) => Container(
              color: widget._config.backgroundColor,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: total != null ? downloaded / total : null,
              ),
            ),
        viewerOverlayBuilder:
            (
              final BuildContext context,
              final Size size,
              final bool Function(Offset) handleLinkTap,
            ) => <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: () async {
                  await widget._controller.resetZoom();
                },
                onDoubleTap: () async {
                  await widget._controller.zoomUp(loop: true);
                },
                onTapUp: (final TapUpDetails details) {
                  handleLinkTap(details.localPosition);
                },
                child: IgnorePointer(
                  child: SizedBox(width: size.width, height: size.height),
                ),
              ),
              PdfViewerScrollThumb(
                controller: widget._controller.pdfController,
                thumbSize: const Size(40, 25),
                thumbBuilder:
                    (
                      final BuildContext context,
                      final Size thumbSize,
                      final int? pageNumber,
                      final PdfViewerController controller,
                    ) => ColoredBox(
                      color: widget._config.scrollThumbColor,
                      child: Center(
                        child: Text(
                          pageNumber.toString(),
                          style: TextStyle(
                            color: widget._config.pageNumberTextColor,
                          ),
                        ),
                      ),
                    ),
              ),
              PdfViewerScrollThumb(
                controller: widget._controller.pdfController,
                orientation: ScrollbarOrientation.bottom,
                thumbSize: const Size(80, 30),
                thumbBuilder:
                    (
                      final BuildContext context,
                      final Size thumbSize,
                      final int? pageNumber,
                      final PdfViewerController controller,
                    ) => Container(color: widget._config.scrollThumbColor),
              ),
            ],
        pageOverlaysBuilder:
            (
              final BuildContext context,
              final Rect pageRect,
              final PdfPage page,
            ) => <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  page.pageNumber.toString(),
                  style: TextStyle(color: widget._config.pageNumberTextColor),
                ),
              ),
            ],
      );

      // Use the injected builder if provided,
      // otherwise create the real PdfViewer
      try {
        if (widget._pdfViewerBuilder != null) {
          return widget._pdfViewerBuilder!(
            widget._source,
            widget._sourceType,
            widget._controller.pdfController,
            commonParams,
            widget._headers,
          );
        } else {
          Widget viewer;
          try {
            switch (widget._sourceType) {
              case ApzPdfSourceType.network:
                viewer = PdfViewer.uri(
                  Uri.parse(widget._source),
                  controller: widget._controller.pdfController,
                  passwordProvider: () =>
                      getPdfPasswordOrAbort(context, widget._config),
                  headers: widget._headers,
                  params: commonParams,
                );
              case ApzPdfSourceType.asset:
                viewer = PdfViewer.asset(
                  widget._source,
                  controller: widget._controller.pdfController,
                  passwordProvider: () =>
                      getPdfPasswordOrAbort(context, widget._config),
                  params: commonParams,
                );
              case ApzPdfSourceType.file:
                viewer = PdfViewer.file(
                  widget._source,
                  controller: widget._controller.pdfController,
                  passwordProvider: () =>
                      getPdfPasswordOrAbort(context, widget._config),
                  params: commonParams,
                );
            }
            return viewer;
          } on Exception catch (e) {
            return Center(child: Text("${widget._config.pdfErrorText} $e"));
          }
        }
      } on Exception catch (e) {
        return Center(child: Text("${widget._config.pdfErrorText} $e"));
      }
    },
  );

  /// Internal helper to get PDF password or abort (pop screen).
  Future<String?> getPdfPasswordOrAbort(
    final BuildContext context,
    final PdfviewerModel config,
  ) async {
    final String? result = await showPdfPasswordDialog(context, config);

    if (result == null || result.isEmpty) {
      // Prevent retry: return null once and exit viewer screen
      await Future<dynamic>.microtask(() async {
        if (context.mounted) {
          // Use `maybePop` to avoid error if there's no route to pop.
          await Navigator.of(context).maybePop(); // dismiss ApzPdfViewer screen
        }
      });

      return null;
    }

    return result;
  }

  /// Shows the PDF password dialog.
  Future<String?> showPdfPasswordDialog(
    final BuildContext context,
    final PdfviewerModel config,
  ) async {
    final TextEditingController textController = TextEditingController();
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (final BuildContext context) => AlertDialog(
        title: Text(
          config.enterTitleText,
          style: Theme.of(context).dialogTheme.titleTextStyle,
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          onSubmitted: (final String value) {
            if (value.isNotEmpty) {
              Navigator.of(context).pop(value.trim());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(config.emptyPasswordErrorText),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() => _showErrorText = true);
              Navigator.of(context).pop();
            },
            child: Text(config.cancelButtonText),
          ),
          TextButton(
            onPressed: () {
              if (textController.text == "") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(config.emptyPasswordErrorText),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.of(context).pop(textController.text.trim());
              }
            },
            child: Text(config.okButtonText),
          ),
        ],
      ),
    );
  }

  /// @nodoc
  /// This method is exposed for testing purposes only to
  /// trigger the password dialog.
  @visibleForTesting
  Future<void> openPasswordDialogForTest() async {
    await showPdfPasswordDialog(context, widget._config);
  }
}
