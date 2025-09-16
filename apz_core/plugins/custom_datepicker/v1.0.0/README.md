# apz_custom_datepicker

A lightweight Flutter plugin to show a custom Datepicker dialog across Android, iOS, and Web, supporting both single and range selection.
---

## ✨ Features


🗓️ Custom date picker dialog

✅ Cross-platform: Android, iOS, and Web support

🔧 Flexible configurations:

    - Initial, min, and max dates
 
    - Single or range calendar modes

    - Theme color and custom button styles

    - Custom date formatting (dd/MM/yyyy, yyyy-MM-dd, etc.)

    - Localization support (based on current locale)


## 🚀 Getting Started


###  Add Dependency

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  apz_custom_datepicker:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/custom_datepicker/v1.0.0
```

---

## 🛠 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web

---

## 📱 Usage

### Step 1: Import the Plugin

```dart
import "package:apz_custom_datepicker/apz_custom_datepicker.dart";
```

### Step 2: Instantiate the Plugin

```dart
final ApzCustomDatepicker customDatePicker = ApzCustomDatepicker();
```

### Step 3: To open custom datepicker

```dart

final CustomDatePickerParams params = CustomDatePickerParams(
            context: context,                            // Required: BuildContext
            minDate: DateTime(2020),                     // Required: Minimum selectable date
            maxDate: DateTime(2030),                     // Required: Maximum selectable date
            initialDate: DateTime(2025, 1, 1),           // Required: Initially selected date
            dialogSize: const Size(325, 400),            // Optional: Dialog size

            selectionType: SelectionType.single,     // Optional: single / range
            themeColor: Colors.blue,                     // Optional: Highlight color

            dateFormat: "dd/MM/yyyy",                    // Optional: Output format for selected date

            cancelButtonText: "Cancel",                  // Optional: Cancel button label
            okButtonText: "Done",                        // Optional: OK button label

            cancelButtonTextStyle: TextStyle(...),       // Optional: Style for cancel text
            okButtonTextStyle: TextStyle(...),           // Optional: Style for done text

            weekdayLabelTextStyle: TextStyle(...),       // Optional: Style for weekday labels
            controlsTextStyle: TextStyle(...),           // Optional: Style for header/month controls
);

try {
      final result = await customDatePicker.showCustomDate(params);
    } on Exception catch (error) {
        print("Exception result: $error");
    }

```

---

## 📬 Contributions

PRs and suggestions are welcome! Please open an issue or create a pull request.

---

## Jira Links
-https://appzillon.atlassian.net/browse/AN-97

