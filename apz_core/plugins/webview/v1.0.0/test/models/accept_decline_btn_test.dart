import "package:apz_webview/models/accept_decline_btn.dart";
import "package:flutter/painting.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("AcceptDeclineBtn", () {
    test("should create AcceptDeclineBtn with correct properties", () {
      const String acceptText = "Accept";
      const String declineText = "Decline";
      const Color acceptBgColor = Color(0xFF00FF00);
      const Color declineBgColor = Color(0xFFFF0000);
      const Color acceptTextColor = Color(0xFFFFFFFF);
      const Color declineTextColor = Color(0xFF000000);

      bool acceptCalled = false;
      bool declineCalled = false;

      final AcceptDeclineBtn acceptDeclineBtn = AcceptDeclineBtn(
        acceptText: acceptText,
        declineText: declineText,
        acceptBgColor: acceptBgColor,
        declineBgColor: declineBgColor,
        acceptTextColor: acceptTextColor,
        declineTextColor: declineTextColor,
        acceptTapAction: () => acceptCalled = true,
        declineTapAction: () => declineCalled = true,
      );

      expect(acceptDeclineBtn.acceptText, equals(acceptText));
      expect(acceptDeclineBtn.declineText, equals(declineText));
      expect(acceptDeclineBtn.acceptBgColor, equals(acceptBgColor));
      expect(acceptDeclineBtn.declineBgColor, equals(declineBgColor));
      expect(acceptDeclineBtn.acceptTextColor, equals(acceptTextColor));
      expect(acceptDeclineBtn.declineTextColor, equals(declineTextColor));

      // Test acceptTapAction
      acceptDeclineBtn.acceptTapAction();
      expect(acceptCalled, isTrue);

      // Test declineTapAction
      acceptDeclineBtn.declineTapAction();
      expect(declineCalled, isTrue);
    });
  });
}
