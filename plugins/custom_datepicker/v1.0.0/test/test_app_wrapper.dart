import 'package:flutter/material.dart';

class TestAppWrapper extends StatelessWidget {
  final Widget child;
  const TestAppWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
}
