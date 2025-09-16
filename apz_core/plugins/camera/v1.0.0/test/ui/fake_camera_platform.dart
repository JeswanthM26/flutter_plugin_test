import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import "package:flutter/services.dart";
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:cross_file/cross_file.dart';

class FakeCameraPlatform extends CameraPlatform
    with MockPlatformInterfaceMixin {
  FakeCameraPlatform();

  int _nextId = 1;
  final Map<int, CameraDescription> _cams = {};
  final Map<int, FlashMode> _flash = {};
  // Per-camera zoom state
  final Map<int, double> _minZoomById = {};
  final Map<int, double> _maxZoomById = {};
  final Map<int, double> _zoomById = {};

  // Device orientation stream (required by CameraController.initialize)
  final StreamController<DeviceOrientationChangedEvent> _deviceCtrl =
      StreamController<DeviceOrientationChangedEvent>.broadcast();

  // Camera-initialized streams per cameraId (required by initialize)
  final Map<int, StreamController<CameraInitializedEvent>> _initCtrls = {};

  // Minimal 1x1 PNG bytes written to a temp file for takePicture
  static final Uint8List _onePxPng = Uint8List.fromList(const [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x60,
    0x00,
    0x00,
    0x00,
    0x02,
    0x00,
    0x01,
    0xE2,
    0x21,
    0xBC,
    0x33,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  StreamController<CameraInitializedEvent> _initCtrl(int id) =>
      _initCtrls.putIfAbsent(
        id,
        () => StreamController<CameraInitializedEvent>.broadcast(),
      );

  @override
  Future<List<CameraDescription>> availableCameras() async =>
      <CameraDescription>[
        const CameraDescription(
          name: 'backCamera',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
        const CameraDescription(
          name: 'frontCamera',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 90,
        ),
      ];

  @override
  Future<int> createCamera(
    CameraDescription description,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    final id = _nextId++;
    _cams[id] = description;
    _flash[id] = FlashMode.off;
    // Seed zoom range and current zoom
    _minZoomById[id] = 1.0;
    _maxZoomById[id] = 4.0; // ensure > min so Slider appears
    _zoomById[id] = 1.0;
    return id;
  }

  // Newer CameraController paths use this overload
  @override
  Future<int> createCameraWithSettings(
    CameraDescription description,
    MediaSettings settings,
  ) async {
    final id = _nextId++;
    _cams[id] = description;
    _flash[id] = FlashMode.off;
    _minZoomById[id] = 1.0;
    _maxZoomById[id] = 4.0;
    _zoomById[id] = 1.0;
    return id;
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    // Emit a single initialized event with sane defaults so the controller can read preview size.
    scheduleMicrotask(() {
      _initCtrl(cameraId).add(
        CameraInitializedEvent(
          cameraId,
          1920, // previewWidth
          1080, // previewHeight
          ExposureMode.auto,
          true, // exposurePointSupported
          FocusMode.auto,
          true, // focusPointSupported
        ),
      );
    });
    // Also seed a default device orientation so controller has a value.
    scheduleMicrotask(() {
      _deviceCtrl.add(
        const DeviceOrientationChangedEvent(DeviceOrientation.portraitUp),
      );
    });
  }

  @override
  Widget buildPreview(int cameraId) =>
      const ColoredBox(color: Color(0xFF000000));
  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    return _minZoomById[cameraId] ?? 1.0;
  } // CameraPlatform defines this; default throws if not overridden. [15]

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    return _maxZoomById[cameraId] ?? 1.0;
  } // If equal to min, your widget hides the slider by design. [15]

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    final minZ = await getMinZoomLevel(cameraId);
    final maxZ = await getMaxZoomLevel(cameraId);
    final clamped = zoom.clamp(minZ, maxZ);
    _zoomById[cameraId] = clamped;
  } // Contro

  @override
  Future<void> dispose(int cameraId) async {
    _cams.remove(cameraId);
    _flash.remove(cameraId);
    _minZoomById.remove(cameraId);
    _maxZoomById.remove(cameraId);
    _zoomById.remove(cameraId);
    await _initCtrls.remove(cameraId)?.close();
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    _flash[cameraId] = mode;
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final dir = await Directory.systemTemp.createTemp('cam_test_');
    final file = File('${dir.path}/pic.png');
    await file.writeAsBytes(_onePxPng);
    return XFile(file.path);
  }

  // Required streams for CameraController.initialize
  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      _deviceCtrl.stream;

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      _initCtrl(cameraId).stream;

  // Optional no-op overrides can be added if your version requires more.
}
