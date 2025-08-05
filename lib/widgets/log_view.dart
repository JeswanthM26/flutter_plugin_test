import 'package:flutter/material.dart';

class LogView extends StatelessWidget {
  final List<String> logs;

  const LogView({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Logs:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...logs.map((log) => Text(log, style: const TextStyle(color: Colors.white, fontSize: 12))),
        ],
      ),
    );
  }
}
