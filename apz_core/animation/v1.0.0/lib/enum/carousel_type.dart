import "package:flutter/material.dart";

/// Define an enum for the two possible carousel.
enum CarouselType {
  /// banner carousel.
  banner,

  /// walkthrough carousel.
  walkthrough,
}


/// walkthrough model class to hold carousel configuration.
class WalkthroughModel {

  /// Constructor for CarouselModel.
  WalkthroughModel({
    required this.imagePaths,
    required this.buttonText, 
    required this.onButtonPressed, 
    this.showIndicator,
    this.autoScroll,
    this.interval,
    this.height,
    this.networkImage,
    this.activeIndicatorColor,
    this.inActiveIndicatorColor,
    this.welcomeTitle,
    this.welcomeDescription,
    this.skipText,
  });
  /// List of image paths for the carousel.
  final List<String> imagePaths;
  /// Whether to show the indicator.
  final bool? showIndicator;
  /// Whether the carousel should auto-scroll.
  final bool? autoScroll;
  /// Interval for auto-scroll.
  final Duration? interval;
  /// Height of the carousel.
  final double? height;
  /// Whether the images are network images.
  final bool? networkImage;
  /// Color for the active indicator.
  final Color? activeIndicatorColor;
  /// Color for the inactive indicator.
  final Color? inActiveIndicatorColor;
  /// Titles for the welcome screen.
  final List<String>? welcomeTitle;
  /// Descriptions for the welcome screen.
  final List<String>? welcomeDescription;
  /// Name of the button to be displayed.
  final String buttonText;
  /// Callback for button press action.
  final VoidCallback onButtonPressed;
  /// Text for the skip button.
  final String? skipText;
}



/// bannerModel class to hold carousel configuration.
class BannerModel {

  /// Constructor for CarouselModel.
  BannerModel({
    required this.imagePaths,
    this.showIndicator,
    this.autoScroll,
    this.interval,
    this.height,
    this.networkImage,
    this.activeIndicatorColor,
    this.inActiveIndicatorColor,

  });
  /// List of image paths for the carousel.
  final List<String> imagePaths;
  /// Whether to show the indicator.
  final bool? showIndicator;
  /// Whether the carousel should auto-scroll.
  final bool? autoScroll;
  /// Interval for auto-scroll.
  final Duration? interval;
  /// Height of the carousel.
  final double? height;
  /// Whether the images are network images.
  final bool? networkImage;
  /// Color for the active indicator.
  final Color? activeIndicatorColor;
  /// Color for the inactive indicator.
  final Color? inActiveIndicatorColor;

}
