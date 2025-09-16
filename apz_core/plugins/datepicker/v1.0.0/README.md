#  Apz Datepicker Plugin

A lightweight Flutter plugin to fetch native Datepicker using native code integration for Android and iOS. 

---

## ✨ Features

- 🚀 Native date picker dialog
- 📆 Support for setting:
  - Initial date
  - Minimum and maximum selectable dates
  - Custom date format

## 🚀 Getting Started


###  Add Dependency

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  apz_datepicker:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/datepicker/v1.0.0
```

---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS

---

## 🔐 For Android

optional parameter 
```dart
    cancelText: "Back",
    doneText: "Done",
    primaryColor: theme.colorScheme.primary.toARGB32(),
    cancelColor: theme.colorScheme.secondary.toARGB32(),
    languageCode: APZLocalization().locale.languageCode,
```


## 🔐 For IOS

optional parameter 
```dart
    title: "Select Date",
    cancelText: "Back",
    doneText: "Done",
    primaryColor: theme.colorScheme.primary.toARGB32(),
    cancelColor: theme.colorScheme.secondary.toARGB32(),
    languageCode: APZLocalization().locale.languageCode,
```
## 📱 Usage

### Step 1: Import the Plugin

```dart
import 'package:apz_datepicker/apz_datepicker.dart';
```

### Step 2: Instantiate the Plugin

```dart
final ApzDatepicker datePicker = ApzDatepicker();
```

### Step 3: To open datepicker

```dart
final DatePickerParams params = DatePickerParams(
      initialDate: defaultInitialDate,
      minDate: DateTime(2020),
      maxDate: DateTime(2030),
      dateFormat: format,
    );
try {
      final String? pickedDate = await datePicker.showDatePicker(
        params: params,
      );
    } on Exception catch (error) {
        print("Exception result: $error");
    }
```

---

## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---

## Jira Links
-https://appzillon.atlassian.net/browse/AN-112