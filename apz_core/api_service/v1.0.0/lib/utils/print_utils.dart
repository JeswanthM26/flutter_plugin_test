import "package:flutter/material.dart";

/// Utility class for printing long strings in chunks to avoid truncation
/// in the console output.
class PrintUtils {
  /// Constructor to initialize the PrintUtils with a debug mode flag.
  /// When [isDebugModeEnabled] is true, printing is enabled.
  /// When false, printing is disabled.
  PrintUtils({required final bool isDebugModeEnabled})
    : _isDebugModeEnabled = isDebugModeEnabled;

  final bool _isDebugModeEnabled;

  /// Prints the given [text] in chunks of [chunkSize] characters.
  /// This is useful for printing long strings without truncation.
  /// If [text] is empty or debug mode is disabled, it prints an empty line.
  void printCompleteStringUsingDebugPrint(
    final String text, {
    final int chunkSize = 800,
  }) {
    if (text.isEmpty || !_isDebugModeEnabled) {
      debugPrint("");
      return;
    }

    // This RegExp splits the string into chunks of up to
    // 'chunkSize' characters.
    // Using RegExp like this is a concise way to iterate over chunks.
    final RegExp pattern = RegExp(".{1,$chunkSize}");
    pattern.allMatches(text).forEach((final RegExpMatch match) {
      // Ensure match.group(0) is not null before printing,
      // though it should always match.
      debugPrint(match.group(0) ?? "");
    });
  }
}
