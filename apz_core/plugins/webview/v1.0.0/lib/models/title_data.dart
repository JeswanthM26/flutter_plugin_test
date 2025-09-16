import "package:flutter/material.dart";

/// A class that holds data for a title, including the title text and its color.
class TitleData {
  /// Constructs a [TitleData] with the given [title] and [titleColor].
  const TitleData({required this.title, required this.titleColor});

  /// The title text.
  final String title;

  /// The color of the title text.
  final Color titleColor;
}
