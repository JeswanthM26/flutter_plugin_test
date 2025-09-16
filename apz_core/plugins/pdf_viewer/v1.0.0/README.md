# 📚 apz_pdf_viewer

A customizable and lightweight Flutter PDF viewer built using the powerful [`pdfrx`](https://pub.dev/packages/pdfrx) package. Supports password-protected files, custom scroll thumbs, and configuration options for a seamless viewing experience.

---

## ✨ Features

- Load PDF from:
  - ✅ Network (with optional headers)
  - ✅ Asset bundle
  - ✅ Local file
- Password protection support
- Custom scroll thumb with page number overlay
- Zoom, tap, and long-press gestures
- Overlay for link navigation
- Handles incorrect/missing passwords gracefully
- Custom UI configuration using `PdfviewerModel`

---

## 🚀 Getting Started

### Add Dependency

```yaml
dependencies:
  apz_pdf_viewer:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/pdf_viewer/v1.0.0
```

Then:

```bash
flutter pub get
```

```dart
⚠️ Note for Windows Users
REQUIRED: You must enable Developer Mode to build pdfrx on Windows.

The build process uses symbolic links, which require Developer Mode to be enabled. If Developer Mode is not enabled:

❌ The build will fail with an error message

🔗 A link to Microsoft’s official instructions will be shown

🔁 You must enable Developer Mode and restart your computer before building

ℹ️ Developer Mode is required only to support symbolic links during runtime, not for general development or app behavior.
```
---

## 🧱 Constructor

```dart
ApzPdfViewer(
  source: 'https://example.com/sample.pdf',
  sourceType: ApzPdfSourceType.network,
  controller: ApzPdfViewerController(),
  config: PdfviewerModel(),
  headers: {
    'Authorization': 'Bearer your_token'
  }, // Optional
)
```

---

## 📦 Configuration Model

Use `PdfviewerModel` to control colors and text behavior:

```dart
final config = PdfviewerModel(
  enterTitleText: 'Enter PDF Password',
  okButtonText: 'OK',
  cancelButtonText: 'Cancel',
  pdfErrorText: 'Failed to load PDF.',
  emptyPasswordErrorText: 'Password cannot be empty.',
  scrollThumbColor: Colors.grey,
  pageNumberTextColor: Colors.white,
);
```

---

## 🎮 Controller

Control zoom and reset from your business logic:

```dart
final controller = ApzPdfViewerController();

// Later:
await controller.zoomUp();
await controller.resetZoom();
```

---

## 🔐 Password Dialog Behavior

If the document is password-protected:
- A dialog appears asking for the password.
- Cancelling the dialog exits the viewer gracefully.
- Empty passwords are not accepted and show a snackbar.

---

## 🧪 Sample Usage

```dart

/// This is to load file
ApzPdfViewer(
  source: "/data/user/0/com.iexceed.retailneu/cache/mlkit_docscan_ui_client/4318696388247395.pdf",
  sourceType: ApzPdfSourceType.file,
  controller: ApzPdfViewerController(),
  config: PdfviewerModel(
    enterTitleText: 'Enter PDF password',
    cancelButtonText: 'Dismiss',
    okButtonText: 'Confirm',
    scrollThumbColor: Colors.blueAccent,
    pageNumberTextColor: Colors.white,
    backgroundColor: Colors.grey[100]!,
  ),
)

/// This is to load asset pdf
ApzPdfViewer(
  source: 'assets/sample.pdf',
  sourceType: ApzPdfSourceType.asset,
  controller: ApzPdfViewerController(),
  config: PdfviewerModel(
    enterTitleText: 'Enter PDF password',
    cancelButtonText: 'Dismiss',
    okButtonText: 'Confirm',
    scrollThumbColor: Colors.blueAccent,
    pageNumberTextColor: Colors.white,
    backgroundColor: Colors.grey[100]!,
  ),
)

/// This is to load network pdf
ApzPdfViewer(
  source: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
  sourceType: ApzPdfSourceType.network,
  controller: ApzPdfViewerController(),
  config: PdfviewerModel(
    enterTitleText: 'Enter PDF password',
    cancelButtonText: 'Dismiss',
    okButtonText: 'Confirm',
    scrollThumbColor: Colors.blueAccent,
    pageNumberTextColor: Colors.white,
    backgroundColor: Colors.grey[100]!,
  ),
)
```
---

## 📊 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web *(pdfrx compatibility may vary)*

---

## 💡 Tips

- To support network requests, pass headers if needed.
- Use gestures (double tap to zoom, long press to reset) for convenience.
- Use `ScaffoldMessenger` to show inline errors/snackbars in password dialogs.

---

---

### Jira Ticket

- [pdf_viewer](https://appzillon.atlassian.net/browse/AN-125)

---
