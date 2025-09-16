# 📦 apz_qr

A Flutter plugin to scan and generate QR codes, powered by `flutter_zxing`. It provides an easy-to-use camera scanner widget and a QR code generator utility.

---
## ⚙️ Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  apz_qr:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/qr/v1.0.0
```

## 🛠️ How to Use

### 📸 1. Scanner View: `ApzScannerView`

Use this widget to scan QR codes and barcodes using the device camera.

#### ✅ Example

```dart
import 'package:apz_qr/view/apz_scanner_view.dart';
```

```dart
ApzQrScanner(
  callbacks: ApzQrScannerCallbacks(
    onScanSuccess: (Code? code) {
      debugPrint('Scan Success: \$code');
    },
    onScanFailure: (Code? code) {
      debugPrint('Scan Failure: \$code');
    },
    onMultiScanSuccess: (Codes codes) {
      debugPrint('Multi Scan Success: \$codes');
    },
    onMultiScanFailure: (Codes codes) {
      debugPrint('Multi Scan Failure: \$codes');
    },
  ),
  icons: const ApzQrScannerIcons(
    flashOnIcon: Icon(Icons.flash_on),
    flashOffIcon: Icon(Icons.flash_off),
    toggleCameraIcon: Icon(Icons.cameraswitch),
    galleryIcon: Icon(Icons.photo_library),
  ),
  texts: const ApzQrScannerTexts(
    permissionDeniedMessage: "Camera permission denied",
  ),
  config: const ApzQrScannerConfig(
    isMultiScan: false,
    resolution: ResolutionPreset.high,
    lensDirection: CameraLensDirection.back,
  ),
),

```

#### 📋 Constructor Parameters

| Parameter  | Type                   | Required | Default                     | Description                                                     |
|------------|------------------------|----------|-----------------------------|-----------------------------------------------------------------|
| `callbacks`| `ApzQrScannerCallbacks`| Yes      | N/A                         | Callback handlers for scan success/failure and multi-scan events|
| `icons`    | `ApzQrScannerIcons?`   | No       | `const ApzQrScannerIcons()` | Customize icons for flash, camera toggle, gallery, etc.         |
| `texts`    | `ApzQrScannerTexts?`   | No       | `const ApzQrScannerTexts()` | Custom messages and text labels used in the scanner UI          |
| `config`   | `ApzQrScannerConfig?`  | No       | `const ApzQrScannerConfig()`| Configuration options like multi-scan mode, resolution, lens direction |

---

### 📋 `ApzQrScannerCallbacks`

Callback functions to handle scan events:

| Callback             | Signature          | Description                                   |
|----------------------|--------------------|-----------------------------------------------|
| `onScanSuccess`      | `Function(Code?)`   | Called when a single scan is successful        |
| `onScanFailure`      | `Function(Code?)`   | Called when a single scan fails                 |
| `onMultiScanSuccess` | `Function(Codes)`   | Called when multi-scan is successful            |
| `onMultiScanFailure` | `Function(Codes)`   | Called when multi-scan fails                     |

---

### 📋 `ApzQrScannerIcons`

Customize the icons used in the scanner UI.

| Field             | Type       | Default       | Description                  |
|-------------------|------------|---------------|------------------------------|
| `flashOnIcon`     | `Widget?`  | Flash on icon | Icon when flash is ON         |
| `flashOffIcon`    | `Widget?`  | Flash off icon| Icon when flash is OFF        |
| `toggleCameraIcon`| `Widget?`  | Camera toggle | Icon to switch cameras        |
| `galleryIcon`     | `Widget?`  | Gallery icon  | Icon for image picker/gallery |

---

### 📋 `ApzQrScannerTexts`

Customize the text messages in the scanner UI.

| Field                   | Type      | Default                | Description                    |
|-------------------------|-----------|------------------------|--------------------------------|
| `permissionDeniedMessage`| `String?` | "Camera permission denied" | Message when camera permission is denied |

---

### 📋 `ApzQrScannerConfig`

Configure scanner options.

| Field           | Type                 | Default                   | Description                                |
|-----------------|----------------------|---------------------------|--------------------------------------------|
| `isMultiScan`   | `bool`               | `false`                   | Enable/disable multi-scan mode             |
| `resolution`    | `ResolutionPreset`   | `ResolutionPreset.high`   | Camera resolution preset                    |
| `lensDirection` | `CameraLensDirection`| `CameraLensDirection.back`| Camera lens direction (front/back)         |

---

### 🧾 2. QR Code Generator: `ApzQRGenerator`

Use this utility to generate QR code images programmatically.

#### ✅ Example

```dart
import 'package:apz_qr/generator/apz_qr_generator.dart';
```

```dart
final ApzQRGenerator _qrGenerator = ApzQRGenerator();
```

```dart
Future<void> _generateQr() async {
  try {
    final Uint8List bytes = await _qrGenerator.generateQrCode(
      text: 'https://www.google.com',
      logoBytes: pickedLogoBytes,
    );
    debugPrint(bytes.toString());
  } catch (e) {
    debugPrint('QR generation error: $e');
  }
}
```

#### 📋 Parameters

| Parameter     | Type              | Default     | Description                            |
|---------------|-------------------|-------------|----------------------------------------|
| `text`        | `String`          | `required`  | The text to encode in the QR code      |
| `height`      | `int`             | `120`       | Height of the generated image          |
| `width`       | `int`             | `120`       | Width of the generated image           |
| `margin`      | `int`             | `0`         | Margin around the QR code              |
| `eccLevel`    | `EccLevel`        | `low`       | Error correction level                 |
| `logoBytes`   | `Uint8List?`      | `null`      | Optional logo image to embed in center |

---


---

#### ⚠️ Platform Notes

- ✅ **Android**: Supported on API 21+ without reflection warnings.
- ✅ **iOS**: Fully supported.
- ⚠️ **Web**: Generation of QR is supported and scanning not supported.

---

#### 📦 Dependencies

- [flutter_zxing](https://pub.dev/packages/flutter_zxing)

#### Jira Ticket Link
- [QR/Barcode_Scanner](https://appzillon.atlassian.net/browse/AN-79)


