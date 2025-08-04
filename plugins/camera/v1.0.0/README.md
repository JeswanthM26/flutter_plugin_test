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

**Inside `<application>` tag:**
```xml
<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
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
import 'package:apz_camera/apz_camera.dart';
```

### Step 2: Instantiate the Plugin

```dart
  final ApzCamera _apzCamera = ApzCamera();
```
### Step 3: Create an ImageModel
```dart
final imageModel = ImageModel(
  crop: true,
  quality: 80,
  fileName: 'my_image',
  format: ImageFormat.jpeg,
  targetWidth: 1080,
  targetHeight: 1080,
  cameraDeviceSensor: CameraDeviceSensor.rear,
  cropTitle: 'Crop Image',
);
```
### Step 4: To open camera 

```dart
 try {
final CameraResult result = await _apzCamera.pickFromCamera(
                  cancelCallback: () => "",
                  imagemodel: imageModel,
                );
     } on Exception catch (error) {
        print("Exception result: $error");
  }
```
### Step 5: Access Output

```dart
print("Image Path: ${result.imageFile.path}");
print("Base64 Size (KB): ${result.base64ImageSizeInKB}");
print("Base64 String: ${result.base64String}");
```
---

## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---

