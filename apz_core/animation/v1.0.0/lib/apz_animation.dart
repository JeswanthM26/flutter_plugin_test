import "dart:async";

import "package:apz_animation/enum/carousel_type.dart";
import "package:apz_animation/enum/gif_position.dart";
import "package:apz_animation/enum/payment_status.dart";
import "package:apz_animation/src/carousel.dart";
import "package:apz_animation/src/payment_inprogress_ui.dart";
import "package:flutter/material.dart";

export "enum/carousel_type.dart";
export "enum/gif_position.dart";
export "enum/payment_status.dart";

/// GifOverlayManager class to manage GIF overlays in the app.
class ApzAnimation {
  OverlayEntry? _overlayEntry;

  /// Flag to indicate if the overlay is for testing purposes.
  @visibleForTesting
  bool isForTesting = false;

  /// Show a GIF overlay at the specified position for a given duration.
  void showGif({
    required final BuildContext context,
    required final String gifPath,
    required final Duration duration,
    required final GifPosition position,
  }) {
    hideGif();

    Widget image;
    if (isForTesting) {
      image = const FlutterLogo();
    } else {
      image = Image.asset(gifPath, fit: BoxFit.cover);
    }

    Alignment alignment;
    switch (position) {
      case GifPosition.top:
        alignment = Alignment.topCenter;
      case GifPosition.center:
        alignment = Alignment.center;
      case GifPosition.bottom:
        alignment = Alignment.bottomCenter;
    }

    _overlayEntry = OverlayEntry(
      builder: (final BuildContext context) => AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: false,
          child: Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Align(alignment: alignment, child: image),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Timer(duration, () {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    });
  }

  /// Hide the currently displayed GIF overlay.
  void hideGif() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  /// get gif widget
  Widget showPaymentStatus({
    required final PaymentStatus paymentStatus,

   final Color? loadingColor,

    final String? successGifPath,

    final String? failureGifPath,
  }) {
    Widget statusGif;
    if (isForTesting) {
      statusGif = const FlutterLogo();
    } else {
      switch (paymentStatus) {
        case PaymentStatus.loading:
          statusGif = PaymentInProgressUI(loaderColor: loadingColor);
        case PaymentStatus.success:
          statusGif = Image.asset(
            successGifPath ?? "packages/apz_animation/gif/success.gif",
            fit: BoxFit.cover,
          );
        case PaymentStatus.failure:
          statusGif = Image.asset(
            failureGifPath ?? "packages/apz_animation/gif/failed.gif",
            fit: BoxFit.cover,
          );
      }
    }

    return statusGif;
  }

 /// show a walkthrough carousel widget with the given image paths.
  Widget walkthroughCarousel(
  {required final WalkthroughModel carouselData}) => Carousel(
     carouselType: CarouselType.walkthrough,
      imagePaths: carouselData.imagePaths,
      showIndicator: carouselData.showIndicator,
      autoScroll: carouselData.autoScroll,
      interval: carouselData.interval,
      height: carouselData.height,
      networkImage: carouselData.networkImage,
      activeIndicatorColor: carouselData.activeIndicatorColor,
      inActiveIndicatorColor: carouselData.inActiveIndicatorColor,
      welcomeTitle: carouselData.welcomeTitle,
      welcomeDescription: carouselData.welcomeDescription,
      buttonName: carouselData.buttonText,
      onButtonPressed: carouselData.onButtonPressed,
      skipText: carouselData.skipText,
    );


   /// show a banner carousel widget with the given image paths.
  Widget bannerCarousel(
  {required final BannerModel carouselData}
    ) => Carousel(
      carouselType: CarouselType.banner,
      imagePaths: carouselData.imagePaths,
      showIndicator: carouselData.showIndicator,
      autoScroll: carouselData.autoScroll,
      interval: carouselData.interval,
      height: carouselData.height,
      networkImage: carouselData.networkImage,
      activeIndicatorColor: carouselData.activeIndicatorColor,
      inActiveIndicatorColor: carouselData.inActiveIndicatorColor,
    );  

}
