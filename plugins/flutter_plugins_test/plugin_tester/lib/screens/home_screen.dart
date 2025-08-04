import 'dart:convert';
import 'package:apz_utils/apz_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plugin_metadata.dart';
import '../widgets/dynamic_form.dart';
import '../services/plugin_launcher.dart';
import 'result_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PluginMetadata> plugins = [];
  PluginMetadata? selectedPlugin;
  Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    loadPluginMetadata();
  }

  Future<void> loadPluginMetadata() async {
    final jsonString = await rootBundle.loadString('assets/plugin_metadata.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      plugins = parsePluginMetadata(jsonMap);
    });
  }

  void onGenerate() async {
    if (selectedPlugin == null) return;
    final logger = Provider.of<APZLoggerProvider>(context, listen: false);

    final result = await PluginLauncher.launch(selectedPlugin!, formData, context,logger);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          plugin: selectedPlugin!,
          result: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin Tester')),
      body: plugins.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<PluginMetadata>(
                    isExpanded: true,
                    value: selectedPlugin,
                    hint: const Text('Select Plugin'),
                    items: plugins
                        .map((plugin) => DropdownMenuItem(
                              value: plugin,
                              child: Text(plugin.name),
                            ))
                        .toList(),
                    onChanged: (plugin) {
                      setState(() {
                        selectedPlugin = plugin;
                        formData = {};
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedPlugin != null && selectedPlugin!.fields.isNotEmpty)
                    Expanded(
                      child: DynamicForm(
                        fields: selectedPlugin!.fields,
                        formData: formData,
                        onChanged: (data) => formData = data,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedPlugin == null ? null : onGenerate,
                    child: const Text('Generate'),
                  ),
                ],
              ),
            ),
    );
  }
}