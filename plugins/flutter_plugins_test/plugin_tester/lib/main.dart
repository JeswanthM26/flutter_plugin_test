// import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';
// import 'package:apz_utils/apz_utils.dart'; 
// Future<void> main() async {
//   runApp(const PluginTesterApp());
  
//   final logger = APZLoggerProvider();
//   await logger.initialize(); 
//    runApp(
//      MultiProvider(
//       providers: [
//         ChangeNotifierProvider.value(value: logger),
//       ],
//       child: MyApp(),
//     ),
//   );
// }


// class PluginTesterApp extends StatelessWidget {
//   const PluginTesterApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Plugin Tester',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'package:apz_utils/apz_utils.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Always required before async init

  final logger = APZLoggerProvider();
  await logger.initialize(); // Must await logger init before runApp

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: logger),
      ],
      child: const PluginTesterApp(), // Inject logger here
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
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
