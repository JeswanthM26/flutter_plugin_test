<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Appzillon Theme

A Flutter package that provides a flexible and customizable theming system for Appzillon applications. This package handles light and dark themes, text scaling, and persistent theme settings.

## Features

- **Default theme** - Ready-to-use light and dark themes with predefined colors and styles
- **Customizable themes** - Create custom themes by setting specific colors, font families, and text scaling
- **Theme persistence** - Automatically saves and restores theme preferences
- **Easy integration** - Simple API for theme management in your Flutter app

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  apz_theme: ^1.0.0
```

## Usage

### Basic Usage

Using the default theme is straightforward:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apz_theme/apz_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'My App',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: MyHomePage(),
    );
  }
}
```

## Default Colors and Theme Overrides

### Default Color Palette

The package comes with a carefully selected default color palette that follows Material Design principles:

#### Light Theme
```dart

  // Default colors - Light theme
  static const Color defaultPrimaryColorLight = Colors.orange;
  static const Color defaultSecondaryColorLight = Colors.orange;
  static const Color defaultTertiaryColorLight = Colors.orangeAccent;
  static const Color defaultNeutralColorLight = Color(0xFF121212); // smoke-black
  static const Color defaultErrorColorLight = Color(0xFFB00020); // dark-red
  static const Color defaultBackgroundColorLight = Color(0xFFF5F5F5); // smoke-white
  static const Color defaultSurfaceColorLight = Colors.white;

```

#### Dark Theme
```dart
  
  // Default colors - Dark theme
  static const Color defaultPrimaryColorDark = Colors.orange;
  static const Color defaultSecondaryColorDark = Colors.orange;
  static const Color defaultTertiaryColorDark = Colors.orangeAccent;
  static const Color defaultNeutralColorDark = Color(0xFF121212); // smoke-black
  static const Color defaultErrorColorDark = Color(0xFFCF6679); // maroon-red
  static const Color defaultBackgroundColorDark = Color(0xFFFFFFFF); // white
  static const Color defaultSurfaceColorDark = Colors.black;

```

#### Font Families
```dart

  // Default Text Scale Factor
  static const double defaultTextScaleFactor = 1.0;
  
  // Default font families
  static const String defaultHeadingFontFamily = 'Montserrat';
  static const String defaultBodyFontFamily = 'Roboto';
  static const String defaultDisplayFontFamily = 'Poppins';
```

### Overriding Colors

You can override colors for both light and dark themes in several ways:

#### 1. Using AppTheme Constructor

```dart
final customTheme = AppTheme(
  // Light theme colors
  primaryColorLight: Color(0xFF6200EE),
  secondaryColorLight: Color(0xFF03DAC6),
  tertiaryColorLight: Color(0xFF03DAC6),
  backgroundColorLight: Colors.white,
  neutralColorLight: Colors.white,
  surfaceColorLight: Colors.white,
  errorColorLight: Color(0xFFB00020),
  
  // Dark theme colors
  primaryColorDark: Color(0xFFBB86FC),
  secondaryColorDark: Color(0xFF03DAC6),
  tertiaryColorLight: Color(0xFF03DAC6),
  backgroundColorDark: Color(0xFF121212),
  neutralColorDark: Color(0xFF121212),
  surfaceColorDark: Color(0xFF121212),
  errorColorDark: Color(0xFFCF6679),
);

// Use the custom theme
final themeProvider = ThemeProvider(theme: customTheme);
```

#### 2. Using ColorScheme

For more granular control, you can create custom color schemes:

```dart
final lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6200EE),
  onPrimary: Colors.white,
  secondary: Color(0xFF03DAC6),
  onSecondary: Colors.black,
  error: Color(0xFFB00020),
  onError: Colors.white,
  background: Colors.white,
  onBackground: Colors.black,
  surface: Colors.white,
  onSurface: Colors.black,
);

final darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFBB86FC),
  onPrimary: Colors.black,
  secondary: Color(0xFF03DAC6),
  onSecondary: Colors.black,
  error: Color(0xFFCF6679),
  onError: Colors.black,
  background: Color(0xFF121212),
  onBackground: Colors.white,
  surface: Color(0xFF121212),
  onSurface: Colors.white,
);

// Apply the color schemes
final customTheme = AppTheme.fromColorSchemes(
  lightColorScheme: lightColorScheme,
  darkColorScheme: darkColorScheme,
);

// Use the custom theme
final themeProvider = ThemeProvider(theme: customTheme);
```

#### 3. Generate Theme from Brand Color

Generate a complete theme from a single brand color:

```dart
// Create a theme based on a brand color
final brandColor = Color(0xFF1976D2); // Blue
final generatedTheme = ThemeUtils.createThemeFromBrandColor(brandColor);

// Use the generated theme with the provider
final themeProvider = ThemeProvider(theme: generatedTheme);
```

### Toggle Theme Mode

Toggle between light and dark themes:

```dart
// In your widget
ElevatedButton(
  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
  child: Text('Toggle Theme'),
)
```

### Text Scaling

Adjust text scaling for accessibility:

```dart
// Set text scale factor
Slider(
  min: 0.8,
  max: 1.5,
  value: context.watch<ThemeProvider>().textScaleFactor,
  onChanged: (value) {
    context.read<ThemeProvider>().setTextScaleFactor(value);
  },
)
```

### Initialize with Device Text Scale

Initialize with the device's text scale factor:

```dart
// In your app initialization
final mediaQueryData = MediaQuery.of(context);
final deviceTextScale = mediaQueryData.textScaleFactor;
themeProvider.initWithDeviceTextScale(deviceTextScale);
```

## Customization Options

The `AppTheme` class supports the following customization options:

- **Colors** - Primary, secondary, tertiary, neutral, error, background, and surface colors for both light and dark themes
- **Font Families** - Heading, body, and display font families
- **Text Scale Factor** - Scale factor for all text in the app

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
