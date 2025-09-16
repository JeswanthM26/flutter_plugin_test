import "package:apz_datepicker/apz_datepicker.dart";
import "package:apz_datepicker/datepicker_params.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

class MockApzDatepicker extends ApzDatepicker {
  final bool isWeb;

  MockApzDatepicker({required this.isWeb});

  @override
  bool getIsWeb() => isWeb;
}

void main() {
  const MethodChannel channel = MethodChannel("com.iexceed/date_picker");

  TestWidgetsFlutterBinding.ensureInitialized();

  group("ApzDatepicker Tests", () {
    late List<MethodCall> log;
    late ApzDatepicker plugin;

    setUp(() {
      log = <MethodCall>[];

      // Simulate native platform by default
      plugin = MockApzDatepicker(isWeb: false);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            if (methodCall.method == "showDatePicker") {
              return "12-10-2023";
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test("returns formatted date from native", () async {
      final params = DatePickerParams(
        initialDate: DateTime(2023, 10, 12),
        minDate: DateTime(2020, 1, 1),
        maxDate: DateTime(2030, 12, 31),
        dateFormat: "dd-MM-yyyy",
      );

      final result = await plugin.showDatePicker(params: params);

      expect(result, "12-10-2023");
      expect(log, hasLength(1));
      expect(log.first.method, "showDatePicker");

      final args = log.first.arguments as Map;
      expect(
        args["initialDate"],
        DateTime(2023, 10, 12).millisecondsSinceEpoch,
      );
      expect(args["minDate"], DateTime(2020, 1, 1).millisecondsSinceEpoch);
      expect(args["maxDate"], DateTime(2030, 12, 31).millisecondsSinceEpoch);
      expect(args["dateFormat"], "dd-MM-yyyy");
    });

    test("throws UnsupportedError when minDate is after maxDate", () async {
      final params = DatePickerParams(
        initialDate: DateTime(2023, 10, 12),
        minDate: DateTime(2030, 1, 1),
        maxDate: DateTime(2020, 1, 1),
        dateFormat: "dd-MM-yyyy",
      );

      expect(
        () => plugin.showDatePicker(params: params),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test("throws UnsupportedPlatformException when running on web", () async {
      final webPlugin = MockApzDatepicker(isWeb: true);

      final params = DatePickerParams(
        initialDate: DateTime(2023, 10, 12),
        dateFormat: "dd-MM-yyyy",
        minDate: DateTime(2030, 1, 1),
        maxDate: DateTime(2020, 1, 1),
      );

      expect(
        () => webPlugin.showDatePicker(params: params),
        throwsA(isA<UnsupportedPlatformException>()),
      );
    });
    test("getIsWeb returns correct platform value", () {
      final plugin = ApzDatepicker();
      expect(plugin.getIsWeb(), equals(kIsWeb));
    });
  });
}
