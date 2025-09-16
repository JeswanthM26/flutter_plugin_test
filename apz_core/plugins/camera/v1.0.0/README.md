# 📸 Apz Camera Plugin

The `apz_camera` plugin is a reusable Flutter module that allows apps to capture images, crop them, compress them, and convert them to Base64.

---

## 🚀 Features

- Pick image from **Camera**
- Optional **Cropping**
- **Compression** and format selection (JPEG, PNG, etc.)
- Output as **Base64 string**
- Retrieve image file path and size
- Permission handling

---

## 🚀 Getting Started

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  apz_camera:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/camera/v1.0.0
```
---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS

---

## 🔐 For Android

Add the following permissions in your `AndroidManifest.xml`:

**Outside `<application>` tag:**
```xml
<!-- Required Permissions -->
<uses-permission android:name="android.permission.CAMERA"/>
```

## 🔐 For IOS

Add the following permissions in your `Info.plist`:
```
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera to take photos.</string>
```
### iOS (in `Podfile `)
To enable camera permission for iOS when using the apz_camera,
add the following snippet to the bottom of your ios/Podfile, inside the post_install do |installer| ... end block:

```swift
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
     target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
      '$(inherited)',
      'PERMISSION_CAMERA=1',
  ]
        end
     end
  end
```  
---

## 📱 Usage

### Step 1: Import the Plugin

```dart
import "package:apz_camera/apz_camera.dart";
```

### Step 2: Instantiate the Plugin

```dart
  final ApzCamera _apzCamera = ApzCamera();
```
### Step 3: Create an Model
```dart
final captureParams =CameraCaptureParams(
        crop: true,
        cropTitle:"Crop Image",
        fileName: Constants.imagePath,
        targetHeight: 1280,
        targetWidth: 1080,
        quality:90,
        format: ImageFormat.png,
        cameraDeviceSensor: CameraDeviceSensor.front,
        previewTitle:"Preview",
);
```
### Step 4: To open camera 

```dart
 try {
final CaptureResult? result = await _apzCamera.openCamera(
                    params: captureParams,
                    context: context,
                  );
     } on Exception catch (error) {
        print("Exception result: $error");
  }
```
### Step 5: Access Output

```dart
print("Image Path: ${result.filePath}");
print("Base64 Size Bytes: ${result.fileSizeBytes}");
print("Base64 String: ${result.base64String}");
```
---

## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---

## Jira Links
-https://appzillon.atlassian.net/browse/AN-86
