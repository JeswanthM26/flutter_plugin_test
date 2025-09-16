import "dart:async";

import "package:apz_auto_read_otp/apz_auto_read_otp.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:otp_autofill/otp_autofill.dart"; 

// Mock class using mocktail
class MockOTPInteractor extends Mock implements OTPInteractor {}

void main() {
  late APZAutoReadOtp autoReadOtp;
  late MockOTPInteractor mockInteractor;

  setUp(() {
    autoReadOtp = APZAutoReadOtp();
    mockInteractor = MockOTPInteractor();
    autoReadOtp.mockOTPInteractor(mockInteractor);
  });

  test("getIsWeb should return same as kIsWeb", () {
    expect(autoReadOtp.getIsWeb(), kIsWeb);
  });

  group("startOTPListener", () {
    test("should emit SMS text when consent listener receives message", () async {
      const smsText = "Your OTP is 123456";
      when(() => mockInteractor.startListenUserConsent(any()))
          .thenAnswer((_) async => smsText);

      final completer = Completer<String>();
      autoReadOtp.onSms = (text) => completer.complete(text);

      await autoReadOtp.startOTPListener(
        type: ListenerType.consent,
        senderNumber: "TEST",
      );

      final result = await completer.future;
      expect(result, smsText);

      verify(() => mockInteractor.startListenUserConsent("TEST")).called(1);
    });

    test("should emit SMS text when retriever listener receives message", () async {
      const smsText = "Your OTP is 654321";
      when(() => mockInteractor.startListenRetriever())
          .thenAnswer((_) async => smsText);

      final completer = Completer<String>();
      autoReadOtp.onSms = (text) => completer.complete(text);

      await autoReadOtp.startOTPListener(type: ListenerType.retriever);

      final result = await completer.future;
      expect(result, smsText);

      verify(() => mockInteractor.startListenRetriever()).called(1);
    });

    test("should not emit if SMS is null", () async {
      when(() => mockInteractor.startListenRetriever())
          .thenAnswer((_) async => null);

      bool called = false;
      autoReadOtp.onSms = (_) => called = true;

      await autoReadOtp.startOTPListener(type: ListenerType.retriever);

      expect(called, false);
    });

    test("should not start again if already listening", () async {
      when(() => mockInteractor.startListenRetriever())
          .thenAnswer((_) async => "dummy");

      await autoReadOtp.startOTPListener(type: ListenerType.retriever);
      await autoReadOtp.startOTPListener(type: ListenerType.retriever);

      // Only the first call should trigger retriever
      verify(() => mockInteractor.startListenRetriever()).called(1);
    });
  });

  group("stopOtpListener", () {
    test("should call stopListenForCode and reset listening state", () async {
      when(() => mockInteractor.stopListenForCode())
          .thenAnswer((_) async => {});

      await autoReadOtp.stopOtpListener();

      verify(() => mockInteractor.stopListenForCode()).called(1);

      // After stopping, it should allow restart
      when(() => mockInteractor.startListenRetriever())
          .thenAnswer((_) async => "OTP");

      await autoReadOtp.startOTPListener(type: ListenerType.retriever);

      verify(() => mockInteractor.startListenRetriever()).called(1);
    });
  });
}
