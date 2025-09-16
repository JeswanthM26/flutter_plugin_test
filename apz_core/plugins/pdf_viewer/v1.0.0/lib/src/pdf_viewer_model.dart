import "package:flutter/material.dart";

/// Model class for configuring the PDF viewer
class PdfviewerModel {

  
/// Constructor for PdfviewerModel
  const PdfviewerModel({
    required this.enterTitleText,
    required this.okButtonText,
    required this.cancelButtonText,
    required this.pdfErrorText,
    required this.emptyPasswordErrorText,
    required this.scrollThumbColor,
    required this.pageNumberTextColor,
    this.backgroundColor= Colors.white,
  });
  /// Texts and colors used in the PDF viewer
  final String enterTitleText;
  /// Button texts for actions in the PDF viewer
  final String okButtonText;
  /// Button text for cancel action in the PDF viewer
  final String cancelButtonText;
  /// Error text displayed when there is an issue with the PDF
  final String pdfErrorText;
  /// Empty Password Error text 
  final String emptyPasswordErrorText;

/// Color of the scroll thumb in the PDF viewer
  final Color scrollThumbColor;
  /// Color of the page number text in the PDF viewer
  final Color pageNumberTextColor;
  /// Background color of the PDF viewer
  final Color backgroundColor;
}
