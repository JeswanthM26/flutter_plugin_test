import "dart:async";
import "package:apz_datepicker/datepicker_params.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

/// A Flutter plugin to show native date pickers.
class ApzDatepicker {
  
  /// Returns true if the current platform is web.
  bool getIsWeb() => kIsWeb;

  static const MethodChannel _channel = MethodChannel(
    "com.iexceed/date_picker",
  );

  /// Shows date picker.
  Future<String?> showDatePicker({
    required final DatePickerParams params,
  }) async {
    final DateTime? min = params.minDate;
    final DateTime? max = params.maxDate;

    if (getIsWeb()) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web platform",
      );
    }
    if (min != null && max != null && min.isAfter(max)) {
      throw UnsupportedError("minDate cannot be after maxDate");
    }
    final String? result = await _channel.invokeMethod(
      "showDatePicker",
      params.toMap(),
    );
    return result;
  }
}
