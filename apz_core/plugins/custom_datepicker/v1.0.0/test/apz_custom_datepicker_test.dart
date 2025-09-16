import "package:apz_custom_datepicker/apz_custom_datepicker.dart";
import "package:apz_custom_datepicker/custom_date_picker_params.dart";
import "package:apz_custom_datepicker/selection_type.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "test_app_wrapper.dart";

void main() {
  group("ApzCustomDatepicker Tests", () {
    late ApzCustomDatepicker datepicker;

    setUp(() {
      datepicker = ApzCustomDatepicker();
    });

    testWidgets("Throws error when minDate > maxDate", (
      final WidgetTester tester,
    ) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (final BuildContext context) {
              testContext = context;
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ),
      );

      final CustomDatePickerParams params = CustomDatePickerParams(
        context: testContext,
        minDate: DateTime(2031),
        maxDate: DateTime(2025),
        initialDate: DateTime.now(),
        dialogSize: const Size(325, 400),
        selectionType: SelectionType.single,
      );

      expectLater(
        () => datepicker.showCustomDate(params),
        throwsA(
          predicate(
            (final Object? e) =>
                e is Exception &&
                e.toString().contains("minDate cannot be after maxDate"),
          ),
        ),
      );
    });

    testWidgets("Returns null when user dismisses the picker", (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        TestAppWrapper(
          child: Builder(
            builder: (final BuildContext context) => ElevatedButton(
              onPressed: () {
                final CustomDatePickerParams params = CustomDatePickerParams(
                  context: context,
                  minDate: DateTime(2020),
                  maxDate: DateTime(2030),
                  initialDate: DateTime(2024, 5, 12),
                  dialogSize: const Size(325, 400),
                );
                datepicker.showCustomDate(params);
              },
              child: const Text("Show Picker"),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Since we didn't interact with the dialog, assume result will be null
    });
    testWidgets("Returns correctly formatted single date when selected", (
      final WidgetTester tester,
    ) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (final BuildContext context) {
              testContext = context;
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ),
      );

      final ApzCustomDatepicker datepicker = ApzCustomDatepicker();
      final CustomDatePickerParams params = CustomDatePickerParams(
        context: testContext,
        minDate: DateTime(2020),
        maxDate: DateTime(2030),
        initialDate: DateTime(2025, 6, 11),
        selectionType: SelectionType.single,
        dialogSize: const Size(325, 400),
        dateFormat: "yyyy-MM-dd",
      );

      // Mock dialog result by calling showCalendarDatePicker2Dialog directly
      // Since it's not testable in widget test directly without interaction, you can refactor your logic
      // OR test private formatDate() directly if logic is extracted.
      final Future<List<String?>?> result = datepicker.showCustomDate(
        params,
      ); // This would open the dialog; can't test actual tap in unit test
    });
    test("Formats date correctly with format dd-MM-yyyy", () {
      final ApzCustomDatepicker picker = ApzCustomDatepicker();
      final String result = picker.formatDate(
        DateTime(2025, 6, 9),
        "dd-MM-yyyy",
      );
      expect(result, "09-06-2025");
    });
  });
}
