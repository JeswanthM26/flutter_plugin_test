import "package:flutter/painting.dart";

/// AcceptDeclineBtn is a model class that holds the properties for an accept/decline button widget.
class AcceptDeclineBtn {
  /// Constructs an [AcceptDeclineBtn] with the required parameters.
  AcceptDeclineBtn({
    required this.acceptText,
    required this.declineText,
    required this.acceptBgColor,
    required this.declineBgColor,
    required this.acceptTextColor,
    required this.declineTextColor,
    required this.acceptTapAction,
    required this.declineTapAction,
  });

  /// The text displayed on the accept button.
  final String acceptText;

  /// The text displayed on the decline button.
  final String declineText;

  /// The background color of the accept button.
  final Color acceptBgColor;

  /// The background color of the decline button.
  final Color declineBgColor;

  /// The text color of the accept button.
  final Color acceptTextColor;

  /// The text color of the decline button.
  final Color declineTextColor;

  /// The action to perform when the accept button is tapped.
  final void Function() acceptTapAction;

  /// The action to perform when the decline button is tapped.
  final void Function() declineTapAction;
}
