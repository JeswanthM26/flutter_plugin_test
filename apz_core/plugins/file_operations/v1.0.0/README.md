# apz_file_operations

A cross-platform file picker plugin for Flutter that supports picking common file types like **PDF**, **DOCX**, **TXT**, **XLSX**, **CSV**, etc.. on both web and mobile.

---

## ✨ Features

- ✅ Pick files on **Android**, **iOS**, and **Web**
- ✅ Default extensions: `.pdf`, `.docx`, `.txt`, `.xlsx`, `.csv` and user can add more extensions
- ✅ Access file metadata: name, path, MIME type, size, and base64String
- ✅ Designed with clean architecture and testability in mind

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  apz_file_operations: 
     git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/file_operations/v1.0.0

```

Then run:

```bash
flutter pub get
```

---

## 🚀 Usage

### Import the package

```dart
import 'package:apz_file_operations/apz_file_operations.dart';
```

### Pick a file

```dart
final ApzFileOperations _apzFileOperations = ApzFileOperations();
```

```dart
final List<FileData>? files = await _apzFileOperations.pickFile(allowMultiple: false);

setState(() {
  _filePath = files;
});
```

---


---

## 💡 Notes

- On **Web**, paths are not accessible due to browser limitations — `path` will be the file name.
- On **Android/iOS**, storage permission is required — make sure to handle it in your app.
- The plugin supports both **single** and **multiple** file selections.

--- Functions parameters:

| parameters                  | value          | 
|-----------------------------|-----------------
| `allowMultiple`             | `bool`         | 
| `additionalExtensions`      | `List<String>` |
| `maxFileSizeInMB`           | `int`          |
| `allowedFileNameRegex`      | `Regex`        |

---



## 🧪 Example Code

```dart
ElevatedButton(
  onPressed: () async {
    final List<FileData>? files = await _apzFileOperations.pickFile(allowMultiple: false);
    if (files != null && files.isNotEmpty) {
      final file = files.first;
      print("Name: ${file.name}");
      print("Size: ${file.size} bytes");
      print("MIME type: ${file.mimeType}");
      print("base64String: ${file.base64String}");
    }
  },
  child: Text("Pick File"),
)
```

---

## 🔒 Permissions 
### Android

Ensure the following permission is added in `android -> AndroidManifest.xml`:

```xml
Note: Starting from Android 13 (API 33) No permission required.
Below Android 13 (API < 33) below permission required.
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

```



---

## 📄 dependencies
```yaml
file_picker
```

### Jira Ticket Link

 -[Apz_file_operations](https://appzillon.atlassian.net/browse/AN-99)