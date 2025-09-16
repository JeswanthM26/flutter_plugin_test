import "dart:math";

import "package:apz_photopicker/apz_photopicker.dart";
import "package:apz_photopicker/enum.dart";
import "package:apz_photopicker/photopicker_image_model.dart";
import "package:apz_photopicker/photopicker_result.dart";
import "package:apz_qr/models/apz_qr_scanner_callbacks.dart";
import "package:apz_qr/models/apz_qr_scanner_config.dart";
import "package:apz_qr/models/apz_qr_scanner_icons.dart";
import "package:apz_qr/models/apz_qr_scanner_texts.dart";
import "package:apz_qr/models/code.dart";
import "package:apz_qr/view/animated_scanner_line.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_zxing/flutter_zxing.dart" as zxing;
import "package:permission_handler/permission_handler.dart";

export "/models/code.dart";
export "/models/decode_params.dart";
export "/models/format.dart";
export "/models/position.dart";
export "apz_qr_scanner.dart";
export "models/apz_qr_scanner_callbacks.dart";
export "models/apz_qr_scanner_config.dart";
export "models/apz_qr_scanner_icons.dart";
export "models/apz_qr_scanner_texts.dart";

///ApzQrScanner is a widget that provides a camera view for scanning barcodes.
class ApzQrScanner extends StatefulWidget {
  /// ApzQrScanner constructor
  const ApzQrScanner({
    required final ApzQrScannerCallbacks callbacks,
    final ApzQrScannerIcons? icons,
    final ApzQrScannerTexts? texts,
    final ApzQrScannerConfig? config,
    super.key,
  }) : _callbacks = callbacks,
       _icons = icons ?? const ApzQrScannerIcons(),
       _texts = texts ?? const ApzQrScannerTexts(),
       _config = config ?? const ApzQrScannerConfig();

  ///ApzQrScanner constructor accept various
  ///parameters to customize the scanner view.
  final ApzQrScannerCallbacks _callbacks;
  final ApzQrScannerIcons _icons;
  final ApzQrScannerTexts _texts;
  final ApzQrScannerConfig _config;

  @override
  State<ApzQrScanner> createState() => ApzScannerViewState();
}

///ApzScannerVewState
class ApzScannerViewState extends State<ApzQrScanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final APZLoggerProvider _logger = APZLoggerProvider();
  bool _hasPermission = false;
  PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndRequestPermissions();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    final PermissionStatus cameraStatus = await _permissionService
        .requestCameraPermission();
    setState(() {
      _hasPermission = cameraStatus.isGranted;
    });
    if (!_hasPermission) {
      if (!mounted) {
        return;
      }
      widget._callbacks.onError?.call(
        PermissionException(
          PermissionsExceptionStatus.denied,
          widget._texts.cameraPermissionText,
        ),
      );
    }
  }

  final PhotopickerImageModel _imageModel = PhotopickerImageModel(
    crop: false,
    quality: 80,
    fileName: "my_image",
    format: PhotopickerImageFormat.jpeg,
    targetWidth: 1080,
    cropTitle: "Crop Image",
  );

  /// method from scan image from gallery
  Future<void> handleGalleryIconPressed() async {
    try {
      final zxing.Zxing zx = zxing.Zxing();
      final ApzPhotopicker apzCamera = ApzPhotopicker();
      final PhotopickerResult? file = await apzCamera.pickFromGallery(
        cancelCallback: () =>
            widget._callbacks.onError?.call(Exception("cancelled")),
        imagemodel: _imageModel,
      );
      if (file == null) {
        return;
      }
      final zxing.DecodeParams params = zxing.DecodeParams(
        imageFormat: zxing.ImageFormat.rgb,
        tryHarder: true,
        tryInverted: true,
        isMultiScan: widget._config.isMultiScan,
      );
      final zxing.Code result = await zx.readBarcodeImagePathString(
        file.imageFile?.path ?? "",
        params,
      );
      if (result.isValid) {
        widget._callbacks.onScanSuccess?.call(_mapZxingCode(result));
      } else {
        widget._callbacks.onScanFailure?.call(_mapZxingCode(result));
      }
    } on UnsupportedPlatformException catch (error) {
      widget._callbacks.onError?.call(error);
    } on PermissionException catch (error) {
      widget._callbacks.onError?.call(error);
    } on Exception catch (error) {
      widget._callbacks.onError?.call(error);
    }
  }

  @override
  Widget build(final BuildContext context) {
    try {
      final bool isCameraSupported =
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
      if (!_hasPermission) {
        return Center(child: Text(widget._texts.waitingText));
      }
      if (kIsWeb || !isCameraSupported) {
        throw UnsupportedPlatformException(
          "QR Scanner is not supported on Web",
        );
      }
      final Size size = MediaQuery.of(context).size;
      final double cropSize =
          min(size.width, size.height) * widget._config.cropPercent;
      return Stack(
        children: <Widget>[
          zxing.ReaderWidget(
            isMultiScan: widget._config.isMultiScan,
            onScan: (final zxing.Code? result) {
              try {
                if (!mounted) {
                  return;
                }
                if (result == null ||
                    !result.isValid ||
                    result.text == null ||
                    result.text!.isEmpty) {
                  final Code? code = _mapZxingCode(result);
                  widget._callbacks.onScanFailure?.call(code);
                  return;
                }

                widget._callbacks.onScanSuccess?.call(_mapZxingCode(result));
              } on Exception catch (e) {
                _logger.debug("Error during scan: $e");
                widget._callbacks.onScanFailure?.call(null);
              }
            },
            onScanFailure: (final zxing.Code? result) {
              widget._callbacks.onScanFailure?.call(_mapZxingCode(result));
            },
            onMultiScan: (final zxing.Codes result) {
              widget._callbacks.onMultiScanSuccess?.call(
                _mapZxingCodes(result),
              );
            },
            onMultiScanFailure: (final zxing.Codes result) {
              widget._callbacks.onMultiScanFailure?.call(
                _mapZxingCodes(result),
              );
            },
            onMultiScanModeChanged:
                widget._callbacks.onMultiScanModeChanged == null
                ? null
                : (final bool enabled) =>
                      widget._callbacks.onMultiScanModeChanged!(
                        isEnabled: enabled,
                      ),
            verticalCropOffset: widget._config.verticalCropOffset,
            horizontalCropOffset: widget._config.horizontalCropOffset,
            tryInverted: true,
            tryDownscale: true,
            maxNumberOfSymbols: 5,
            scanDelay: Duration(
              milliseconds: widget._config.isMultiScan ? 50 : 500,
            ),
            resolution: widget._config.resolution,
            lensDirection: widget._config.lensDirection,
            flashOnIcon: widget._icons.flashOnIcon,
            flashOffIcon: widget._icons.flashOffIcon,
            flashAlwaysIcon: widget._icons.flashAlwaysIcon,
            flashAutoIcon: widget._icons.flashAutoIcon,
            galleryIcon: const SizedBox.shrink(),
            cropPercent: widget._config.cropPercent,
            toggleCameraIcon: widget._icons.toggleCameraIcon,
            onControllerCreated: (_, final Exception? error) {
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $error"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          AnimatedScannerLine(
            cropSize: cropSize,
            isMultiScan: widget._config.isMultiScan,
            lineColor: widget._config.scannerLineColor,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: widget._icons.galleryIcon,
                      color: Colors.white,
                      onPressed: handleGalleryIconPressed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } on UnsupportedPlatformException catch (e) {
      // Catch the specific exception and show error UI
      widget._callbacks.onError?.call(e);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(e.message, textAlign: TextAlign.center),
        ),
      );
    } on Exception catch (e) {
      // Optionally, catch other exceptions
      widget._callbacks.onError?.call(e);
      return Center(child: Text("Unexpected error: $e"));
    }
  }

  Code? _mapZxingCode(final zxing.Code? input) {
    if (input == null) {
      return null;
    }

    return Code(
      text: input.text,
      isValid: input.isValid,
      error: input.error,
      rawBytes: input.rawBytes,
      format: input.format,
      isInverted: input.isInverted,
      isMirrored: input.isMirrored,
      duration: input.duration,
      imageBytes: input.imageBytes,
      imageWidth: input.imageWidth,
      imageHeight: input.imageHeight,
    );
  }

  Codes _mapZxingCodes(final zxing.Codes input) => Codes(
    codes: input.codes.map((final zxing.Code z) => _mapZxingCode(z)!).toList(),
    duration: input.duration,
  );

  /// testing purpose checking permission
  @visibleForTesting
  void testHasPermission({required final bool hasPermission}) {
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  @visibleForTesting
  /// Testing Purpose
  bool get hasPermission => _hasPermission;

  /// This is for testing handleScanSuccess method
  @visibleForTesting
  void handleScanSuccess(final zxing.Code? result) {
    widget._callbacks.onScanSuccess?.call(_mapZxingCode(result));
  }

  /// This is for testing handleScanFailure method
  @visibleForTesting
  void handleScanFailure(final zxing.Code? result) {
    widget._callbacks.onScanFailure?.call(_mapZxingCode(result));
  }

  /// This is for testing handleMultiScanSuccess method
  @visibleForTesting
  void handleMultiScanSuccess(final zxing.Codes result) {
    widget._callbacks.onMultiScanSuccess?.call(_mapZxingCodes(result));
  }

  /// This is for testing handleMultiScanFailure method
  @visibleForTesting
  void handleMultiScanFailure(final zxing.Codes result) {
    widget._callbacks.onMultiScanFailure?.call(_mapZxingCodes(result));
  }

  /// This is for testing handleMultiScanModeChanged method
  @visibleForTesting
  void handleMultiScanModeChanged({required final bool enabled}) {
    widget._callbacks.onMultiScanModeChanged?.call(isEnabled: enabled);
  }

  /// Expose a method for testing permission checks
  @visibleForTesting
  Future<void> checkAndRequestPermissions() async {
    await _checkAndRequestPermissions();
  }

  /// For Testing purpose (GETTER)
  @visibleForTesting
  PermissionService get permissionService => _permissionService;
  // Add this getter

  /// For Testing purpose (SETTER)
  @visibleForTesting
  set permissionService(final PermissionService service) {
    _permissionService = service;
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>("hasPermission", hasPermission))
      ..add(
        DiagnosticsProperty<PermissionService>(
          "permissionService",
          permissionService,
        ),
      );
  }
}

/// This class is responsible for managing permissions.
class PermissionService {
  /// Request contacts permission.
  Future<PermissionStatus> requestCameraPermission() =>
      Permission.camera.request();
}
