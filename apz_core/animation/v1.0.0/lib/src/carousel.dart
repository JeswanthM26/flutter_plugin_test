import "dart:async";
import "package:apz_animation/enum/carousel_type.dart";
import "package:flutter/material.dart";

/// Carousel widget to display a list of images in a scrollable view.
class Carousel extends StatefulWidget {
  /// constructor for the Carousel widget.
  Carousel({
    required final CarouselType carouselType,
    super.key,
    final List<String>? imagePaths,
    final bool? showIndicator,
    final bool? autoScroll,
    final Duration? interval,
    final double? height,
    final bool? networkImage,
    final Color? activeIndicatorColor,
    final Color? inActiveIndicatorColor,
    final List<String>? welcomeTitle,
    final List<String>? welcomeDescription,
    final String? buttonName,
    final VoidCallback? onButtonPressed,
    final String? skipText,
  }) : _imagePaths = imagePaths ?? <String>[],
       _showIndicator = showIndicator ?? true,
       _autoScroll = autoScroll ?? true,
       _interval = interval ?? const Duration(seconds: 3),
       _height = height ?? 250.0,
       _networkImage = networkImage ?? false,
       _activeIndicatorColor = activeIndicatorColor ?? Colors.blue,
       _inActiveIndicatorColor = inActiveIndicatorColor ?? Colors.grey,
       _welcomeTitle = welcomeTitle ?? <String>[],
       _welcomeDescription = welcomeDescription ?? <String>[],
       _buttonName = buttonName ?? "Get Started",
       _onButtonPressed = onButtonPressed,
       _carouselType = carouselType,
       _skipText = skipText ?? "Skip";

  final CarouselType _carouselType;
  final List<String> _imagePaths;
  final bool _showIndicator;
  final bool _autoScroll;
  final Duration _interval;
  final double _height;
  final bool _networkImage;
  final Color _activeIndicatorColor;
  final Color _inActiveIndicatorColor;
  final List<String>? _welcomeTitle;
  final List<String>? _welcomeDescription;
  final String? _buttonName;
  final VoidCallback? _onButtonPressed;
  final String? _skipText;

  @override
  State<Carousel> createState() => CarouselState();
}

/// carousel state class to manage the carousel widget's state.
class CarouselState extends State<Carousel> {
  late final List<String> _carouselImages;
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget._carouselType == CarouselType.banner) {
      if (widget._imagePaths.length == 1) {
        _carouselImages = widget._imagePaths;
      } else {
        _carouselImages = <String>[
          widget._imagePaths.last,
          ...widget._imagePaths,
          widget._imagePaths.first,
        ];
      }
    } else {
      while (widget._welcomeTitle!.length < widget._imagePaths.length) {
        widget._welcomeTitle?.add(""); // Fill with empty string
      }
      while (widget._welcomeDescription!.length < widget._imagePaths.length) {
        widget._welcomeDescription?.add(""); // Fill with empty string
      }
      _carouselImages = widget._imagePaths;
    }

    if (widget._carouselType == CarouselType.banner) {
      _controller = widget._imagePaths.length == 1
          ? PageController()
          : PageController(viewportFraction: 0.8, initialPage: 1);
      _currentPage = 1;
    } else {
      _controller = PageController();
    }

    if (widget._autoScroll && widget._imagePaths.length > 1) {
      _timer = Timer.periodic(widget._interval, (_) async {
        if (widget._carouselType == CarouselType.banner) {
          _currentPage++;

          await _controller.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );

          if (_currentPage == _carouselImages.length - 1) {
            _currentPage = 1;
            await Future<void>.delayed(const Duration(milliseconds: 300));
            _controller.jumpToPage(_currentPage);
          }
        } else {
          _currentPage = (_currentPage + 1) % _carouselImages.length;
          await _controller.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Column(
    children: <Widget>[
      if (widget._carouselType == CarouselType.banner)
        SizedBox(height: widget._height, child: _buildPageView())
      else
        Expanded(child: _buildPageView()),
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 25),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child:
              _currentPage == widget._imagePaths.length - 1 &&
                  widget._carouselType != CarouselType.banner
              ? SizedBox(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton.icon(
                        key: const ValueKey<String>("getStarted"),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(widget._buttonName ?? "Get Started"),
                        onPressed: widget._onButtonPressed ?? () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : widget._showIndicator
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Visibility(
                          visible: widget._imagePaths.length > 1,
                          child: SizedBox(
                            height: 45,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                key: const ValueKey<String>("indicatorRow"),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List<Widget>.generate(
                                  widget._imagePaths.length,
                                  (final int index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width:
                                        widget._carouselType ==
                                            CarouselType.banner
                                        ? (_currentPage - 1) == index
                                              ? 20
                                              : 8
                                        : _currentPage == index
                                        ? 20
                                        : 8,
                                    height:
                                        widget._carouselType ==
                                            CarouselType.banner
                                        ? (_currentPage - 1) == index
                                              ? 20
                                              : 8
                                        : _currentPage == index
                                        ? 20
                                        : 8,
                                    decoration: BoxDecoration(
                                      color:
                                          widget._carouselType ==
                                              CarouselType.banner
                                          ? (_currentPage - 1) == index
                                                ? widget._activeIndicatorColor
                                                : widget._inActiveIndicatorColor
                                          : _currentPage == index
                                          ? widget._activeIndicatorColor
                                          : widget._inActiveIndicatorColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget._carouselType != CarouselType.banner)
                      Material(
                        child: InkWell(
                          onTap: () async {
                            _currentPage = _carouselImages.length - 1;
                            await _controller.animateToPage(
                              _currentPage,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text("${widget._skipText}"),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    ],
  );

  PageView _buildPageView() {
    if (widget._carouselType == CarouselType.banner) {
      // For banner mode, create an infinite scroll effect
      return PageView.builder(
        controller: _controller,
        itemCount: _carouselImages.length,
        onPageChanged: (final int index) {
          setState(() => _currentPage = index);
          if ((widget._carouselType == CarouselType.banner) &&
              index == _carouselImages.length - 1) {
            Future<void>.delayed(const Duration(milliseconds: 300), () {
              _controller.jumpToPage(1);
              setState(() => _currentPage = 1);
            });
          } else if ((widget._carouselType == CarouselType.banner) &&
              index == 0) {
            Future<void>.delayed(const Duration(milliseconds: 300), () {
              _controller.jumpToPage(_carouselImages.length - 2);
              setState(() => _currentPage = _carouselImages.length - 2);
            });
          }
        },
        itemBuilder: (final BuildContext context, final int index) {
          final bool isActive = index == _currentPage;
          final String imagePath = _carouselImages[index];

          return AnimatedScale(
            scale: isActive ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isActive ? 1.0 : 0.85,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: SizedBox(
                  height: widget._height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget._networkImage
                              ? Image.network(
                                  imagePath,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                  loadingBuilder:
                                      (
                                        final BuildContext context,
                                        final Widget child,
                                        final ImageChunkEvent? progress,
                                      ) {
                                        if (progress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                  errorBuilder:
                                      (
                                        final BuildContext context,
                                        final Object error,
                                        final StackTrace? stackTrace,
                                      ) => const Icon(Icons.broken_image),
                                )
                              : Image.asset(
                                  imagePath,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                  errorBuilder:
                                      (
                                        final BuildContext context,
                                        final Object error,
                                        final StackTrace? stackTrace,
                                      ) => const Icon(Icons.broken_image),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      // For non-banner mode, keep the original PageView
      return PageView.builder(
        controller: _controller,
        itemCount: widget._imagePaths.length,
        onPageChanged: (final int index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (final BuildContext context, final int index) {
          final bool isActive = index == _currentPage;
          return AnimatedScale(
            scale: isActive ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isActive ? 1.0 : 0.85,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: widget._networkImage
                                ? Image.network(
                                    widget._imagePaths[index],
                                    width: double.infinity,
                                    fit: BoxFit.fill,
                                    loadingBuilder:
                                        (
                                          final BuildContext context,
                                          final Widget child,
                                          final ImageChunkEvent? progress,
                                        ) {
                                          if (progress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                    errorBuilder:
                                        (
                                          final BuildContext context,
                                          final Object error,
                                          final StackTrace? stackTrace,
                                        ) => const Icon(Icons.broken_image),
                                  )
                                : Image.asset(
                                    widget._imagePaths[index],
                                    width: double.infinity,
                                    fit: BoxFit.fill,
                                    errorBuilder:
                                        (
                                          final BuildContext context,
                                          final Object error,
                                          final StackTrace? stackTrace,
                                        ) => const Icon(Icons.broken_image),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Visibility(
                      visible:
                          widget._welcomeTitle?[index] != null &&
                          widget._welcomeTitle![index].isNotEmpty,
                      child: Text(
                        widget._welcomeTitle?[index] ?? "",
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Visibility(
                      visible:
                          widget._welcomeDescription?[index] != null &&
                          widget._welcomeDescription![index].isNotEmpty,
                      child: Text(
                        widget._welcomeDescription?[index] ?? "",
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
