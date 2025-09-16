import "dart:async";
import "dart:typed_data";
import "dart:ui";

import "package:apz_camera/models/camera_capture_params.dart";
import "package:apz_camera/models/capture_result.dart";
import "package:apz_camera/ui/crop_image_widget.dart";
import "package:apz_camera/ui/image_preview_widget.dart";
import "package:apz_camera/utils/image_processor.dart";
import "package:camera/camera.dart";
import "package:flutter/material.dart";

///camara preview widget
class CameraPreviewWidget extends StatefulWidget {
  ///constructor
  const CameraPreviewWidget({
    required final CameraCaptureParams params,
    super.key,
  }) : _params = params;

  final CameraCaptureParams _params;

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

/// State for CameraPreviewWidget
class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCapturing = false;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  FlashMode _currentFlashMode = FlashMode.off;

  double _bgWidgetWidth = 0;
  double _bgWidgetHeight = 0;

  // Zoom state
  final double _minZoom = 1;
  final double _maxZoom = 5;
  double _currentZoom = 1;
  double _baseZoomDuringGesture = 1;
  Timer? _zoomThrottleTimer;
  static const double _zoomEps = 0.01; // 1% step to reduce spam
  static const int _zoomThrottleMs = 16; // ~60 FPS; use 33 for ~30 FPS
  @override
  void initState() {
    super.initState();
    unawaited(_initCamera());
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();

    // Pick lens by params, fallback to first camera.
    int fallbackIndex = 0;
    for (int i = 0; i < (_cameras?.length ?? 0); i++) {
      if (_cameras?[i].lensDirection == widget._params.lensDirection) {
        _selectedCameraIndex = i;
        break;
      }
      fallbackIndex = i;
    }
    _selectedCameraIndex = _selectedCameraIndex.clamp(0, fallbackIndex);

    _controller = CameraController(
      _cameras?[_selectedCameraIndex] ?? (throw Exception("No camera found")),
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _initializeControllerFuture = _controller?.initialize();
    await _initializeControllerFuture;

    // Fetch zoom limits and set initial zoom
    await _controller?.setZoomLevel(_currentZoom);

    // Set initial flash mode after init
    await _controller?.setFlashMode(_currentFlashMode);

    _bgWidgetWidth = _controller?.value.previewSize?.height ?? 0;
    _bgWidgetHeight = _controller?.value.previewSize?.width ?? 0;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || (_cameras?.length ?? 0) <= 1) {
      return;
    }

    _selectedCameraIndex = (_selectedCameraIndex + 1) % (_cameras?.length ?? 0);

    await _controller?.dispose();

    _controller = CameraController(
      _cameras?[_selectedCameraIndex] ?? (throw Exception("No camera found")),
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initializeControllerFuture = _controller?.initialize();
    await _initializeControllerFuture;
    // Reset flash mode after camera switch
    _currentFlashMode = FlashMode.off;
    await _controller?.setFlashMode(_currentFlashMode);

    // Refresh zoom bounds
    await _controller?.setZoomLevel(_currentZoom);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) {
      return;
    }

    FlashMode newFlashMode;
    switch (_currentFlashMode) {
      case FlashMode.off:
        newFlashMode = FlashMode.auto;
      case FlashMode.auto:
        newFlashMode = FlashMode.always;
      case FlashMode.always:
      case FlashMode.torch:
        newFlashMode = FlashMode.off;
    }

    await _controller?.setFlashMode(newFlashMode);
    if (mounted) {
      setState(() {
        _currentFlashMode = newFlashMode;
      });
    }
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
    }
  }

  String _getFlashModeText() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return "OFF";
      case FlashMode.auto:
        return "AUTO";
      case FlashMode.always:
        return "ON";
      case FlashMode.torch:
        return "TORCH";
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      await _initializeControllerFuture;

      final XFile? image = await _controller?.takePicture();
      final Uint8List? imageBytes = await image?.readAsBytes();

      // Preview first
      bool shouldProceed = false;
      if (mounted) {
        shouldProceed =
            await Navigator.of(context).push<bool>(
              MaterialPageRoute<bool>(
                builder: (final BuildContext context) => ImagePreviewWidget(
                  imageBytes: imageBytes ?? Uint8List(0),
                  title: widget._params.previewTitle,
                ),
              ),
            ) ??
            false;
      }

      if (shouldProceed && mounted) {
        if (widget._params.crop) {
          // Navigate to crop screen
          final CaptureResult? result = await Navigator.of(context)
              .push<CaptureResult>(
                MaterialPageRoute<CaptureResult>(
                  builder: (final BuildContext context) => CropImageWidget(
                    imageBytes: imageBytes ?? Uint8List(0),
                    params: widget._params,
                  ),
                ),
              );

          if (result != null && mounted) {
            Navigator.of(context).pop(result);
          }
        } else {
          // Process image directly without cropping
          final ImageProcessor imageProcessor = ImageProcessor();
          final CaptureResult result = await imageProcessor.processImage(
            imageBytes: imageBytes ?? Uint8List(0),
            params: widget._params,
          );

          if (mounted) {
            Navigator.of(context).pop(result);
          }
        }
      }
    } catch (e) {
      throw Exception("Failed to capture image: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _applyZoom(final double level) async {
    if (_controller == null || !(_controller?.value.isInitialized ?? false)) {
      return;
    }
    // clamp and avoid redundant set
    final double clamped = level.clamp(_minZoom, _maxZoom);
    if ((clamped - _currentZoom).abs() < _zoomEps) {
      return;
    }
    _currentZoom = clamped;
    await _controller?.setZoomLevel(_currentZoom);
    if (mounted) {
      setState(() {});
    }
  }

  void _scheduleZoomUpdate(final double level) {
    if (_zoomThrottleTimer?.isActive ?? false) {
      return;
    }
    _zoomThrottleTimer = Timer(
      const Duration(milliseconds: _zoomThrottleMs),
      () {
        unawaited(_applyZoom(level));
      },
    );
  }

  // Pinch-to-zoom handlers
  void _onScaleStart(final ScaleStartDetails details) {
    _baseZoomDuringGesture = _currentZoom;
  }

  Future<void> _onScaleUpdate(final ScaleUpdateDetails details) async {
    if (_controller == null || !(_controller?.value.isInitialized ?? false)) {
      return;
    }
    final double desired = _baseZoomDuringGesture * details.scale;
    final double clamped = desired.clamp(_minZoom, _maxZoom);
    // throttle instead of awaiting setZoomLevel on every event
    _scheduleZoomUpdate(clamped);
  }

  Widget _cameraPreviewScaled(final BuildContext context) {
    if (_controller == null || !(_controller?.value.isInitialized ?? false)) {
      return const SizedBox.shrink();
    }
    final double cameraRatio = 1 / (_controller?.value.aspectRatio ?? 1.0);
    return ClipRect(
      child: Transform.scale(
        scale: 1,
        child: Center(
          child: AspectRatio(
            aspectRatio: cameraRatio,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _zoomThrottleTimer?.cancel();
    _initializeControllerFuture = null;
    // dispose should be sync
    // ignore: discarded_futures
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    const Color bgColor = Color.fromARGB(255, 207, 202, 202);
    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder:
            (final BuildContext context, final AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controller != null &&
                  (_controller?.value.isInitialized ?? false)) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      width: _bgWidgetWidth,
                      height: _bgWidgetHeight,
                      alignment: Alignment.center, // centers the icon
                      child: Icon(
                        Icons.switch_camera_outlined,
                        size: _bgWidgetWidth * 0.4,
                        color: Colors.black,
                      ),
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(),
                      child: Container(
                        width: _bgWidgetWidth,
                        height: _bgWidgetHeight,
                        color: bgColor.withValues(
                          alpha: 0.8,
                        ), // transparent overlay
                      ),
                    ),

                    // GestureDetector retains only pinch to zoom
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      child: _cameraPreviewScaled(context),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                        child: IconButton(
                          key: const Key("closeButton"),
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop(CaptureResult(isCanceled: true));
                          },
                        ),
                      ),
                    ),
                    // Flash button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      right: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                        child: IconButton(
                          key: const Key("flashButton"),
                          icon: Icon(
                            _getFlashIcon(),
                            color: _currentFlashMode != FlashMode.off
                                ? Colors.yellow
                                : Colors.white,
                          ),
                          onPressed: _toggleFlash,
                          tooltip: "Flash: ${_getFlashModeText()}",
                        ),
                      ),
                    ),

                    // Bottom controls
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 40,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              if (_cameras != null &&
                                  (_cameras?.length ?? 0) > 1)
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                  child: IconButton(
                                    key: const Key("switchCameraButton"),
                                    iconSize: 32,
                                    icon: const Icon(
                                      Icons.switch_camera,
                                      color: Colors.white,
                                    ),
                                    onPressed: _switchCamera,
                                  ),
                                )
                              else
                                const SizedBox(width: 48),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: _isCapturing
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                        ),
                                      )
                                    : IconButton(
                                        key: const Key("captureButton"),
                                        iconSize: 40,
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.black,
                                        ),
                                        onPressed: _isCapturing
                                            ? null
                                            : _captureImage,
                                      ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
      ),
    );
  }
}
