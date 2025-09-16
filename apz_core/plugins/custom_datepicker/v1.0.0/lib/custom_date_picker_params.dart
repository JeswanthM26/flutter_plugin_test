import "package:apz_custom_datepicker/selection_type.dart";
import "package:flutter/material.dart";

///class that holds parameters for the customdate picker
class CustomDatePickerParams {
  ///constructor for the CustomDatePickerParams
  CustomDatePickerParams({
    required this.context,
    required this.minDate,
    required this.maxDate,
    required this.initialDate,
    this.dialogSize,
    this.selectionType = SelectionType.single,
    this.themeColor,
    this.cancelButtonTextStyle,
    this.okButtonTextStyle,
    this.cancelButtonText,
    this.okButtonText,
    this.dateFormat,
    this.weekdayLabelTextStyle,
    this.controlsTextStyle,
  });

  ///context of the widget
  final BuildContext context;

  ///first date
  final DateTime minDate;

  ///last date
  final DateTime maxDate;

  ///initial date to be selected in the date picker
  final DateTime? initialDate;

  ///type of calendar to be displayed in the custom date picker
  final SelectionType selectionType;

  ///color of the theme to be used in the date picker
  final Color? themeColor;

  ///text styles for the cancel and ok buttons
  final TextStyle? cancelButtonTextStyle;

  ///text styles for the ok button
  final TextStyle? okButtonTextStyle;

  ///text for the cancel button
  final String? cancelButtonText;

  ///text for the done button
  final String? okButtonText;

  ///format for the date to be displayed in the date picker
  final String? dateFormat;

  ///text style for the weekday labels in the date picker
  final TextStyle? weekdayLabelTextStyle;

  ///text style for the controls in the date picker
  final TextStyle? controlsTextStyle;

  /// size of the dialog to be displayed in the date picker
  final Size? dialogSize;
}
