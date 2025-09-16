/// DatePickerParams class for managing date picker parameters
class DatePickerParams {
  //// Creates an instance of DatePickerParams with the required parameters.
  const DatePickerParams({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.dateFormat,
    this.title,
    this.cancelText,
    this.doneText,
    this.primaryColor,
    this.cancelColor,
    this.languageCode,
  });

  /// Creates an instance of DatePickerParams with the required parameters.
  final DateTime? initialDate;

  /// The minimum date that can be selected in the date picker.
  final DateTime? minDate;

  /// The maximum date that can be selected in the date picker.
  final DateTime? maxDate;

  /// The format in which the date will be displayed.
  final String? dateFormat;

  /// The title of the date picker dialog.
  final String? title;

  /// The text for the cancel button in the date picker dialog.
  final String? cancelText;

  /// The text for the done button in the date picker dialog.
  final String? doneText;

  /// The primary color for the date picker dialog.
  final int? primaryColor;

  /// The cancel color for the date picker dialog.
  final int? cancelColor;

  /// The language code for localization of the date picker dialog.
  final String? languageCode;

  /// Converts the DatePickerParams instance to a map for method channel arg.
  Map<String, dynamic> toMap() => <String, dynamic>{
    "initialDate": initialDate?.millisecondsSinceEpoch,
    "minDate": minDate?.millisecondsSinceEpoch,
    "maxDate": maxDate?.millisecondsSinceEpoch,
    "dateFormat": dateFormat,
    "title": title,
    "cancelText": cancelText,
    "doneText": doneText,
    "primaryColor": primaryColor,
    "errorColor": cancelColor,
    "languageCode": languageCode,
  };
}
