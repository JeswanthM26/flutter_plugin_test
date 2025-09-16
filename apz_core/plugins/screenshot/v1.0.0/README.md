# 📸 apz_screenshot

A lightweight and easy-to-use Flutter plugin to capture screenshots of widgets **without manually wrapping them in `RepaintBoundary`**. It can return both `Uint8List` (image bytes) and `Image` widgets directly.

---

## ✨ Features

- 📷 Capture any widget via context.
- 💾 Get result as `Uint8List` or a Flutter `Image`.
- 🧠 Auto-detects nearest `RepaintBoundary`.
- 🔄 No boilerplate — use directly anywhere in the widget tree.

---

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  apz_screenshot:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/screenshot/v1.0.0 
```

Then run:

```bash
flutter pub get
```

---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web

## 🛠️ Usage

### Capture Widget & Save Screenshot 
This captures the widget from context, saves it (downloads on web, saves to file on mobile), and returns a preview Image.

```dart
final ApzScreenshot apzScreenshot = ApzScreenshot();

final screenshot = await apzScreenshot.captureAndSave(
  text: "captured screen shot" // text to be shared along with image
  context,
  customFileName: "test", // Optional
);

if (screenshot != null) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: screenshot.image,
    ),
  );
}

```
### Jira Ticket

- [screenshot](https://appzillon.atlassian.net/browse/AN-141)
---


