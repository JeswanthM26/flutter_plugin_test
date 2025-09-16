# apz_share

A lightweight wrapper around [`share_plus`](https://pub.dev/packages/share_plus) for sharing text and files across Android, iOS, and other platforms with optional Web fallback.

## ✨ Features

- ✅ Share plain text with optional subject
- ✅ Share a single file with optional message
- ✅ Share multiple files
- ✅ Platform-safe logic (web fallback included)
- 🧪 Designed with testability in mind

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  apz_share:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/share/v1.0.0  
```

Then run:

```bash
flutter pub get
```

## 🔧 Setup

For Android,iOSand Web no additional setup is required beyond what `share_plus` requires.

## 🧑‍💻 Usage


### Share plain text

```dart
import 'package:apz_share/apz_share.dart';

ApzShare apzShare = ApzShare();

await apzShare.shareText(
  text: "Hello from apz_share!",
  title: "Greetings",
  subject: "Greetings", // optional, can use as email subject
);

// share asset files

await apzShare.shareAssetFile(
 assetPath: "assets/pdf/sample_pdf_protected.pdf",
  title: "Hi, add your title",
  text: "Check out this file!",
  mimeType: "application/pdf"
  );
```

### Share a single file

```dart
await apzShare.shareFile(
  filePath: "/path/to/file.png",
   title: "Hi, add your title",
  text: "Check this out!",
);
```

### Share multiple files

```dart
await apzShare.shareMultipleFiles(
  filePaths: ["/path/to/file1.jpg", "/path/to/file2.jpg"],
  title: "Hi, add your title",
  text: "Multiple files here!",
);
```

``` dart

ℹ️ iOS Share Behavior Note
When using the share methods:

await apzShare.shareAssetFile(
  assetPath: "assets/pdf/sample_pdf_protected.pdf",
  title: "Hi, add your title",
  text: "Check out this file!",
  mimeType: "application/pdf",
);

await apzShare.shareFile(
  filePath: "/path/to/file.png",
  title: "Hi, add your title",
  text: "Check this out!",
);
On iOS, if you pass text and file the share sheet will display:

📄 The file

📝 plain text 1 document

And both file and text will be shared successfully.

However, if you only provide title without text, like:

The title will appear in the share sheet UI

But only the file will actually be shared (title is ignored in content)


```

## 🌐 Platform Support

| Platform | Support    |
|----------|------------|
| Android  | ✅ Full     |
| iOS      | ✅ Full     |
| Web      | ✅ Full |

---

### Jira Ticket

- [share](https://appzillon.atlassian.net/browse/AN-133)

---


