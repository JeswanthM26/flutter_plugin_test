import 'package:apz_deeplink/apz_deeplink.dart';
import 'package:apz_notification/apz_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'package:apz_utils/apz_utils.dart'; 
import 'package:apz_app_switch/apz_app_switch.dart';
import 'package:apz_biometric/apz_biometric.dart';
import 'package:flutter_driver/driver_extension.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = APZLoggerProvider();
  await logger.initialize();

  final appSwitch = ApzAppSwitch();
  await appSwitch.initialize();
  appSwitch.lifecycleStream.listen((state) {
    if (state == AppLifecycleState.resumed) {
      ApzNotification.instance.showLocalNotification(
        title: 'App Resumed',
        body: 'The app has been resumed.',
      );
    }
  });

  final deeplink = ApzDeeplink();
  await deeplink.initialize();
  deeplink.linkStream.listen((data) {
    ApzNotification.instance.showLocalNotification(
      title: 'Deep Link Received',
      body: data.toString(),
    );
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: logger),
      ],
      child: const PluginTesterApp(),
    ),
  );
}

class PluginTesterApp extends StatelessWidget {
  const PluginTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plugin Tester',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: const Color(0xFF3F51B5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}







// 