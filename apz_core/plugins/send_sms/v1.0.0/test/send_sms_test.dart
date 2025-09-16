import "package:apz_send_sms/apz_send_sms.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  const MethodChannel channel = MethodChannel("com.iexceed/apz_send_sms");
  final List<MethodCall> log = <MethodCall>[];

  late TestWidgetsFlutterBinding binding;
  setUp(() {
    binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      final MethodCall methodCall,
    ) async {
      log.add(methodCall);
      if (methodCall.method == "sendSMS") {
        return "launched";
      }
      throw PlatformException(code: "NOT_IMPLEMENTED");
    });
    log.clear();
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test("throws exception if phoneNumber is empty", () async {
    final ApzSendSMS sendSMS = ApzSendSMS();
    expect(
      () => sendSMS.send(phoneNumber: "   ", message: "Hello"),
      throwsA(isA<Exception>()),
    );
  });

  test("throws exception if message is empty", () async {
    final ApzSendSMS sendSMS = ApzSendSMS();
    expect(
      () => sendSMS.send(phoneNumber: "1234567890", message: "   "),
      throwsA(isA<Exception>()),
    );
  });

  test("throws UnsupportedPlatformException on web", () async {
    final ApzSendSMS sendSMS = ApzSendSMS()..setIsWeb(isWeb: true);
    expect(
      () => sendSMS.send(phoneNumber: "1234567890", message: "Hello"),
      throwsA(isA<UnsupportedPlatformException>()),
    );
  });

  test("send returns launched status when aunched", () async {
    final ApzSendSMS sendSMS = ApzSendSMS();
    final SendSMSStatus status = await sendSMS.send(
      phoneNumber: "1234567890",
      message: "Hello",
    );
    expect(status, SendSMSStatus.launched);
    expect(log, hasLength(1));
    expect(log.first.method, "sendSMS");
    expect(log.first.arguments, <String, String>{
      "number": "1234567890",
      "message": "Hello",
    });
  });

  test("send returns sent status", () async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      final MethodCall methodCall,
    ) async {
      log.add(methodCall);
      return "sent";
    });
    final ApzSendSMS sendSMS = ApzSendSMS();
    final SendSMSStatus status = await sendSMS.send(
      phoneNumber: "1234567890",
      message: "Hello",
    );
    expect(status, SendSMSStatus.sent);
  });

  test("send returns cancelled status", () async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      final MethodCall methodCall,
    ) async {
      log.add(methodCall);
      return "cancelled";
    });
    final ApzSendSMS sendSMS = ApzSendSMS();
    final SendSMSStatus status = await sendSMS.send(
      phoneNumber: "1234567890",
      message: "Hello",
    );
    expect(status, SendSMSStatus.cancelled);
  });

  test("send throws exception on error", () async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      final MethodCall methodCall,
    ) async {
      throw PlatformException(code: "SEND_SMS_ERROR", message: "Failed");
    });
    final ApzSendSMS sendSMS = ApzSendSMS();
    expect(
      () => sendSMS.send(phoneNumber: "1234567890", message: "Hello"),
      throwsA(isA<PlatformException>()),
    );
  });

  test("send throws exception on unknown status", () async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      final MethodCall methodCall,
    ) async {
      log.add(methodCall);
      return "unknown_status";
    });
    final ApzSendSMS sendSMS = ApzSendSMS();
    expect(
      () => sendSMS.send(phoneNumber: "1234567890", message: "Hello"),
      throwsA(isA<Exception>()),
    );
  });
}
