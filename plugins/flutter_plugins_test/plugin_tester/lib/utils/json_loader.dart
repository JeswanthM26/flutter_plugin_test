import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plugin_metadata.dart';

class JsonLoader {
  static Future<List<PluginMetadata>> loadPluginMetadata() async {
    final jsonString = await rootBundle.loadString('assets/plugin_metadata.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return parsePluginMetadata(jsonMap);
  }
} 