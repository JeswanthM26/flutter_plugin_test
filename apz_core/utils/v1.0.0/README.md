# APZ Utils

A comprehensive utility package for Appzillon-Neu Flutter projects.

## Features

- **Logger**: A powerful logging utility with file logging support and persistence
- **Validator**: A comprehensive string validation utility
- **Launchers**: A utility class for launching various platform-specific features like phone calls, SMS, and URLs in Flutter applications.
- **ApzAppWipeOut**: A Flutter plugin to wipe out all local app data across platforms — Android, iOS and Web. Useful for features like logout/reset, clearing app cache.

## Features Coming Soon

- **Crypto**: A comprehensive encryption and decryption utility
- **Formatter**: A comprehensive string and number formatting/masking utility
- **Network**: A comprehensive network check utility

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  apz_utils:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/utils/v1.0.0
```

## Usage

### Logger

The logger utility provides a simple interface for logging with different levels, file logging support, and persistence of settings.

#### Setup

1. Initialize the logger in your app's initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the logger
  final logger = APZLoggerProvider();
  await logger.initialize(); // IMPORTANT: Must await initialization

  // After initialization, you can set the log level
  // By default initial log level will be info
  logger.setLogLevel(APZLogLevel.debug);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: logger),
      ],
      child: MyApp(),
    ),
  );
}
```

⚠️ **Important Notes**:

- Always `await logger.initialize()` before using any logger methods
- The logger uses a singleton pattern, so you'll get the same instance throughout your app
- You can check if the logger is initialized using `logger.isInitialized`
- Attempting to use logger methods before initialization will throw a `StateError`

#### Basic Usage

```dart
final logger = APZLoggerProvider();

// Ensure logger is initialized before use
if (logger.isInitialized) {
  // Log messages with different levels
  logger.debug('Debug message');
  logger.info('Info message');
  logger.error('Error message', error, stackTrace);
} else {
  print('Logger not initialized yet!');
}
```

#### Configuration

```dart
final logger = APZLoggerProvider();

// Get all available log levels as enum
List<APZLogLevel> levels = logger.logLevel;  // Returns [verbose, debug, info, warning, error, wtf, nothing]

// Set log level using enum
logger.setLogLevel(APZLogLevel.debug);

// Get current log level as enum
APZLogLevel currentLevel = logger.getLogLevel();

// Available Log Levels (as enum)
APZLogLevel.debug      // Debugging information
APZLogLevel.info       // General information
APZLogLevel.error      // Errors that need immediate attention

// Example: Using with DropdownButton
DropdownButton<APZLogLevel>(
  value: logger.getLogLevel(),
  items: logger.logLevel.map((level) => DropdownMenuItem(
    value: level,
    child: Text(level.name), // Will show: verbose, debug, info, etc.
  )).toList(),
  onChanged: (APZLogLevel? newLevel) {
    if (newLevel != null) {
      logger.setLogLevel(newLevel);
    }
  },
);

// Example: Set to only show errors and above
logger.setLogLevel(APZLogLevel.error);

// File logging operations
await logger.enableFileLogging();
await logger.disableFileLogging();
bool isEnabled = logger.isFileLoggingEnabled();
String? logPath = logger.getLogFilePath();
await logger.clearLogs();
```

#### Using with Provider and LogLevel

Since the logger implements `ChangeNotifier` and uses an enum for log levels, you can create reactive UI components:

```dart
// Example: Log Level Selection Widget
class LogLevelSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<APZLoggerProvider>(
      builder: (context, logger, child) {
        return Column(
          children: [
            // Dropdown for log level selection
            DropdownButton<APZLogLevel>(
              value: logger.getLogLevel(),
              items: logger.logLevel.map((level) => DropdownMenuItem(
                value: level,
                child: Text(level.name.toUpperCase()),
              )).toList(),
              onChanged: (level) {
                if (level != null) {
                  logger.setLogLevel(level);
                }
              },
            ),

            // Toggle for file logging
            SwitchListTile(
              title: const Text('File Logging'),
              value: logger.isFileLoggingEnabled(),
              onChanged: (enabled) async {
                if (enabled) {
                  await logger.enableFileLogging();
                } else {
                  await logger.disableFileLogging();
                }
              },
            ),

            // Button to clear logs
            ElevatedButton(
              onPressed: () => logger.clearLogs(),
              child: const Text('Clear Logs'),
            ),
          ],
        );
      },
    );
  }
}
```

The logger utility includes:

- Multiple log levels (debug, info, error)
- File logging support
- Persistent settings using SharedPreferences
- Pretty printing with method count, timestamps, and emojis
- Provider integration for reactive updates
- Singleton pattern for consistent logging across the app

### Validator

The validator utility provides a comprehensive set of string validation methods.

```dart
import 'package:apz_utils/apz_utils.dart';

// Basic validations
APZValidator.isEmpty(""); // true
APZValidator.isEmail("test@iexceed.com"); // true
APZValidator.isNumeric("123"); // true
APZValidator.isAlpha("abc"); // true
APZValidator.isAlphanumeric("abc123"); // true

// Advanced validations
APZValidator.isURL("https://iexceed.com"); // true
APZValidator.isCreditCard("4111111111111111"); // true
APZValidator.isIP("192.168.1.1"); // true
APZValidator.isIPv4("192.168.1.1"); // true
APZValidator.isIPv6("2001:0db8:85a3:0000:0000:8a2e:0370:7334"); // true

// Custom validations
APZValidator.isStrongPassword("Test@123"); // true (checks for strong password criteria)
APZValidator.isPhoneNumber("+1234567890"); // true
APZValidator.isNumberInRange("50", min: 0, max: 100); // true

// String manipulations
APZValidator.contains("Hello World", "World"); // true
APZValidator.equals("test", "test"); // true
APZValidator.isLength("test", min: 3, max: 5); // true

// Format validations
APZValidator.isJson('{"key": "value"}'); // true
APZValidator.isBase64("SGVsbG8gV29ybGQ="); // true
APZValidator.isMd5("d41d8cd98f00b204e9800998ecf8427e"); // true
APZValidator.isHexColor("#ff0000"); // true
```

Available Validation Methods:

- `isAlpha`: Checks if string contains only letters
- `isAlphanumeric`: Checks if string contains only letters and numbers
- `isAscii`: Checks if string contains only ASCII characters
- `isBase64`: Checks if string is base64 encoded
- `isCreditCard`: Validates credit card numbers
- `isDate`: Checks if string is a valid date
- `isEmail`: Validates email addresses
- `isFloat`: Checks if string is a decimal number
- `isFQDN`: Validates Fully Qualified Domain Names
- `isHexColor`: Validates hex color codes
- `isHexadecimal`: Checks if string is hexadecimal
- `isIP`: Validates IP addresses (v4 and v6)
- `isJson`: Checks if string is valid JSON
- `isLength`: Checks string length against min/max values
- `isMacAddress`: Validates MAC addresses
- `isMd5`: Checks if string is an MD5 hash
- `isNumeric`: Checks if string contains only numbers
- `isPhoneNumber`: Validates phone numbers
- `isStrongPassword`: Checks password strength
- `isURL`: Validates URLs
- `isWhitespace`: Checks if string is only whitespace
- `isEmpty`: Checks if string is null or empty
- `contains`: Checks if string contains a substring
- `equals`: Compares two strings
- `matchesPattern`: Matches string against a regex pattern

### Launchers

- Launch phone dialer with a specified phone number
- Send SMS messages with optional message content
- Open URLs in external browser
- Platform-specific handling (web vs native)
- URL sanitization and validation

#### Launch Phone Call

##### Add below code in AndroidManifest.xml for Android

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="tel" />
  </intent>
</queries>
```

##### Add below code in Info.plist inside Runner for iOS

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>tel</string>
</array>
```

##### Code Example

```dart
try {
  await Launchers().launchCall('1234567890');
} on UnsupportedPlatformException catch (e) {
  print('Platform not supported: ${e.message}');
} catch (e) {
  print('Error launching call: $e');
}
```

#### Send SMS

##### Add below code in AndroidManifest.xml for Android

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="sms" />
  </intent>
</queries>
```

##### Add below code in Info.plist inside Runner for iOS

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>sms</string>
</array>
```

##### Code Example

```dart
try {
  await Launchers().sendSMS('1234567890', message: 'Hello!');
} on UnsupportedPlatformException catch (e) {
  print('Platform not supported: ${e.message}');
} catch (e) {
  print('Error sending SMS: $e');
}
```

#### Open URL

##### Code Example

```dart
try {
  await Launchers().launchInExternalBrowser('https://example.com');
} catch (e) {
  print('Error launching URL: $e');
}
```

### Platform Support

| Platform | Phone Call | SMS | URL |
| -------- | ---------- | --- | --- |
| Android  | ✅         | ✅  | ✅  |
| iOS      | ✅         | ✅  | ✅  |
| Web      | ❌         | ❌  | ✅  |

## Error Handling

The class throws different types of exceptions:

- `UnsupportedPlatformException`: When a feature is not supported on the current platform
- `Exception`: For invalid inputs (empty phone numbers, malformed URLs)

## Jira Links
- https://appzillon.atlassian.net/browse/AN-95
- https://appzillon.atlassian.net/browse/AN-105


### ApzAppWipeOut

A Flutter plugin to wipe out all local app data across platforms — Android, iOS and Web. Useful for features like logout/reset, clearing app cache.

---

#### 🔧 Features

- 🚀 Clears app's internal data (cache, files, documents,SharedPreference)
- 🌐 Web support (clears CacheStorage,  localStorage, sessionStorage)
- 🧪 Simple API for integration and testing

#### usage

```dart

import "package:apz_utils/apz_utils.dart";

try{
  await ApzAppWipeOut().wipeAllData();
} on Exception catch(e){
  print(e);
}

```
### Platform Support

| Platform | ApzAppWipeOut|
| -------- | ----------| 
| Android  |     ✅   | 
| iOS      |     ✅   | 
| Web      |     ✅   | 

#### Jira Ticket Links

- [ApzAppWipeOut](https://appzillon.atlassian.net/browse/AN-148)
