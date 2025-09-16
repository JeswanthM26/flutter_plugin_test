# ApzAnimation Usage

## Overview

`ApzAnimation` allows you to display a GIF (or any widget) overlay at the top, center, or bottom of the screen for a specified duration.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  apz_animation:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/animation/v1.0.0
```

Then run:

```sh
flutter pub get
```

## Example

```dart
import 'package:apz_animation/apz_animation.dart';

final apzAnimation = ApzAnimation();

// Show a GIF overlay
apzAnimation.showGif(
  context: context, // BuildContext
  gifPath: 'assets/your_gif.gif', // Path to your GIF asset
  duration: Duration(seconds: 2), // How long to show
  position: GifPosition.center, // top, center, or bottom
);

// Hide the overlay manually (optional)
apzAnimation.hideGif();

// shows payment loading and success animations

PaymentStatus _currentStatus = PaymentStatus.loading; // PaymentStatus.success, PaymentStatus.failure

apzAnimation.showPaymentStatus(
  paymentStatus: _currentStatus,
  loadingColor: Colors.orange
  successGifPath: 'assets/your_success_gif.gif', //optional
  failureGifPath: 'assets/your_failure_gif.gif', //optional
),

// get walkthrough carousel widget

apzAnimation.walkthroughCarousel(
      carouselData:WalkthroughModel(
          imagePaths:<String>[
              "assets/images/long_banner1.jpg"
              "assets/images/long_banner2.jpg"
              "assets/images/long_banner3.jpg"
                  ],
          interval: const Duration(seconds: 2),
          height: MediaQuery.of(context).size.height,
          activeIndicatorColor:Colors.orange,
          welcomeTitle:<String>[
               "Welcome Text for first slide",
               "Welcome Text for second slide",
               "Welcome Text for third slide",
                  ],
           welcomeDescription: <String>[
                "Description Text for first slide",
                "Description Text for second slide",
                "Description Text for third slide",
                  ],
           buttonName"Get Started!",
           onButtonPressed: () async {
                          //Navigate to Login Page
                  },
           autoScroll: false, // Set to false for manual control
                      )
               ),                                 

// get banner carousel

apzAnimation.bannerCarousel(
      carouselData:BannerModel(
          imagePaths: <String>[
              "assets/images/banner1.png",
              "assets/images/banner2.png",
              "assets/images/banner3.png",
              "assets/images/banner4.png",
                ],
           interval: const Duration(seconds: 2),
           height: 260,
           activeIndicatorColor: Colors.orange,
            )
              ),
```

## Testing

To avoid asset errors in tests, set:

```dart
apzAnimation.isForTesting = true;
```

This will show a FlutterLogo instead of a GIF.

## Enum: GifPosition

- `GifPosition.top`
- `GifPosition.center`
- `GifPosition.bottom`

## Notes

- Make sure your asset is included in `pubspec.yaml` if you use a real GIF.

## Jira Links
- https://appzillon.atlassian.net/browse/AN-144
- https://appzillon.atlassian.net/browse/AN-149
- https://appzillon.atlassian.net/browse/AN-156
