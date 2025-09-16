import "dart:typed_data";
import "package:apz_camera/models/camera_capture_params.dart";
import "package:apz_camera/models/capture_result.dart";
import "package:apz_camera/utils/image_processor.dart";
import "package:crop_your_image/crop_your_image.dart";
import "package:flutter/material.dart";

/// A widget that allows users to crop the captured image.
class CropImageWidget extends StatefulWidget {
  /// Constructor
  const CropImageWidget({
    required final Uint8List imageBytes,
    required final CameraCaptureParams params,
    super.key,
  }) : _imageBytes = imageBytes,
       _params = params;
  final Uint8List _imageBytes;
  final CameraCaptureParams _params;

  @override
  State<CropImageWidget> createState() => CropImageWidgetState();
}

/// The state for [CropImageWidget].
class CropImageWidgetState extends State<CropImageWidget> {
  final CropController _cropController = CropController();
  bool _isCropping = false;

  void _cropImage() {
    setState(() {
      _isCropping = true;
    });
    _cropController.crop();
  }

  Future<void> _onCropped(final CropResult cropResult) async {
    try {
      if (cropResult is CropSuccess) {
        final ImageProcessor imageProcessor = ImageProcessor();
        final CaptureResult result = await imageProcessor.processImage(
          imageBytes: widget._imageBytes,
          params: widget._params,
          croppedImageBytes: cropResult.croppedImage,
        );

        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } else if (cropResult is CropFailure) {
        setState(() {
          _isCropping = false;
        });
        throw Exception("Cropping failed: ${cropResult.cause}");
      }
    } catch (e) {
      setState(() {
        _isCropping = false;
      });
      throw Exception("Failed to process image: $e");
    }
  }

  Future<void> _cancelCrop() async {
    try {
      setState(() {
        _isCropping = true;
      });
      final ImageProcessor imageProcessor = ImageProcessor();
      final CaptureResult result = await imageProcessor.processImage(
        imageBytes: widget._imageBytes,
        params: widget._params,
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      setState(() {
        _isCropping = false;
      });
      throw Exception("Failed to process image: $e");
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
    backgroundColor: const Color.fromARGB(255, 48, 47, 47),
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text(
        widget._params.cropTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      leading: IconButton(
        key: const Key("cancelCropButton"),
        iconSize: 32,
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: _cancelCrop,
      ),
      actions: <Widget>[
        IconButton(
          key: const Key("cropButton"),
          iconSize: 32,
          icon: const Icon(Icons.crop, color: Colors.white),
          onPressed: _cropImage,
        ),
      ],
    ),
    body: _isCropping
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Processing image...",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        : Column(
            children: <Widget>[
              Expanded(
                child: Crop(
                  image: widget._imageBytes,
                  controller: _cropController,
                  onCropped: _onCropped,
                  aspectRatio:
                      widget._params.targetWidth != null &&
                          widget._params.targetHeight != null
                      ? (widget._params.targetWidth ?? 1) /
                            (widget._params.targetHeight ?? 1)
                      : null,
                  baseColor: Colors.black,
                  maskColor: Colors.black.withValues(alpha: 0.7),
                  cornerDotBuilder:
                      (final double size, final EdgeAlignment edgeAlignment) =>
                          const DotControl(color: Colors.blue),
                ),
              ),
            ],
          ),
  );
}
