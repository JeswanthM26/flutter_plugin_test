import "package:apz_custom_datepicker/custom_date_picker_params.dart";
import "package:apz_custom_datepicker/selection_type.dart";
import "package:calendar_date_picker2/calendar_date_picker2.dart";
import "package:flutter/material.dart";

/// A custom date picker that allows users to select a single or range dates.
class ApzCustomDatepicker {
  /// Displays a custom date picker dialog.
  Future<List<String?>?> showCustomDate(
    final CustomDatePickerParams params,
  ) async {
    try {
      if (params.minDate.isAfter(params.maxDate)) {
        throw ArgumentError("minDate cannot be after maxDate");
      }
      // Convert to CalendarDatePicker2Type
      final CalendarDatePicker2Type internalType =
          params.selectionType == SelectionType.single
          ? CalendarDatePicker2Type.single
          : CalendarDatePicker2Type.range;

      final CalendarDatePicker2WithActionButtonsConfig config =
          CalendarDatePicker2WithActionButtonsConfig(
            calendarType: internalType,
            firstDate: params.minDate,
            lastDate: params.maxDate,
            selectedDayHighlightColor:
                params.themeColor ?? Theme.of(params.context).primaryColor,
            okButton: Text(
              params.okButtonText ?? "OK",
              style: params.okButtonTextStyle,
            ),
            cancelButton: Text(
              params.cancelButtonText ?? "Cancel",
              style: params.cancelButtonTextStyle,
            ),
            weekdayLabelTextStyle: params.weekdayLabelTextStyle,
            controlsTextStyle: params.controlsTextStyle,
            centerAlignModePicker: true,
            rangeBidirectional: true,
          );

      final List<DateTime?> initialValue =
          internalType == CalendarDatePicker2Type.single
          ? <DateTime>[params.initialDate ?? DateTime.now()]
          : <DateTime?>[params.initialDate, null];

      final List<DateTime?>? result = await showCalendarDatePicker2Dialog(
        context: params.context,
        config: config,
        value: initialValue,
        dialogSize: params.dialogSize ?? const Size(325, 400),
        borderRadius: BorderRadius.circular(15),
      );

      if (result == null || result.isEmpty) {
        return null;
      }
      return result
          .whereType<DateTime>()
          .map(
            (final DateTime date) =>
                formatDate(date, params.dateFormat ?? "dd/MM/yyyy"),
          )
          .toList();
    } catch (e) {
      throw Exception("custom DatePicker error: $e");
    }
  }

  /// Formats a DateTime object into a string based on the provided format.
  String formatDate(final DateTime date, final String format) {
    String twoDigits(final int n) => n.toString().padLeft(2, "0");

    final String day = twoDigits(date.day);
    final String month = twoDigits(date.month);
    final String year = date.year.toString();

    return format
        .replaceAll("dd", day)
        .replaceAll("MM", month)
        .replaceAll("yyyy", year);
  }
}
